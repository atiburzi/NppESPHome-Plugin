# `TNppCommands`

`TNppCommands` is the command registry for a Notepad++ plugin. It is declared
in the `Npp.Commands` unit and owns both the plugin-facing command metadata and
the contiguous `TFuncItem` array required by the Notepad++ plugin ABI.

The registry provides stable, application-defined string identifiers. These
identifiers keep application code independent from two volatile numeric values:

- the item index, which depends on registration order;
- the `CmdID`, which Notepad++ assigns after receiving the exported array.

The class also manages separators, initial shortcuts, captions, checked and
enabled states, and enabled-state notifications used by `TNppToolbar`.

## Required units

```pascal
uses
  Winapi.Windows,
  Npp.Api,
  Npp.Host,
  Npp.Commands;
```

## Position in the framework

`TNppPlugin` creates and owns one `TNppCommands` instance. A plugin normally
registers its commands through the inherited `Commands` property:

```pascal
constructor TMyPlugin.Create;
begin
  inherited;
  PluginName := 'My Plugin';
  Commands.AddCommand('build', 'Build project', BuildCommand);
end;
```

Do not free `Commands` when it belongs to a `TNppPlugin`. Direct construction
is intended for standalone infrastructure and tests. A directly constructed
registry owns neither the supplied `TNppHost` nor the callback targets.

```text
plugin command declarations
          |
          v
     TNppCommands
       /       \
      v         v
TFuncItem[]   stable metadata
      |         |
      v         v
 Notepad++    toolbar / app
```

## The three command identities

Every real command can be observed through three different identifiers.

| Identity | Example | Assigned by | Stability |
| --- | --- | --- | --- |
| Stable ID | `build` | Plugin application | Stable across menu reordering |
| Index | `4` | `TNppCommands` | Depends on registration order |
| Command ID | `22017` | Notepad++ | Available after host registration |

Application code should normally use the stable ID. The index is useful when
an API explicitly refers to the exported function-item order. The command ID
is required only when calling a native Notepad++ or Win32 menu API.

Stable IDs are case-insensitive: `build`, `Build`, and `BUILD` identify the
same entry.

## Related public types

### `TNppMenuEntry`

```pascal
TNppMenuEntry = record
  Id: string;
  Index: Integer;
  IsSeparator: Boolean;
  Checked: Boolean;
  Enabled: Boolean;
end;
```

The record exposes the application metadata stored for one registered item.

| Field | Meaning |
| --- | --- |
| `Id` | Stable, plugin-defined identifier |
| `Index` | Position in the exported `TFuncItem` array |
| `IsSeparator` | `True` for a menu separator |
| `Checked` | Last checked state stored by the registry |
| `Enabled` | Last enabled state stored by the registry |

`Entries[Index]` returns this record by value. Modifying the returned copy does
not modify the registry; use `SetChecked` and `SetEnabled` instead.

### `TNppCommandEnabledChanged`

```pascal
TNppCommandEnabledChanged = procedure(const Id: string;
  Enabled: Boolean) of object;
```

This method callback is raised after the enabled state of a real command
changes. `Id` is the stable identifier and `Enabled` is the new state.

```pascal
procedure TCommandObserver.CommandEnabledChanged(const Id: string;
  Enabled: Boolean);
begin
  Log(Format('%s enabled: %s', [Id, BoolToStr(Enabled, True)]));
end;
```

## Construction and lifetime

### `Create`

```pascal
constructor Create(AHost: TNppHost);
```

Creates an empty registry connected to `AHost`. `AHost` is required; passing
`nil` raises `EArgumentNilException`.

```pascal
Commands := TNppCommands.Create(Host);
try
  // Register and use commands.
finally
  Commands.Free;
end;
```

The registry keeps a reference to the host but does not own it. The host must
remain alive until the registry has been destroyed.

### `Destroy`

```pascal
destructor Destroy; override;
```

Releases every shortcut pointer owned by the registered `TFuncItem` records and
then releases the internal arrays. It does not free the host or callback-bound
objects.

## Registration

Commands and separators must be added in the exact order in which they should
appear under the Notepad++ **Plugins** menu. Registration is normally completed
inside the plugin constructor, before Notepad++ calls `getFuncsArray`.

Do not add more entries after the command array has been published to
Notepad++. Growing the internal dynamic array can change its address and would
invalidate the pointer retained by the host.

### `AddCommand`

```pascal
function AddCommand(const Id: string; const Caption: nppString;
  Callback: FuncItemCmdProc; ShortcutKey: PShortcutKey = nil;
  Checked: Boolean = False): Integer;
```

Registers one callable plugin command and returns its zero-based item index.

| Parameter | Meaning |
| --- | --- |
| `Id` | Stable application identifier |
| `Caption` | Initial text displayed in the Plugins menu |
| `Callback` | Parameterless `cdecl` procedure called by Notepad++ |
| `ShortcutKey` | Optional initial shortcut; ownership is transferred |
| `Checked` | Initial checked state |

