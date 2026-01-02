unit UnitFormToolbar;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ImageCollection, NppPlugin, NppPluginForms,
  Vcl.ComCtrls, Vcl.ImgList, Vcl.VirtualImageList, System.ImageList, Vcl.BaseImageCollection;

type
  TFormToolbar = class(TNppPluginForm)
    LabelNote: TLabel;
    ImageCollectionDark: TImageCollection;
    VirtualImageListDark: TVirtualImageList;
    ImageCollectionLight: TImageCollection;
    VirtualImageListLight: TVirtualImageList;
    TreeViewToolbar: TTreeView;
    LabelInfo: TLabel;
    procedure ToggleDarkMode; override;
    procedure FormCreate(Sender: TObject);
    procedure TreeViewToolbarDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure TreeViewToolbarDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeViewToolbarStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure TreeViewToolbarCheckStateChanged(Sender: TCustomTreeView; Node: TTreeNode; CheckState: TNodeCheckState);
    procedure TreeViewToolbarChange(Sender: TObject; Node: TTreeNode);
    procedure SaveConfiguration;
    procedure LoadConfiguration;
  public
    { Public declarations }
  end;

var
  FormToolbar: TFormToolbar;

implementation

{$R *.dfm}

uses
  ESPHomePlugin, ESPHomeShared, NppSupport, System.StrUtils, System.RegularExpressions;

procedure TFormToolbar.FormCreate(Sender: TObject);
begin
  LoadConfiguration;
end;

procedure TFormToolbar.ToggleDarkMode;
var
  DarkModeColors: TNppDarkModeColors;
begin
  inherited ToggleDarkMode;
  if Plugin.IsDarkModeEnabled then
  begin
    DarkModeColors := Default(TNppDarkModeColors);
    Plugin.GetDarkModeColors(@DarkModeColors);
    Self.Color := TColor(DarkModeColors.Background);
    Self.Font.Color := TColor(DarkModeColors.Text);
    LabelNote.Font.Color := TColor(DarkModeColors.Text);
    TreeViewToolbar.Images := VirtualImageListLight;
    Icon.Handle := LoadImage(HInstance, resMainIconLight, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR);
  end
  else
  begin
    Self.Color := clBtnFace;
    Self.Font.Color := clWindowText;
    LabelNote.Font.Color := clWindowText;
    TreeViewToolbar.Images := VirtualImageListDark;
    Icon.Handle := LoadImage(HInstance, resMainIconDark, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR);
  end;
end;

var
  DragNode: TTreeNode;

procedure TFormToolbar.TreeViewToolbarChange(Sender: TObject; Node: TTreeNode);
begin
  inherited;
  SaveConfiguration;
end;

procedure TFormToolbar.TreeViewToolbarCheckStateChanged(Sender: TCustomTreeView; Node: TTreeNode; CheckState: TNodeCheckState);
begin
  inherited;
  SaveConfiguration;
end;

procedure TFormToolbar.TreeViewToolbarDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  DropNode, NewNode: TTreeNode;
begin
  inherited;
  if Assigned(DragNode) then
  begin
    DropNode := TreeViewToolbar.GetNodeAt(X, Y);
    if Assigned(DropNode) and (DropNode <> DragNode) then
    begin
      TreeViewToolbar.Items.BeginUpdate;
      try
        NewNode := TreeViewToolbar.Items.Insert(DropNode, DragNode.Text);
        NewNode.Assign(DragNode);
        DragNode.Delete;
        DragNode := nil;
      finally
        TreeViewToolbar.Items.EndUpdate;
      end;
    end;
  end;
end;

procedure TFormToolbar.TreeViewToolbarDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  inherited;
  Accept := (Source = TreeViewToolbar) and Assigned(DragNode);
  TreeViewToolbar.Selected := TreeViewToolbar.GetNodeAt(X, Y);
end;

procedure TFormToolbar.TreeViewToolbarStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
  inherited;
  DragNode := TreeViewToolbar.Selected;
end;

procedure TFormToolbar.LoadConfiguration;
var
  Index, Count: Integer;
  Node: TTreeNode;
  ToolbarConfig, DefaultConfig: string;
  Item, Pattern: string;
  Parts: TArray<string>;
  Regex: TRegEx;
begin

  TreeViewToolbar.Items.Clear;

  Count := 0;
  DefaultConfig := '';
  for Index := 0 to Length(ToolbarIconItemKey) - 1 do
    if ToolbarIconItemKey[Index] <> '' then
    begin
      DefaultConfig := Concat(DefaultConfig, IntToStr(Index), ':1;');
      Inc(Count);
    end;

  ToolbarConfig := ConfigFile.ReadString(csSectionGeneral, csKeyToolbarConfig, DefaultConfig);

  Pattern := Format('^(?:\d+:[01];){%d}$', [Count]);
  Regex := TRegEx.Create(Pattern);

  if not Regex.IsMatch(ToolbarConfig) then
    ToolbarConfig := DefaultConfig;

  Pattern := DarkModeSuffix[not Plugin.IsDarkModeEnabled];

  for Item in ToolbarConfig.Split([';'], TStringSplitOptions.ExcludeEmpty) do
  begin
    if Item <> '' then
    begin
      Parts := Item.Split([':']);
      if Length(Parts) = 2 then
      begin
        Val(Parts[0], Index, Count);
        if (Count = 0) and (Index < Length(ToolbarIconItemKey)) then
        begin
          Node := TreeViewToolbar.Items.Add(nil, Plugin.GetFuncByIndex(Index).ItemName);
          if Assigned(Node) then
          begin
            Node.StateIndex := Index;
            Node.ImageIndex := TreeViewToolbar.Images.GetIndexByName(ToolbarIconItemKey[Index] + Pattern);
            Node.SelectedIndex := Node.ImageIndex;
            Node.Checked := (Parts[1] = '1');
          end;
        end;
      end;
    end;
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
  ConfigFile.WriteString(csSectionGeneral, csKeyToolbarConfig, ToolbarConfig);
end;


end.
