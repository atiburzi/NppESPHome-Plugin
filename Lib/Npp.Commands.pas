// Generic Notepad++ plugin menu registry.
//
// The registry keeps stable, plugin-defined identifiers separate from the
// command indexes assigned by Notepad++.  This makes menu state and toolbar
// models independent from the concrete plugin implementation.

unit Npp.Commands;

interface

uses
  Winapi.Windows, System.SysUtils, Npp.Api, Npp.Plugin;

type
  TNppCommandEnabledChanged = procedure(const Id: string;
    Enabled: Boolean) of object;

  TNppMenuEntry = record
    Id: string;
    Index: Integer;
    IsSeparator: Boolean;
    Checked: Boolean;
    Enabled: Boolean;
  end;

  TNppPluginMenu = class
  private
    FPlugin: TNppPlugin;
    FEntries: TArray<TNppMenuEntry>;
    FOnEnabledChanged: TNppCommandEnabledChanged;
    FEnabledListeners: TArray<TNppCommandEnabledChanged>;
    function GetCount: Integer;
    function GetEntry(Index: Integer): TNppMenuEntry;
    function ShortcutText(CommandId: Integer): string;
  public
    constructor Create(APlugin: TNppPlugin);

    function AddCommand(const Id: string; const Caption: nppString;
      Callback: FuncItemCmdProc; ShortcutKey: PShortcutKey = nil;
      Checked: Boolean = False): Integer;
    function AddSeparator(const Id: string = ''): Integer;

    function IndexOf(const Id: string): Integer;
    function IdFromIndex(Index: Integer): string;
    function CommandId(const Id: string): Integer;
    function FunctionItem(const Id: string): PFuncItem;
    function Caption(const Id: string): string;
    function IsChecked(const Id: string): Boolean;
    function IsEnabled(const Id: string): Boolean;

    procedure SetCaption(const Id: string; const Caption: nppString;
      PreserveShortcut: Boolean = True);
    procedure SetChecked(const Id: string; Checked: Boolean;
      Delayed: Boolean = True);
    procedure SetEnabled(const Id: string; Enabled: Boolean);
    procedure AddEnabledListener(const Listener: TNppCommandEnabledChanged);
    procedure RemoveEnabledListener(const Listener: TNppCommandEnabledChanged);

    property Count: Integer read GetCount;
    property Entries[Index: Integer]: TNppMenuEntry read GetEntry;
    property OnEnabledChanged: TNppCommandEnabledChanged
      read FOnEnabledChanged write FOnEnabledChanged;
  end;

  // Generic name; TNppPluginMenu remains as a source-compatible name for
  // existing plugins.
  TNppCommands = TNppPluginMenu;

implementation

function SameEnabledListener(const Left,
  Right: TNppCommandEnabledChanged): Boolean;
begin
  Result := (TMethod(Left).Code = TMethod(Right).Code) and
    (TMethod(Left).Data = TMethod(Right).Data);
end;

constructor TNppPluginMenu.Create(APlugin: TNppPlugin);
begin
  if not Assigned(APlugin) then
    raise EArgumentNilException.Create('APlugin');
  inherited Create;
  FPlugin := APlugin;
end;

function TNppPluginMenu.GetCount: Integer;
begin
  Result := Length(FEntries);
end;

function TNppPluginMenu.GetEntry(Index: Integer): TNppMenuEntry;
begin
  if (Index < 0) or (Index >= Length(FEntries)) then
    raise EArgumentOutOfRangeException.CreateFmt(
      'Menu entry index %d is out of range', [Index]);
  Result := FEntries[Index];
end;

