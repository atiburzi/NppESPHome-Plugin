# `TNppHost`

`TNppHost` is the typed gateway to the Notepad++ window, the two Scintilla
views, and the native toolbar. It is declared in the `Npp.Host` unit.

The class isolates the rest of the framework from direct `SendMessage`,
`PostMessage`, and Win32 child-window discovery calls. This design provides:

- one authoritative source for the handles received through `setInfo`;
- an explicit distinction between synchronous and asynchronous operations;
- injectable message transports for tests that do not create real windows;
- replaceable native-toolbar handle resolution;
- a common dependency for commands, toolbar management, and optional VCL
  integration.

## Required units

Basic use requires:

```pascal
uses
  Winapi.Windows,
  Npp.Api,
  Npp.Host;
```

Add these units when using Scintilla messages, native toolbar messages, or
Notepad++ menu command constants:

```pascal
uses
  Winapi.CommCtrl,
  Npp.Scintilla.Api,
  Npp.MenuCmdID;
```

## Position in the framework

`TNppPlugin` creates and owns one `TNppHost` instance. A plugin implementation
normally uses the inherited `Host` property:

```pascal
procedure TMyPlugin.DoNppnReady;
var
  BufferId: LRESULT;
begin
  inherited;
  BufferId := Host.SendNpp(NPPM_GETCURRENTBUFFERID);
end;
```

Do not free an instance obtained from `TNppPlugin.Host`. Direct construction is
intended for standalone infrastructure and isolated tests.

```text
Plugin / Commands / Toolbar / VCL
                 |
                 v
             TNppHost
                 |
       configurable transports
                 |
                 v
     Notepad++ / Scintilla / toolbar
```

## Host data: `TNppData`

The constructor receives a `TNppData` record declared in `Npp.Api`:

```pascal
TNppData = record
  NppHandle: HWND;
  ScintillaMainHandle: HWND;
  ScintillaSecondHandle: HWND;
end;
```

| Field | Content |
| --- | --- |
| `NppHandle` | Handle of the main Notepad++ window |
| `ScintillaMainHandle` | Handle of the primary Scintilla view |
| `ScintillaSecondHandle` | Handle of the secondary Scintilla view |

`TNppHost` stores the record by value. `TNppPlugin.SetInfo` automatically
updates `Host.Data` when Notepad++ supplies the real handles.

## Callback types

The unit exposes three procedural callback types:

```pascal
TNppHostTransport = function(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;

TNppHostPostTransport = function(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): Boolean;

TNppToolbarHandleResolver = function(NppHandle: HWND): HWND;
```

| Type | Responsibility | Default implementation |
| --- | --- | --- |
| `TNppHostTransport` | Sends a synchronous message | `NppDefaultHostTransport` |
| `TNppHostPostTransport` | Queues an asynchronous message | `NppDefaultHostPostTransport` |
| `TNppToolbarHandleResolver` | Finds the native Notepad++ toolbar | `NppDefaultToolbarHandleResolver` |

These are plain Delphi functions rather than `of object` methods, which makes
them easy to replace with deterministic global functions in tests.

## Constructor

### `Create`

```pascal
constructor Create(const AData: TNppData;
  const ATransport: TNppHostTransport = nil;
  const APostTransport: TNppHostPostTransport = nil;
  const AToolbarHandleResolver: TNppToolbarHandleResolver = nil);
```

Creates the gateway and copies the supplied handles.

| Parameter | Meaning |
| --- | --- |
| `AData` | Initial Notepad++ and Scintilla handles |
| `ATransport` | Synchronous transport; `nil` selects `SendMessage` |
| `APostTransport` | Asynchronous transport; `nil` selects `PostMessage` |
| `AToolbarHandleResolver` | Toolbar resolver; `nil` selects Win32 discovery |

```pascal
Host := TNppHost.Create(Data);
try
  Host.SendNpp(NPPM_GETCURRENTBUFFERID);
finally
  Host.Free;
end;
```

## Properties

### `Data`

```pascal
property Data: TNppData read FData write FData;
```

Contains the handles used by all destination-specific methods.

```pascal
Host.Data := NewNppData;
```

The whole record is replaced. Changing a source variable after assigning it
does not change this property.

### `Transport`

```pascal
property Transport: TNppHostTransport read FTransport write SetTransport;
```

Defines the function used by `Send` and all synchronous convenience methods.
The default is `NppDefaultHostTransport`, which calls
`Winapi.Windows.SendMessage`. Assigning `nil` restores that default.

```pascal
Host.Transport := FakeSend;
// Run the test.
Host.Transport := nil;
```

### `PostTransport`

```pascal
property PostTransport: TNppHostPostTransport
  read FPostTransport write SetPostTransport;
```

Defines the function used by `Post` and `PostNpp`. The default is
`NppDefaultHostPostTransport`, based on `PostMessage`. Assigning `nil`
restores the default.

### `ToolbarHandleResolver`

```pascal
property ToolbarHandleResolver: TNppToolbarHandleResolver
  read FToolbarHandleResolver write SetToolbarHandleResolver;
```

