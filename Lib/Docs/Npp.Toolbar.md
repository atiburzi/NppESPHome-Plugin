# `Npp.Toolbar`

The `Npp.Toolbar` unit provides a VCL-independent toolbar model and manager.
It uses stable command IDs from `TNppCommands`, owns native icon resources,
serializes layout configuration, and rebuilds the Notepad++ toolbar.

The application remains responsible for persistence and for any configuration
dialog. The toolbar accepts and produces strings but never reads an INI file,
registry key, or other storage.

## Public model types

### `TNppToolbarLayoutItem`

```pascal
TNppToolbarLayoutItem = record
  ItemId: string;
  Visible: Boolean;
end;
```

`ItemId` is the stable command ID; `Visible` controls whether the item is
inserted into the native toolbar.

### `TNppToolbarButton`

Stores runtime state for a button:

| Field | Meaning |
| --- | --- |
| `CommandId` | Numeric ID assigned by Notepad++ |
| `ItemId` | Stable `TNppCommands` ID |
| `Sequence` | Current layout position |
| `Visible` | Current configured visibility |
| `Enabled` | State mirrored from `TNppCommands` |
| `NativeButton` | Captured Win32 `TTBButton` template |
| `IconData` | Owned light/dark icon and bitmap handles |

`PNppToolbarButton` is a pointer to this record and
`TNppToolbarButtons` is its dynamic-array type.

## `TNppToolbarLayout`

This caller-owned class edits an ordered list independently from the native
toolbar and any UI.

### Properties

| Property | Meaning |
| --- | --- |
| `Count` | Number of layout items |
| `Items[Index]` / default indexer | Copy of one item; invalid indexes raise `EArgumentOutOfRangeException` |

### Methods

| Method | Behavior |
| --- | --- |
| `Add(ItemId, Visible)` | Appends one unique ID; visible by default |
| `IndexOf(ItemId)` | Case-insensitive lookup, returning `-1` when absent |
| `Move(FromIndex, ToIndex)` | Moves one item and preserves all other relative order |
| `SetVisible(Index, Visible)` | Changes visibility; invalid indexes raise |
| `Serialize` | Produces the canonical configuration string |
| `CreateDefault(AvailableIds)` | Creates a layout containing every ID as visible |
| `TryParse(Value, out Layout)` | Validates and creates a caller-owned layout |

IDs must be non-empty, unique case-insensitively, and must not contain `:`,
`;`, or `|`. Invalid or duplicate IDs raise `EArgumentException`.

```pascal
Layout := TNppToolbarLayout.Create;
try
  Layout.Add('build');
  Layout.Add('upload', False);
  Layout.Move(1, 0);
  Layout.SetVisible(0, True);
  ConfigText := Layout.Serialize;
finally
  Layout.Free;
end;
```

### Configuration grammar

The only supported format is a sequence of stable IDs and visibility flags:

```text
build:1;upload:0;logs:1;
```

- `1` means visible and `0` means hidden.
- Order defines toolbar order.
- The trailing semicolon is mandatory.
- Empty configuration is valid and represents an empty layout.
- Duplicate IDs, unknown flags, malformed fields, or missing trailing
  semicolons are invalid.
- There is no version prefix and no legacy-format compatibility.

`TryParse` returns `False` and sets `Layout := nil` on failure.

```pascal
if TNppToolbarLayout.TryParse(SavedText, Layout) then
try
  EditLayout(Layout);
finally
  Layout.Free;
end;
```

## Provider callbacks

### `TNppToolbarIconProvider`

```pascal
TNppToolbarIconProvider = function(const Entry: TNppMenuEntry;
  out IconData: TToolbarIconsWithDarkMode): Boolean of object;
```

Called once for each non-separator command during `Initialize`. Return
`True` and fill `IconData` to expose a toolbar button; return `False` to
omit the command.

On success, ownership of every nonzero `HBITMAP`/`HICON` in `IconData`
transfers to `TNppToolbar`. On failure or exception, the manager also releases
any handles already written to `IconData`.

### `TNppToolbarDisabledIconProvider`

```pascal
TNppToolbarDisabledIconProvider = function(SourceIcon: HICON;
  Width, Height: Integer): HICON of object;
```

Optionally creates a disabled icon matching the native toolbar size.
`SourceIcon` is borrowed and must not be destroyed. Ownership of the returned
icon transfers temporarily to the manager, which copies it into the native
disabled image list and destroys it.

```pascal
function TMyPlugin.CreateToolbarIcons(const Entry: TNppMenuEntry;
  out IconData: TToolbarIconsWithDarkMode): Boolean;
begin
  FillChar(IconData, SizeOf(IconData), 0);
  Result := Entry.Id = 'build';
  if Result then
  begin
    IconData.ToolbarIcon := CopyIcon(BuildLightIcon);
    IconData.ToolbarIconDarkMode := CopyIcon(BuildDarkIcon);
  end;
end;
```

## `TNppToolbar` construction

```pascal
constructor Create(AHost: TNppHost; ACommands: TNppCommands;
  const IconProvider: TNppToolbarIconProvider;
  const DisabledIconProvider: TNppToolbarDisabledIconProvider = nil);
```

Host, command registry, and icon provider are required; a missing value raises
`EArgumentNilException`. The toolbar retains but does not own the host,
commands, or callback targets. They must outlive it.

Normal plugins use the protected helper:

```pascal
ConfigureToolbar(CreateToolbarIcons, CreateDisabledIcon);
```

The constructor registers an enabled-state listener with `TNppCommands`; the
destructor removes it and releases icon resources.

## Properties

