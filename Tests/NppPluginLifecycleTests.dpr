program NppPluginLifecycleTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Npp.Api in '..\Lib\Npp.Api.pas',
  Npp.Scintilla.Api in '..\Lib\Npp.Scintilla.Api.pas',
  Npp.MenuCmdID in '..\Lib\Npp.MenuCmdID.pas',
  FileVersionInfo in '..\Lib\FileVersionInfo.pas',
  Npp.Plugin in '..\Lib\Npp.Plugin.pas';

type
  TTestPlugin = class(TNppPlugin)
  private
    FNotificationWasVisible: Boolean;
    FShutdownCalls: Integer;
  protected
    procedure DoNppnFileSaved; override;
    procedure DoNppnShutdown; override;
  public
    property NotificationWasVisible: Boolean read FNotificationWasVisible;
    property ShutdownCalls: Integer read FShutdownCalls;
  end;

procedure TTestPlugin.DoNppnFileSaved;
begin
  FNotificationWasVisible := Assigned(SCNotification);
end;

procedure TTestPlugin.DoNppnShutdown;
begin
  Inc(FShutdownCalls);
end;

procedure Check(const Condition: Boolean; const MessageText: string);
begin
  if not Condition then
    raise Exception.Create(MessageText);
end;

procedure RunTests;
var
  Plugin: TTestPlugin;
  Notification: TSCNotification;
  FuncCount: Integer;
begin
  Plugin := TTestPlugin.Create;
  try
    Check(Plugin.GetFuncsArray(FuncCount) = nil,
      'An empty command table must return nil');
    Check(FuncCount = 0, 'An empty command table must have zero elements');

    FillChar(Notification, SizeOf(Notification), 0);
    Notification.nmhdr.code := NPPN_FILESAVED;
    Plugin.BeNotified(@Notification);
    Check(Plugin.NotificationWasVisible,
      'The current notification must be visible inside its callback');
    Check(Plugin.SCNotification = nil,
      'The host-owned notification pointer must be cleared after the callback');

    Notification.nmhdr.code := NPPN_SHUTDOWN;
    Plugin.BeNotified(@Notification);
    Plugin.BeNotified(@Notification);
    Plugin.Shutdown;
    Check(Plugin.ShutdownCalls = 1, 'Shutdown must be idempotent');
    Check(Plugin.IsShuttingDown, 'Shutdown state was not recorded');
    Check(Plugin.IsShutdownComplete, 'Shutdown did not complete');

    Plugin.BeNotified(nil);
  finally
    Plugin.Free;
  end;
end;

begin
  try
    RunTests;
    Writeln('TNppPlugin lifecycle checks passed for ',
      SizeOf(Pointer) * 8, '-bit.');
  except
    on E: Exception do
    begin
      Writeln(ErrOutput, E.ClassName, ': ', E.Message);
      Halt(1);
    end;
  end;
end.
