# `TNppPlugin`

`TNppPlugin` is the base class that coordinates a Notepad++ plugin's ABI
entry points, lifecycle, notifications, host access, command registry, optional
toolbar, version metadata, and common document operations. It is declared in
`Npp.Plugin`.

## Responsibilities and ownership

A `TNppPlugin` instance always creates and owns:

- one `TNppHost`;
- one `TNppCommands`;
- an internal guard for delayed toolbar refresh callbacks.

It optionally owns one `TNppToolbar` after `ConfigureToolbar` is called.
The destructor releases the toolbar first, then commands, then the host.

Application forms, configuration stores, threads, and processes remain the
responsibility of the descendant.

## Declaring a plugin

```pascal
type
  TMyPlugin = class(TNppPlugin)
  protected
    procedure DoNppnReady; override;
    procedure DoNppnShutdown; override;
  public
    constructor Create; override;
  end;

var
  PluginClass: TNppPluginClass = TMyPlugin;
```

`TNppPluginClass` is the metaclass type used by `NppPluginInclude.pas` to
construct the concrete plugin lazily.

## Properties

| Property | Meaning and lifetime |
| --- | --- |
| `NppData` | Read-only copy of the handles supplied by Notepad++ |
| `Host` | Owned typed message gateway; never free it directly |
| `Commands` | Owned command registry; always available |
| `Toolbar` | Owned toolbar manager, or `nil` until configured |
| `PluginName` | Name returned by the ABI and displayed under Plugins |
| `PluginMajorVersion` | Writable major component loaded from the DLL resource |
| `PluginMinorVersion` | Writable minor component loaded from the DLL resource |
| `SCNotification` | Current notification pointer; valid only during dispatch |
| `IsShuttingDown` | Becomes `True` when `Shutdown` starts |
| `IsShutdownComplete` | Becomes `True` after the shutdown hook finishes |

The release/build values and copyright are exposed through methods rather than
properties.

## Construction and service configuration

### `Create` and `Destroy`

The virtual constructor creates host and command services with zero handles.
A descendant should call `inherited`, assign `PluginName`, register every
command, and optionally configure the toolbar. DLL version metadata is loaded
by the base class when Notepad++ sends `NPPN_READY`.

```pascal
constructor TMyPlugin.Create;
begin
  inherited;
  PluginName := 'My Plugin';
  Commands.AddCommand('run', 'Run', RunCommand);
  ConfigureToolbar(CreateToolbarIcons);
end;
```

`Destroy` invalidates delayed toolbar work and frees owned services. Destroy
application forms and host-dependent resources in `DoNppnShutdown`, while
Notepad++ is still available.

### `ConfigureToolbar`

```pascal
procedure ConfigureToolbar(const IconProvider: TNppToolbarIconProvider;
  const DisabledIconProvider: TNppToolbarDisabledIconProvider = nil);
```

Protected method that creates the optional toolbar. It raises
`EArgumentNilException` for a missing icon provider and
`EInvalidOpException` when called twice or after shutdown has started.

### `GetVersionInfo`

Protected method that reads the current DLL's numeric file version and copyright
resource into the plugin fields. The base `DoNppnReady` implementation invokes
it automatically after Notepad++ is ready. A descendant overriding
`DoNppnReady` must call `inherited` to preserve this behavior. Before that
notification, version fields retain their initial zero/empty values unless the
writable major and minor properties are assigned explicitly.

### `BeforeDestruction`

Public `TObject` override reserved for pre-destruction lifecycle behavior.
Descendants overriding it must call `inherited`; normal cleanup belongs in
`DoNppnShutdown` or `Destroy`.

## ABI and lifecycle methods

| Method | Purpose |
| --- | --- |
| `SetInfo(NppData)` | Stores host handles and synchronizes `Host.Data` |
| `GetName` | Returns the ABI pointer for `PluginName` |
| `GetFuncsArray(out Count)` | Delegates command-array publication to `Commands` |
| `MessageProc(var Msg)` | Dispatches Windows messages and applies separators on `WM_CREATE` |
| `BeNotified(SN)` | Stores, dispatches, and finally clears `SCNotification` |
| `Shutdown` | Executes the shutdown hook exactly once |
| `GetCurrentScintilla` | Returns the HWND of the active editor view |

`NppPluginInclude.pas` calls these methods from the exported DLL functions.
Application code rarely calls them directly.

An override of `SetInfo` must call `inherited` before using `Host` or
Notepad++ paths:

```pascal
procedure TMyPlugin.SetInfo(NppData: TNppData);
begin
  inherited;
  ConfigPath := TPath.Combine(GetPluginConfigDir, 'settings.ini');
end;
```

## Plugin and host information