| Property | Purpose |
| --- | --- |
| `ButtonCount` | Number of commands accepted by the icon provider |
| `Button[Index]` | Compatibility pointer to internal storage, or `nil` |
| `Host` | Associated, non-owned `TNppHost` |
| `Commands` | Associated, non-owned `TNppCommands` |

Prefer `GetButtonInfo` to `Button[Index]`. The pointer becomes invalid when
`Initialize` resizes the internal array and must never be freed.

## Configuration methods

### `IsConfigurationValid`

Static syntax check implemented through `TNppToolbarLayout.TryParse`.

```pascal
if not TNppToolbar.IsConfigurationValid(SavedText) then
  SavedText := Toolbar.DefaultConfiguration;
```

It validates grammar only; availability of IDs is reconciled after toolbar
initialization.

### `Configuration`

Returns the canonical current string. Before initialization it returns the
validated string stored by `ApplyConfiguration`; afterward it returns the
layout normalized against available buttons.

### `DefaultConfiguration`

Returns all currently available toolbar buttons in provider/command order with
visibility enabled.

### `CreateLayout(Default)`

Returns a new caller-owned layout. `Default=False` creates the current layout;
`Default=True` creates the all-visible default.

Before initialization, a valid stored configuration is returned without
dropping unknown IDs because the provider has not yet declared availability.
After initialization, unavailable IDs are removed and newly available IDs are
appended as visible.

### `ApplyConfiguration`

Validates and stores a string. Invalid input raises `EArgumentException`.
Before initialization it only preserves the canonical string. After
initialization it normalizes the layout and calls `Refresh`.

The application performs persistence:

```pascal
if TNppToolbar.IsConfigurationValid(Ini.ReadString('UI', 'Toolbar', '')) then
  Toolbar.ApplyConfiguration(Ini.ReadString('UI', 'Toolbar', ''));

Ini.WriteString('UI', 'Toolbar', Toolbar.Configuration);
```

### `ApplyLayout`

Serializes and applies a non-`nil` layout. Passing `nil` raises
`EArgumentNilException`. The method does not take ownership.

```pascal
Layout := Toolbar.CreateLayout;
try
  Layout.Move(2, 0);
  Toolbar.ApplyLayout(Layout);
finally
  Layout.Free;
end;
```

## Native lifecycle methods

### `Initialize`

Releases old icon handles, calls the icon provider for every real command,
builds the button model, and registers light/dark icons through
`NPPM_ADDTOOLBARICON_FORDARKMODE`.

`TNppPlugin.DoNppnToolbarModification` calls it automatically. On hosts older
than Notepad++ 8 it produces an empty configuration. If initialization fails,
partial icon resources are released and the exception is propagated.

### `CaptureNativeButtons`

Finds each button by command ID and captures the native `TTBButton` template
created by Notepad++. It is called after Notepad++ has created the native
toolbar buttons.

### `Refresh`

Reconciles the current layout, removes stale or duplicate native copies,
reinserts visible buttons in configured order, applies enabled state, rebuilds
optional disabled images, sizes, redraws, and shows the toolbar.

It is a no-op when the host version or native toolbar handle is unavailable.

### `ReleaseResources`

Destroys owned bitmaps and light/dark icons, clears the button model, and marks
the toolbar uninitialized. It is safe to call repeatedly. It preserves the
configuration string so a later `Initialize` can rebuild the toolbar with the
same layout. It does not destroy the host, commands, native toolbar, or provider
targets.

The normal sequence is managed by `TNppPlugin`:

1. construct plugin and configure toolbar;
2. optionally apply persisted configuration;
3. `NPPN_TBMODIFICATION` calls `Initialize`;
4. `NPPN_READY` calls `CaptureNativeButtons` and `Refresh`;
5. icon-set or dark-mode changes trigger reinitialization/refresh;
6. plugin destruction releases toolbar resources.

## State and inspection methods

### `SetEnabled`

Updates the model and native `TBSTATE_ENABLED` flag for a stable ID. Unknown
or unavailable toolbar IDs are ignored.

Application code should normally call `Commands.SetEnabled`; the toolbar is
already subscribed and mirrors the change automatically.

### `CaptionForItem`

Returns the current command caption for a stable toolbar ID, or an empty string
when the command is unknown. Configuration dialogs can use it as display text
while retaining `ItemId` as identity.

### `GetButtonInfo`

```pascal
function GetButtonInfo(Index: Integer;
  out Button: TNppToolbarButton): Boolean; overload;
function GetButtonInfo(const ItemId: string;
  out Button: TNppToolbarButton): Boolean; overload;
```

Copies one button record by model index or stable ID and returns `True`. Stable
ID lookup is case-insensitive. For an invalid index or unknown ID it returns
`False` and zeros the output record.

The copied native handles remain owned by `TNppToolbar`; never destroy them.

```pascal
for Index := 0 to Toolbar.ButtonCount - 1 do
  if Toolbar.GetButtonInfo(Index, Info) then
    AddEditorRow(Info.ItemId, Toolbar.CaptionForItem(Info.ItemId),
      Info.Visible);

if Toolbar.GetButtonInfo('run', Info) then
  ShowStatus(Info.Enabled);
```

## Practical rules

- Use stable command IDs in layouts and configuration UIs.
- Register all commands before initializing the toolbar.
- Let the icon provider decide which commands have toolbar buttons.
- Transfer newly owned icon handles from the provider; never return borrowed
  handles as owned values.
- Apply configuration before initialization when loading persisted state.
- Persist only `Toolbar.Configuration`; storage belongs to the application.
- Use `Commands.SetEnabled` as the authoritative enabled-state API.
- Prefer `GetButtonInfo` over the compatibility pointer property.
- Recreate application-owned configuration dialogs independently from this
  VCL-free framework component.
