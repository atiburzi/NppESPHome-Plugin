// Generic Notepad++ plugin menu registry.
//
// The registry keeps stable, plugin-defined identifiers separate from the
// command indexes assigned by Notepad++.  This makes menu state and toolbar
// models independent from the concrete plugin implementation.

unit Npp.Commands;

interface

uses
  Winapi.Windows, System.SysUtils, Npp.Api, Npp.Host;

type
  TNppCommandEnabledChanged = procedure(const Id: string;
    Enabled: Boolean) of object;

  // ***************************************************************************
  // Purpose: Stores application metadata associated with one ABI menu item.
  // ***************************************************************************
  TNppMenuEntry = record
    Id: string;
    Index: Integer;
    IsSeparator: Boolean;
    Checked: Boolean;
    Enabled: Boolean;
  end;

  // ***************************************************************************
  // Purpose: Owns plugin commands, shortcuts, menu state, and the ABI array.
  // ***************************************************************************
  TNppCommands = class
  private
    FHost: TNppHost;
    FFuncItemArray: TArray<TFuncItem>;
    FEntries: TArray<TNppMenuEntry>;
    FOnEnabledChanged: TNppCommandEnabledChanged;
    FEnabledListeners: TArray<TNppCommandEnabledChanged>;
    function GetCount: Integer;
    function GetEntry(Index: Integer): TNppMenuEntry;
    function ShortcutText(CommandId: Integer): string;
    function AddFunctionItem(const Caption: nppString;
      Callback: FuncItemCmdProc; ShortcutKey: PShortcutKey;
      Checked: Boolean): Integer;
    function FunctionItemAt(Index: Integer): PFuncItem;
    class function SameEnabledListener(const Left,
      Right: TNppCommandEnabledChanged): Boolean; static;
  public
    constructor Create(AHost: TNppHost);
    destructor Destroy; override;

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
    function GetFuncsArray(out Count: Integer): PFuncItem;
    procedure ApplySeparators;

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

implementation

resourcestring
  rsMenuEntryIndexOutOfRange = 'Menu entry index %d is out of range';
  rsMenuCommandIdentifierRequired = 'A menu command identifier is required';
  rsMenuCommandIdentifierReserved =
    'Menu command identifier contains a reserved character: %s';
  rsDuplicateMenuCommandIdentifier =
    'Duplicate menu command identifier: %s';
  rsMenuCommandCallbackRequired =
    'Menu command %s must provide a callback';
  rsMenuEntryIdentifierReserved =
    'Menu entry identifier contains a reserved character: %s';
  rsDuplicateMenuEntryIdentifier =
    'Duplicate menu entry identifier: %s';
  rsUnknownMenuCommandIdentifier = 'Unknown menu command identifier: %s';

// *****************************************************************************
// Purpose: Compares two enabled-state listeners by code address and instance.
// *****************************************************************************
class function TNppCommands.SameEnabledListener(const Left,
  Right: TNppCommandEnabledChanged): Boolean;
begin
  Result := (TMethod(Left).Code = TMethod(Right).Code) and
    (TMethod(Left).Data = TMethod(Right).Data);
end;

// *****************************************************************************
// Purpose: Creates and initializes the TNppCommands instance.
// *****************************************************************************
constructor TNppCommands.Create(AHost: TNppHost);
begin
  if not Assigned(AHost) then
    raise EArgumentNilException.Create('AHost');
  inherited Create;
  FHost := AHost;
end;

// *****************************************************************************
// Purpose: Releases resources owned by the TNppCommands instance.
// *****************************************************************************
destructor TNppCommands.Destroy;
var
  Index: Integer;
begin
  // Shortcut pointers are allocated by MakeShortcutKey and transferred to the
  // registry together with their function items.
  for Index := 0 to High(FFuncItemArray) do
    if Assigned(FFuncItemArray[Index].ShortcutKey) then
      Dispose(FFuncItemArray[Index].ShortcutKey);
  inherited;
end;

// *****************************************************************************
// Purpose: Appends one ABI-compatible function item to the exported command array.
// *****************************************************************************
function TNppCommands.AddFunctionItem(const Caption: nppString;
  Callback: FuncItemCmdProc; ShortcutKey: PShortcutKey;
  Checked: Boolean): Integer;