| Method | Result |
| --- | --- |
| `GetMajorVersion` | DLL file-version major component |
| `GetMinorVersion` | DLL file-version minor component |
| `GetReleaseNumber` | DLL file-version release component |
| `GetBuildNumber` | DLL file-version build component |
| `GetCopyright` | Copyright string from the DLL resource |
| `GetNppVersion(var Major, Minor)` | Normalized Notepad++ version |
| `IsNppMinVersion(Major, Minor)` | Whether the host meets a minimum version |
| `IsDarkModeEnabled` | Dark-mode state; `False` on unsupported hosts |
| `GetDarkModeColors(PColors)` | Fills a `TNppDarkModeColors` record |
| `GetToolbarIconSetChoice` | Current Notepad++ toolbar icon family/size choice |
| `GetNppWindowTitle` | Current main-window caption |

The normalized minor scale follows `TNppHost`: for example, Notepad++ 8.5.4
is tested as `IsNppMinVersion(8, 540)`.

`GetDarkModeColors` returns `False` without contacting the host when `PColors`
is `nil`; it also returns `False` when the host is
too old, or the query fails.

## Directory methods

| Method | Result |
| --- | --- |
| `GetNppDir` | Notepad++ installation directory |
| `GetPluginDir` | host plugin directory |
| `GetPluginConfigDir` | writable plugin configuration directory |
| `GetPluginDocDir` | documentation directory for this plugin |
| `GetPluginDllPath` | absolute path of the running plugin DLL |

These methods return empty strings when the host cannot provide the requested
value. Build application paths after `SetInfo`, not in the lightweight base
constructor.

## Current document information

| Method | Result |
| --- | --- |
| `GetFullCurrentPath` | Absolute active-document path |
| `GetCurrentDirectory` | Directory containing the active document |
| `GetFullFileName` | File name and extension without its directory |
| `GetFileNameWithoutExt` | File name without extension |
| `GetFileNameExt` | File extension |
| `GetEncoding` | Notepad++ buffer encoding value |
| `GetEOLFormat` | Notepad++ EOL format value |
| `GetLanguageType` | Active `TNppLang` numeric value |
| `GetLanguageName(Lang)` | Notepad++ language name |
| `GetLanguageDesc(Lang)` | Human-readable language description |
| `GetCurrentLine` | Zero-based caret line |
| `GetCurrentColumn` | Zero-based caret column |
| `GetCurrentWord` | Selection or word under the caret |
| `GetFilePos(out File, out Line, out Column)` | Path and caret location in one call |

```pascal
GetFilePos(FileName, Line, Column);
StatusText := Format('%s (%d:%d)', [FileName, Line + 1, Column + 1]);
```

## Views, buffers, and open files

Buffer-position and Scintilla methods use `MAIN_VIEW` (0) and `SUB_VIEW` (1).
Open-file count methods instead use `ALL_OPEN_FILES` (0), `PRIMARY_VIEW` (1),
and `SECOND_VIEW` (2). Invalid values generally produce a neutral result such
as `0`, `False`, or `-1`, according to the underlying method.

Qualify these constants with `Npp.Api` in units that also import WinAPI units;
Windows headers can expose identically named symbols such as `SECOND_VIEW`.

| Method | Purpose |
| --- | --- |
| `GetCurrentViewIdx` | Returns the active view index |
| `GetCurrentViewIdx(ScHandle)` | Maps a Scintilla HWND to a view index |
| `GetCurrentDocIndex(View)` | Returns the active tab index in a view |
| `GetCurrentBufferId` | Returns the active stable buffer ID |
| `GetBufferIdFromPos(View, Doc)` | Maps view/tab position to buffer ID |
| `GetPosFromBufferId(BufferId, out Doc)` | Returns view and tab position |
| `GetFullPathFromBufferId(BufferId)` | Resolves a buffer to its absolute path |
| `GetCurrentBufferDirty(View)` | Reports unsaved changes in a view |
| `GetOpenFilesCnt(Type)` | Counts paths for `ALL_OPEN_FILES`, `PRIMARY_VIEW`, or `SECOND_VIEW` |
| `GetOpenFiles(Type)` | Returns the matching open paths |
| `GetLineCount(View)` | Scintilla line count |
| `GetCurrentPos(View)` | Scintilla caret character position |
| `GetLineFromPosition(View, Position)` | Maps a character position to a line |
| `GetFirstVisibleLine(View)` | First visible display line |
| `GetLinesOnScreen(View)` | Number of visible display lines |

```pascal
for FileName in GetOpenFiles(Npp.Api.ALL_OPEN_FILES) do
  ProcessOpenFile(FileName);
```

Returned arrays and strings are owned by the caller through normal Delphi
managed-type semantics.

## File operations

