unit Npp.Host;

interface

uses
  Winapi.Windows,
  Npp.Api;

type
  // Transport used by the host wrapper. Tests can inject a deterministic
  // function without creating a Notepad++ window.
  TNppHostTransport = function(Handle: HWND; Msg: UINT; WParam: WPARAM;
    LParam: LPARAM): LRESULT;
  TNppHostPostTransport = function(Handle: HWND; Msg: UINT; WParam: WPARAM;
    LParam: LPARAM): Boolean;

  TNppHost = class
  private
    FData: TNppData;
    FTransport: TNppHostTransport;
    FPostTransport: TNppHostPostTransport;
    procedure SetTransport(const Value: TNppHostTransport);
    procedure SetPostTransport(const Value: TNppHostPostTransport);
  public
    constructor Create(const AData: TNppData;
      const ATransport: TNppHostTransport = nil;
      const APostTransport: TNppHostPostTransport = nil);

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

    property Data: TNppData read FData write FData;
    property Transport: TNppHostTransport read FTransport write SetTransport;
    property PostTransport: TNppHostPostTransport read FPostTransport
      write SetPostTransport;
  end;

function NppDefaultHostTransport(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
function NppDefaultHostPostTransport(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): Boolean;

implementation

function NppDefaultHostTransport(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  Result := Winapi.Windows.SendMessage(Handle, Msg, WParam, LParam);
end;

function NppDefaultHostPostTransport(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): Boolean;
begin
  Result := Winapi.Windows.PostMessage(Handle, Msg, WParam, LParam);
end;

constructor TNppHost.Create(const AData: TNppData;
  const ATransport: TNppHostTransport;
  const APostTransport: TNppHostPostTransport);
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
end;

procedure TNppHost.SetTransport(const Value: TNppHostTransport);
begin
  if Assigned(Value) then
    FTransport := Value
  else
    FTransport := NppDefaultHostTransport;
end;

procedure TNppHost.SetPostTransport(const Value: TNppHostPostTransport);
begin
  if Assigned(Value) then
    FPostTransport := Value
  else
    FPostTransport := NppDefaultHostPostTransport;
end;

function TNppHost.Send(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  if not Assigned(FTransport) then
    Exit(0);
  Result := FTransport(Handle, Msg, WParam, LParam);
end;

function TNppHost.Post(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): Boolean;
begin
  if not Assigned(FPostTransport) then
    Exit(False);
  Result := FPostTransport(Handle, Msg, WParam, LParam);
end;

function TNppHost.SendNpp(Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  Result := Send(FData.NppHandle, Msg, WParam, LParam);
end;

function TNppHost.PostNpp(Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): Boolean;
begin
  Result := Post(FData.NppHandle, Msg, WParam, LParam);
end;

function TNppHost.SendMainScintilla(Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  Result := Send(FData.ScintillaMainHandle, Msg, WParam, LParam);
end;

function TNppHost.SendSecondScintilla(Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  Result := Send(FData.ScintillaSecondHandle, Msg, WParam, LParam);
end;

end.