begin
  Result := Length(FFuncItemArray);
  // Notepad++ consumes this as a contiguous C-compatible array. Keep the ABI
  // record and the application metadata in separate parallel structures.
  SetLength(FFuncItemArray, Result + 1);
  StringToWideChar(Caption, FFuncItemArray[Result].ItemName,
    Length(FFuncItemArray[Result].ItemName));
  FFuncItemArray[Result].Func := Callback;
  FFuncItemArray[Result].ShortcutKey := ShortcutKey;
  FFuncItemArray[Result].Checked := Checked;
end;

// *****************************************************************************
// Purpose: Returns a pointer to a function item by validated array index.
// *****************************************************************************
function TNppCommands.FunctionItemAt(Index: Integer): PFuncItem;
begin
  Result := nil;
  if (Index >= 0) and (Index < Length(FFuncItemArray)) then
    Result := @FFuncItemArray[Index];
end;

// *****************************************************************************
// Purpose: Returns the contiguous function-item array required by Notepad++.
// *****************************************************************************
function TNppCommands.GetFuncsArray(out Count: Integer): PFuncItem;
begin
  Count := Length(FFuncItemArray);
  if Count = 0 then
    Result := nil
  else
    Result := @FFuncItemArray[0];
end;

// *****************************************************************************
// Purpose: Converts placeholder function items into native menu separators.
// *****************************************************************************
procedure TNppCommands.ApplySeparators;
var
  Menu: HMENU;
  Index: Integer;
  Item: PFuncItem;
begin
  if FHost.Data.NppHandle = 0 then
    Exit;
  Menu := GetMenu(FHost.Data.NppHandle);
  if Menu = 0 then
    Exit;
  // Separator identity is application metadata. A regular caption may legally
  // begin with '-', so its display text must never determine menu semantics.
  for Index := 0 to High(FEntries) do
    if FEntries[Index].IsSeparator then
    begin
      Item := FunctionItemAt(FEntries[Index].Index);
      if Assigned(Item) then
        ModifyMenu(Menu, Item^.CmdID,
          MF_BYCOMMAND or MF_SEPARATOR, 0, nil);
    end;
end;

// *****************************************************************************
// Purpose: Returns the number of registered items.
// *****************************************************************************
function TNppCommands.GetCount: Integer;
begin
  Result := Length(FEntries);
end;

// *****************************************************************************
// Purpose: Returns a validated copy of a registered menu entry.
// *****************************************************************************
function TNppCommands.GetEntry(Index: Integer): TNppMenuEntry;
begin
  if (Index < 0) or (Index >= Length(FEntries)) then
    raise EArgumentOutOfRangeException.CreateFmt(
      rsMenuEntryIndexOutOfRange, [Index]);
  Result := FEntries[Index];
end;

// *****************************************************************************
// Purpose: Returns the index associated with a stable identifier.
// *****************************************************************************
function TNppCommands.IndexOf(const Id: string): Integer;
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

// *****************************************************************************
// Purpose: Returns the stable identifier stored at a command index.
// *****************************************************************************
function TNppCommands.IdFromIndex(Index: Integer): string;
begin
  Result := '';
  if (Index >= 0) and (Index < Length(FEntries)) then
    Result := FEntries[Index].Id;
end;

// *****************************************************************************
// Purpose: Registers a command under a stable application-defined identifier.
// *****************************************************************************
function TNppCommands.AddCommand(const Id: string; const Caption: nppString;
  Callback: FuncItemCmdProc; ShortcutKey: PShortcutKey;
  Checked: Boolean): Integer;