| Method | Purpose |
| --- | --- |
| `OpenFile(FileName, ReadOnly)` | Opens or activates a file and optionally marks it read-only |
| `OpenFile(FileName, Line, ReadOnly)` | Opens the file and moves to a zero-based line |
| `SaveFile(FileName)` | Saves the specified open document |
| `SaveCurrentFile` | Saves the active document |
| `SaveAllFiles` | Saves every modified document |
| `SwitchToFile(FileName)` | Activates an already open absolute path |
| `ReloadFile(FileName, Alert)` | Reloads a specified file |
| `ReloadCurrentFile(Alert)` | Reloads the active buffer |

Boolean operations return the result reported by Notepad++. `OpenFile` applies
read-only state explicitly through Scintilla after either activating an existing
document or opening a new one; it never relies on the menu toggle. `Alert=True`
allows the host to warn about losing unsaved changes.

```pascal
if OpenFile(ProjectFile, 0, False) then
  Commands.SetEnabled('build', True);
```

## Notification hooks

Override only the notifications the application needs. `BeNotified` makes
`SCNotification` available during the hook and clears it afterward. Never
store that pointer for later use. Call `inherited` so framework behavior such
as toolbar lifecycle and shutdown remains active.

| Hook | Notification / framework behavior |
| --- | --- |
| `DoNppnReady` | `NPPN_READY`; captures and refreshes the optional toolbar |
| `DoNppnToolbarModification` | `NPPN_TBMODIFICATION`; initializes toolbar icons |
| `DoNppToolbarIconsetChanged` | `NPPN_TOOLBARICONSETCHANGED`; schedules refresh after native image-list replacement |
| `DoNppnDarkModeChanged` | `NPPN_DARKMODECHANGED`; refreshes the optional toolbar |
| `DoNppnBeforeShutDown` | `NPPN_BEFORESHUTDOWN` |
| `DoNppnCancelShutDown` | `NPPN_CANCELSHUTDOWN` |
| `DoNppnShutdown` | `NPPN_SHUTDOWN`; application cleanup hook |
| `DoNppnFileBeforeLoad` | `NPPN_FILEBEFORELOAD` |
| `DoNppnFileLoadFailed` | `NPPN_FILELOADFAILED` |
| `DoNppnFileBeforeOpen` | `NPPN_FILEBEFOREOPEN` |
| `DoNppnFileOpened` | `NPPN_FILEOPENED` |
| `DoNppnFileBeforeClose` | `NPPN_FILEBEFORECLOSE` |
| `DoNppnFileClosed` | `NPPN_FILECLOSED` |
| `DoNppnFileBeforeSave` | `NPPN_FILEBEFORESAVE` |
| `DoNppnFileSaved` | `NPPN_FILESAVED` |
| `DoNppnFileBeforeRename` | `NPPN_FILEBEFORERENAME` |
| `DoNppnFileRenameCancel` | `NPPN_FILERENAMECANCEL` |
| `DoNppnFileRenamed` | `NPPN_FILERENAMED` |
| `DoNppnFileBeforeDelete` | `NPPN_FILEBEFOREDELETE` |
| `DoNppnFileDeleteFailed` | `NPPN_FILEDELETEFAILED` |
| `DoNppnFileDeleted` | `NPPN_FILEDELETED` |
| `DoNppnBufferActivated` | `NPPN_BUFFERACTIVATED` |
| `DoNppnLangChanged` | `NPPN_LANGCHANGED` |
| `DoNppnReadOnlyChanged` | `NPPN_READONLYCHANGED` |
| `DoNppnDocOrderChanged` | `NPPN_DOCORDERCHANGED` |
| `DoNppnShortcutRemapped` | `NPPN_SHORTCUTREMAPPED` |
| `DoNppnWordStylesUpdated` | `NPPN_WORDSTYLESUPDATED` |
| `DoNppnSnapshotDirtyFileLoaded` | `NPPN_SNAPSHOTDIRTYFILELOADED` |
| `DoNppnCmdLinePluginMsg` | `NPPN_CMDLINEPLUGINMSG` |
| `DoNppExternalLexerBuffer` | `NPPN_EXTERNALLEXERBUFFER` |
| `DoNppGlobalModified` | `NPPN_GLOBALMODIFIED` |
| `DoNppNativeLangChanged` | `NPPN_NATIVELANGCHANGED` |

```pascal
procedure TMyPlugin.DoNppnBufferActivated;
begin
  inherited;
  RefreshCommandState;
end;

procedure TMyPlugin.DoNppnShutdown;
begin
  FreeAndNil(MainForm);
  inherited;
end;
```

## Recommended lifecycle

1. Constructor: set the name, register commands, configure optional toolbar.
2. `SetInfo`: call `inherited`, then create path-dependent services.
3. `DoNppnToolbarModification`: let the framework register toolbar icons.
4. `DoNppnReady`: create forms and start host-dependent application work.
5. Notification hooks: update application state without retaining
   `SCNotification`.
6. `DoNppnShutdown`: stop workers and destroy forms/resources.
7. Destructor: let the base class release toolbar, commands, and host.
