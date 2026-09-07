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
    function GetToolbarHandle: HWND; override;
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

function TTestPlugin.GetToolbarHandle: HWND;
begin
  Result := HWND(1);
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
  Ids: TArray<string>;
  Layout: TNppToolbarLayout;
  WasLegacy: Boolean;
  Plugin: TTestPlugin;
  Menu: TNppPluginMenu;
  Toolbar: TNppPluginToolbar;
  Provider: TIconProvider;
  Data: TNppData;
begin
  Check(TNppPluginToolbar.IsConfigurationValid('', 0),
    'An empty toolbar must accept an empty configuration');
  Check(TNppPluginToolbar.IsConfigurationValid('2:1;0:0;1:1;', 3),
    'A reordered configuration should be valid');
  Check(TNppPluginToolbar.IsConfigurationValid('0:1;1:0;2:1;', 3),
    'The default configuration should be valid');

  Check(not TNppPluginToolbar.IsConfigurationValid('0:1;', 3),
    'A configuration with missing buttons must be rejected');
  Check(not TNppPluginToolbar.IsConfigurationValid('0:1;0:0;1:1;', 3),
    'Duplicate button indexes must be rejected');
  Check(not TNppPluginToolbar.IsConfigurationValid('0:1;1:0;3:1;', 3),
    'Out-of-range button indexes must be rejected');
  Check(not TNppPluginToolbar.IsConfigurationValid('0:2;1:0;2:1;', 3),
    'Visibility values other than 0 or 1 must be rejected');
  Check(not TNppPluginToolbar.IsConfigurationValid('0;1:0;2:1;', 3),
    'Malformed configuration entries must be rejected');
  Check(not TNppPluginToolbar.IsConfigurationValid('0:1;', 0),
    'A non-empty configuration must be rejected for an empty toolbar');
  Check(not TNppPluginToolbar.IsConfigurationValid(';', 0),
    'Separator-only configuration must be rejected for an empty toolbar');
  Check(not TNppPluginToolbar.IsConfigurationValid('', -1),
    'Negative button counts must be rejected');

  Check(TNppPluginToolbar.IsConfigurationValid(
    'v2|run:1;compile:0;upload:1;', 3),
    'A stable-ID configuration should be valid');
  Check(not TNppPluginToolbar.IsConfigurationValid(
    'v2|run:1;run:0;upload:1;', 3),
    'Duplicate stable IDs must be rejected');

  Ids := ['run', 'compile', 'upload'];
  Check(TNppToolbarLayout.TryParse('2:1;0:0;1:1;', Ids,
    Layout, WasLegacy), 'Legacy layout import failed');
  try
    Check(WasLegacy, 'Legacy layout was not identified');
    Check(Layout.Serialize = 'v2|upload:1;run:0;compile:1;',
      'Legacy order was not converted to stable IDs');
    Layout.Move(2, 0);
    Layout.SetVisible(0, False);
    Check(Layout.Serialize = 'v2|compile:0;upload:1;run:0;',
      'Layout move/visibility operations failed');
  finally
    Layout.Free;
  end;

  Ids := ['run', 'compile', 'new-command'];
  Check(TNppToolbarLayout.TryParse(
    'v2|removed-command:0;compile:0;run:1;', Ids,
    Layout, WasLegacy), 'Stable layout merge failed');
  try
    Check(not WasLegacy, 'Stable layout was incorrectly marked legacy');
    Check(Layout.Serialize = 'v2|compile:0;run:1;new-command:1;',
      'Removed/new commands were not merged correctly');
  finally
    Layout.Free;
  end;

  // A host that keeps reporting the button but refuses TB_DELETEBUTTON used
  // to make Refresh loop forever. It must now stop after the failed delete.
  Plugin := TTestPlugin.Create;
  try
    FillChar(Data, SizeOf(Data), 0);
    Data.NppHandle := HWND(101);
    Plugin.SetInfo(Data);
    Plugin.Host.Transport := MockTransport;
    Menu := TNppPluginMenu.Create(Plugin);
    try
      Menu.AddCommand('run', 'Run', DummyCommand);
      Menu.FunctionItem('run')^.CmdID := 100;
      Provider := TIconProvider.Create;
      try
        Toolbar := TNppPluginToolbar.Create(Plugin, Menu,
          Provider.CreateIcons);
        try
          Toolbar.Initialize;
          DeleteCalls := 0;
          Toolbar.Refresh;
          Check(DeleteCalls = 1,
            'Refresh retried a failed native button deletion');
        finally
          Toolbar.Free;
        end;
      finally
        Provider.Free;
      end;
    finally
      Menu.Free;
    end;
  finally
    Plugin.Free;
  end;
end;

begin
  try
    RunTests;
    Writeln('TNppPluginToolbar configuration checks passed for ',
      SizeOf(Pointer) * 8, '-bit.');
  except
    on E: Exception do
    begin
      Writeln(ErrOutput, E.ClassName, ': ', E.Message);
      Halt(1);
    end;
  end;
end.