begin
  if Id = '' then
    raise EArgumentException.Create(rsMenuCommandIdentifierRequired);
  // These delimiters belong to the toolbar configuration grammar; rejecting
  // them here guarantees that every command ID can be serialized safely.
  if (Pos(':', Id) > 0) or (Pos(';', Id) > 0) or (Pos('|', Id) > 0) then
    raise EArgumentException.CreateFmt(
      rsMenuCommandIdentifierReserved, [Id]);
  if IndexOf(Id) >= 0 then
    raise EArgumentException.CreateFmt(
      rsDuplicateMenuCommandIdentifier, [Id]);
  if not Assigned(Callback) then
    raise EArgumentException.CreateFmt(
      rsMenuCommandCallbackRequired, [Id]);

  Result := AddFunctionItem(Caption, Callback, ShortcutKey, Checked);
  SetLength(FEntries, Length(FEntries) + 1);
  FEntries[High(FEntries)].Id := Id;
  FEntries[High(FEntries)].Index := Result;
  FEntries[High(FEntries)].IsSeparator := False;
  FEntries[High(FEntries)].Checked := Checked;
  FEntries[High(FEntries)].Enabled := True;
end;

// *****************************************************************************
// Purpose: Registers a separator while preserving command-array ordering.
// *****************************************************************************
function TNppCommands.AddSeparator(const Id: string): Integer;
var
  EntryId: string;
begin
  EntryId := Id;
  if EntryId = '' then
    EntryId := Format('Sep$%d', [Length(FEntries)]);
  if (Pos(':', EntryId) > 0) or (Pos(';', EntryId) > 0) or
     (Pos('|', EntryId) > 0) then
    raise EArgumentException.CreateFmt(
      rsMenuEntryIdentifierReserved, [EntryId]);
  if IndexOf(EntryId) >= 0 then
    raise EArgumentException.CreateFmt(
      rsDuplicateMenuEntryIdentifier, [EntryId]);

  Result := AddFunctionItem('-', nil, nil, False);
  SetLength(FEntries, Length(FEntries) + 1);
  FEntries[High(FEntries)].Id := EntryId;
  FEntries[High(FEntries)].Index := Result;
  FEntries[High(FEntries)].IsSeparator := True;
  FEntries[High(FEntries)].Checked := False;
  FEntries[High(FEntries)].Enabled := False;
end;

// *****************************************************************************
// Purpose: Returns the command identifier assigned by Notepad++.
// *****************************************************************************
function TNppCommands.CommandId(const Id: string): Integer;
var
  Item: PFuncItem;
begin
  Item := FunctionItem(Id);
  if Assigned(Item) then
    Result := Item^.CmdID
  else
    Result := -1;
end;

// *****************************************************************************
// Purpose: Returns the ABI function item associated with a stable identifier.
// *****************************************************************************
function TNppCommands.FunctionItem(const Id: string): PFuncItem;
var
  EntryIndex: Integer;
begin
  Result := nil;
  EntryIndex := IndexOf(Id);
  if EntryIndex >= 0 then
    Result := FunctionItemAt(FEntries[EntryIndex].Index);
end;

// *****************************************************************************
// Purpose: Returns the current caption of a registered command.
// *****************************************************************************
function TNppCommands.Caption(const Id: string): string;
var
  Item: PFuncItem;
begin
  Item := FunctionItem(Id);
  if Assigned(Item) then
    Result := string(Item^.ItemName)
  else
    Result := '';
end;

// *****************************************************************************
// Purpose: Reports whether a registered command is checked.
// *****************************************************************************
function TNppCommands.IsChecked(const Id: string): Boolean;
var
  EntryIndex: Integer;
begin
  EntryIndex := IndexOf(Id);
  Result := (EntryIndex >= 0) and FEntries[EntryIndex].Checked;
end;

// *****************************************************************************
// Purpose: Reports whether a registered command is enabled.
// *****************************************************************************
function TNppCommands.IsEnabled(const Id: string): Boolean;
var
  EntryIndex: Integer;
begin
  EntryIndex := IndexOf(Id);
  Result := (EntryIndex >= 0) and FEntries[EntryIndex].Enabled;
end;

// *****************************************************************************
// Purpose: Formats the current Notepad++ shortcut assigned to a command.
// *****************************************************************************
function TNppCommands.ShortcutText(CommandId: Integer): string;
var
  Shortcut: TShortcutKey;
  Parts: TArray<string>;
  KeyName: array [0 .. 255] of Char;
