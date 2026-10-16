program NppPluginToolbarConfigTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Winapi.Windows,
  Winapi.CommCtrl,
  Npp.Api in '..\Lib\Npp.Api.pas',
  Npp.Scintilla.Api in '..\Lib\Npp.Scintilla.Api.pas',
  Npp.MenuCmdID in '..\Lib\Npp.MenuCmdID.pas',
  FileVersionInfo in '..\Lib\FileVersionInfo.pas',
  Npp.Plugin in '..\Lib\Npp.Plugin.pas',
  Npp.Commands in '..\Lib\Npp.Commands.pas',
  Npp.Toolbar in '..\Lib\Npp.Toolbar.pas';

type
  TTestPlugin = class(TNppPlugin)
  public
    procedure SetupToolbar(const IconProvider: TNppToolbarIconProvider);
  end;

  TIconProvider = class
  public
    function CreateIcons(const Entry: TNppMenuEntry;
      out IconData: TToolbarIconsWithDarkMode): Boolean;
  end;

var
  DeleteCalls: Integer;

procedure DummyCommand; cdecl;
begin
end;

function MockToolbarHandle(NppHandle: HWND): HWND;
begin
  Result := HWND(1);
end;

procedure TTestPlugin.SetupToolbar(
  const IconProvider: TNppToolbarIconProvider);
begin
  ConfigureToolbar(IconProvider);
end;

function TIconProvider.CreateIcons(const Entry: TNppMenuEntry;
  out IconData: TToolbarIconsWithDarkMode): Boolean;
begin
  FillChar(IconData, SizeOf(IconData), 0);
  Result := True;
end;

