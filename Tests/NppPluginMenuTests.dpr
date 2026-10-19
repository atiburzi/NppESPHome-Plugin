program NppPluginMenuTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Winapi.Windows,
  Npp.Api in '..\Lib\Npp.Api.pas',
  Npp.Scintilla.Api in '..\Lib\Npp.Scintilla.Api.pas',
  Npp.MenuCmdID in '..\Lib\Npp.MenuCmdID.pas',
  FileVersionInfo in '..\Lib\FileVersionInfo.pas',
  Npp.Plugin in '..\Lib\Npp.Plugin.pas',
  Npp.Commands in '..\Lib\Npp.Commands.pas';

type
  TTestPlugin = class(TNppPlugin)
  end;

  TMenuObserver = class
  public
    Calls: Integer;
    LastId: string;
    LastEnabled: Boolean;
    procedure EnabledChanged(const Id: string; Enabled: Boolean);
  end;

procedure DummyCommand; cdecl;
begin
end;

procedure TMenuObserver.EnabledChanged(const Id: string; Enabled: Boolean);
begin
  Inc(Calls);
  LastId := Id;
  LastEnabled := Enabled;
end;

procedure Check(const Condition: Boolean; const MessageText: string);
begin
  if not Condition then
    raise Exception.Create(MessageText);
end;

procedure ExpectDuplicate(TryAdd: TProc);
begin
  try
    TryAdd;
  except
    on E: EArgumentException do
      Exit;
  end;
  raise Exception.Create('Duplicate menu identifier was accepted');
end;

procedure CheckNativeSeparatorMetadata;
var
  Data: TNppData;
  HostWindow: HWND;
  NativeMenu: HMENU;
  Plugin: TTestPlugin;
  Menu: TNppCommands;
  Item: PFuncItem;
begin
  HostWindow := CreateWindowEx(0, 'STATIC', 'TNppCommands test host',
    WS_OVERLAPPED, 0, 0, 100, 100, 0, 0, HInstance, nil);
  Check(HostWindow <> 0, 'Test host window could not be created');
  NativeMenu := CreateMenu;
  try
    Check(NativeMenu <> 0, 'Test menu could not be created');
    Check(SetMenu(HostWindow, NativeMenu),
      'Test menu could not be attached to the host window');
    Plugin := TTestPlugin.Create;
    try
      FillChar(Data, SizeOf(Data), 0);
      Data.NppHandle := HostWindow;
      Plugin.SetInfo(Data);
      Menu := Plugin.Commands;

      Menu.AddCommand('hyphen', '- Real command', DummyCommand);
      Item := Menu.FunctionItem('hyphen');
      Item^.CmdID := 41001;
      Check(AppendMenu(NativeMenu, MF_STRING, Item^.CmdID,
        '- Real command'), 'Regular test command could not be appended');

      Menu.AddSeparator('separator');
      Item := Menu.FunctionItem('separator');
      Item^.CmdID := 41002;
      Check(AppendMenu(NativeMenu, MF_STRING, Item^.CmdID, '-'),
        'Separator placeholder could not be appended');

      Menu.ApplySeparators;
      Check((GetMenuState(NativeMenu, 41001, MF_BYCOMMAND) and
        MF_SEPARATOR) = 0,
        'A regular hyphen-prefixed caption became a separator');
      Check((GetMenuState(NativeMenu, 41002, MF_BYCOMMAND) and
        MF_SEPARATOR) <> 0,
        'Separator metadata was not applied to the native menu');
    finally
      Plugin.Free;
    end;
  finally
    SetMenu(HostWindow, 0);
    if NativeMenu <> 0 then
      DestroyMenu(NativeMenu);
    DestroyWindow(HostWindow);
  end;
end;

procedure RunTest;
var
  Plugin: TTestPlugin;
  Menu: TNppCommands;
  FuncCount: Integer;
  FuncItem: PFuncItem;
  Observer: TMenuObserver;
begin
  Plugin := TTestPlugin.Create;
  try
    Plugin.PluginName := 'Menu test';
    Menu := Plugin.Commands;
    Observer := TMenuObserver.Create;
    Menu.OnEnabledChanged := Observer.EnabledChanged;
    try
      Check(Menu.AddCommand('first', 'First command', DummyCommand) = 0,
        'First command index is incorrect');
      Check(Menu.AddSeparator = 1, 'Separator index is incorrect');
      Check(Menu.AddCommand('second', 'Second command', DummyCommand) = 2,
        'Second command index is incorrect');
      Check(Menu.Count = 3, 'Menu count is incorrect');
      Check(Menu.IndexOf('FIRST') = 0, 'Menu lookup must be case-insensitive');
      Check(Menu.IdFromIndex(1) = 'Sep$1', 'Separator identifier is incorrect');
      Check(Menu.Entries[1].IsSeparator, 'Separator kind was not recorded');
      Check(Menu.CommandId('missing') = -1, 'Unknown command must return -1');

      ExpectDuplicate(
        procedure
        begin
          Menu.AddCommand('FIRST', 'Duplicate', DummyCommand);
        end);

      Menu.SetCaption('first', 'Updated command');
      FuncItem := Menu.FunctionItem('first');
      Check(Assigned(FuncItem), 'Function lookup failed');
      Check(string(PWideChar(@FuncItem^.ItemName[0])) = 'Updated command',
        'Caption update did not reach the ABI record');
      Menu.SetChecked('first', True, False);
      Check(Menu.IsChecked('first'), 'Checked state was not retained');
      Menu.SetEnabled('first', False);
      Check(not Menu.IsEnabled('first'), 'Enabled state was not retained');
      Check((Observer.Calls = 1) and (Observer.LastId = 'first') and
        not Observer.LastEnabled,
        'Enabled-state notification was not raised');

      try
        Menu.AddCommand('invalid:id', 'Invalid', DummyCommand);
        raise Exception.Create('Reserved identifier character was accepted');
      except
        on E: EArgumentException do
          ;
      end;

      Check(Plugin.GetFuncsArray(FuncCount) <> nil, 'Function table is nil');
      Check(FuncCount = 3, 'Function table count is incorrect');
      Check(Menu.GetFuncsArray(FuncCount) = Plugin.GetFuncsArray(FuncCount),
        'TNppPlugin did not expose the command-owned ABI table');
    finally
      Menu.OnEnabledChanged := nil;
      Observer.Free;
    end;
  finally
    Plugin.Free;
  end;
end;

begin
  try
    RunTest;
    CheckNativeSeparatorMetadata;
    Writeln('TNppCommands checks passed for ', SizeOf(Pointer) * 8, '-bit.');
  except
    on E: Exception do
    begin
      Writeln(ErrOutput, E.ClassName, ': ', E.Message);
      Halt(1);
    end;
  end;
end.