begin
  Result := '';
  FillChar(Shortcut, SizeOf(Shortcut), 0);
  if FHost.SendNpp(NPPM_GETSHORTCUTBYCMDID, WPARAM(CommandId),
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

// *****************************************************************************
// Purpose: Updates a command caption and preserves its shortcut when requested.
// *****************************************************************************
procedure TNppCommands.SetCaption(const Id: string; const Caption: nppString;
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
      rsUnknownMenuCommandIdentifier, [Id]);
  Item := FunctionItem(Id);
  if not Assigned(Item) then
    raise EArgumentException.CreateFmt(
      rsUnknownMenuCommandIdentifier, [Id]);
  StringToWideChar(Caption, Item^.ItemName, Length(Item^.ItemName));
  NppHandle := FHost.Data.NppHandle;
  if NppHandle = 0 then
    Exit;
  PluginMenu := HMENU(FHost.SendNpp(NPPM_GETMENUHANDLE,
    Npp.Api.NPPPLUGINMENU, 0));
  if PluginMenu <> 0 then
  begin
    DisplayCaption := string(Caption);
    // ModifyMenu replaces the entire visible label, so the shortcut text must
    // be appended again when the caption changes at runtime.
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

// *****************************************************************************
// Purpose: Updates the stored and native checked state of a command.
// *****************************************************************************
procedure TNppCommands.SetChecked(const Id: string; Checked: Boolean;
  Delayed: Boolean);
var
  Item: PFuncItem;
  EntryIndex: Integer;
begin
  EntryIndex := IndexOf(Id);
  if (EntryIndex < 0) or FEntries[EntryIndex].IsSeparator then
    raise EArgumentException.CreateFmt(
      rsUnknownMenuCommandIdentifier, [Id]);
  if FEntries[EntryIndex].Checked = Checked then
    Exit;
  Item := FunctionItemAt(FEntries[EntryIndex].Index);
  if Assigned(Item) then
  begin
    Item^.Checked := Checked;
    FEntries[EntryIndex].Checked := Checked;
    if Delayed then
      FHost.PostNpp(NPPM_SETMENUITEMCHECK, WPARAM(Item^.CmdID),
        LPARAM(Checked))
    else
      FHost.SendNpp(NPPM_SETMENUITEMCHECK, WPARAM(Item^.CmdID),
        LPARAM(Checked));
  end;
end;

// *****************************************************************************
// Purpose: Updates command availability and notifies toolbar listeners.
// *****************************************************************************
procedure TNppCommands.SetEnabled(const Id: string; Enabled: Boolean);
var
  EntryIndex, I: Integer;
  Item: PFuncItem;
  PluginMenu: HMENU;
  Flags: UINT;
begin
  EntryIndex := IndexOf(Id);
  if (EntryIndex < 0) or FEntries[EntryIndex].IsSeparator then
    raise EArgumentException.CreateFmt(
      rsUnknownMenuCommandIdentifier, [Id]);
  if FEntries[EntryIndex].Enabled = Enabled then
    Exit;
  FEntries[EntryIndex].Enabled := Enabled;
  Item := FunctionItemAt(FEntries[EntryIndex].Index);
  if Assigned(Item) then
  begin
    PluginMenu := HMENU(FHost.SendNpp(NPPM_GETMENUHANDLE,
      Npp.Api.NPPPLUGINMENU, 0));
    if PluginMenu <> 0 then
    begin
      Flags := MF_BYCOMMAND;
      if Enabled then
        Flags := Flags or MF_ENABLED
      else
        Flags := Flags or MF_GRAYED;
      Winapi.Windows.EnableMenuItem(PluginMenu, Item^.CmdID, Flags);
      DrawMenuBar(FHost.Data.NppHandle);
    end;
  end;
  if Assigned(FOnEnabledChanged) then
    FOnEnabledChanged(Id, Enabled);
  // Notify every registered service after the menu state is authoritative.
  // TNppToolbar uses this path to mirror availability without index mapping.
  for I := 0 to High(FEnabledListeners) do
    if Assigned(FEnabledListeners[I]) then
      FEnabledListeners[I](Id, Enabled);
end;

// *****************************************************************************
// Purpose: Adds a command-state listener unless it is already registered.
// *****************************************************************************
procedure TNppCommands.AddEnabledListener(
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

// *****************************************************************************
// Purpose: Removes a previously registered command-state listener.
// *****************************************************************************
procedure TNppCommands.RemoveEnabledListener(
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
