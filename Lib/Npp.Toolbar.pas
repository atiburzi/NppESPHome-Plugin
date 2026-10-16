// Generic Notepad++ toolbar manager.
// The unit contains no VCL dependency: the embedding plugin supplies icon
// production and, optionally, disabled-icon rendering.
unit Npp.Toolbar;

interface

uses
  Winapi.Windows, Winapi.CommCtrl, System.SysUtils, System.Types,
  Npp.Api, Npp.Host, Npp.Commands;

type
  // ***************************************************************************
  // Purpose: Associates one stable command identifier with its visibility state.
  // ***************************************************************************
  TNppToolbarLayoutItem = record
    ItemId: string;
    Visible: Boolean;
  end;

  // ***************************************************************************
  // Purpose: Models ordered toolbar visibility using stable application-defined IDs.
  // ***************************************************************************
  TNppToolbarLayout = class
  private
    FItems: TArray<TNppToolbarLayoutItem>;
    function GetCount: Integer;
    function GetItem(Index: Integer): TNppToolbarLayoutItem;
    class function IsValidItemId(const Value: string): Boolean; static;
  public
    procedure Add(const ItemId: string; Visible: Boolean = True);
    function IndexOf(const ItemId: string): Integer;
    procedure Move(FromIndex, ToIndex: Integer);
    procedure SetVisible(Index: Integer; Visible: Boolean);
    function Serialize: string;

    class function CreateDefault(const AvailableIds: TArray<string>):
      TNppToolbarLayout; static;
    class function TryParse(const Value: string;
      out Layout: TNppToolbarLayout): Boolean; static;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TNppToolbarLayoutItem read GetItem; default;
  end;

  // ***************************************************************************
  // Purpose: Holds framework and native state for one toolbar button.
  // ***************************************************************************
  TNppToolbarButton = record
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

  // ***************************************************************************
  // Purpose: Builds, configures, and synchronizes a generic Notepad++ toolbar.
  // ***************************************************************************
  TNppToolbar = class
  private
    FHost: TNppHost;
    FCommands: TNppCommands;
    FIconProvider: TNppToolbarIconProvider;
    FDisabledIconProvider: TNppToolbarDisabledIconProvider;
    FConfiguration: string;
    FInitialized: Boolean;
    FButtons: TNppToolbarButtons;

    function GetButton(Index: Integer): PNppToolbarButton;
    function GetButtonCount: Integer;
    function FindButton(const ItemId: string): Integer;
    class function IndexOfId(const Values: TArray<string>;
      const Value: string): Integer; static;
    function AvailableIds: TArray<string>;
    function NormalizeLayout(const Source: TNppToolbarLayout):
      TNppToolbarLayout;
    procedure CommandEnabledChanged(const Id: string; Enabled: Boolean);
    procedure PrepareButton(var Button: TNppToolbarButton);
    procedure RefreshDisabledImage(ToolbarHandle: HWND;
      NormalListHandle, DisabledListHandle: HIMAGELIST;
      IconSize: TPoint; const CommandId: Integer);
    procedure ReleaseIconData(var IconData: TToolbarIconsWithDarkMode);
  public
    constructor Create(AHost: TNppHost; ACommands: TNppCommands;
      const IconProvider: TNppToolbarIconProvider;
      const DisabledIconProvider: TNppToolbarDisabledIconProvider = nil);
    destructor Destroy; override;

    procedure Initialize;
    procedure CaptureNativeButtons;
    procedure Refresh;
    procedure ReleaseResources;

    class function IsConfigurationValid(const Value: string): Boolean; static;
    function Configuration: string;
    function DefaultConfiguration: string;
    function CreateLayout(Default: Boolean = False): TNppToolbarLayout;
    procedure ApplyConfiguration(const Value: string);
    procedure ApplyLayout(const Layout: TNppToolbarLayout);
    procedure SetEnabled(const ItemId: string; State: Boolean);
    function CaptionForItem(const ItemId: string): string;
    function GetButtonInfo(Index: Integer;
      out Button: TNppToolbarButton): Boolean; overload;
    function GetButtonInfo(const ItemId: string;
      out Button: TNppToolbarButton): Boolean; overload;

    // Kept for source compatibility. Prefer GetButtonInfo: the pointer becomes
    // invalid after Initialize changes the underlying dynamic array.
    property Button[Index: Integer]: PNppToolbarButton read GetButton;
    property ButtonCount: Integer read GetButtonCount;
    property Host: TNppHost read FHost;
    property Commands: TNppCommands read FCommands;
  end;