Defines how `GetToolbarHandle` finds the native toolbar. The default enumerates
the child windows of Notepad++ and returns the first `ToolbarWindow32`.

```pascal
function FakeToolbarResolver(NppHandle: HWND): HWND;
begin
  Result := HWND(1234);
end;

Host.ToolbarHandleResolver := FakeToolbarResolver;
```

Assigning `nil` restores the default resolver.

## Generic transport methods

### `Send`

```pascal
function Send(Handle: HWND; Msg: UINT; WParam: WPARAM = 0;
  LParam: LPARAM = 0): LRESULT;
```

Sends `Msg` synchronously to an explicit handle through `Transport` and
returns the recipient's `LRESULT` unchanged.

```pascal
CurrentView := 0;
Host.Send(Host.Data.NppHandle, NPPM_GETCURRENTSCINTILLA, 0,
  LPARAM(@CurrentView));
```

The recipient has processed the message when the call returns. A synchronous
message may therefore use pointers to local variables when the message contract
requires them.

Use this generic method for a destination outside the three standard handles or
for an already resolved native toolbar handle.

### `Post`

```pascal
function Post(Handle: HWND; Msg: UINT; WParam: WPARAM = 0;
  LParam: LPARAM = 0): Boolean;
```

Queues a message through `PostTransport` and returns immediately. The result
only reports whether the message was queued; it does not report whether the
recipient later completed the operation successfully.

```pascal
if not Host.Post(TargetHandle, WM_APP + 1) then
  raise Exception.Create('Unable to queue the message');
```

> The recipient processes an asynchronous message after `Post` returns. Never
> pass pointers to local variables, temporary strings, or objects that may be
> destroyed before the recipient handles the message.

## Notepad++ methods

### `SendNpp`

```pascal
function SendNpp(Msg: UINT; WParam: WPARAM = 0;
  LParam: LPARAM = 0): LRESULT;
```

Equivalent to `Send(Data.NppHandle, Msg, WParam, LParam)`. Use it for
synchronous `NPPM_*` requests.

```pascal
BufferId := Host.SendNpp(NPPM_GETCURRENTBUFFERID);
```

Parameter and result semantics come from the individual Notepad++ message.
`TNppHost` forwards them without interpretation.

### `PostNpp`

```pascal
function PostNpp(Msg: UINT; WParam: WPARAM = 0;
  LParam: LPARAM = 0): Boolean;
```

Equivalent to `Post(Data.NppHandle, Msg, WParam, LParam)`. Use it when
Notepad++ should process an operation after the current plugin callback returns.

```pascal
Host.PostNpp(NPPM_MENUCOMMAND, 0, LPARAM(IDM_VIEW_ALL_CHARACTERS));
```

The lifetime restrictions documented for `Post` also apply here.

## Scintilla methods

### `SendMainScintilla`

```pascal
function SendMainScintilla(Msg: UINT; WParam: WPARAM = 0;
  LParam: LPARAM = 0): LRESULT;
```

Sends a synchronous message to `Data.ScintillaMainHandle`.

```pascal
CharacterCount := Host.SendMainScintilla(SCI_GETLENGTH);
```

### `SendSecondScintilla`

```pascal
function SendSecondScintilla(Msg: UINT; WParam: WPARAM = 0;
  LParam: LPARAM = 0): LRESULT;
```

Sends a synchronous message to `Data.ScintillaSecondHandle`.

```pascal
IsModified := Host.SendSecondScintilla(SCI_GETMODIFY) <> 0;
```

Neither method determines which editor is active. Query Notepad++ first when
the operation must target the current view:

```pascal
CurrentView := 0;
Host.SendNpp(NPPM_GETCURRENTSCINTILLA, 0, LPARAM(@CurrentView));

if CurrentView = 0 then
  CurrentPosition := Host.SendMainScintilla(SCI_GETCURRENTPOS)
else
  CurrentPosition := Host.SendSecondScintilla(SCI_GETCURRENTPOS);
```

## Notepad++ version methods

### `GetNppVersion`

```pascal
function GetNppVersion(var MajorVersion, MinorVersion: Integer): Integer;
```

Sends `NPPM_GETNPPVERSION`, separates the major and minor portions, and
normalizes the minor portion to the framework's three-digit scale.

| Notepad++ version | `MajorVersion` | `MinorVersion` |
| --- | ---: | ---: |
| 8.5 | 8 | 500 |
| 8.4.1 | 8 | 410 |
| 8.5.4 | 8 | 540 |

The function also returns `MajorVersion`.

```pascal
Host.GetNppVersion(Major, Minor);
```

### `IsNppMinVersion`

```pascal
function IsNppMinVersion(AMajorVersion, AMinorVersion: Integer): Boolean;
```

Returns `True` when the current host is equal to or newer than the requested
version. `AMinorVersion` must use the same normalized scale.

```pascal
SupportsNewApi := Host.IsNppMinVersion(8, 540);
SupportsMajorEight := Host.IsNppMinVersion(8, 0);
```

## Native toolbar

### `GetToolbarHandle`

