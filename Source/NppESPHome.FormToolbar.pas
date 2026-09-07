// Toolbar customization dialog owned by NppESPHome.
// The reusable toolbar model, parsing, persistence and native synchronization
// remain in Npp.Toolbar; this unit only presents and edits that model.
unit NppESPHome.FormToolbar;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.ImgList,
  Vcl.StdCtrls,
  Vcl.VirtualImageList,
  Npp.Plugin,
  Npp.Toolbar,
  Npp.Vcl.Forms, System.ImageList;

type
  // Node order defines toolbar order; checked state defines visibility.
  // Icon resources and visual behavior deliberately remain application-owned.
  TFormToolbar = class(TNppPluginForm)
    VirtualImageList: TVirtualImageList;
    TreeViewToolbar: TTreeView;
    LabelInfo: TLabel;
    ButtonOk: TButton;
    ButtonCancel: TButton;
    ButtonApply: TButton;
    ButtonReset: TButton;
    procedure FormCreate(Sender: TObject);
    procedure TreeViewToolbarDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TreeViewToolbarDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeViewToolbarStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure TreeViewToolbarEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure TreeViewToolbarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TreeViewToolbarKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ButtonSaveClick(Sender: TObject);
    procedure ButtonResetClick(Sender: TObject);
  private
    FDragNode: TTreeNode;
    procedure ApplyConfiguration;
    procedure ClearNodes;
    function FindToolbarButton(const ItemId: string;
      out Button: TNppToolbarButton): Boolean;
    function GetToolbar: TNppToolbar;
    procedure LoadConfiguration(const ADefault: Boolean = False);
    procedure MoveNodeAfter(Node, Target: TTreeNode);
    procedure RefreshNodeImages;
    function TryGetNodeButton(Node: TTreeNode;
      out Button: TNppToolbarButton): Boolean;
  public
    destructor Destroy; override;
    procedure ToggleDarkMode; override;
  end;

var
  FormToolbar: TFormToolbar;

implementation

{$R *.dfm}

uses
  Npp.Api,
  NppESPHome.Plugin,
  NppESPHome.Shared;

type
  PToolbarItemId = ^string;

function TFormToolbar.GetToolbar: TNppToolbar;
begin
  Result := (ParentPlugin as TESPHomePlugin).Toolbar;
end;

function TFormToolbar.FindToolbarButton(const ItemId: string;
  out Button: TNppToolbarButton): Boolean;
var
  I: Integer;
begin
  Result := False;
  FillChar(Button, SizeOf(Button), 0);
  for I := 0 to GetToolbar.ButtonCount - 1 do
    if GetToolbar.GetButtonInfo(I, Button) and
       SameText(Button.ItemId, ItemId) then
      Exit(True);
end;

function TFormToolbar.TryGetNodeButton(Node: TTreeNode;
  out Button: TNppToolbarButton): Boolean;
var
  ItemId: PToolbarItemId;
begin
  Result := False;
  FillChar(Button, SizeOf(Button), 0);
  if not Assigned(Node) or not Assigned(Node.Data) then
    Exit;
  ItemId := PToolbarItemId(Node.Data);
  Result := FindToolbarButton(ItemId^, Button);
end;

procedure TFormToolbar.ClearNodes;
var
  ItemId: PToolbarItemId;
  Node: TTreeNode;
begin
  if not Assigned(TreeViewToolbar) then
    Exit;
  Node := TreeViewToolbar.Items.GetFirstNode;
  while Assigned(Node) do
  begin
    ItemId := PToolbarItemId(Node.Data);
    if Assigned(ItemId) then
    begin
      Dispose(ItemId);
      Node.Data := nil;
    end;
    Node := Node.GetNext;
  end;
  TreeViewToolbar.Items.Clear;
end;

destructor TFormToolbar.Destroy;
begin
  ClearNodes;
  inherited;
end;

procedure TFormToolbar.FormCreate(Sender: TObject);
begin
  FDragNode := nil;
  ToggleDarkMode;
  LoadConfiguration;
end;

