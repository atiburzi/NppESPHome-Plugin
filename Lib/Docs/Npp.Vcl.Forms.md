# `TNppPluginForm`

`TNppPluginForm`, declared in `Npp.Vcl.Forms`, is the optional VCL base class
for normal modeless plugin windows. It integrates a `TForm` with the
Notepad++ host, VCL application handle, modeless-dialog registry, placement,
close behavior, keyboard navigation, and dark mode.

## Required units

```pascal
uses
  Vcl.Forms,
  Npp.Plugin,
  Npp.Vcl.Forms;
```

## Public fields

| Field | Purpose |
| --- | --- |
| `ParentPlugin` | Non-owning reference to the associated `TNppPlugin` |
| `DefaultCloseAction` | Close action forced by `DoClose`; defaults to `caNone` |

The form must not outlive `ParentPlugin`.

## Constructors

### `Create(ParentPlugin)`

Loads the descendant's DFM as a top-level plugin form. A `nil` plugin raises
`EArgumentNilException`. The constructor attaches the shared VCL
`Application.Handle`, creates the form, assigns the Notepad++ parent window,
registers the modeless dialog, and initializes theming when supported.

```pascal
SettingsForm := TSettingsForm.Create(Plugin);
try
  SettingsForm.ShowModal;
finally
  SettingsForm.Free;
end;
```

### `Create(AOwner: TNppPluginForm)`

Creates a DFM-backed child dialog owned by another plugin form and reuses the
owner's `ParentPlugin`.

```pascal
DetailsForm := TDetailsForm.Create(Self);
```

The owner must be assigned and must already have a plugin association.

### `CreateRuntime(ParentPlugin, Dummy)`

Creates a top-level form with `CreateNew`, without loading a DFM. `Dummy`
only distinguishes the overload and should be zero.

```pascal
RuntimeForm := TNppPluginForm.CreateRuntime(Plugin, 0);
RuntimeForm.Caption := 'Generated window';
```

### `Destroy`

Unregisters the modeless dialog, destroys the VCL form, and detaches the shared
application handle. The original `Application.Handle` is restored only after
the last framework form has detached.

The attachment counter, previous handle, and active host handle are owned by an
internal process-wide state class. They are not exposed as mutable unit state.
Destroying forms in a different order from their creation is supported, and
detachment does not dereference `ParentPlugin`.

## Protected lifecycle methods

| Method | Purpose |
| --- | --- |
| `CreateParams` | Removes `WS_CHILD` so the plugin window remains top-level |
| `DoCreate` | Centers the form over Notepad++ and constrains it to a monitor |
| `DoClose` | Applies `DefaultCloseAction` before inherited close handling |
| `RegisterForm` | Registers the HWND through `NPPM_MODELESSDIALOG` |
| `UnregisterForm` | Removes the HWND from the modeless-dialog registry |

Registration methods are protected and idempotent. They act only when both the
Notepad++ window and form handle are valid.

A descendant overriding lifecycle methods must call `inherited`.

## Public methods

### `InitLanguage`

A virtual no-op hook for application-owned localization. Override it to update
captions after the DFM has loaded.

```pascal
procedure TSettingsForm.InitLanguage;
begin
  inherited;
  Caption := Translate('Settings');
end;
```

### `ToggleDarkMode`

Chooses initial-theme or theme-change mode and delegates to
`SubclassAndTheme`. Calls before Notepad++ 8.5.4 do not send the unsupported
subclassing message.

```pascal
procedure TMyPlugin.DoNppnDarkModeChanged;
begin
  inherited;
  if Assigned(SettingsForm) then
    SettingsForm.ToggleDarkMode;
end;
```

### `SubclassAndTheme`

```pascal
procedure SubclassAndTheme(DmFlag: TNppDarkMode); virtual;
```

Sends `NPPM_DARKMODESUBCLASSANDTHEME` for this form handle. Override it only
when a specialized window requires different theme behavior.

### `WantChildKey`

Forwards dialog-navigation messages to the child control and returns whether
the child handled them. This supports keyboard navigation in modeless forms.

## Creating a descendant

```pascal
type
  TSettingsForm = class(TNppPluginForm)
  public
    procedure InitLanguage; override;
  end;

SettingsForm := TSettingsForm.Create(Self);
SettingsForm.DefaultCloseAction := caHide;
SettingsForm.Show;
```

## Practical rules

- Create forms only after `TNppPlugin.SetInfo` has supplied a valid host.
- Destroy all plugin forms during shutdown while the host is still available.
- Use the plugin-aware constructors; do not call inherited `TForm`
  constructors directly.
- Set `DefaultCloseAction := caHide` for reusable modeless windows.
- Call `inherited` from overridden VCL lifecycle methods.
- Keep all visual resources and localization in the application, not the core
  framework.