implementation

resourcestring
  rsToolbarLayoutIndexOutOfRange =
    'Toolbar layout index %d is out of range';
  rsInvalidToolbarItemIdentifier =
    'Invalid toolbar item identifier: %s';
  rsDuplicateToolbarItemIdentifier =
    'Duplicate toolbar item identifier: %s';
  rsToolbarMoveIndexOutOfRange = 'Toolbar move index is out of range';
  rsInvalidToolbarConfiguration = 'Invalid toolbar configuration';

// *****************************************************************************
// Purpose: Validates an item identifier against configuration delimiters.
// *****************************************************************************
class function TNppToolbarLayout.IsValidItemId(
  const Value: string): Boolean;
begin
  Result := (Value <> '') and (Pos(':', Value) = 0) and
    (Pos(';', Value) = 0) and (Pos('|', Value) = 0);
end;

// *****************************************************************************
// Purpose: Returns the number of registered items.
// *****************************************************************************
function TNppToolbarLayout.GetCount: Integer;
begin
  Result := Length(FItems);
end;

// *****************************************************************************
// Purpose: Returns a validated toolbar layout item.
// *****************************************************************************
function TNppToolbarLayout.GetItem(Index: Integer): TNppToolbarLayoutItem;
begin
  if (Index < 0) or (Index >= Length(FItems)) then
    raise EArgumentOutOfRangeException.CreateFmt(
      rsToolbarLayoutIndexOutOfRange, [Index]);
  Result := FItems[Index];
end;

// *****************************************************************************
// Purpose: Appends a unique stable identifier to the toolbar layout.
// *****************************************************************************
procedure TNppToolbarLayout.Add(const ItemId: string; Visible: Boolean);
var
  NewIndex: Integer;
begin
  if not IsValidItemId(ItemId) then
    raise EArgumentException.CreateFmt(
      rsInvalidToolbarItemIdentifier, [ItemId]);
  if IndexOf(ItemId) >= 0 then
    raise EArgumentException.CreateFmt(
      rsDuplicateToolbarItemIdentifier, [ItemId]);
  NewIndex := Length(FItems);
  SetLength(FItems, NewIndex + 1);
  FItems[NewIndex].ItemId := ItemId;
  FItems[NewIndex].Visible := Visible;
end;