procedure TFormToolbar.ToggleDarkMode;
var
  DarkModeColors: TNppDarkModeColors;
  IsDark: Boolean;
begin
  inherited;
  if not Assigned(ParentPlugin) or not Assigned(Resources) then
    Exit;

  AssignWindowIcon(Icon);
  IsDark := ParentPlugin.IsDarkModeEnabled;
  if ParentPlugin.GetToolbarIconSetChoice = nppToolbarStandardSmall then
    VirtualImageList.ImageCollection := Resources.LowResImages
  else if IsDark then
    VirtualImageList.ImageCollection := Resources.StandardImages
  else
    VirtualImageList.ImageCollection := Resources.LightModeImages;
  RefreshNodeImages;

  if IsDark then
  begin
    DarkModeColors := Default(TNppDarkModeColors);
    if ParentPlugin.GetDarkModeColors(@DarkModeColors) then
    begin
      Color := TColor(DarkModeColors.Background);
      Font.Color := TColor(DarkModeColors.Text);
    end
    else
    begin
      Color := TColor($202020);
      Font.Color := clWhite;
    end;
  end
  else
  begin
    Color := clBtnFace;
    Font.Color := clWindowText;
  end;
  TreeViewToolbar.Color := Color;
  TreeViewToolbar.Font.Color := Font.Color;
  TreeViewToolbar.Invalidate;
end;

procedure TFormToolbar.RefreshNodeImages;
var
  Button: TNppToolbarButton;
  ImageIndex: Integer;
  Node: TTreeNode;
begin
  if not Assigned(TreeViewToolbar) or not Assigned(VirtualImageList) then
    Exit;
  Node := TreeViewToolbar.Items.GetFirstNode;
  while Assigned(Node) do
  begin
    if TryGetNodeButton(Node, Button) then
    begin
      ImageIndex := VirtualImageList.GetIndexByName(Button.ItemId);
      Node.ImageIndex := ImageIndex;
      Node.SelectedIndex := ImageIndex;
    end;
    Node := Node.GetNextSibling;
  end;
end;

procedure TFormToolbar.LoadConfiguration(const ADefault: Boolean);
var
  Button: TNppToolbarButton;
  CaptionText: string;
  I, ImageIndex: Integer;
  ItemId: PToolbarItemId;
  Layout: TNppToolbarLayout;
  Node: TTreeNode;
begin
  if not ParentPlugin.IsNppMinVersion(8, 0) then
    Exit;

  Layout := GetToolbar.LoadLayout(ADefault);
  try
    TreeViewToolbar.Items.BeginUpdate;
    try
      ClearNodes;
      for I := 0 to Layout.Count - 1 do
      begin
        if not FindToolbarButton(Layout[I].ItemId, Button) then
          Continue;
        CaptionText := GetToolbar.CaptionForItem(Button.ItemId);
        if CaptionText = '' then
          CaptionText := Button.ItemId;
        New(ItemId);
        try
          ItemId^ := Button.ItemId;
          Node := TreeViewToolbar.Items.Add(nil, CaptionText);
          Node.Data := ItemId;
        except
          Dispose(ItemId);
          raise;
        end;
        // StateIndex is reserved by TTreeView for checkbox state images. The
        // node carries a separately allocated copy of the stable command ID.
        ImageIndex := VirtualImageList.GetIndexByName(Button.ItemId);
        Node.ImageIndex := ImageIndex;
        Node.SelectedIndex := ImageIndex;
        Node.Checked := Layout[I].Visible;
      end;
      if TreeViewToolbar.Items.Count > 0 then
      begin
        TreeViewToolbar.Selected := TreeViewToolbar.Items[0];
        TreeViewToolbar.Selected.MakeVisible;
      end;
    finally
      TreeViewToolbar.Items.EndUpdate;
    end;
  finally
    Layout.Free;
  end;
end;

procedure TFormToolbar.ApplyConfiguration;
var
  Button: TNppToolbarButton;
  Layout: TNppToolbarLayout;
  Node: TTreeNode;
