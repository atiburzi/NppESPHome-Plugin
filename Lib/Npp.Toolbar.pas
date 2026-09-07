// Generic Notepad++ toolbar manager.
// The unit contains no VCL dependency: the embedding plugin supplies icon
// production and, optionally, disabled-icon rendering.
unit Npp.Toolbar;

interface

uses
  Winapi.Windows, Winapi.CommCtrl, System.SysUtils, System.Types,
  Npp.Api, Npp.Plugin, Npp.Commands;

type
  TNppToolbarLayoutItem = record
    ItemId: string;
    Visible: Boolean;
  end;

  // Ordered, stable-ID toolbar layout. The persisted v2 format survives
  // command insertions/removals; the manager transparently imports the old
  // numeric format.
  TNppToolbarLayout = class
  private
    FItems: TArray<TNppToolbarLayoutItem>;
    function GetCount: Integer;
    function GetItem(Index: Integer): TNppToolbarLayoutItem;
  public
    procedure Add(const ItemId: string; Visible: Boolean = True);
    function IndexOf(const ItemId: string): Integer;
    procedure Move(FromIndex, ToIndex: Integer);
    procedure SetVisible(Index: Integer; Visible: Boolean);
    function Serialize: string;

    class function CreateDefault(const AvailableIds: TArray<string>):
      TNppToolbarLayout; static;
    class function TryParse(const Value: string;
      const AvailableIds: TArray<string>; out Layout: TNppToolbarLayout;
      out WasLegacy: Boolean): Boolean; static;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TNppToolbarLayoutItem read GetItem; default;
  end;

  TNppToolbarButton = record
    MenuEntryIndex: Integer;
    CommandId: Integer;
    ItemId: string;
    Sequence: Integer;
    Visible: Boolean;
    Enabled: Boolean;
    NativeButton: TTBButton;
    IconData: TToolbarIconsWithDarkMode;
  end;

  PNppToolbarButton = ^TNppToolbarButton;
  TNppToolbarButtons = TArray<TNppToolbarButton>;

  TNppToolbarIconProvider = function(const Entry: TNppMenuEntry;
    out IconData: TToolbarIconsWithDarkMode): Boolean of object;
  TNppToolbarDisabledIconProvider = function(SourceIcon: HICON;
    Width, Height: Integer): HICON of object;
  TNppToolbarConfigReader = function(const DefaultValue: string): string of object;
  TNppToolbarConfigWriter = procedure(const Value: string) of object;

  TNppPluginToolbar = class
  private
    FPlugin: TNppPlugin;
    FMenu: TNppCommands;
    FIconProvider: TNppToolbarIconProvider;
    FDisabledIconProvider: TNppToolbarDisabledIconProvider;
    FConfigReader: TNppToolbarConfigReader;
    FConfigWriter: TNppToolbarConfigWriter;
    FButtons: TNppToolbarButtons;

    function GetButton(Index: Integer): PNppToolbarButton;
    function GetButtonCount: Integer;
    function FindButton(const ItemId: string): Integer;
    function AvailableIds: TArray<string>;
    procedure CommandEnabledChanged(const Id: string; Enabled: Boolean);
    procedure PrepareButton(var Button: TNppToolbarButton);
    procedure RefreshDisabledImage(ToolbarHandle: HWND;
      NormalListHandle, DisabledListHandle: HIMAGELIST;
      IconSize: TPoint; const CommandId: Integer);
    procedure ReleaseIconData(var IconData: TToolbarIconsWithDarkMode);
  public
    constructor Create(APlugin: TNppPlugin; AMenu: TNppCommands;
      const IconProvider: TNppToolbarIconProvider;
      const DisabledIconProvider: TNppToolbarDisabledIconProvider = nil;
      const ConfigReader: TNppToolbarConfigReader = nil;
      const ConfigWriter: TNppToolbarConfigWriter = nil);
    destructor Destroy; override;

    procedure Initialize;
    procedure CaptureNativeButtons;
    procedure Refresh;
    procedure ReleaseResources;

    class function IsConfigurationValid(const Value: string;
      ButtonCount: Integer): Boolean; static;
    function Configuration(Default: Boolean = False): string;
    procedure SaveConfiguration(const Value: string);
    function LoadLayout(Default: Boolean = False): TNppToolbarLayout;
    procedure SaveLayout(const Layout: TNppToolbarLayout);
    procedure SetEnabled(const ItemId: string; State: Boolean);
    function CaptionForItem(const ItemId: string): string;
    function GetButtonInfo(Index: Integer; out Button: TNppToolbarButton): Boolean;

    // Kept for source compatibility. Prefer GetButtonInfo: the pointer becomes
    // invalid after Initialize changes the underlying dynamic array.
    property Button[Index: Integer]: PNppToolbarButton read GetButton;
    property ButtonCount: Integer read GetButtonCount;
    property Plugin: TNppPlugin read FPlugin;
    property Commands: TNppCommands read FMenu;
  end;

  TNppToolbar = TNppPluginToolbar;

