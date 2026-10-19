// Typed and testable gateway to the Notepad++ and Scintilla window protocols.
unit Npp.Host;

interface

uses
  Winapi.Windows,
  Winapi.CommCtrl,
  System.SysUtils,
  Npp.Api;

type
  // Transport used by the host wrapper. Tests can inject a deterministic
  // function without creating a Notepad++ window.
  TNppHostTransport = function(Handle: HWND; Msg: UINT; WParam: WPARAM;
    LParam: LPARAM): LRESULT;
  TNppHostPostTransport = function(Handle: HWND; Msg: UINT; WParam: WPARAM;
    LParam: LPARAM): Boolean;
  TNppToolbarHandleResolver = function(NppHandle: HWND): HWND;

  // ***************************************************************************
  // Purpose: Centralizes synchronous and asynchronous host message transport.
  // ***************************************************************************
  TNppHost = class
  private
    FData: TNppData;
    FTransport: TNppHostTransport;
    FPostTransport: TNppHostPostTransport;
    FToolbarHandleResolver: TNppToolbarHandleResolver;
    procedure SetTransport(const Value: TNppHostTransport);
    procedure SetPostTransport(const Value: TNppHostPostTransport);
    procedure SetToolbarHandleResolver(const Value: TNppToolbarHandleResolver);
  public
    constructor Create(const AData: TNppData;
      const ATransport: TNppHostTransport = nil;
      const APostTransport: TNppHostPostTransport = nil;
      const AToolbarHandleResolver: TNppToolbarHandleResolver = nil);

    function Send(Handle: HWND; Msg: UINT; WParam: WPARAM = 0;
      LParam: LPARAM = 0): LRESULT;
    function Post(Handle: HWND; Msg: UINT; WParam: WPARAM = 0;
      LParam: LPARAM = 0): Boolean;
    function SendNpp(Msg: UINT; WParam: WPARAM = 0;
      LParam: LPARAM = 0): LRESULT;
    function PostNpp(Msg: UINT; WParam: WPARAM = 0;
      LParam: LPARAM = 0): Boolean;
    function SendMainScintilla(Msg: UINT; WParam: WPARAM = 0;
      LParam: LPARAM = 0): LRESULT;
    function SendSecondScintilla(Msg: UINT; WParam: WPARAM = 0;
      LParam: LPARAM = 0): LRESULT;
    function GetNppVersion(var MajorVersion, MinorVersion: Integer): Integer;
    function IsNppMinVersion(AMajorVersion, AMinorVersion: Integer): Boolean;
    function GetToolbarHandle: HWND;
    procedure PerformMenuCommand(MenuCmdId: Integer; Param: Integer = 0;
      Delayed: Boolean = True);

    property Data: TNppData read FData write FData;
    property Transport: TNppHostTransport read FTransport write SetTransport;
    property PostTransport: TNppHostPostTransport read FPostTransport
      write SetPostTransport;
    property ToolbarHandleResolver: TNppToolbarHandleResolver
      read FToolbarHandleResolver write SetToolbarHandleResolver;
  end;