The stable ID must:

- not be empty;
- be unique without regard to case;
- not contain `:`, `;`, or `|` because these characters are reserved by the
  toolbar configuration grammar.

`Callback` must be assigned. Invalid input raises `EArgumentException`.

```pascal
procedure BuildCommand; cdecl;
begin
  TMyPlugin(Plugin).BuildCurrentProject;
end;

constructor TMyPlugin.Create;
begin
  inherited;
  Commands.AddCommand('build', 'Build project', BuildCommand);
end;
```

The callback type is defined by the Notepad++ ABI:

```pascal
FuncItemCmdProc = procedure; cdecl;
```

It cannot receive parameters or be an `of object` method. A plugin therefore
usually registers a small global wrapper that forwards the call to its current
plugin instance.

#### Registering an initial shortcut

`PShortcutKey` points to heap memory that becomes owned by `TNppCommands` after
successful registration. Do not dispose it or reuse the same pointer for a
second command.

```pascal
function NewShortcut(Ctrl, Alt, Shift: Boolean; Key: UCHAR): PShortcutKey;
begin
  New(Result);
  Result^.IsCtrl := Ctrl;
  Result^.IsAlt := Alt;
  Result^.IsShift := Shift;
  Result^.Key := Key;
end;

Commands.AddCommand('build', 'Build project', BuildCommand,
  NewShortcut(True, False, False, Ord('B')));
```

Notepad++ owns the user's current shortcut configuration. The pointer supplied
here defines only the initial/default shortcut exposed through `TFuncItem`.

### `AddSeparator`

```pascal
function AddSeparator(const Id: string = ''): Integer;
```

Adds a placeholder item at the current position and returns its zero-based
index. The placeholder is later converted into a native menu separator by
`ApplySeparators`.

```pascal
Commands.AddCommand('open', 'Open project', OpenCommand);
Commands.AddSeparator('sep.project.actions');
Commands.AddCommand('close', 'Close project', CloseCommand);
```

When `Id` is empty, the registry generates `Sep$N`, where `N` is the current
entry count. Explicit separator IDs are preferable when another component,
such as a toolbar editor, needs to identify the separator reliably.

Separator IDs follow the same uniqueness and reserved-character rules as
command IDs. A separator has no callback, is never checked, and is stored as
disabled.

## Collection properties

### `Count`

```pascal
property Count: Integer read GetCount;
```

Returns the total number of registered commands and separators.

```pascal
for Index := 0 to Commands.Count - 1 do
  ProcessEntry(Commands.Entries[Index]);
```

### `Entries`

```pascal
property Entries[Index: Integer]: TNppMenuEntry read GetEntry;
```

Returns a copy of the entry at `Index`. An invalid index raises
`EArgumentOutOfRangeException`.

```pascal
Entry := Commands.Entries[0];
if not Entry.IsSeparator then
  ShowMessage(Entry.Id);
```

### `OnEnabledChanged`

```pascal
property OnEnabledChanged: TNppCommandEnabledChanged
  read FOnEnabledChanged write FOnEnabledChanged;
```

Defines one application callback notified by `SetEnabled`. It is independent
from the multi-listener list managed by `AddEnabledListener`.

```pascal
Commands.OnEnabledChanged := Observer.CommandEnabledChanged;
try
  Commands.SetEnabled('build', False);
finally
  Commands.OnEnabledChanged := nil;
end;
```

The registry does not own the callback target. Clear the property before that
object is destroyed.

## Lookup methods

### `IndexOf`

```pascal
function IndexOf(const Id: string): Integer;
```

Returns the zero-based index of a stable ID, using a case-insensitive
comparison. Returns `-1` when `Id` is empty or unknown.

```pascal
Index := Commands.IndexOf('BUILD');
```

### `IdFromIndex`

```pascal
function IdFromIndex(Index: Integer): string;
```

Returns the stable ID stored at `Index`. Returns an empty string when the index
is outside the collection.

```pascal
Id := Commands.IdFromIndex(2);
```

### `CommandId`

```pascal
function CommandId(const Id: string): Integer;
```

Returns the numeric `CmdID` stored by Notepad++ in the command's `TFuncItem`.
Returns `-1` for an unknown ID.

```pascal
NativeId := Commands.CommandId('build');
if NativeId >= 0 then
  UseNativeCommandId(NativeId);
```

Notepad++ assigns command IDs only after it receives the array exported by
`getFuncsArray`. A known command can therefore still contain its initial zero
value during early plugin construction. Use this method only after host command
registration when a valid native ID is required.

### `FunctionItem`

```pascal
function FunctionItem(const Id: string): PFuncItem;
```

