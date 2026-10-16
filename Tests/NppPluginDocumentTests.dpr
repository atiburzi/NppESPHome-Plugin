program NppPluginDocumentTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Types,
  Winapi.Windows,
  Npp.Api in '..\Lib\Npp.Api.pas',
  Npp.Scintilla.Api in '..\Lib\Npp.Scintilla.Api.pas',
  FileVersionInfo in '..\Lib\FileVersionInfo.pas',
  Npp.Plugin in '..\Lib\Npp.Plugin.pas',
  Npp.Commands in '..\Lib\Npp.Commands.pas',
  Npp.Toolbar in '..\Lib\Npp.Toolbar.pas';

type
  TTestPlugin = class(TNppPlugin)
  end;

const
  TestNppHandle = HWND(101);
  TestMainHandle = HWND(201);
  TestSecondHandle = HWND(202);

var
  InvalidViewCalls: Integer;
  DarkColorCalls: Integer;
  OpenCalls: Integer;
  SwitchCalls: Integer;
  ReadOnlyCalls: Integer;
  LastReadOnlyHandle: HWND;

procedure Check(const Condition: Boolean; const MessageText: string);
begin
  if not Condition then
    raise Exception.Create(MessageText);
end;

function PathForBuffer(const BufferId: NativeInt): string;
begin
  case BufferId of
    1000: Result := 'C:\main-0.yaml';
    1001: Result := 'C:\main-1.yaml';
    2000: Result := 'C:\second-0.yaml';
  else
    Result := '';
  end;
end;

function MockTransport(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
var
  BufferId: NativeInt;
  FileName: string;
begin
  Result := 0;
  if (Handle = TestMainHandle) and (Msg = SCI_SETREADONLY) then
  begin
    Inc(ReadOnlyCalls);
    LastReadOnlyHandle := Handle;
    Exit(1);
  end;

  case Msg of
    NPPM_GETNPPVERSION:
      Result := LRESULT((8 shl 16) or 540);
    NPPM_ISDARKMODEENABLED:
      Result := 1;
    NPPM_GETDARKMODECOLORS:
      begin
        Inc(DarkColorCalls);
        Result := 1;
      end;
    NPPM_GETNBOPENFILES:
      case Integer(LParam) of
        Npp.Api.PRIMARY_VIEW: Result := 2;
        Npp.Api.SECOND_VIEW: Result := 1;
      end;
    NPPM_GETBUFFERIDFROMPOS:
      case Integer(LParam) of
        Npp.Api.MAIN_VIEW: Result := 1000 + Integer(WParam);
        Npp.Api.SUB_VIEW: Result := 2000 + Integer(WParam);
      else
        Inc(InvalidViewCalls);
      end;
    NPPM_GETFULLPATHFROMBUFFERID:
      begin
        BufferId := NativeInt(WParam);
        FileName := PathForBuffer(BufferId);
        if LParam = 0 then
          Exit(Length(FileName));
        if FileName <> '' then
          Move(PChar(FileName)^, PChar(LParam)^,
            (Length(FileName) + 1) * SizeOf(Char));
        Result := Length(FileName);
      end;
    NPPM_SWITCHTOFILE:
      begin
        Inc(SwitchCalls);
        Result := 1;
      end;
    NPPM_DOOPEN:
      begin
        Inc(OpenCalls);
        Result := 1;
      end;
    NPPM_GETCURRENTSCINTILLA:
      begin
        PInteger(LParam)^ := Npp.Api.MAIN_VIEW;
        Result := 1;
      end;
  end;
end;

procedure CheckOpenFiles(Plugin: TTestPlugin);
var
  DisplayPath: string;
  Files: TStringDynArray;
begin
  Files := Plugin.GetOpenFiles(Npp.Api.PRIMARY_VIEW);
  Check((Length(Files) = 2) and (Files[0] = 'C:\main-0.yaml') and
    (Files[1] = 'C:\main-1.yaml'),
    'Primary-view enumeration used the wrong view constants');

  Files := Plugin.GetOpenFiles(Npp.Api.SECOND_VIEW);
  DisplayPath := '<none>';
  if Length(Files) > 0 then
    DisplayPath := Files[0];
  Check((Length(Files) = 1) and (Files[0] = 'C:\second-0.yaml'),
    Format('Second-view enumeration returned %d file(s): %s',
      [Length(Files), DisplayPath]));

  Files := Plugin.GetOpenFiles(Npp.Api.ALL_OPEN_FILES);
  Check((Length(Files) = 3) and (Files[2] = 'C:\second-0.yaml'),
    'All-files enumeration did not combine both views');
  Check(InvalidViewCalls = 0,
    'File enumeration sent a count-scope value as a view index');
end;

procedure RunTests;
var
  Data: TNppData;
  Plugin: TTestPlugin;
begin
  Plugin := TTestPlugin.Create;
  try
    FillChar(Data, SizeOf(Data), 0);
    Data.NppHandle := TestNppHandle;
    Data.ScintillaMainHandle := TestMainHandle;
    Data.ScintillaSecondHandle := TestSecondHandle;
    Plugin.SetInfo(Data);
    Plugin.Host.Transport := MockTransport;

    CheckOpenFiles(Plugin);

    DarkColorCalls := 0;
    Check(not Plugin.GetDarkModeColors(nil),
      'A nil dark-mode color destination was accepted');
    Check(DarkColorCalls = 0,
      'The host received a dark-mode color request with a nil destination');

    Check(Plugin.OpenFile('C:\main-0.yaml', True),
      'An already-open file was not activated');
    Check((SwitchCalls = 1) and (OpenCalls = 0),
      'An already-open file was opened again');
    Check((ReadOnlyCalls = 1) and (LastReadOnlyHandle = TestMainHandle),
      'Read-only state was not applied to an already-open file');

    Check(Plugin.OpenFile('C:\new.yaml', True),
      'A new file was not opened');
    Check((OpenCalls = 1) and (ReadOnlyCalls = 2),
      'Read-only state was not applied after opening a new file');
  finally
    Plugin.Free;
  end;
end;

begin
  try
    RunTests;
    Writeln('TNppPlugin document checks passed for ',
      SizeOf(Pointer) * 8, '-bit.');
  except
    on E: Exception do
    begin
      Writeln(ErrOutput, E.ClassName, ': ', E.Message);
      Halt(1);
    end;
  end;
end.