function NppDefaultHostTransport(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
function NppDefaultHostPostTransport(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): Boolean;
function NppDefaultToolbarHandleResolver(NppHandle: HWND): HWND;

implementation

// *****************************************************************************
// Purpose: Sends a synchronous Win32 message through the production transport.
// *****************************************************************************
function NppDefaultHostTransport(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  Result := Winapi.Windows.SendMessage(Handle, Msg, WParam, LParam);
end;

// *****************************************************************************
// Purpose: Posts an asynchronous Win32 message through the production transport.
// *****************************************************************************
function NppDefaultHostPostTransport(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): Boolean;
begin
  Result := Winapi.Windows.PostMessage(Handle, Msg, WParam, LParam);
end;

// *****************************************************************************
// Purpose: Locates the first toolbar child while enumerating Notepad++ windows.
// *****************************************************************************
function EnumToolbarChild(Wnd: HWND; LParam: LPARAM): BOOL; stdcall;
var
  ClassName: array[0..255] of Char;
  ToolbarHandle: ^HWND;
begin
  GetClassName(Wnd, ClassName, Length(ClassName));
  if StrComp(ClassName, TOOLBARCLASSNAME) = 0 then
  begin
    ToolbarHandle := Pointer(LParam);
    ToolbarHandle^ := Wnd;
    Result := False;
  end
  else
    Result := True;
end;

// *****************************************************************************
// Purpose: Resolves the native toolbar handle owned by the Notepad++ window.
// *****************************************************************************
function NppDefaultToolbarHandleResolver(NppHandle: HWND): HWND;
begin
  Result := 0;
  if NppHandle <> 0 then
    EnumChildWindows(NppHandle, @EnumToolbarChild, LPARAM(@Result));
end;

// *****************************************************************************
// Purpose: Creates and initializes the TNppHost instance.
// *****************************************************************************
constructor TNppHost.Create(const AData: TNppData;
  const ATransport: TNppHostTransport;
  const APostTransport: TNppHostPostTransport;
  const AToolbarHandleResolver: TNppToolbarHandleResolver);
begin
  inherited Create;
  FData := AData;
  if Assigned(ATransport) then
    FTransport := ATransport
  else
    FTransport := NppDefaultHostTransport;
  if Assigned(APostTransport) then
    FPostTransport := APostTransport
  else
    FPostTransport := NppDefaultHostPostTransport;
  if Assigned(AToolbarHandleResolver) then
    FToolbarHandleResolver := AToolbarHandleResolver
  else
    FToolbarHandleResolver := NppDefaultToolbarHandleResolver;
end;

// *****************************************************************************
// Purpose: Selects the synchronous transport, restoring the Win32 default for nil.
// *****************************************************************************
procedure TNppHost.SetTransport(const Value: TNppHostTransport);
begin
  if Assigned(Value) then
    FTransport := Value
  else
    FTransport := NppDefaultHostTransport;
end;

// *****************************************************************************
// Purpose: Selects the asynchronous transport, restoring the Win32 default for nil.
// *****************************************************************************
procedure TNppHost.SetPostTransport(const Value: TNppHostPostTransport);
begin
  if Assigned(Value) then
    FPostTransport := Value
  else
    FPostTransport := NppDefaultHostPostTransport;
end;

// *****************************************************************************
// Purpose: Selects the toolbar resolver, restoring the Win32 default for nil.
// *****************************************************************************
procedure TNppHost.SetToolbarHandleResolver(
  const Value: TNppToolbarHandleResolver);
begin
  if Assigned(Value) then
    FToolbarHandleResolver := Value
  else
    FToolbarHandleResolver := NppDefaultToolbarHandleResolver;
end;

// *****************************************************************************
// Purpose: Sends a message synchronously through the configured transport.
// *****************************************************************************
function TNppHost.Send(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  if not Assigned(FTransport) then
    Exit(0);
  Result := FTransport(Handle, Msg, WParam, LParam);
end;

// *****************************************************************************
// Purpose: Posts a message asynchronously through the configured transport.
// *****************************************************************************
function TNppHost.Post(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): Boolean;
begin
  if not Assigned(FPostTransport) then
    Exit(False);
  Result := FPostTransport(Handle, Msg, WParam, LParam);
end;

// *****************************************************************************
// Purpose: Sends a synchronous message to the Notepad++ main window.
// *****************************************************************************
function TNppHost.SendNpp(Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  Result := Send(FData.NppHandle, Msg, WParam, LParam);
end;

// *****************************************************************************
// Purpose: Posts an asynchronous message to the Notepad++ main window.
// *****************************************************************************
function TNppHost.PostNpp(Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): Boolean;
begin
  Result := Post(FData.NppHandle, Msg, WParam, LParam);
end;

// *****************************************************************************
// Purpose: Sends a synchronous message to the primary Scintilla view.
// *****************************************************************************
function TNppHost.SendMainScintilla(Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  Result := Send(FData.ScintillaMainHandle, Msg, WParam, LParam);
end;

// *****************************************************************************
// Purpose: Sends a synchronous message to the secondary Scintilla view.
// *****************************************************************************
function TNppHost.SendSecondScintilla(Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  Result := Send(FData.ScintillaSecondHandle, Msg, WParam, LParam);
end;

// *****************************************************************************
// Purpose: Reads and normalizes the Notepad++ major and minor version numbers.
// *****************************************************************************
function TNppHost.GetNppVersion(var MajorVersion,
  MinorVersion: Integer): Integer;
var
  Version: LRESULT;
begin
  Version := SendNpp(NPPM_GETNPPVERSION);
  MajorVersion := HiWord(Version);
  MinorVersion := LoWord(Version);
  // Notepad++ encodes one- and two-digit minor versions without fixed decimal
  // width. Normalize them so callers can compare, for example, 8.5 as 8.500.
  if MinorVersion < 10 then
    MinorVersion := MinorVersion * 100
  else if MinorVersion < 100 then
    MinorVersion := MinorVersion * 10;
  Result := MajorVersion;
end;

// *****************************************************************************
// Purpose: Reports whether the host satisfies a required Notepad++ version.
// *****************************************************************************
function TNppHost.IsNppMinVersion(AMajorVersion,
  AMinorVersion: Integer): Boolean;
var
  MajorVersion, MinorVersion: Integer;
begin
  GetNppVersion(MajorVersion, MinorVersion);
  Result := (MajorVersion > AMajorVersion) or
    ((MajorVersion = AMajorVersion) and (MinorVersion >= AMinorVersion));
end;

// *****************************************************************************
// Purpose: Resolves the current native toolbar window handle.
// *****************************************************************************
function TNppHost.GetToolbarHandle: HWND;
begin
  if Assigned(FToolbarHandleResolver) then
    Result := FToolbarHandleResolver(FData.NppHandle)
  else
    Result := 0;
end;

// *****************************************************************************
// Purpose: Executes a native Notepad++ menu command synchronously or asynchronously.
// *****************************************************************************
procedure TNppHost.PerformMenuCommand(MenuCmdId, Param: Integer;
  Delayed: Boolean);
begin
  if Delayed then
    PostNpp(NPPM_MENUCOMMAND, WPARAM(Param), LPARAM(MenuCmdId))
  else
    SendNpp(NPPM_MENUCOMMAND, WPARAM(Param), LPARAM(MenuCmdId));
end;

end.