// *****************************************************************************
// Purpose: Returns the index associated with a stable identifier.
// *****************************************************************************
function TNppToolbarLayout.IndexOf(const ItemId: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(FItems) do
    if SameText(FItems[I].ItemId, ItemId) then
      Exit(I);
end;

// *****************************************************************************
// Purpose: Moves a toolbar layout item while preserving the relative order of the others.
// *****************************************************************************
procedure TNppToolbarLayout.Move(FromIndex, ToIndex: Integer);
var
  I: Integer;
  Item: TNppToolbarLayoutItem;
begin
  if (FromIndex < 0) or (FromIndex >= Count) or
     (ToIndex < 0) or (ToIndex >= Count) then
    raise EArgumentOutOfRangeException.Create(rsToolbarMoveIndexOutOfRange);
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

// *****************************************************************************
// Purpose: Updates the visibility flag of a toolbar layout item.
// *****************************************************************************
procedure TNppToolbarLayout.SetVisible(Index: Integer; Visible: Boolean);
begin
  if (Index < 0) or (Index >= Count) then
    raise EArgumentOutOfRangeException.CreateFmt(
      rsToolbarLayoutIndexOutOfRange, [Index]);
  FItems[Index].Visible := Visible;
end;

// *****************************************************************************
// Purpose: Serializes the layout to the canonical stable-ID configuration string.
// *****************************************************************************
function TNppToolbarLayout.Serialize: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(FItems) do
    Result := Result + FItems[I].ItemId + ':' +
      IntToStr(Ord(FItems[I].Visible)) + ';';
end;

// *****************************************************************************
// Purpose: Creates the default layout with every available item visible.
// *****************************************************************************
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

// *****************************************************************************
// Purpose: Parses and validates a canonical toolbar configuration string.
// *****************************************************************************
class function TNppToolbarLayout.TryParse(const Value: string;
  out Layout: TNppToolbarLayout): Boolean;
var
  Items, Parts: TArray<string>;
  I: Integer;
begin
  Result := False;
  Layout := nil;
  if Value = '' then
  begin
    Layout := TNppToolbarLayout.Create;
    Exit(True);
  end;

  // Serialize always produces a trailing separator. Requiring the canonical
  // shape keeps the configuration contract small and unambiguous.
  if (Value[Length(Value)] <> ';') or (Value[1] = ';') or
     (Pos(';;', Value) > 0) then
    Exit;
  Items := Value.Split([';'], TStringSplitOptions.ExcludeEmpty);
  if Length(Items) = 0 then
    Exit;
  Layout := TNppToolbarLayout.Create;
  try
    for I := 0 to High(Items) do
    begin
      Parts := Items[I].Split([':']);
      if (Length(Parts) <> 2) or not IsValidItemId(Parts[0]) or
         ((Parts[1] <> '0') and (Parts[1] <> '1')) then
        Exit;
      if Layout.IndexOf(Parts[0]) >= 0 then
        Exit;
      Layout.Add(Parts[0], Parts[1] = '1');
    end;
    Result := True;
  finally
    if not Result then
      FreeAndNil(Layout);
  end;
end;

// *****************************************************************************
// Purpose: Creates and initializes the TNppToolbar instance.
// *****************************************************************************
constructor TNppToolbar.Create(AHost: TNppHost;
  ACommands: TNppCommands; const IconProvider: TNppToolbarIconProvider;
  const DisabledIconProvider: TNppToolbarDisabledIconProvider);
begin
  if not Assigned(AHost) then
    raise EArgumentNilException.Create('AHost');
  if not Assigned(ACommands) then
    raise EArgumentNilException.Create('ACommands');
  if not Assigned(IconProvider) then
    raise EArgumentNilException.Create('IconProvider');
  inherited Create;
  FHost := AHost;
  FCommands := ACommands;
  FIconProvider := IconProvider;
  FDisabledIconProvider := DisabledIconProvider;
  FConfiguration := '';
  FInitialized := False;
  FCommands.AddEnabledListener(CommandEnabledChanged);
end;

// *****************************************************************************
// Purpose: Releases resources owned by the TNppToolbar instance.
// *****************************************************************************
destructor TNppToolbar.Destroy;
begin
  FCommands.RemoveEnabledListener(CommandEnabledChanged);
  ReleaseResources;
  inherited;
end;

// *****************************************************************************
// Purpose: Returns a temporary pointer to an internal toolbar button.
// *****************************************************************************
function TNppToolbar.GetButton(Index: Integer): PNppToolbarButton;
begin
  Result := nil;
  if (Index >= 0) and (Index < Length(FButtons)) then
    Result := @FButtons[Index];
end;

// *****************************************************************************
// Purpose: Copies toolbar button information without exposing internal storage.
// *****************************************************************************
function TNppToolbar.GetButtonInfo(Index: Integer;
  out Button: TNppToolbarButton): Boolean;
begin
  Result := (Index >= 0) and (Index < Length(FButtons));
  if Result then
    Button := FButtons[Index]
  else
    FillChar(Button, SizeOf(Button), 0);
end;

// *****************************************************************************
// Purpose: Copies toolbar button information selected by stable identifier.
// *****************************************************************************
function TNppToolbar.GetButtonInfo(const ItemId: string;
  out Button: TNppToolbarButton): Boolean;
begin
  Result := GetButtonInfo(FindButton(ItemId), Button);
end;

// *****************************************************************************
// Purpose: Returns the number of toolbar buttons created by the icon provider.
// *****************************************************************************
function TNppToolbar.GetButtonCount: Integer;
begin
  Result := Length(FButtons);
end;

// *****************************************************************************
// Purpose: Returns the model index of a toolbar button identified by stable ID.
// *****************************************************************************
function TNppToolbar.FindButton(const ItemId: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(FButtons) do
    if SameText(FButtons[I].ItemId, ItemId) then
      Exit(I);
end;

// *****************************************************************************
// Purpose: Returns the case-insensitive position of a stable identifier.
// *****************************************************************************
class function TNppToolbar.IndexOfId(const Values: TArray<string>;
  const Value: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(Values) do
    if SameText(Values[I], Value) then
      Exit(I);
end;

// *****************************************************************************
// Purpose: Returns the stable identifiers of all available toolbar buttons.
// *****************************************************************************
function TNppToolbar.AvailableIds: TArray<string>;
var
  I: Integer;
begin
  SetLength(Result, Length(FButtons));
  for I := 0 to High(FButtons) do
    Result[I] := FButtons[I].ItemId;
end;

// *****************************************************************************
// Purpose: Reconciles a layout with the toolbar buttons currently available.
// *****************************************************************************
function TNppToolbar.NormalizeLayout(
  const Source: TNppToolbarLayout): TNppToolbarLayout;
var
  Ids: TArray<string>;
  AvailableIndex, I: Integer;
begin
  if not Assigned(Source) then
    raise EArgumentNilException.Create('Source');
  Ids := AvailableIds;
  Result := TNppToolbarLayout.Create;
  try
    for I := 0 to Source.Count - 1 do
    begin
      AvailableIndex := IndexOfId(Ids, Source[I].ItemId);
      if AvailableIndex >= 0 then
        Result.Add(Ids[AvailableIndex], Source[I].Visible);
    end;
    for I := 0 to High(Ids) do
      if Result.IndexOf(Ids[I]) < 0 then
        Result.Add(Ids[I], True);
  except
    Result.Free;
    raise;
  end;
end;

// *****************************************************************************
// Purpose: Reports whether a string follows the canonical toolbar format.
// *****************************************************************************
class function TNppToolbar.IsConfigurationValid(
  const Value: string): Boolean;
var
  Layout: TNppToolbarLayout;
begin
  Result := TNppToolbarLayout.TryParse(Value, Layout);
  Layout.Free;
end;

// *****************************************************************************
// Purpose: Creates a caller-owned current or default toolbar layout.
// *****************************************************************************
function TNppToolbar.CreateLayout(Default: Boolean): TNppToolbarLayout;
var
  Parsed: TNppToolbarLayout;
begin
  if Default then
    Exit(TNppToolbarLayout.CreateDefault(AvailableIds));

  if not TNppToolbarLayout.TryParse(FConfiguration, Parsed) then
    Exit(TNppToolbarLayout.CreateDefault(AvailableIds));
  if not FInitialized then
    Exit(Parsed);
  try
    Result := NormalizeLayout(Parsed);
  finally
    Parsed.Free;
  end;
end;

// *****************************************************************************
// Purpose: Returns the canonical current toolbar configuration string.
// *****************************************************************************
function TNppToolbar.Configuration: string;
var
  Layout: TNppToolbarLayout;
begin
  if not FInitialized then
    Exit(FConfiguration);
  Layout := CreateLayout;
  try
    Result := Layout.Serialize;
  finally
    Layout.Free;
  end;
end;

// *****************************************************************************
// Purpose: Generates the canonical default toolbar configuration string.
// *****************************************************************************
function TNppToolbar.DefaultConfiguration: string;
var
  Layout: TNppToolbarLayout;
begin
  Layout := CreateLayout(True);
  try
    Result := Layout.Serialize;
  finally
    Layout.Free;
  end;
end;

// *****************************************************************************
// Purpose: Validates, stores, and applies a toolbar configuration string.
// *****************************************************************************
procedure TNppToolbar.ApplyConfiguration(const Value: string);
var
  Parsed, Normalized: TNppToolbarLayout;
begin
  if not TNppToolbarLayout.TryParse(Value, Parsed) then
    raise EArgumentException.Create(rsInvalidToolbarConfiguration);
  try
    // Configuration can be supplied before NPPN_TBMODIFICATION. In that case
    // preserve its stable IDs until Initialize knows which buttons exist.
    if FInitialized then
    begin
      Normalized := NormalizeLayout(Parsed);
      try
        FConfiguration := Normalized.Serialize;
      finally
        Normalized.Free;
      end;
    end
    else
      FConfiguration := Parsed.Serialize;
  finally
    Parsed.Free;
  end;
  if FInitialized then
    Refresh;
end;

// *****************************************************************************
// Purpose: Serializes and applies a toolbar layout supplied by the caller.
// *****************************************************************************
procedure TNppToolbar.ApplyLayout(const Layout: TNppToolbarLayout);
begin
  if not Assigned(Layout) then
    raise EArgumentNilException.Create('Layout');
  ApplyConfiguration(Layout.Serialize);
end;

// *****************************************************************************
// Purpose: Releases every native icon handle owned by one toolbar button.
// *****************************************************************************
procedure TNppToolbar.ReleaseIconData(
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

// *****************************************************************************
// Purpose: Builds the toolbar model and registers its icons with Notepad++.
// *****************************************************************************
procedure TNppToolbar.Initialize;
var
  I, ButtonIndex: Integer;
  Entry: TNppMenuEntry;
  Button: TNppToolbarButton;
  HasIcon: Boolean;
  Layout: TNppToolbarLayout;
begin
  ReleaseResources;
  if not FHost.IsNppMinVersion(8, 0) then
  begin
    FInitialized := True;
    FConfiguration := '';
    Exit;
  end;

  try
    for I := 0 to FCommands.Count - 1 do
    begin
      Entry := FCommands.Entries[I];
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
      // Successful providers transfer ownership of every returned GDI handle
      // to this manager, including handles later released during reinitialize.
      Button.CommandId := FCommands.CommandId(Entry.Id);
      Button.ItemId := Entry.Id;
      Button.Sequence := ButtonIndex;
      Button.Enabled := FCommands.IsEnabled(Entry.Id);
      SetLength(FButtons, ButtonIndex + 1);
      FButtons[ButtonIndex] := Button;
      FHost.SendNpp(NPPM_ADDTOOLBARICON_FORDARKMODE,
        WPARAM(Button.CommandId), LPARAM(@FButtons[ButtonIndex].IconData));
    end;
    FInitialized := True;
    Layout := CreateLayout;
    try
      FConfiguration := Layout.Serialize;
    finally
      Layout.Free;
    end;
  except
    ReleaseResources;
    raise;
  end;
end;

// *****************************************************************************
// Purpose: Captures the native button templates created by Notepad++.
// *****************************************************************************
procedure TNppToolbar.CaptureNativeButtons;
var
  I: Integer;
  ToolbarHandle: HWND;
  ButtonIndex: LRESULT;
begin
  ToolbarHandle := FHost.GetToolbarHandle;
  if ToolbarHandle = 0 then
    Exit;
  for I := 0 to High(FButtons) do
  begin
    FButtons[I].CommandId := FCommands.CommandId(FButtons[I].ItemId);
    FillChar(FButtons[I].NativeButton, SizeOf(TTBButton), 0);
    ButtonIndex := FHost.Send(ToolbarHandle, TB_COMMANDTOINDEX,
      WPARAM(FButtons[I].CommandId), 0);
    if ButtonIndex >= 0 then
      FHost.Send(ToolbarHandle, TB_GETBUTTON, ButtonIndex,
        LPARAM(@FButtons[I].NativeButton));
  end;
end;

// *****************************************************************************
// Purpose: Synchronizes command and enabled state before native insertion.
// *****************************************************************************
procedure TNppToolbar.PrepareButton(var Button: TNppToolbarButton);
begin
  Button.NativeButton.idCommand := Button.CommandId;
  if Button.Enabled then
    Button.NativeButton.fsState := Button.NativeButton.fsState or TBSTATE_ENABLED
  else
    Button.NativeButton.fsState :=
      Button.NativeButton.fsState and not TBSTATE_ENABLED;
end;

// *****************************************************************************
// Purpose: Rebuilds one disabled image in the native toolbar image list.
// *****************************************************************************
procedure TNppToolbar.RefreshDisabledImage(ToolbarHandle: HWND;
  NormalListHandle, DisabledListHandle: HIMAGELIST; IconSize: TPoint;
  const CommandId: Integer);
var
  ButtonIndex: LRESULT;
  NativeButton: TTBButton;
  SourceIcon, NewIcon: HICON;
begin
  if not Assigned(FDisabledIconProvider) then
    Exit;
  ButtonIndex := FHost.Send(ToolbarHandle, TB_COMMANDTOINDEX,
    WPARAM(CommandId), 0);
  if ButtonIndex < 0 then
    Exit;
  FillChar(NativeButton, SizeOf(NativeButton), 0);
  if FHost.Send(ToolbarHandle, TB_GETBUTTON, ButtonIndex,
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

// *****************************************************************************
// Purpose: Rebuilds the native toolbar from the current layout and command state.
// *****************************************************************************
procedure TNppToolbar.Refresh;
var
  ToolbarHandle: HWND;
  ButtonIndex, NativeCount: LRESULT;
  FuncIndex, ConfigIndex, DeleteAttempt, MaxDeletes: Integer;
  NormalListHandle, DisabledListHandle: HIMAGELIST;
  IconSize: TPoint;
  Layout: TNppToolbarLayout;
begin
  if not FHost.IsNppMinVersion(8, 0) then
    Exit;
  ToolbarHandle := FHost.GetToolbarHandle;
  if ToolbarHandle = 0 then
    Exit;

  NativeCount := FHost.Send(ToolbarHandle, TB_BUTTONCOUNT, 0, 0);
  if NativeCount < 1 then
    MaxDeletes := 1
  else
    MaxDeletes := NativeCount + 1;
  for FuncIndex := 0 to High(FButtons) do
  begin
    // Remove every stale copy. Some Notepad++ toolbar rebuilds can temporarily
    // leave duplicate command buttons behind; the bounded loop also prevents a
    // broken host transport from spinning forever.
    for DeleteAttempt := 1 to MaxDeletes do
    begin
      ButtonIndex := FHost.Send(ToolbarHandle, TB_COMMANDTOINDEX,
        WPARAM(FButtons[FuncIndex].CommandId), 0);
      if ButtonIndex < 0 then
        Break;
      if FHost.Send(ToolbarHandle, TB_DELETEBUTTON,
        ButtonIndex, 0) = 0 then
        Break;
    end;
    FButtons[FuncIndex].Visible := False;
  end;

  Layout := CreateLayout;
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
      FHost.Send(ToolbarHandle, TB_ADDBUTTONS, 1,
        LPARAM(@FButtons[FuncIndex].NativeButton));
      FHost.Send(ToolbarHandle, TB_SETSTATE,
        WPARAM(FButtons[FuncIndex].CommandId),
        LPARAM(FButtons[FuncIndex].NativeButton.fsState));
    end;
  finally
    Layout.Free;
  end;

  FHost.Send(ToolbarHandle, TB_AUTOSIZE, 0, 0);
  FHost.Send(ToolbarHandle, TB_SETMAXTEXTROWS, 0, 0);
  NormalListHandle := HIMAGELIST(FHost.Send(ToolbarHandle,
    TB_GETIMAGELIST, 0, 0));
  DisabledListHandle := HIMAGELIST(FHost.Send(ToolbarHandle,
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

// *****************************************************************************
// Purpose: Mirrors a command enabled-state change into the toolbar.
// *****************************************************************************
procedure TNppToolbar.CommandEnabledChanged(const Id: string;
  Enabled: Boolean);
begin
  SetEnabled(Id, Enabled);
end;

// *****************************************************************************
// Purpose: Synchronizes one toolbar button with its command enabled state.
// *****************************************************************************
procedure TNppToolbar.SetEnabled(const ItemId: string; State: Boolean);
var
  ModelIndex: Integer;
  ToolbarHandle: HWND;
  ButtonState: LRESULT;
begin
  ModelIndex := FindButton(ItemId);
  if ModelIndex < 0 then
    Exit;
  FButtons[ModelIndex].Enabled := State;
  ToolbarHandle := FHost.GetToolbarHandle;
  if ToolbarHandle = 0 then
    Exit;
  ButtonState := FHost.Send(ToolbarHandle, TB_GETSTATE,
    WPARAM(FButtons[ModelIndex].CommandId), 0);
  if ButtonState < 0 then
    Exit;
  if State then
    ButtonState := ButtonState or TBSTATE_ENABLED
  else
    ButtonState := ButtonState and not TBSTATE_ENABLED;
  FHost.Send(ToolbarHandle, TB_SETSTATE,
    WPARAM(FButtons[ModelIndex].CommandId), LPARAM(ButtonState));
end;

// *****************************************************************************
// Purpose: Returns the current command caption for a toolbar item.
// *****************************************************************************
function TNppToolbar.CaptionForItem(const ItemId: string): string;
begin
  Result := FCommands.Caption(ItemId);
end;

// *****************************************************************************
// Purpose: Releases toolbar icon resources and clears the button model.
// *****************************************************************************
procedure TNppToolbar.ReleaseResources;
var
  I: Integer;
begin
  FInitialized := False;
  for I := 0 to High(FButtons) do
    ReleaseIconData(FButtons[I].IconData);
  SetLength(FButtons, 0);
end;

end.
