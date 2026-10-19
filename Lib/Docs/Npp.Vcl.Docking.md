# `TNppPluginDocking`

`TNppPluginDocking`, declared in `Npp.Vcl.Docking`, extends
`TNppPluginForm` with Notepad++ docking-manager registration, dock/float
notifications, tab metadata, show/hide messages, and docking-specific theme and
focus behavior.

## Required units

```pascal
uses
  Npp.Api,
  Npp.Plugin,
  Npp.Vcl.Forms,
  Npp.Vcl.Docking;
```

## Construction

A docking form requires a dialog ID. In the standard framework this is the
zero-based command index returned by `Commands.AddCommand` for the menu item
that shows or hides the panel.

### Supported constructors

```pascal
constructor Create(NppParent: TNppPlugin; DlgId: Integer);
constructor Create(AOwner: TNppPluginForm; DlgId: Integer);
```

The first creates a top-level DFM-backed docking form. The second creates one
owned by another plugin form. Both set `DefaultCloseAction` to `caHide`,
register the panel immediately, and initially make it visible.

```pascal
ShowPanelIndex := Commands.AddCommand('show.panel', 'Show panel',
  ShowPanelCommand);
...
Panel := TProjectPanel.Create(Self, ShowPanelIndex);
if not RestorePanelVisible then
  Panel.Hide;
```

The host must be valid when construction registers the panel.

### Unsupported constructors

```pascal
constructor Create(NppParent: TNppPlugin);
constructor Create(AOwner: TNppPluginForm);
```

These inherited-compatible overloads intentionally raise an exception because
Notepad++ docking registration cannot be completed without `DlgId`.

### `Destroy`

Hides a registered panel while the host is available and clears local
registration state. Notepad++ exposes no public unregister message for docking
panels.

## Properties

| Property | Purpose |
| --- | --- |
| `DlgID` | Dialog/menu index supplied to the constructor |
| `IsDockingRegistered` | Local registration state |
| `DockingData` | Read-only copy of the current `TTbData` ABI record |
| `OnDock` | Event raised for a `DMN_DOCK` notification |
| `OnFloat` | Event raised for a `DMN_FLOAT` notification |

Event targets are not owned by the form and must remain alive while assigned.

`DockingData` is a copy. Its internal pointers refer to strings owned by the
form; do not retain or free them.

## Methods

### `RegisterDockingForm`

```pascal
procedure RegisterDockingForm(
  MaskStyle: Cardinal = DWS_DF_CONT_LEFT);
```

Registers the panel through `NPPM_DMMREGASDCKDLG`. The method is idempotent
and raises `EInvalidOpException` when the Notepad++ host is unavailable.

`MaskStyle` selects the initial docking side and may contain supported
`DWS_*` flags. The method adds `DWS_ADDINFO` automatically and adds
`DWS_ICONTAB` when the form has an icon.

### `Show`

Registers the form if necessary, sends `NPPM_DMMSHOW`, and shows the VCL
window.

```pascal
Panel.Show;
```

### `Hide`

Sends `NPPM_DMMHIDE` when registered and then hides the VCL window.

```pascal
Panel.Hide;
```

### `RefreshDockingInfo`

Synchronizes caption, module name, additional information, and icon pointers,
then notifies Notepad++ through `NPPM_DMMUPDATEDISPINFO`. It is a no-op before
registration or without a valid host.

Call it after changing `Caption`, `Icon`, or other displayed metadata.

### `UpdateDisplayInfo`

```pascal
procedure UpdateDisplayInfo; overload;
procedure UpdateDisplayInfo(Info: string); overload;
```

The parameterless overload clears the optional tab information. The string
overload stores new information and calls `RefreshDockingInfo`.

```pascal
Panel.UpdateDisplayInfo('3 active tasks');
Panel.UpdateDisplayInfo; // clear it
```

### `SubclassAndTheme`

Overrides the normal-form implementation with a deliberate no-op. Notepad++
themes docking panels itself and does not support
`NPPM_DARKMODESUBCLASSANDTHEME` for them.

## Dock and float events

The protected `OnWM_NOTIFY` message method handles `WM_NOTIFY` and accepts
notifications only from its associated Notepad++ window. It closes the form for
`DMN_CLOSE` and invokes the corresponding event for `DMN_DOCK` or `DMN_FLOAT`.

```pascal
procedure TMyPlugin.PanelDocked(Sender: TObject);
begin
  SaveFloatingState(False);
end;

Panel.OnDock := PanelDocked;
Panel.OnFloat := PanelFloated;
```

A `DMN_CLOSE` notification calls `Close`; the default `caHide` behavior
keeps the form instance alive.

## Creating a descendant

```pascal
type
  TProjectPanel = class(TNppPluginDocking)
  end;

Panel := TProjectPanel.Create(Plugin, ShowPanelIndex);
Panel.Caption := 'Projects';
Panel.RefreshDockingInfo;
```

The class recursively removes `WS_EX_CONTROLPARENT` from itself and child
controls to prevent Win32 focus loops when a panel floats.

## Practical rules

- Supply the command index, not the Notepad++ `CmdID`.
- Construct the panel only after valid host handles are available.
- Hide it after construction when persisted state says it should start hidden.
- Use `Show` and `Hide`, not only the inherited `Visible` property.
- Call `RefreshDockingInfo` after changing tab metadata.
- Do not call dark-mode subclassing directly on a docking form.
- Destroy panels during plugin shutdown while Notepad++ is still valid.