Returns a pointer to the ABI `TFuncItem` associated with a stable ID, or `nil`
when no entry exists. Separators also have a function item.

```pascal
Item := Commands.FunctionItem('build');
if Assigned(Item) then
  NativeId := Item^.CmdID;
```

The returned pointer refers to internal dynamic-array storage. Do not free it,
and do not retain it while adding more commands or separators because an array
resize can invalidate the pointer.

### `Caption`

```pascal
function Caption(const Id: string): string;
```

Returns the caption currently stored in the associated `TFuncItem`. Returns an
empty string for an unknown ID.

```pascal
CurrentCaption := Commands.Caption('build');
```

The ABI buffer has `FNITEM_NAMELEN` elements, currently 64 wide characters
including the terminator. Longer captions are truncated when copied into the
record.

### `IsChecked`

```pascal
function IsChecked(const Id: string): Boolean;
```

Returns the checked state stored by the registry. Unknown IDs and separators
produce `False`.

### `IsEnabled`

```pascal
function IsEnabled(const Id: string): Boolean;
```

Returns the enabled state stored by the registry. New commands start enabled;
unknown IDs and separators produce `False`.

```pascal
if Commands.IsEnabled('build') and Commands.IsChecked('watch') then
  RefreshBuildWatcher;
```

## ABI publication and separators

### `GetFuncsArray`

```pascal
function GetFuncsArray(out Count: Integer): PFuncItem;
```

Returns the contiguous command array required by the Notepad++ `getFuncsArray`
export and writes the number of entries to `Count`. If the registry is empty,
it returns `nil` and writes zero.

```pascal
Items := Commands.GetFuncsArray(ItemCount);
```

The returned memory is owned by `TNppCommands`. The caller must neither modify
the array length nor free the pointer. Register every item before publishing
this pointer and keep the registry alive while Notepad++ uses it.

`TNppPlugin.GetFuncsArray` delegates to this method, and
`NppPluginInclude.pas` exposes that result through the DLL entry point. Normal
plugin code does not need to call it directly.

### `ApplySeparators`

```pascal
procedure ApplySeparators;
```

Converts every entry registered through `AddSeparator` into a native Win32
menu separator while preserving its array position. Separator identity comes
from registry metadata, so a regular command caption may safely start with `-`.

The method does nothing if `Host.Data.NppHandle` or the native menu handle is
zero. `TNppPlugin.MessageProc` calls it automatically when processing
`WM_CREATE`, so normal plugin implementations should not call it themselves.

```pascal
// Needed only in a custom lifecycle that does not use TNppPlugin.MessageProc.
Commands.ApplySeparators;
```

## Updating command state

### `SetCaption`

```pascal
procedure SetCaption(const Id: string; const Caption: nppString;
  PreserveShortcut: Boolean = True);
```

Updates the caption in the ABI record and, when the native Plugins menu is
available, updates the visible menu item.

When `PreserveShortcut` is `True`, the method asks Notepad++ for the command's
current shortcut and appends its formatted text after a tab. This is necessary
because the Win32 `ModifyMenu` call replaces the entire visible label.

```pascal
Commands.SetCaption('build', 'Build current project');
Commands.SetCaption('build', 'Build', False); // do not append shortcut text
```

The method raises `EArgumentException` for an unknown ID or separator. If the
native menu is not ready, the ABI caption is still updated. Captions longer
than the fixed `TFuncItem.ItemName` buffer are truncated.

### `SetChecked`

```pascal
procedure SetChecked(const Id: string; Checked: Boolean;
  Delayed: Boolean = True);
```

Updates both the registry and `TFuncItem.Checked`, then requests the equivalent
native Notepad++ menu state through `NPPM_SETMENUITEMCHECK`.

```pascal
Commands.SetChecked('watch', True);           // asynchronous host update
Commands.SetChecked('watch', False, False);   // synchronous host update
```

`Delayed=True` uses `PostNpp`; `Delayed=False` uses `SendNpp`. No host message
is sent when the requested state already matches the stored state. An unknown
ID or separator raises `EArgumentException`.

### `SetEnabled`

```pascal
procedure SetEnabled(const Id: string; Enabled: Boolean);
```

Updates the stored availability, enables or grays the native Plugins menu item
when available, redraws the menu bar, and then notifies enabled-state observers.

```pascal
Commands.SetEnabled('build', ProjectAssigned);
```

Notification order is:

1. the native and stored command state is updated;
2. `OnEnabledChanged` is called, when assigned;
3. listeners registered with `AddEnabledListener` are called in registration
   order.

Nothing happens when the state has not changed. An unknown ID or separator
raises `EArgumentException`.

`TNppToolbar` registers itself as a listener. Consequently,
`Commands.SetEnabled` must be the source of truth for application command
availability; do not update only the toolbar button.

## Enabled-state listeners