function MockTransport(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  case Msg of
    NPPM_GETNPPVERSION:
      Result := LRESULT((8 shl 16) or 500);
    TB_BUTTONCOUNT:
      Result := 1;
    TB_COMMANDTOINDEX:
      Result := 0;
    TB_DELETEBUTTON:
      begin
        Inc(DeleteCalls);
        Result := 0;
      end;
  else
    Result := 0;
  end;
end;

procedure Check(const Condition: Boolean; const MessageText: string);
begin
  if not Condition then
    raise Exception.Create(MessageText);
end;

procedure RunTests;
var
  Layout: TNppToolbarLayout;
  Plugin: TTestPlugin;
  Menu: TNppCommands;
  Toolbar: TNppToolbar;
  Provider: TIconProvider;
  Data: TNppData;
  Notification: TSCNotification;
  Button: TNppToolbarButton;
  SavedConfiguration: string;
begin
  Check(TNppToolbar.IsConfigurationValid(''),
    'An empty toolbar must accept an empty configuration');
  Check(TNppToolbar.IsConfigurationValid(
    'run:1;compile:0;upload:1;'),
    'A stable-ID configuration should be valid');
  Check(not TNppToolbar.IsConfigurationValid(
    'v2|run:1;compile:0;upload:1;'),
    'The removed v2 prefix must be rejected');
  Check(not TNppToolbar.IsConfigurationValid(
    'run:1;run:0;upload:1;'),
    'Duplicate stable IDs must be rejected');
  Check(not TNppToolbar.IsConfigurationValid(
    'run:2;compile:0;upload:1;'),
    'Visibility values other than 0 or 1 must be rejected');
  Check(not TNppToolbar.IsConfigurationValid('run;compile:0;'),
    'Malformed configuration entries must be rejected');
  Check(not TNppToolbar.IsConfigurationValid('run:1'),
    'A non-canonical configuration without trailing separator was accepted');
  Check(not TNppToolbar.IsConfigurationValid(';'),
    'Separator-only configuration must be rejected for an empty toolbar');

  Check(TNppToolbarLayout.TryParse(
    'upload:1;run:0;compile:1;', Layout),
    'Stable-ID layout parsing failed');
  try
    Check(Layout.Serialize = 'upload:1;run:0;compile:1;',
      'Serialization unexpectedly changed the current format');
    Layout.Move(2, 0);
    Layout.SetVisible(0, False);
    Check(Layout.Serialize = 'compile:0;upload:1;run:0;',
      'Layout move/visibility operations failed');
  finally
    Layout.Free;
  end;

  // A host that keeps reporting the button but refuses TB_DELETEBUTTON used
  // to make Refresh loop forever. It must now stop after the failed delete.
  Provider := TIconProvider.Create;
  try
    Plugin := TTestPlugin.Create;
    try
      Check(Assigned(Plugin.Commands),
        'The plugin must always own a command registry');
      Check(not Assigned(Plugin.Toolbar),
        'The toolbar must remain optional until configured');
      FillChar(Data, SizeOf(Data), 0);
      Data.NppHandle := HWND(101);
      Plugin.SetInfo(Data);
      Plugin.Host.Transport := MockTransport;
      Plugin.Host.ToolbarHandleResolver := MockToolbarHandle;
      Menu := Plugin.Commands;
      Menu.AddCommand('run', 'Run', DummyCommand);
      Menu.FunctionItem('run')^.CmdID := 100;
      Menu.AddCommand('compile', 'Compile', DummyCommand);
      Menu.FunctionItem('compile')^.CmdID := 101;
      Menu.AddCommand('new-command', 'New command', DummyCommand);
      Menu.FunctionItem('new-command')^.CmdID := 102;
      Plugin.SetupToolbar(Provider.CreateIcons);
      Toolbar := Plugin.Toolbar;
      Check(Assigned(Toolbar),
        'ConfigureToolbar did not publish the owned toolbar');
      Toolbar.ApplyConfiguration('2:1;0:0;1:1;');

      try
        Plugin.SetupToolbar(Provider.CreateIcons);
        raise Exception.Create('A second toolbar configuration was accepted');
      except
        on E: EInvalidOpException do
          ;
      end;

      FillChar(Notification, SizeOf(Notification), 0);
      Notification.nmhdr.code := NPPN_TBMODIFICATION;
      Plugin.BeNotified(@Notification);
      Check(Toolbar.ButtonCount = 3,
        'Toolbar notification did not initialize the button model');
      Check(Toolbar.GetButtonInfo(0, Button) and (Button.CommandId = 100),
        'Toolbar did not resolve CmdID directly from the command registry');
      Check(Toolbar.GetButtonInfo('RUN', Button) and
        (Button.CommandId = 100),
        'Stable-ID toolbar lookup must be case-insensitive');
      Check(not Toolbar.GetButtonInfo('missing', Button),
        'Unknown stable toolbar ID was accepted');
      Check(Toolbar.Configuration =
        'run:1;compile:1;new-command:1;',
        'The obsolete numeric format was interpreted as command indexes');

      Toolbar.ApplyConfiguration(
        'removed-command:0;compile:0;run:1;');
      Check(Toolbar.Configuration =
        'compile:0;run:1;new-command:1;',
        'Toolbar did not reconcile removed and newly available stable IDs');
      Check(Toolbar.DefaultConfiguration =
        'run:1;compile:1;new-command:1;',
        'Toolbar did not generate the default configuration');

      Layout := Toolbar.CreateLayout;
      try
        Check((Layout.Count = 3) and
          (Layout[0].ItemId = 'compile') and not Layout[0].Visible,
          'Toolbar did not expose its current in-memory layout');
      finally
        Layout.Free;
      end;

      try
        Toolbar.ApplyConfiguration('v2|run:1;');
        raise Exception.Create('A v2 configuration was accepted');
      except
        on E: EArgumentException do
          ;
      end;

      DeleteCalls := 0;
      Toolbar.Refresh;
      Check(DeleteCalls = 3,
        'Refresh retried a failed native button deletion');

      SavedConfiguration := Toolbar.Configuration;
      Toolbar.ReleaseResources;
      Check(Toolbar.ButtonCount = 0,
        'ReleaseResources left an invalid toolbar model published');
      Check(not Toolbar.GetButtonInfo('run', Button),
        'Released toolbar buttons remained accessible');
      Check(Toolbar.Configuration = SavedConfiguration,
        'ReleaseResources discarded the persistent configuration');

      Plugin.BeNotified(@Notification);
      Check((Toolbar.ButtonCount = 3) and
        (Toolbar.Configuration = SavedConfiguration),
        'Toolbar could not reinitialize from its preserved configuration');
    finally
      Plugin.Free;
    end;
  finally
    Provider.Free;
  end;
end;

begin
  try
    RunTests;
    Writeln('TNppToolbar configuration checks passed for ',
      SizeOf(Pointer) * 8, '-bit.');
  except
    on E: Exception do
    begin
      Writeln(ErrOutput, E.ClassName, ': ', E.Message);
      Halt(1);
    end;
  end;
end.