```pascal
function GetToolbarHandle: HWND;
```

Calls `ToolbarHandleResolver(Data.NppHandle)` and returns the native toolbar
handle, or zero when no toolbar is found.

```pascal
ToolbarHandle := Host.GetToolbarHandle;
if ToolbarHandle <> 0 then
  ButtonCount := Host.Send(ToolbarHandle, TB_BUTTONCOUNT);
```

Notepad++ may recreate its toolbar. Resolve the handle when needed instead of
caching it for the plugin's entire lifetime. Prefer `TNppToolbar` for normal
button management.

## Native menu commands

### `PerformMenuCommand`

```pascal
procedure PerformMenuCommand(MenuCmdId: Integer; Param: Integer = 0;
  Delayed: Boolean = True);
```

Executes a native Notepad++ `IDM_*` command through `NPPM_MENUCOMMAND`.

| Parameter | Meaning |
| --- | --- |
| `MenuCmdId` | Constant declared in `Npp.MenuCmdID` |
| `Param` | Optional value forwarded through `WParam` |
| `Delayed` | `True` uses `PostNpp`; `False` uses `SendNpp` |

Delayed execution is the default because it avoids starting another menu
command while Notepad++ is still processing the current plugin callback.

```pascal
Host.PerformMenuCommand(IDM_FILE_SAVE);
Host.PerformMenuCommand(IDM_FILE_SAVE, 0, False);
```

This method invokes native Notepad++ commands. Use `TNppCommands` to manage
commands registered by the plugin itself.

## Public default functions

### `NppDefaultHostTransport`

```pascal
function NppDefaultHostTransport(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
```

Forwards all parameters to `Winapi.Windows.SendMessage`.

### `NppDefaultHostPostTransport`

```pascal
function NppDefaultHostPostTransport(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): Boolean;
```

Forwards all parameters to `Winapi.Windows.PostMessage` and returns whether
the message was queued.

### `NppDefaultToolbarHandleResolver`

```pascal
function NppDefaultToolbarHandleResolver(NppHandle: HWND): HWND;
```

Enumerates the children of `NppHandle` and returns the first native toolbar.
It returns zero when the parent handle is zero or no toolbar is found.

These functions are normally selected automatically. They are public so tests
and custom transports can explicitly restore or compose production behavior.

## Test example without Notepad++

```pascal
var
  LastHandle: HWND;
  LastMessage: UINT;

function FakeSend(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  LastHandle := Handle;
  LastMessage := Msg;
  if Msg = NPPM_GETCURRENTBUFFERID then
    Exit(42);
  Result := 0;
end;

procedure TestCurrentBuffer;
var
  Data: TNppData;
  TestHost: TNppHost;
begin
  FillChar(Data, SizeOf(Data), 0);
  Data.NppHandle := HWND(101);

  TestHost := TNppHost.Create(Data, FakeSend);
  try
    Assert(TestHost.SendNpp(NPPM_GETCURRENTBUFFERID) = 42);
    Assert(LastHandle = HWND(101));
    Assert(LastMessage = NPPM_GETCURRENTBUFFERID);
  finally
    TestHost.Free;
  end;
end;
```

A `TNppPlugin` test can replace transports without replacing the host object:

```pascal
Plugin.Host.Transport := FakeSend;
Plugin.Host.PostTransport := FakePost;
Plugin.Host.ToolbarHandleResolver := FakeToolbarResolver;
```

## Practical rules

- Use `SendNpp` for synchronous `NPPM_*` messages.
- Use `SendMainScintilla` or `SendSecondScintilla` for `SCI_*` messages.
- Use `PostNpp` when work must happen after the current callback.
- Never pass temporary data through `Post` or `PostNpp`.
- Consult each message contract before interpreting `WParam`, `LParam`, or
  `LRESULT`.
- Use the normalized minor scale, such as `410` for Notepad++ 8.4.1.
- Do not cache the result of `GetToolbarHandle` indefinitely.
- Do not create or free `Host` manually in a `TNppPlugin` descendant.
- Assign `nil` to a callback property to restore its Win32 default.

## Quick reference

| Member | Destination | Mode | Result |
| --- | --- | --- | --- |
| `Send` | Explicit HWND | Synchronous | Recipient `LRESULT` |
| `Post` | Explicit HWND | Asynchronous | Whether the message was queued |
| `SendNpp` | Notepad++ | Synchronous | Notepad++ `LRESULT` |
| `PostNpp` | Notepad++ | Asynchronous | Whether the message was queued |
| `SendMainScintilla` | Primary Scintilla | Synchronous | Scintilla `LRESULT` |
| `SendSecondScintilla` | Secondary Scintilla | Synchronous | Scintilla `LRESULT` |
| `GetNppVersion` | Notepad++ | Synchronous | Normalized major and minor |
| `IsNppMinVersion` | Notepad++ | Synchronous | Version comparison result |
| `GetToolbarHandle` | Native toolbar | Synchronous | Handle or zero |
| `PerformMenuCommand` | Notepad++ menu | Configurable | No return value |
