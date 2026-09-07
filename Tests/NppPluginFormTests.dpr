program NppPluginFormTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Forms,
  Npp.Api in '..\Lib\Npp.Api.pas',
  Npp.Scintilla.Api in '..\Lib\Npp.Scintilla.Api.pas',
  Npp.MenuCmdID in '..\Lib\Npp.MenuCmdID.pas',
  FileVersionInfo in '..\Lib\FileVersionInfo.pas',
  Npp.Plugin in '..\Lib\Npp.Plugin.pas',
  Npp.Vcl.Forms in '..\Lib\Npp.Vcl.Forms.pas',
  Npp.Vcl.Docking in '..\Lib\Npp.Vcl.Docking.pas';

type
  TTestPlugin = class(TNppPlugin);

  TTestForm = class(TNppPluginForm)
  end;

  TTestDocking = class(TNppPluginDocking)
  end;

{$R NppPluginFormTests.dfm}
{$R NppPluginDockingTest.dfm}

function FormHostTransport(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  case Msg of
    NPPM_GETNPPVERSION:
      Result := LRESULT((8 shl 16) or 60);
    NPPM_ISDARKMODEENABLED:
      Result := 0;
  else
    Result := 1;
  end;
end;

procedure Check(const Condition: Boolean; const MessageText: string);
begin
  if not Condition then
    raise Exception.Create(MessageText);
end;

procedure CheckNilArguments;
var
  Raised: Boolean;
begin
  Raised := False;
  try
    TNppPluginForm.Create(TNppPlugin(nil));
  except
    on E: EArgumentNilException do
      Raised := True;
  end;
  Check(Raised, 'TNppPluginForm must reject a nil plugin');

  Raised := False;
  try
    TNppPluginDocking.Create(TNppPlugin(nil), 0);
  except
    on E: EArgumentNilException do
      Raised := True;
  end;
  Check(Raised, 'TNppPluginDocking must reject a nil plugin');
end;

procedure RunTests;
var
  Plugin: TTestPlugin;
  NppData: TNppData;
  Form: TTestForm;
  Docking: TTestDocking;
  ChildMessage: TMessage;
  PreviousApplicationHandle: HWND;
begin
  CheckNilArguments;

  Plugin := TTestPlugin.Create;
  try
    FillChar(NppData, SizeOf(NppData), 0);
    // A real window handle is enough for the host-message guards; the desktop
    // window safely ignores the Notepad++-specific messages used by this test.
    NppData.NppHandle := GetDesktopWindow;
    Plugin.SetInfo(NppData);
    Plugin.Host.Transport := FormHostTransport;
    PreviousApplicationHandle := Application.Handle;

    Form := TTestForm.Create(Plugin);
    try
      Check(Application.Handle = NppData.NppHandle,
        'VCL application was not attached by the optional forms layer');
      Check(Form.ParentPlugin = Plugin, 'Normal form lost its parent plugin');
      Check(Form.DefaultCloseAction = caNone,
        'Normal form default close action is incorrect');
      FillChar(ChildMessage, SizeOf(ChildMessage), 0);
      Check(not Form.WantChildKey(nil, ChildMessage),
        'WantChildKey must reject a nil child');
    finally
      Form.Free;
    end;
    Check(Application.Handle = PreviousApplicationHandle,
      'VCL application handle was not restored after the last form');

    Docking := TTestDocking.Create(Plugin, 0);
    try
      Check(Application.Handle = NppData.NppHandle,
        'Docking form did not attach the VCL application');
      Check(Docking.DlgID = 0, 'Docking dialog id was not preserved');
      Check(Docking.IsDockingRegistered,
        'Docking form did not complete host registration');
      Docking.UpdateDisplayInfo('hostless test');
      Docking.Hide;
      Docking.Show;
    finally
      Docking.Free;
    end;
    Check(Application.Handle = PreviousApplicationHandle,
      'Docking form did not restore the VCL application handle');

  finally
    Plugin.Free;
  end;
end;

begin
  try
    Application.Initialize;
    RunTests;
    Writeln('TNppPlugin form and docking checks passed for ',
      SizeOf(Pointer) * 8, '-bit.');
  except
    on E: Exception do
    begin
      Writeln(ErrOutput, E.ClassName, ': ', E.Message);
      Halt(1);
    end;
  end;
end.
