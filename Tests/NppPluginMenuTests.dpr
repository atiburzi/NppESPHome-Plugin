program NppPluginMenuTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
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

procedure RunTest;
var
  Plugin: TTestPlugin;
  Menu: TNppPluginMenu;
  FuncCount: Integer;
  FuncItem: PFuncItem;
  Observer: TMenuObserver;
begin
  Plugin := TTestPlugin.Create;
  try
    Plugin.PluginName := 'Menu test';
    Menu := TNppPluginMenu.Create(Plugin);
    try
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
      finally
        Menu.OnEnabledChanged := nil;
        Observer.Free;
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
    RunTest;
    Writeln('TNppPluginMenu checks passed for ', SizeOf(Pointer) * 8, '-bit.');
  except
    on E: Exception do
    begin
      Writeln(ErrOutput, E.ClassName, ': ', E.Message);
      Halt(1);
    end;
  end;
end.