function TNppPluginMenu.IndexOf(const Id: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  if Id = '' then
    Exit;
  for I := 0 to High(FEntries) do
    if SameText(FEntries[I].Id, Id) then
      Exit(I);
end;

function TNppPluginMenu.IdFromIndex(Index: Integer): string;
begin
  Result := '';
  if (Index >= 0) and (Index < Length(FEntries)) then
    Result := FEntries[Index].Id;
end;

function TNppPluginMenu.AddCommand(const Id: string; const Caption: nppString;
  Callback: FuncItemCmdProc; ShortcutKey: PShortcutKey;
  Checked: Boolean): Integer;
begin
  if Id = '' then
    raise EArgumentException.Create('A menu command identifier is required');
  if (Pos(':', Id) > 0) or (Pos(';', Id) > 0) or (Pos('|', Id) > 0) then
    raise EArgumentException.CreateFmt(
      'Menu command identifier contains a reserved character: %s', [Id]);
  if IndexOf(Id) >= 0 then
    raise EArgumentException.CreateFmt(
      'Duplicate menu command identifier: %s', [Id]);
  if not Assigned(Callback) then
    raise EArgumentException.CreateFmt(
      'Menu command %s must provide a callback', [Id]);

  Result := FPlugin.RegisterFuncItem(Caption, Callback, ShortcutKey, Checked);
  SetLength(FEntries, Length(FEntries) + 1);
  FEntries[High(FEntries)].Id := Id;
  FEntries[High(FEntries)].Index := Result;
  FEntries[High(FEntries)].IsSeparator := False;
  FEntries[High(FEntries)].Checked := Checked;
  FEntries[High(FEntries)].Enabled := True;
end;

function TNppPluginMenu.AddSeparator(const Id: string): Integer;
var
  EntryId: string;
begin
  EntryId := Id;
  if EntryId = '' then
    EntryId := Format('Sep$%d', [Length(FEntries)]);
  if (Pos(':', EntryId) > 0) or (Pos(';', EntryId) > 0) or
     (Pos('|', EntryId) > 0) then
    raise EArgumentException.CreateFmt(
      'Menu entry identifier contains a reserved character: %s', [EntryId]);
  if IndexOf(EntryId) >= 0 then
    raise EArgumentException.CreateFmt(
      'Duplicate menu entry identifier: %s', [EntryId]);

  Result := FPlugin.RegisterFuncItem('-', nil, nil);
  SetLength(FEntries, Length(FEntries) + 1);
  FEntries[High(FEntries)].Id := EntryId;
  FEntries[High(FEntries)].Index := Result;
  FEntries[High(FEntries)].IsSeparator := True;
  FEntries[High(FEntries)].Checked := False;
  FEntries[High(FEntries)].Enabled := False;
end;

function TNppPluginMenu.CommandId(const Id: string): Integer;
var
  EntryIndex: Integer;
begin
  EntryIndex := IndexOf(Id);
  if EntryIndex < 0 then
    Exit(-1);
  Result := FPlugin.CmdIdFromMenuItemIdx(FEntries[EntryIndex].Index);
end;

function TNppPluginMenu.FunctionItem(const Id: string): PFuncItem;
var
  EntryIndex: Integer;
begin
  Result := nil;
  EntryIndex := IndexOf(Id);
  if EntryIndex >= 0 then
    Result := FPlugin.GetFuncByIndex(FEntries[EntryIndex].Index);
end;

function TNppPluginMenu.Caption(const Id: string): string;
var
  Item: PFuncItem;
begin
  Item := FunctionItem(Id);
  if Assigned(Item) then
    Result := string(Item^.ItemName)
  else
    Result := '';
end;

function TNppPluginMenu.IsChecked(const Id: string): Boolean;
var
  EntryIndex: Integer;
begin
  EntryIndex := IndexOf(Id);
  Result := (EntryIndex >= 0) and FEntries[EntryIndex].Checked;
end;

function TNppPluginMenu.IsEnabled(const Id: string): Boolean;
var
  EntryIndex: Integer;
begin
  EntryIndex := IndexOf(Id);
  Result := (EntryIndex >= 0) and FEntries[EntryIndex].Enabled;
end;

function TNppPluginMenu.ShortcutText(CommandId: Integer): string;
var
  Shortcut: TShortcutKey;
  Parts: TArray<string>;
  KeyName: array [0 .. 255] of Char;
begin
  Result := '';
  FillChar(Shortcut, SizeOf(Shortcut), 0);
  if FPlugin.Host.SendNpp(NPPM_GETSHORTCUTBYCMDID, WPARAM(CommandId),
    LPARAM(@Shortcut)) = 0 then
    Exit;
  if Shortcut.IsCtrl then
    Parts := Parts + ['Ctrl'];
  if Shortcut.IsAlt then
    Parts := Parts + ['Alt'];
  if Shortcut.IsShift then
    Parts := Parts + ['Shift'];
  if Shortcut.Key <> 0 then
    if GetKeyNameText(MapVirtualKey(Shortcut.Key, MAPVK_VK_TO_VSC) shl 16,
      KeyName, Length(KeyName)) > 0 then
      Parts := Parts + [KeyName]
    else
      Parts := Parts + [Format('VK_%d', [Shortcut.Key])];
  Result := string.Join('+', Parts);
end;

procedure TNppPluginMenu.SetCaption(const Id: string; const Caption: nppString;
  PreserveShortcut: Boolean);
var
  EntryIndex: Integer;
  Item: PFuncItem;
  PluginMenu: HMENU;
  NppHandle: HWND;
  DisplayCaption, Shortcut: string;
begin
  EntryIndex := IndexOf(Id);
  if (EntryIndex < 0) or FEntries[EntryIndex].IsSeparator then
    raise EArgumentException.CreateFmt(
      'Unknown menu command identifier: %s', [Id]);
  Item := FunctionItem(Id);
  if not Assigned(Item) then
    raise EArgumentException.CreateFmt(
      'Unknown menu command identifier: %s', [Id]);
  StringToWideChar(Caption, Item^.ItemName, Length(Item^.ItemName));
  NppHandle := FPlugin.NppData.NppHandle;
  if NppHandle = 0 then
    Exit;
  PluginMenu := HMENU(FPlugin.Host.SendNpp(NPPM_GETMENUHANDLE,
    Npp.Api.NPPPLUGINMENU, 0));
  if PluginMenu <> 0 then
  begin
    DisplayCaption := string(Caption);
    if PreserveShortcut then
    begin
      Shortcut := ShortcutText(Item^.CmdID);
      if Shortcut <> '' then
        DisplayCaption := DisplayCaption + #9 + Shortcut;
    end;
    ModifyMenu(PluginMenu, Item^.CmdID, MF_BYCOMMAND or MF_STRING,
      Item^.CmdID, PChar(DisplayCaption));
    DrawMenuBar(NppHandle);
  end;
end;

procedure TNppPluginMenu.SetChecked(const Id: string; Checked: Boolean;
  Delayed: Boolean);
var
  Item: PFuncItem;
  EntryIndex: Integer;
begin
  EntryIndex := IndexOf(Id);
  if (EntryIndex < 0) or FEntries[EntryIndex].IsSeparator then
    raise EArgumentException.CreateFmt(
      'Unknown menu command identifier: %s', [Id]);
  if FEntries[EntryIndex].Checked = Checked then
    Exit;
  Item := FPlugin.GetFuncByIndex(FEntries[EntryIndex].Index);
  if Assigned(Item) then
  begin
    Item^.Checked := Checked;
    FEntries[EntryIndex].Checked := Checked;
    FPlugin.CheckMenuItem(FEntries[EntryIndex].Index, Checked, Delayed);
  end;
end;

procedure TNppPluginMenu.SetEnabled(const Id: string; Enabled: Boolean);
var
  EntryIndex, I: Integer;
begin
  EntryIndex := IndexOf(Id);
  if (EntryIndex < 0) or FEntries[EntryIndex].IsSeparator then
    raise EArgumentException.CreateFmt(
      'Unknown menu command identifier: %s', [Id]);
  if FEntries[EntryIndex].Enabled = Enabled then
    Exit;
  FEntries[EntryIndex].Enabled := Enabled;
  FPlugin.EnableMenuItem(FEntries[EntryIndex].Index, Enabled);
  if Assigned(FOnEnabledChanged) then
    FOnEnabledChanged(Id, Enabled);
  for I := 0 to High(FEnabledListeners) do
    if Assigned(FEnabledListeners[I]) then
      FEnabledListeners[I](Id, Enabled);
end;

procedure TNppPluginMenu.AddEnabledListener(
  const Listener: TNppCommandEnabledChanged);
var
  I: Integer;
begin
  if not Assigned(Listener) then
    Exit;
  for I := 0 to High(FEnabledListeners) do
    if SameEnabledListener(FEnabledListeners[I], Listener) then
      Exit;
  SetLength(FEnabledListeners, Length(FEnabledListeners) + 1);
  FEnabledListeners[High(FEnabledListeners)] := Listener;
end;

procedure TNppPluginMenu.RemoveEnabledListener(
  const Listener: TNppCommandEnabledChanged);
var
  I, J: Integer;
begin
  for I := 0 to High(FEnabledListeners) do
    if SameEnabledListener(FEnabledListeners[I], Listener) then
    begin
      for J := I to High(FEnabledListeners) - 1 do
        FEnabledListeners[J] := FEnabledListeners[J + 1];
      SetLength(FEnabledListeners, Length(FEnabledListeners) - 1);
      Exit;
    end;
end;

end.