begin
  Layout := TNppToolbarLayout.Create;
  try
    Node := TreeViewToolbar.Items.GetFirstNode;
    while Assigned(Node) do
    begin
      if TryGetNodeButton(Node, Button) then
        Layout.Add(Button.ItemId, Node.Checked);
      Node := Node.GetNextSibling;
    end;
    GetToolbar.SaveLayout(Layout);
  finally
    Layout.Free;
  end;

  GetToolbar.Refresh;
  (ParentPlugin as TESPHomePlugin).RefreshPluginMenu;
end;

procedure TFormToolbar.ButtonSaveClick(Sender: TObject);
begin
  ApplyConfiguration;
end;

procedure TFormToolbar.ButtonResetClick(Sender: TObject);
begin
  LoadConfiguration(True);
end;

procedure TFormToolbar.MoveNodeAfter(Node, Target: TTreeNode);
var
  NextNode: TTreeNode;
begin
  NextNode := Target.GetNextSibling;
  if NextNode = Node then
    Exit;
  if Assigned(NextNode) then
    Node.MoveTo(NextNode, naInsert)
  else
    Node.MoveTo(nil, naAdd);
end;

procedure TFormToolbar.TreeViewToolbarDragDrop(Sender, Source: TObject;
  X, Y: Integer);
var
  DropNode: TTreeNode;
  RowRect: TRect;
begin
  if (Source <> TreeViewToolbar) or not Assigned(FDragNode) then
    Exit;
  DropNode := TreeViewToolbar.GetNodeAt(X, Y);
  if Assigned(DropNode) and (DropNode <> FDragNode) then
  begin
    RowRect := DropNode.DisplayRect(False);
    TreeViewToolbar.Items.BeginUpdate;
    try
      if Y < RowRect.Top + (RowRect.Height div 2) then
        FDragNode.MoveTo(DropNode, naInsert)
      else
        MoveNodeAfter(FDragNode, DropNode);
      TreeViewToolbar.Selected := FDragNode;
      FDragNode.MakeVisible;
    finally
      TreeViewToolbar.Items.EndUpdate;
    end;
  end;
  FDragNode := nil;
end;

procedure TFormToolbar.TreeViewToolbarDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  DropNode: TTreeNode;
begin
  Accept := (Source = TreeViewToolbar) and Assigned(FDragNode);
  if Accept then
  begin
    DropNode := TreeViewToolbar.GetNodeAt(X, Y);
    if Assigned(DropNode) then
      TreeViewToolbar.Selected := DropNode;
  end;
end;

procedure TFormToolbar.TreeViewToolbarEndDrag(Sender, Target: TObject;
  X, Y: Integer);
begin
  FDragNode := nil;
end;

procedure TFormToolbar.TreeViewToolbarKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Node, TargetNode: TTreeNode;
begin
  if not (ssCtrl in Shift) then
    Exit;
  Node := TreeViewToolbar.Selected;
  if not Assigned(Node) then
    Exit;

  TreeViewToolbar.Items.BeginUpdate;
  try
    case Key of
      VK_UP:
        begin
          TargetNode := Node.GetPrevSibling;
          if Assigned(TargetNode) then
            Node.MoveTo(TargetNode, naInsert);
          Key := 0;
        end;
      VK_DOWN:
        begin
          TargetNode := Node.GetNextSibling;
          if Assigned(TargetNode) then
            MoveNodeAfter(Node, TargetNode);
          Key := 0;
        end;
    end;
    TreeViewToolbar.Selected := Node;
    Node.MakeVisible;
  finally
    TreeViewToolbar.Items.EndUpdate;
  end;
end;

procedure TFormToolbar.TreeViewToolbarMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
begin
  Node := TreeViewToolbar.GetNodeAt(X, Y);
  if Assigned(Node) and
     (htOnStateIcon in TreeViewToolbar.GetHitTestInfoAt(X, Y)) then
    TreeViewToolbar.Selected := Node;
end;

procedure TFormToolbar.TreeViewToolbarStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  FDragNode := TreeViewToolbar.Selected;
end;

end.
