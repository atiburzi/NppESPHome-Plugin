program NppHostTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Winapi.Windows,
  Npp.Api in '..\Lib\Npp.Api.pas',
  Npp.MenuCmdID in '..\Lib\Npp.MenuCmdID.pas',
  Npp.Scintilla.Api in '..\Lib\Npp.Scintilla.Api.pas',
  FileVersionInfo in '..\Lib\FileVersionInfo.pas',
  Npp.Host in '..\Lib\Npp.Host.pas',
  Npp.Plugin in '..\Lib\Npp.Plugin.pas';

var
  MockCalls: Integer;
  MockPostCalls: Integer;
  LastHandle: HWND;

function MockTransport(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  Inc(MockCalls);
  LastHandle := Handle;
  if Msg = NPPM_GETNPPVERSION then
    Result := LRESULT((8 shl 16) or 500)
  else
    Result := 0;
end;

function MockPostTransport(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): Boolean;
begin
  Inc(MockPostCalls);
  LastHandle := Handle;
  Result := True;
end;

procedure Check(const Condition: Boolean; const MessageText: string);
begin
  if not Condition then
    raise Exception.Create(MessageText);
end;

procedure Run;
var
  Data: TNppData;
  Host: TNppHost;
  Plugin: TNppPlugin;
  Major, Minor: Integer;
begin
  FillChar(Data, SizeOf(Data), 0);
  Data.NppHandle := HWND(101);
  Data.ScintillaMainHandle := HWND(102);
  Data.ScintillaSecondHandle := HWND(103);
  Host := TNppHost.Create(Data, MockTransport, MockPostTransport);
  try
    Check(Host.SendNpp(NPPM_GETNPPVERSION) =
      LRESULT((8 shl 16) or 500),
      'Injected host transport was not called');
    Check(LastHandle = Data.NppHandle,
      'SendNpp did not use the Notepad++ handle');
    Host.SendMainScintilla(1);
    Check(LastHandle = Data.ScintillaMainHandle,
      'SendMainScintilla used the wrong handle');
    Host.SendSecondScintilla(1);
    Check(LastHandle = Data.ScintillaSecondHandle,
      'SendSecondScintilla used the wrong handle');
    Check(Host.PostNpp(1), 'Injected post transport failed');
    Check((MockPostCalls = 1) and (LastHandle = Data.NppHandle),
      'PostNpp did not use the injectable post transport');
  finally
    Host.Free;
  end;

  Plugin := TNppPlugin.Create;
  try
    Plugin.Host.Transport := MockTransport;
    Plugin.Host.PostTransport := MockPostTransport;
    Plugin.SetInfo(Data);
    Plugin.GetNppVersion(Major, Minor);
    Check((Major = 8) and (Minor = 500),
      'TNppPlugin did not route version queries through Npp.Host');
    Check(MockCalls = 4, 'Unexpected host transport call count');
  finally
    Plugin.Free;
  end;
end;

begin
  try
    Run;
    Writeln('Npp.Host injection checks passed for ', SizeOf(Pointer) * 8, '-bit.');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
