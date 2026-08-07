// Toolbar customization dialog for NppESPHome.
// Edits plugin-command order and visibility, then persists and applies the resulting native toolbar layout.
unit NppESPHome.FormToolbar;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.UITypes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, NppPlugin, NppPluginForm,
  Vcl.ComCtrls, Vcl.VirtualImageList, Vcl.ImgList, System.ImageList;

type
  // Modal editor whose root nodes represent configurable toolbar commands.
  // Node order defines toolbar order and checked state defines visibility.
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

// *****************************************************************************
// Purpose: Persists the edited toolbar layout, rebuilds the native toolbar, and
// refreshes plugin command state.
// *****************************************************************************
procedure TFormToolbar.ButtonOkClick(Sender: TObject);
begin
  inherited;
  SaveConfiguration;
  TESPHomePlugin(Plugin).RefreshToolbarConfiguration;
  TESPHomePlugin(Plugin).RefreshPluginMenu;
end;

// *****************************************************************************
// Purpose: Reloads the default toolbar order and visibility into the editor
// without immediately persisting it.
// *****************************************************************************
procedure TFormToolbar.ButtonResetClick(Sender: TObject);
begin
  inherited;
  LoadConfiguration(True);
end;

// *****************************************************************************
// Purpose: Initializes the dialog theme and loads the saved toolbar
// configuration.
// *****************************************************************************
procedure TFormToolbar.FormCreate(Sender: TObject);
begin
  ToggleDarkMode;
  LoadConfiguration;
end;

// *****************************************************************************
// Purpose: Synchronizes the dialog palette and image collection with the active
// Notepad++ theme and icon-size choice.
// *****************************************************************************
procedure TFormToolbar.ToggleDarkMode;
var
  DarkModeColors: TNppDarkModeColors;
begin
  inherited ToggleDarkMode;
  AssignWindowIcon(Icon);

  // Small-icon mode has a dedicated collection; other modes follow the theme.
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

// *****************************************************************************
// Purpose: Moves the dragged command before or after the target node according
// to the vertical drop position.
// *****************************************************************************
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
      // The upper and lower halves of a row mean insert-before and insert-after.
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

// *****************************************************************************
// Purpose: Accepts valid toolbar-tree drags and highlights the prospective
// target node.
// *****************************************************************************
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

// *****************************************************************************
// Purpose: Clears the transient node reference when a drag operation ends.
// *****************************************************************************
procedure TFormToolbar.TreeViewToolbarEndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
  inherited;
  DragNode := nil;
end;

// *****************************************************************************
// Purpose: Supports command reordering with Ctrl+Up and Ctrl+Down while
// preserving selection and visibility.
// *****************************************************************************
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

// *****************************************************************************
// Purpose: Selects the node whose state icon was clicked so later operations
// act on the same command.
// *****************************************************************************
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

// *****************************************************************************
// Purpose: Captures the selected node as the source of a toolbar reorder
// operation.
// *****************************************************************************
procedure TFormToolbar.TreeViewToolbarStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
  inherited;
  DragNode := TreeViewToolbar.Selected;
end;

// *****************************************************************************
// Purpose: Populates the tree from the saved or default toolbar configuration,
// resolving command captions and images.
// *****************************************************************************
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
    // Preserve the model index independently of the node''s visual position.
    Node.StateIndex := Index;
    Node.SelectedIndex := Image;
    Node.Checked := Parts[1] = '1';
  end;
end;

// *****************************************************************************
// Purpose: Serializes the current command order and checked state to the plugin
// INI file.
// *****************************************************************************
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
