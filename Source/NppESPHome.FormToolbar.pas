unit NppESPHome.FormToolbar;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.UITypes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, NppPlugin, NppPluginForm,
  Vcl.ComCtrls, Vcl.VirtualImageList, Vcl.ImgList, System.ImageList;

type
  TFormToolbar = class(TNppPluginForm)
    VirtualImageList: TVirtualImageList;
    TreeViewToolbar: TTreeView;
    LabelInfo: TLabel;
    ButtonOk: TButton;
    ButtonCancel: TButton;
    ButtonApply: TButton;
    ButtonReset: TButton;
    procedure ToggleDarkMode; override;
    procedure FormCreate(Sender: TObject);
    procedure TreeViewToolbarDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure TreeViewToolbarDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeViewToolbarStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure SaveConfiguration;
    procedure LoadConfiguration(const ADefault: Boolean = False);
    procedure ButtonOkClick(Sender: TObject);
    procedure TreeViewToolbarEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure TreeViewToolbarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TreeViewToolbarKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ButtonResetClick(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FormToolbar: TFormToolbar;

implementation

{$R *.dfm}

uses
  NppESPHome.Plugin, NppESPHome.Shared, NppMessages, System.StrUtils;

procedure TFormToolbar.ButtonOkClick(Sender: TObject);
begin
  inherited;
  SaveConfiguration;
  TESPHomePlugin(Plugin).RefreshToolbarConfiguration;
  TESPHomePlugin(Plugin).RefreshPluginMenu;
end;

procedure TFormToolbar.ButtonResetClick(Sender: TObject);
begin
  inherited;
  LoadConfiguration(True);
end;

procedure TFormToolbar.FormCreate(Sender: TObject);
begin
  ToggleDarkMode;
  LoadConfiguration;
end;

procedure TFormToolbar.ToggleDarkMode;
var
  DarkModeColors: TNppDarkModeColors;
begin
  inherited ToggleDarkMode;
  AssignWindowIcon(Icon);

  if Plugin.GetToolbarIconSetChoice = nppToolbarStandardSmall then
    VirtualImageList.ImageCollection := Resources.LowResImages
  else if Plugin.IsDarkModeEnabled then
    VirtualImageList.ImageCollection := Resources.StandardImages
  else
    VirtualImageList.ImageCollection := Resources.LightModeImages;

  if Plugin.IsDarkModeEnabled then
  begin
    DarkModeColors := Default(TNppDarkModeColors);
    Plugin.GetDarkModeColors(@DarkModeColors);
    Self.Color := TColor(DarkModeColors.Background);
    Self.Font.Color := TColor(DarkModeColors.Text);
  end
  else
  begin
    Self.Color := clBtnFace;
    Self.Font.Color := clWindowText;
  end;
end;

var
  DragNode: TTreeNode;

procedure TFormToolbar.TreeViewToolbarDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  DropNode: TTreeNode;
  R: TRect;
begin
  inherited;
  if (Source <> TreeViewToolbar) or not Assigned(DragNode) then
    Exit;
  DropNode := TreeViewToolbar.GetNodeAt(X, Y);
  if Assigned(DropNode) and (DropNode <> DragNode) then
  begin
    R := DropNode.DisplayRect(False);
    TreeViewToolbar.Items.BeginUpdate;
    try
      if Y < R.Top + (R.Height div 2) then
        DragNode.MoveTo(DropNode, naInsert)
      else
        DragNode.MoveTo(DropNode, naAdd);
      TreeViewToolbar.Selected := DragNode;
    finally
      TreeViewToolbar.Items.EndUpdate;
      DragNode := nil;
    end;
  end
  else
    DragNode := nil;
end;

procedure TFormToolbar.TreeViewToolbarDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  DropNode: TTreeNode;
begin
  inherited;
  Accept := (Source = TreeViewToolbar) and Assigned(DragNode);
  if Accept then
  begin
    DropNode := TreeViewToolbar.GetNodeAt(X, Y);
    if Assigned(DropNode) then
      TreeViewToolbar.Selected := DropNode;
  end;
end;

procedure TFormToolbar.TreeViewToolbarEndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
  inherited;
  DragNode := nil;
end;

procedure TFormToolbar.TreeViewToolbarKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Node, NextNode, TargetNode: TTreeNode;
begin
  inherited;
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
          begin
            Node.MoveTo(TargetNode, naInsert);
            TreeViewToolbar.Selected := Node;
            Node.MakeVisible;
          end;
          Key := 0;
        end;
      VK_DOWN:
        begin
          NextNode := Node.GetNextSibling;
          if Assigned(NextNode) then
          begin
            TargetNode := NextNode.GetNextSibling;
            if Assigned(TargetNode) then
              Node.MoveTo(TargetNode, naInsert)
            else
              Node.MoveTo(nil, naAdd);
            TreeViewToolbar.Selected := Node;
            Node.MakeVisible;
          end;
          Key := 0;
        end;
    end;
  finally
    TreeViewToolbar.Items.EndUpdate;
  end;
end;

procedure TFormToolbar.TreeViewToolbarMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
begin
  inherited;
  Node := TreeViewToolbar.GetNodeAt(X, Y);
  if Assigned(Node) and (htOnStateIcon in TreeViewToolbar.GetHitTestInfoAt(X, Y)) then
    TreeViewToolbar.Selected := Node;
end;

procedure TFormToolbar.TreeViewToolbarStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
  inherited;
  DragNode := TreeViewToolbar.Selected;
end;

procedure TFormToolbar.LoadConfiguration(const ADefault: Boolean = False);
var
  Button: PToolbarButton;
  Image: System.UITypes.TImageIndex;
  Index: Integer;
  Node: TTreeNode;
  ToolbarConfig, Item: string;
  Parts: TArray<string>;
begin
  inherited;
  if not Plugin.IsNppMinVersion(8, 0) then
    Exit;
  TreeViewToolbar.Items.Clear;
  ToolbarConfig := TESPHomePlugin(Plugin).GetToolbarConfiguration(ADefault);
  for Item in ToolbarConfig.Split([';'], TStringSplitOptions.ExcludeEmpty) do
  begin
    Parts := Item.Split([':']);
    if Length(Parts) <> 2 then
      Continue;
    if not TryStrToInt(Parts[0], Index) then
      Continue;
    if (Index < 0) or (Index >= TESPHomePlugin(Plugin).ToolbarButtonCount) then
      Continue;
    Button := TESPHomePlugin(Plugin).ToolbarButton[Index];
    if not Assigned(Button) then
      Continue;
    Image := TreeViewToolbar.Images.GetIndexByName(Button^.FuncItemID);
    if Image < 0 then
      Continue;
    Node := TreeViewToolbar.Items.Add(nil, Plugin.GetFuncByCmdID(Button^.CmdID).ItemName);
    Node.ImageIndex := Image;
    Node.StateIndex := Index;
    Node.SelectedIndex := Image;
    Node.Checked := Parts[1] = '1';
  end;
end;

procedure TFormToolbar.SaveConfiguration;
var
  Node: TTreeNode;
  ToolbarConfig: string;
begin
  ToolbarConfig := '';
  for Node in TreeViewToolbar.Items do
    ToolbarConfig := Concat(ToolbarConfig, IntToStr(Node.StateIndex), ':', IfThen(Node.Checked, '1', '0'), ';');
  ConfigIniFile.WriteString(csSectionGeneral, csKeyToolbarConfig, ToolbarConfig);
end;

end.