implementation

function IndexOfId(const Values: TArray<string>; const Value: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(Values) do
    if SameText(Values[I], Value) then
      Exit(I);
end;

function IsValidItemId(const Value: string): Boolean;
begin
  Result := (Value <> '') and (Pos(':', Value) = 0) and
    (Pos(';', Value) = 0) and (Pos('|', Value) = 0);
end;

function TNppToolbarLayout.GetCount: Integer;
begin
  Result := Length(FItems);
end;

function TNppToolbarLayout.GetItem(Index: Integer): TNppToolbarLayoutItem;
begin
  if (Index < 0) or (Index >= Length(FItems)) then
    raise EArgumentOutOfRangeException.CreateFmt(
      'Toolbar layout index %d is out of range', [Index]);
  Result := FItems[Index];
end;

procedure TNppToolbarLayout.Add(const ItemId: string; Visible: Boolean);
var
  NewIndex: Integer;
begin
  if not IsValidItemId(ItemId) then
    raise EArgumentException.CreateFmt(
      'Invalid toolbar item identifier: %s', [ItemId]);
  if IndexOf(ItemId) >= 0 then
    raise EArgumentException.CreateFmt(
      'Duplicate toolbar item identifier: %s', [ItemId]);
  NewIndex := Length(FItems);
  SetLength(FItems, NewIndex + 1);
  FItems[NewIndex].ItemId := ItemId;
  FItems[NewIndex].Visible := Visible;
end;

function TNppToolbarLayout.IndexOf(const ItemId: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(FItems) do
    if SameText(FItems[I].ItemId, ItemId) then
      Exit(I);
end;

procedure TNppToolbarLayout.Move(FromIndex, ToIndex: Integer);
var
  I: Integer;
  Item: TNppToolbarLayoutItem;
begin
  if (FromIndex < 0) or (FromIndex >= Count) or
     (ToIndex < 0) or (ToIndex >= Count) then
    raise EArgumentOutOfRangeException.Create('Toolbar move index is out of range');
  if FromIndex = ToIndex then
    Exit;
  Item := FItems[FromIndex];
  if FromIndex < ToIndex then
    for I := FromIndex to ToIndex - 1 do
      FItems[I] := FItems[I + 1]
  else
    for I := FromIndex downto ToIndex + 1 do
      FItems[I] := FItems[I - 1];
  FItems[ToIndex] := Item;
end;

procedure TNppToolbarLayout.SetVisible(Index: Integer; Visible: Boolean);
begin
  if (Index < 0) or (Index >= Count) then
    raise EArgumentOutOfRangeException.CreateFmt(
      'Toolbar layout index %d is out of range', [Index]);
  FItems[Index].Visible := Visible;
end;

function TNppToolbarLayout.Serialize: string;
var
  I: Integer;
begin
  Result := 'v2|';
  for I := 0 to High(FItems) do
    Result := Result + FItems[I].ItemId + ':' +
      IntToStr(Ord(FItems[I].Visible)) + ';';
end;

class function TNppToolbarLayout.CreateDefault(
  const AvailableIds: TArray<string>): TNppToolbarLayout;
var
  I: Integer;
begin
  Result := TNppToolbarLayout.Create;
  try
    for I := 0 to High(AvailableIds) do
      Result.Add(AvailableIds[I], True);
  except
    Result.Free;
    raise;
  end;
end;

class function TNppToolbarLayout.TryParse(const Value: string;
  const AvailableIds: TArray<string>; out Layout: TNppToolbarLayout;
  out WasLegacy: Boolean): Boolean;
var
  Items, Parts: TArray<string>;
  SeenIds: TArray<string>;
  I, ItemIndex, NumericIndex: Integer;
  ItemId: string;
  Visible: Boolean;
begin
  Result := False;
  Layout := nil;
  WasLegacy := False;
  Items := nil;
  Parts := nil;
  SeenIds := nil;

  if Copy(Value, 1, 3) = 'v2|' then
  begin
    Items := Copy(Value, 4, MaxInt).Split(
      [';'], TStringSplitOptions.ExcludeEmpty);
    Layout := TNppToolbarLayout.Create;
    try
      for I := 0 to High(Items) do
      begin
        Parts := Items[I].Split([':']);
        if (Length(Parts) <> 2) or not IsValidItemId(Parts[0]) or
           ((Parts[1] <> '0') and (Parts[1] <> '1')) or
           (IndexOfId(SeenIds, Parts[0]) >= 0) then
          Exit;
        SetLength(SeenIds, Length(SeenIds) + 1);
        SeenIds[High(SeenIds)] := Parts[0];
        if IndexOfId(AvailableIds, Parts[0]) >= 0 then
          Layout.Add(Parts[0], Parts[1] = '1');
      end;
      for I := 0 to High(AvailableIds) do
        if Layout.IndexOf(AvailableIds[I]) < 0 then
          Layout.Add(AvailableIds[I], True);
      Result := True;
    finally
      if not Result then
        FreeAndNil(Layout);
    end;
    Exit;
  end;

  WasLegacy := True;
  if Length(AvailableIds) = 0 then
  begin
    if Value <> '' then
      Exit;
    Layout := TNppToolbarLayout.Create;
    Exit(True);
  end;
  Items := Value.Split([';'], TStringSplitOptions.ExcludeEmpty);
  if Length(Items) <> Length(AvailableIds) then
    Exit;
  Layout := TNppToolbarLayout.Create;
  try
    SetLength(SeenIds, Length(AvailableIds));
    for I := 0 to High(Items) do
    begin
      Parts := Items[I].Split([':']);
      if (Length(Parts) <> 2) or not TryStrToInt(Parts[0], NumericIndex) or
         (NumericIndex < 0) or (NumericIndex >= Length(AvailableIds)) or
         (SeenIds[NumericIndex] <> '') or
         ((Parts[1] <> '0') and (Parts[1] <> '1')) then
        Exit;
      SeenIds[NumericIndex] := AvailableIds[NumericIndex];
    end;
    for I := 0 to High(Items) do
    begin
      Parts := Items[I].Split([':']);
      TryStrToInt(Parts[0], ItemIndex);
      ItemId := AvailableIds[ItemIndex];
      Visible := Parts[1] = '1';
      Layout.Add(ItemId, Visible);
    end;
    Result := True;
  finally
    if not Result then
      FreeAndNil(Layout);
  end;
end;

constructor TNppPluginToolbar.Create(APlugin: TNppPlugin;
  AMenu: TNppCommands; const IconProvider: TNppToolbarIconProvider;
  const DisabledIconProvider: TNppToolbarDisabledIconProvider;
  const ConfigReader: TNppToolbarConfigReader;
  const ConfigWriter: TNppToolbarConfigWriter);
begin
  if not Assigned(APlugin) then
    raise EArgumentNilException.Create('APlugin');
  if not Assigned(AMenu) then
    raise EArgumentNilException.Create('AMenu');
  if not Assigned(IconProvider) then
    raise EArgumentNilException.Create('IconProvider');
  inherited Create;
  FPlugin := APlugin;
  FMenu := AMenu;
  FIconProvider := IconProvider;
  FDisabledIconProvider := DisabledIconProvider;
  FConfigReader := ConfigReader;
  FConfigWriter := ConfigWriter;
  FMenu.AddEnabledListener(CommandEnabledChanged);
end;

destructor TNppPluginToolbar.Destroy;
begin
  FMenu.RemoveEnabledListener(CommandEnabledChanged);
  ReleaseResources;
  inherited;
end;

function TNppPluginToolbar.GetButton(Index: Integer): PNppToolbarButton;
begin
  Result := nil;
  if (Index >= 0) and (Index < Length(FButtons)) then
    Result := @FButtons[Index];
end;

function TNppPluginToolbar.GetButtonInfo(Index: Integer;
  out Button: TNppToolbarButton): Boolean;
begin
  Result := (Index >= 0) and (Index < Length(FButtons));
  if Result then
    Button := FButtons[Index]
  else
    FillChar(Button, SizeOf(Button), 0);
end;

function TNppPluginToolbar.GetButtonCount: Integer;
begin
  Result := Length(FButtons);
end;

function TNppPluginToolbar.FindButton(const ItemId: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(FButtons) do
    if SameText(FButtons[I].ItemId, ItemId) then
      Exit(I);
end;

function TNppPluginToolbar.AvailableIds: TArray<string>;
var
  I: Integer;
begin
  SetLength(Result, Length(FButtons));
  for I := 0 to High(FButtons) do
    Result[I] := FButtons[I].ItemId;
end;

class function TNppPluginToolbar.IsConfigurationValid(const Value: string;
  ButtonCount: Integer): Boolean;
var
  Items, Parts, Seen: TArray<string>;
  Index, I: Integer;
begin
  Result := False;
  if ButtonCount < 0 then
    Exit;
  if Copy(Value, 1, 3) = 'v2|' then
  begin
    Items := Copy(Value, 4, MaxInt).Split(
      [';'], TStringSplitOptions.ExcludeEmpty);
    if Length(Items) <> ButtonCount then
      Exit;
    for I := 0 to High(Items) do
    begin
      Parts := Items[I].Split([':']);
      if (Length(Parts) <> 2) or not IsValidItemId(Parts[0]) or
         ((Parts[1] <> '0') and (Parts[1] <> '1')) or
         (IndexOfId(Seen, Parts[0]) >= 0) then
        Exit;
      SetLength(Seen, Length(Seen) + 1);
      Seen[High(Seen)] := Parts[0];
    end;
    Exit(True);
  end;
  if ButtonCount = 0 then
    Exit(Value = '');
  Items := Value.Split([';'], TStringSplitOptions.ExcludeEmpty);
  if Length(Items) <> ButtonCount then
    Exit;
  SetLength(Seen, ButtonCount);
  for I := 0 to High(Items) do
  begin
    Parts := Items[I].Split([':']);
    if (Length(Parts) <> 2) or
       not TryStrToInt(Parts[0], Index) or
       (Index < 0) or (Index >= ButtonCount) or (Seen[Index] <> '') or
       ((Parts[1] <> '0') and (Parts[1] <> '1')) then
      Exit;
    Seen[Index] := Parts[0];
  end;
  Result := True;
end;

function TNppPluginToolbar.LoadLayout(Default: Boolean): TNppToolbarLayout;
var
  Candidate, DefaultValue: string;
  Parsed: TNppToolbarLayout;
  WasLegacy: Boolean;
  Ids: TArray<string>;
begin
  Ids := AvailableIds;
  Result := TNppToolbarLayout.CreateDefault(Ids);
  if Default or not Assigned(FConfigReader) then
    Exit;
  DefaultValue := Result.Serialize;
  Candidate := FConfigReader(DefaultValue);
  if TNppToolbarLayout.TryParse(Candidate, Ids, Parsed, WasLegacy) then
  begin
    Result.Free;
    Result := Parsed;
    if WasLegacy and Assigned(FConfigWriter) then
      FConfigWriter(Result.Serialize);
  end;
end;

function TNppPluginToolbar.Configuration(Default: Boolean): string;
var
  Layout: TNppToolbarLayout;
begin
  Layout := LoadLayout(Default);
  try
    Result := Layout.Serialize;
  finally
    Layout.Free;
  end;
end;

procedure TNppPluginToolbar.SaveConfiguration(const Value: string);
var
  Layout: TNppToolbarLayout;
  WasLegacy: Boolean;
begin
  if not TNppToolbarLayout.TryParse(Value, AvailableIds, Layout, WasLegacy) then
    raise EArgumentException.Create('Invalid toolbar configuration');
  try
    if Assigned(FConfigWriter) then
      FConfigWriter(Layout.Serialize);
  finally
    Layout.Free;
  end;
end;

procedure TNppPluginToolbar.SaveLayout(const Layout: TNppToolbarLayout);
begin
  if not Assigned(Layout) then
    raise EArgumentNilException.Create('Layout');
  SaveConfiguration(Layout.Serialize);
end;

procedure TNppPluginToolbar.ReleaseIconData(
  var IconData: TToolbarIconsWithDarkMode);
begin
  if IconData.ToolbarBmp <> 0 then
    DeleteObject(IconData.ToolbarBmp);
  if IconData.ToolbarIcon <> 0 then
    DestroyIcon(IconData.ToolbarIcon);
  if IconData.ToolbarIconDarkMode <> 0 then
    DestroyIcon(IconData.ToolbarIconDarkMode);
  FillChar(IconData, SizeOf(IconData), 0);
end;

procedure TNppPluginToolbar.Initialize;
var
  I, ButtonIndex: Integer;
  Entry: TNppMenuEntry;
  Button: TNppToolbarButton;
  HasIcon: Boolean;
begin
  ReleaseResources;
  SetLength(FButtons, 0);
  if not FPlugin.IsNppMinVersion(8, 0) then
    Exit;

  try
    for I := 0 to FMenu.Count - 1 do
    begin
      Entry := FMenu.Entries[I];
      if Entry.IsSeparator then
        Continue;
      FillChar(Button, SizeOf(Button), 0);
      try
        HasIcon := FIconProvider(Entry, Button.IconData);
      except
        ReleaseIconData(Button.IconData);
        raise;
      end;
      if not HasIcon then
      begin
        ReleaseIconData(Button.IconData);
        Continue;
      end;
      ButtonIndex := Length(FButtons);
      Button.MenuEntryIndex := Entry.Index;
      Button.CommandId := FPlugin.CmdIdFromMenuItemIdx(Entry.Index);
      Button.ItemId := Entry.Id;
      Button.Sequence := ButtonIndex;
      Button.Enabled := FMenu.IsEnabled(Entry.Id);
      SetLength(FButtons, ButtonIndex + 1);
      FButtons[ButtonIndex] := Button;
      FPlugin.RegisterToolbarIcon(Button.CommandId,
        FButtons[ButtonIndex].IconData);
    end;
  except
    ReleaseResources;
    SetLength(FButtons, 0);
    raise;
  end;
end;

procedure TNppPluginToolbar.CaptureNativeButtons;
var
  I: Integer;
  ToolbarHandle: HWND;
  ButtonIndex: LRESULT;
begin
  ToolbarHandle := FPlugin.GetToolbarHandle;
  if ToolbarHandle = 0 then
    Exit;
  for I := 0 to High(FButtons) do
  begin
    FButtons[I].CommandId :=
      FPlugin.CmdIdFromMenuItemIdx(FButtons[I].MenuEntryIndex);
    FillChar(FButtons[I].NativeButton, SizeOf(TTBButton), 0);
    ButtonIndex := FPlugin.Host.Send(ToolbarHandle, TB_COMMANDTOINDEX,
      WPARAM(FButtons[I].CommandId), 0);
    if ButtonIndex >= 0 then
      FPlugin.Host.Send(ToolbarHandle, TB_GETBUTTON, ButtonIndex,
        LPARAM(@FButtons[I].NativeButton));
  end;
end;

procedure TNppPluginToolbar.PrepareButton(var Button: TNppToolbarButton);
begin
  Button.NativeButton.idCommand := Button.CommandId;
  if Button.Enabled then
    Button.NativeButton.fsState := Button.NativeButton.fsState or TBSTATE_ENABLED
  else
    Button.NativeButton.fsState :=
      Button.NativeButton.fsState and not TBSTATE_ENABLED;
end;

procedure TNppPluginToolbar.RefreshDisabledImage(ToolbarHandle: HWND;
  NormalListHandle, DisabledListHandle: HIMAGELIST; IconSize: TPoint;
  const CommandId: Integer);
var
  ButtonIndex: LRESULT;
  NativeButton: TTBButton;
  SourceIcon, NewIcon: HICON;
begin
  if not Assigned(FDisabledIconProvider) then
    Exit;
  ButtonIndex := FPlugin.Host.Send(ToolbarHandle, TB_COMMANDTOINDEX,
    WPARAM(CommandId), 0);
  if ButtonIndex < 0 then
    Exit;
  FillChar(NativeButton, SizeOf(NativeButton), 0);
  if FPlugin.Host.Send(ToolbarHandle, TB_GETBUTTON, ButtonIndex,
    LPARAM(@NativeButton)) = 0 then
    Exit;
  if NativeButton.iBitmap < 0 then
    Exit;

  SourceIcon := ImageList_GetIcon(NormalListHandle,
    NativeButton.iBitmap, ILD_NORMAL);
  if SourceIcon = 0 then
    Exit;
  try
    NewIcon := FDisabledIconProvider(SourceIcon, IconSize.X, IconSize.Y);
    if NewIcon <> 0 then
    try
      ImageList_ReplaceIcon(DisabledListHandle, NativeButton.iBitmap, NewIcon);
    finally
      DestroyIcon(NewIcon);
    end;
  finally
    DestroyIcon(SourceIcon);
  end;
end;

procedure TNppPluginToolbar.Refresh;
var
  ToolbarHandle: HWND;
  ButtonIndex, NativeCount: LRESULT;
  FuncIndex, ConfigIndex, DeleteAttempt, MaxDeletes: Integer;
  NormalListHandle, DisabledListHandle: HIMAGELIST;
  IconSize: TPoint;
  Layout: TNppToolbarLayout;
begin
  if not FPlugin.IsNppMinVersion(8, 0) then
    Exit;
  ToolbarHandle := FPlugin.GetToolbarHandle;
  if ToolbarHandle = 0 then
    Exit;

  NativeCount := FPlugin.Host.Send(ToolbarHandle, TB_BUTTONCOUNT, 0, 0);
  if NativeCount < 1 then
    MaxDeletes := 1
  else
    MaxDeletes := NativeCount + 1;
  for FuncIndex := 0 to High(FButtons) do
  begin
    for DeleteAttempt := 1 to MaxDeletes do
    begin
      ButtonIndex := FPlugin.Host.Send(ToolbarHandle, TB_COMMANDTOINDEX,
        WPARAM(FButtons[FuncIndex].CommandId), 0);
      if ButtonIndex < 0 then
        Break;
      if FPlugin.Host.Send(ToolbarHandle, TB_DELETEBUTTON,
        ButtonIndex, 0) = 0 then
        Break;
    end;
    FButtons[FuncIndex].Visible := False;
  end;

  Layout := LoadLayout;
  try
    for ConfigIndex := 0 to Layout.Count - 1 do
    begin
      FuncIndex := FindButton(Layout[ConfigIndex].ItemId);
      if FuncIndex < 0 then
        Continue;
      FButtons[FuncIndex].Sequence := ConfigIndex;
      FButtons[FuncIndex].Visible := Layout[ConfigIndex].Visible;
      if not FButtons[FuncIndex].Visible then
        Continue;
      PrepareButton(FButtons[FuncIndex]);
      FPlugin.Host.Send(ToolbarHandle, TB_ADDBUTTONS, 1,
        LPARAM(@FButtons[FuncIndex].NativeButton));
      FPlugin.Host.Send(ToolbarHandle, TB_SETSTATE,
        WPARAM(FButtons[FuncIndex].CommandId),
        LPARAM(FButtons[FuncIndex].NativeButton.fsState));
    end;
  finally
    Layout.Free;
  end;

  FPlugin.Host.Send(ToolbarHandle, TB_AUTOSIZE, 0, 0);
  FPlugin.Host.Send(ToolbarHandle, TB_SETMAXTEXTROWS, 0, 0);
  NormalListHandle := HIMAGELIST(FPlugin.Host.Send(ToolbarHandle,
    TB_GETIMAGELIST, 0, 0));
  DisabledListHandle := HIMAGELIST(FPlugin.Host.Send(ToolbarHandle,
    TB_GETDISABLEDIMAGELIST, 0, 0));
  if (NormalListHandle = 0) or (DisabledListHandle = 0) then
    Exit;
  if not ImageList_GetIconSize(NormalListHandle, IconSize.X, IconSize.Y) then
    Exit;
  if (IconSize.X <= 0) or (IconSize.Y <= 0) then
    Exit;
  for FuncIndex := 0 to High(FButtons) do
    if FButtons[FuncIndex].Visible then
      RefreshDisabledImage(ToolbarHandle, NormalListHandle,
        DisabledListHandle, IconSize, FButtons[FuncIndex].CommandId);
  InvalidateRect(ToolbarHandle, nil, True);
  ShowWindow(ToolbarHandle, SW_SHOW);
  UpdateWindow(ToolbarHandle);
end;

procedure TNppPluginToolbar.CommandEnabledChanged(const Id: string;
  Enabled: Boolean);
begin
  SetEnabled(Id, Enabled);
end;

procedure TNppPluginToolbar.SetEnabled(const ItemId: string; State: Boolean);
var
  ModelIndex: Integer;
  ToolbarHandle: HWND;
  ButtonState: LRESULT;
begin
  ModelIndex := FindButton(ItemId);
  if ModelIndex < 0 then
    Exit;
  FButtons[ModelIndex].Enabled := State;
  ToolbarHandle := FPlugin.GetToolbarHandle;
  if ToolbarHandle = 0 then
    Exit;
  ButtonState := FPlugin.Host.Send(ToolbarHandle, TB_GETSTATE,
    WPARAM(FButtons[ModelIndex].CommandId), 0);
  if ButtonState < 0 then
    Exit;
  if State then
    ButtonState := ButtonState or TBSTATE_ENABLED
  else
    ButtonState := ButtonState and not TBSTATE_ENABLED;
  FPlugin.Host.Send(ToolbarHandle, TB_SETSTATE,
    WPARAM(FButtons[ModelIndex].CommandId), LPARAM(ButtonState));
end;

function TNppPluginToolbar.CaptionForItem(const ItemId: string): string;
begin
  Result := FMenu.Caption(ItemId);
end;

procedure TNppPluginToolbar.ReleaseResources;
var
  I: Integer;
begin
  for I := 0 to High(FButtons) do
    ReleaseIconData(FButtons[I].IconData);
end;

end.