### `AddEnabledListener`

```pascal
procedure AddEnabledListener(const Listener: TNppCommandEnabledChanged);
```

Adds a listener unless the same method and object instance are already
registered. Passing `nil` has no effect.

```pascal
Commands.AddEnabledListener(Observer.CommandEnabledChanged);
```

The registry does not own listener targets. A target must unregister before it
is destroyed.

### `RemoveEnabledListener`

```pascal
procedure RemoveEnabledListener(const Listener: TNppCommandEnabledChanged);
```

Removes the matching method callback. Calling it for an unregistered listener
has no effect.

```pascal
Commands.RemoveEnabledListener(Observer.CommandEnabledChanged);
```

## Complete registration example

```pascal
const
  cmdBuild = 'build';
  cmdWatch = 'watch';

procedure BuildCommand; cdecl;
begin
  TMyPlugin(Plugin).BuildCurrentProject;
end;

procedure WatchCommand; cdecl;
begin
  TMyPlugin(Plugin).ToggleWatcher;
end;

constructor TMyPlugin.Create;
begin
  inherited;
  PluginName := 'My Plugin';

  Commands.AddCommand(cmdBuild, 'Build project', BuildCommand,
    NewShortcut(True, False, False, Ord('B')));
  Commands.AddSeparator('sep.build.watch');
  Commands.AddCommand(cmdWatch, 'Watch project', WatchCommand, nil, False);
end;

procedure TMyPlugin.RefreshCommandState;
begin
  Commands.SetEnabled(cmdBuild, ProjectAssigned);
  Commands.SetEnabled(cmdWatch, ProjectAssigned);
  Commands.SetChecked(cmdWatch, WatcherRunning);
end;
```

In real plugin code, ensure the global callback wrappers cannot run before the
plugin singleton has been published or after it has been cleared.

## Error behavior

| Operation | Invalid input | Result |
| --- | --- | --- |
| `Create(nil)` | Missing host | `EArgumentNilException` |
| `AddCommand` | Empty, duplicate, or reserved ID | `EArgumentException` |
| `AddCommand` | `nil` callback | `EArgumentException` |
| `AddSeparator` | Duplicate or reserved ID | `EArgumentException` |
| `Entries[Index]` | Index outside collection | `EArgumentOutOfRangeException` |
| `SetCaption` | Unknown ID or separator | `EArgumentException` |
| `SetChecked` | Unknown ID or separator | `EArgumentException` |
| `SetEnabled` | Unknown ID or separator | `EArgumentException` |
| Lookup methods | Unknown ID | Sentinel value: `-1`, `nil`, `''`, or `False` |

## Practical rules

- Register commands in display order during plugin construction.
- Use stable IDs everywhere in application code.
- Treat stable IDs as case-insensitive.
- Never use `:`, `;`, or `|` in a stable ID.
- Do not add entries after the ABI array has been exported.
- Treat `PFuncItem` and the array returned by `GetFuncsArray` as borrowed
  pointers.
- Transfer a distinct heap-allocated `PShortcutKey` to each command.
- Use `SetEnabled` as the authoritative path for both menu and toolbar state.
- Remove method listeners before destroying their target objects.
- Call `ApplySeparators` manually only when replacing the standard
  `TNppPlugin` message lifecycle.

## Quick reference

| Member | Purpose | Failure or fallback |
| --- | --- | --- |
| `Create` | Creates a registry bound to a host | Raises for `nil` host |
| `AddCommand` | Registers a callable item | Raises for invalid input |
| `AddSeparator` | Registers an ordered separator | Generates `Sep$N` when ID is empty |
| `Count` | Counts commands and separators | Never raises |
| `Entries[Index]` | Returns entry metadata | Raises for invalid index |
| `IndexOf` | Maps stable ID to index | `-1` |
| `IdFromIndex` | Maps index to stable ID | Empty string |
| `CommandId` | Reads the Notepad++ command ID | `-1` for unknown ID |
| `FunctionItem` | Returns the associated ABI record | `nil` |
| `Caption` | Reads the stored caption | Empty string |
| `IsChecked` | Reads the stored checked state | `False` |
| `IsEnabled` | Reads the stored enabled state | `False` |
| `GetFuncsArray` | Exposes the contiguous ABI table | `nil` when empty |
| `ApplySeparators` | Converts separator placeholders | No-op without a host menu |
| `SetCaption` | Updates ABI and visible captions | Raises for non-command ID |
| `SetChecked` | Updates stored and native check state | Raises for non-command ID |
| `SetEnabled` | Updates state and notifies observers | Raises for non-command ID |
| `OnEnabledChanged` | Installs one enabled-state observer | No ownership transfer |
| `AddEnabledListener` | Adds a deduplicated observer | Ignores `nil` |
| `RemoveEnabledListener` | Removes an observer | No-op when absent |
