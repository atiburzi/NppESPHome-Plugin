unit UnitFormProjects;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, ESPHomeShared, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, NppPlugin, NppPluginDockingForms,
  Vcl.StdCtrls, Vcl.ImgList, Vcl.VirtualImageList, Vcl.ImageCollection,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Menus, VirtualTrees.BaseTree, VirtualTrees,
  VirtualTrees.Types, Vcl.ActnList, JvStaticText, System.Actions, System.ImageList, Vcl.BaseImageCollection, JvExControls, VirtualTrees.BaseAncestorVCL,
  VirtualTrees.AncestorVCL, Vcl.ToolWin, Vcl.Buttons;

type
  PProjectNode = ^TProjectNode;
  TProjectNode = record
    Caption: string;
    FileName: string;
    Level: Integer;
    Project: TProject;
  end;

type
  TFormProjects = class(TNppPluginDockingForm)
    ImageCollectionDark: TImageCollection;
    VirtualImageListDark24: TVirtualImageList;
    ImageCollectionLight: TImageCollection;
    VirtualImageListLight24: TVirtualImageList;
    ToolBarCommands: TToolBar;
    ToolButtonRun: TToolButton;
    ToolButtonCompile: TToolButton;
    ToolButtonUpload: TToolButton;
    ToolButtonShowLogs: TToolButton;
    ToolButtonClean: TToolButton;
    ToolButtonSep2: TToolButton;
    ToolButtonVisit: TToolButton;
    ToolButtonSep3: TToolButton;
    ToolButtonSep1: TToolButton;
    ToolButtonOpen: TToolButton;
    ToolButtonOpenDeps: TToolButton;
    VirtualImageListLight16: TVirtualImageList;
    VirtualImageListDark16: TVirtualImageList;
    ToolButtonSettings: TToolButton;
    PopupMenuAddRemove: TPopupMenu;
    MenuItemAddNewProject: TMenuItem;
    MenuItemRemoveProject: TMenuItem;
    FileOpenDialogProject: TFileOpenDialog;
    PopupMenuProjects: TPopupMenu;
    PopupMenuOpen: TMenuItem;
    PopupMenuOpenDeps: TMenuItem;
    PopupMenuN1: TMenuItem;
    PopupMenuRun: TMenuItem;
    PopupMenuCompile: TMenuItem;
    ActionList: TActionList;
    ActionOpen: TAction;
    ActionOpenDeps: TAction;
    ActionRun: TAction;
    ActionCompile: TAction;
    ActionUpload: TAction;
    ActionShowLogs: TAction;
    ActionClean: TAction;
    ActionVisit: TAction;
    ActionSettings: TAction;
    ActionAddProject: TAction;
    ActionRemoveProject: TAction;
    PopupMenuUpload: TMenuItem;
    PopupMenuShowLogs: TMenuItem;
    PopupMenuClean: TMenuItem;
    PopupMenuN2: TMenuItem;
    PopupMenuVisit: TMenuItem;
    PopupMenuN3: TMenuItem;
    PopupMenuSettings: TMenuItem;
    PanelTop: TPanel;
    GroupBoxProjects: TGroupBox;
    VirtualStringTreeProjects: TVirtualStringTree;
    PanelBottom: TPanel;
    GroupBoxTemplates: TGroupBox;
    LabelFilter: TLabel;
    LabelCategory: TLabel;
    EditTextFilter: TButtonedEdit;
    ComboBoxCategories: TComboBox;
    Splitter: TSplitter;
    VirtualStringTreeTemplates: TVirtualStringTree;
    PopupMenuTemplates: TPopupMenu;
    PopupMenuEditTemplatesXMLFile: TMenuItem;
    PopupMenuReloadXMLFileConfiguration: TMenuItem;
    StaticTextDescription: TJvStaticText;
    ButtonMenuTemplates: TSpeedButton;
    PopUpMenuN4: TMenuItem;
    PopupMenuDownloadTemplates: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure VirtualStringTreeProjectsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure VirtualStringTreeProjectsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
      var ImageIndex: TImageIndex);
    procedure VirtualStringTreeProjectsCollapsing(Sender: TBaseVirtualTree; Node: PVirtualNode; var Allowed: Boolean);
    procedure VirtualStringTreeProjectsChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure ActionOpenExecute(Sender: TObject);
    procedure ActionOpenDepsExecute(Sender: TObject);
    procedure ActionAddProjectExecute(Sender: TObject);
    procedure ActionRemoveProjectExecute(Sender: TObject);
    procedure ActionCleanExecute(Sender: TObject);
    procedure ActionCompileExecute(Sender: TObject);
    procedure ActionRunExecute(Sender: TObject);
    procedure ActionSettingsExecute(Sender: TObject);
    procedure ActionShowLogsExecute(Sender: TObject);
    procedure ActionUploadExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure VirtualStringTreeTemplatesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure VirtualStringTreeTemplatesChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure EditTextFilterChange(Sender: TObject);
    procedure ComboBoxCategoriesChange(Sender: TObject);
    procedure VirtualStringTreeTemplatesDblClick(Sender: TObject);
    procedure EditTextFilterRightButtonClick(Sender: TObject);
    procedure PopupMenuEditTemplatesXMLFileClick(Sender: TObject);
    procedure PopupMenuReloadXMLFileConfigurationClick(Sender: TObject);
    procedure VirtualStringTreeTemplatesGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      var LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: string);
    procedure ButtonMenuTemplatesClick(Sender: TObject);
    procedure PopupMenuDownloadTemplatesClick(Sender: TObject);
    procedure PopupMenuTemplatesPopup(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ToggleDarkMode; override;
    procedure RefreshProjectsList;
    procedure RefreshCategoryList;
    procedure RefreshTemplatesList(const Component: string = ''; const Category: string = '');    
    procedure RefreshToolbar;
    procedure CurrentDocumentChanged;
    function GetVirtualNodeFromFileName(const FileName: string): PVirtualNode;
  end;

var
  FormProjects: TFormProjects;

implementation

{$R *.dfm}

uses
  System.StrUtils, ESPHomePlugin, NppSupport, SciSupport, Math, System.IOUtils;

procedure TFormProjects.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if Action = caHide then
    ConfigFile.WriteBool(csSectionGeneral, csKeyProjectWindow, False);
end;

procedure TFormProjects.FormCreate(Sender: TObject);
begin
  VirtualStringTreeProjects.NodeDataSize := SizeOf(TProjectNode);
  VirtualStringTreeTemplates.NodeDataSize := SizeOf(TTemplate);
  RefreshProjectsList;
  RefreshCategoryList;
  RefreshTemplatesList;
end;

procedure TFormProjects.RefreshProjectsList;
var
  P: TProject;
  I: Integer;
  Node: PVirtualNode;
  Data: PProjectNode;
begin
  VirtualStringTreeProjects.BeginUpdate;
  VirtualStringTreeProjects.Clear;
  for P in ProjectList do
    if P.IsValid then
    begin
      Node := VirtualStringTreeProjects.AddChild(nil);
      Data := VirtualStringTreeProjects.GetNodeData(Node);
      Data.Caption := P.FriendlyName;
      Data.FileName := P.FileName;
      Data.Level := -1;
      Data.Project := P;
      for I := 0 to P.OptionDependencies.Count - 1 do
      begin
        Data := VirtualStringTreeProjects.GetNodeData(VirtualStringTreeProjects.AddChild(Node));
        Data.FileName := P.OptionDependencies[I];
        Data.Caption := ExtractFileName(Data.FileName);
        Data.Level := I;
        Data.Project := P;
      end;
    end;
  VirtualStringTreeProjects.ClearSelection;
  if Assigned(ProjectList.Current) then
  begin
    Node := GetVirtualNodeFromFileName(ProjectList.Current.FileName);
    if Assigned(Node) then
      VirtualStringTreeProjects.AddToSelection(Node, True);
  end;
  VirtualStringTreeProjects.FullExpand;
  VirtualStringTreeProjects.EndUpdate;
  RefreshToolbar;
end;

procedure TFormProjects.RefreshCategoryList;
var
  Category: string;
  Template: TTemplate;
  Categories: TStringList;
begin
  Categories := TStringList.Create(dupIgnore, True, False);
  for Template in TemplateList do
    Categories.Add(Template.Category);
  ComboBoxCategories.Items.BeginUpdate;
  ComboBoxCategories.Clear;   
  ComboBoxCategories.Items.Add(rsAnyCategory);  
  for Category in Categories do
    ComboBoxCategories.Items.Add(Category);
  ComboBoxCategories.ItemIndex := 0;   
  Categories.Free;
  ComboBoxCategories.Items.EndUpdate;  
end;

procedure TFormProjects.RefreshTemplatesList(const Component: string = ''; const Category: string = '');
var
  Template: TTemplate;
  Data: PTemplate; 
  Node: PVirtualNode;
  MaxWidth0, MaxWidth1: Integer;
begin
  MaxWidth0 := VirtualStringTreeTemplates.Canvas.TextWidth(VirtualStringTreeTemplates.Header.Columns[0].Text) + 16;
  MaxWidth1 := VirtualStringTreeTemplates.Canvas.TextWidth(VirtualStringTreeTemplates.Header.Columns[1].Text) + 16;
  VirtualStringTreeTemplates.BeginUpdate;
  VirtualStringTreeTemplates.Clear;
  for Template in TemplateList do
  begin  
    if ((Category = '') or (Category = rsAnyCategory) or (Template.Category = Category)) and
        ((Component = '') or ContainsText(Template.Name, Component)) then  
    begin
      Node := VirtualStringTreeTemplates.AddChild(nil);
      Data := VirtualStringTreeTemplates.GetNodeData(Node);
      Data^ := Template;
      MaxWidth0 := Max(MaxWidth0, VirtualStringTreeTemplates.Canvas.TextWidth(Data^.Name) + 16);
      MaxWidth1 := Max(MaxWidth1, VirtualStringTreeTemplates.Canvas.TextWidth(Data^.Category) + 16);
    end;
  end; 
  VirtualStringTreeTemplates.Header.Columns[0].Width := MaxWidth0;
  VirtualStringTreeTemplates.Header.Columns[1].Width := MaxWidth1;
  VirtualStringTreeTemplates.FullExpand;
  VirtualStringTreeTemplates.EndUpdate;
end;

procedure TFormProjects.ToggleDarkMode;
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
    Icon.Handle := LoadImage(HInstance, resMainIconLight, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR);
    VirtualStringTreeProjects.Images := VirtualImageListLight16;
    ToolbarCommands.Images := VirtualImageListLight24;
    PopupMenuAddRemove.Images := VirtualImageListLight16;
    PopupMenuProjects.Images := VirtualImageListLight16;
    EditTextFilter.Images := VirtualImageListLight16;
    ButtonMenuTemplates.Images := VirtualImageListLight24;
    ToolbarCommands.HotTrackColor := TColor(DarkModeColors.hotEdge);
  end
  else
  begin
    Self.Color := clBtnFace;
    Self.Font.Color := clWindowText;
    Icon.Handle := LoadImage(HInstance, resMainIconDark, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR);
    VirtualStringTreeProjects.Images := VirtualImageListDark16;
    ToolbarCommands.Images := VirtualImageListDark24;
    PopupMenuAddRemove.Images := VirtualImageListDark16;
    PopupMenuProjects.Images := VirtualImageListDark16;
    EditTextFilter.Images := VirtualImageListDark16;
    ButtonMenuTemplates.Images := VirtualImageListDark24;
    ToolbarCommands.HotTrackColor := clActiveCaption;
  end;
  VirtualStringTreeProjects.Colors.FocusedSelectionColor := ToolbarCommands.HotTrackColor;
  VirtualStringTreeProjects.Colors.FocusedSelectionBorderColor := ToolbarCommands.HotTrackColor;
  VirtualStringTreeProjects.Colors.SelectionTextColor := Self.Font.Color;
  VirtualStringTreeProjects.Colors.UnfocusedSelectionColor := ToolbarCommands.HotTrackColor;
  VirtualStringTreeProjects.Colors.UnfocusedSelectionBorderColor := ToolbarCommands.HotTrackColor;

  VirtualStringTreeTemplates.Colors.FocusedSelectionColor := ToolbarCommands.HotTrackColor;
  VirtualStringTreeTemplates.Colors.FocusedSelectionBorderColor := ToolbarCommands.HotTrackColor;
  VirtualStringTreeTemplates.Colors.SelectionTextColor := Self.Font.Color;
  VirtualStringTreeTemplates.Colors.UnfocusedSelectionColor := ToolbarCommands.HotTrackColor;
  VirtualStringTreeTemplates.Colors.UnfocusedSelectionBorderColor := ToolbarCommands.HotTrackColor;

  ToolbarCommands.GradientStartColor := Self.Color;
  ToolbarCommands.GradientEndColor := Self.Color;

  StaticTextDescription.Font.Color := Self.Font.Color;

  Repaint;
end;

procedure TFormProjects.VirtualStringTreeProjectsChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PProjectNode;
begin
  inherited;
  ProjectList.Current := nil;
  if Assigned(Node) then
  begin
    Data := Sender.GetNodeData(Node);
    if Assigned(Data) then
      ProjectList.Current := Data^.Project;
  end;
  RefreshToolbar;
  ESPHomePlugin.Plugin.UpdatePluginMenu;
end;

procedure TFormProjects.VirtualStringTreeProjectsCollapsing(Sender: TBaseVirtualTree; Node: PVirtualNode; var Allowed: Boolean);
begin
  inherited;
  Allowed := False;
end;

procedure TFormProjects.VirtualStringTreeProjectsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: TImageIndex);
var
  Data: PProjectNode;
begin
  inherited;
  Data := Sender.GetNodeData(Node);
  if Kind in [ikNormal, ikSelected] then
  begin
    if Data^.Level >= 0 then
      ImageIndex := VirtualStringTreeProjects.Images.GetIndexByName('dependency')
    else
      ImageIndex := VirtualStringTreeProjects.Images.GetIndexByName('projects');
  end;
  if (Kind in [ikState]) and (Data^.Level < 0) then
  begin
    if Data^.Project.IsOnline then
      ImageIndex := VirtualStringTreeProjects.Images.GetIndexByName('wifi_on')
    else
      ImageIndex := VirtualStringTreeProjects.Images.GetIndexByName('wifi_off');
  end;
end;

procedure TFormProjects.VirtualStringTreeProjectsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Data: PProjectNode;
begin
  inherited;
  Data := Sender.GetNodeData(Node);
  CellText := Data^.Caption;
end;

procedure TFormProjects.VirtualStringTreeTemplatesChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PTemplate;
begin
  inherited;
  if Assigned(Node) then
  begin
    Data := Sender.GetNodeData(Node);
    if Assigned(Data) then
      StaticTextDescription.Caption := Data^.Description;
  end;
end;

procedure TFormProjects.VirtualStringTreeTemplatesDblClick(Sender: TObject);
var
  Data: PTemplate; 
  Node: PVirtualNode;
  currentScintilla: Integer;
  hSci: HWND;
  Utf8: UTF8String;
begin
  inherited;
  Node := VirtualStringTreeTemplates.GetFirstSelected();
  if Assigned(Node) then
  begin
    Data := VirtualStringTreeTemplates.GetNodeData(Node);
    if Assigned(Data) then
    begin
      SendMessage(Plugin.NppData.NppHandle, NPPM_GETCURRENTSCINTILLA, 0, LPARAM(@currentScintilla));
      if currentScintilla = 0 then
        hSci := Plugin.NppData.ScintillaMainHandle
      else
        hSci := Plugin.NppData.ScintillaSecondHandle;
      Utf8 := UTF8String(Data^.YAML);
      SendMessage(hSci, SCI_REPLACESEL, 0, LPARAM(PAnsiChar(Utf8)));
    end;
  end;
end;

procedure TFormProjects.VirtualStringTreeTemplatesGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  var LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: string);
var
  Data: PTemplate;
begin
  inherited;
  Data := Sender.GetNodeData(Node);
  HintText := Data^.Description;
end;

procedure TFormProjects.VirtualStringTreeTemplatesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Data: PTemplate;
begin
  inherited;
  Data := Sender.GetNodeData(Node);
  if Column = 0 then
    CellText := Data^.Name
  else if Column = 1 then
    CellText := Data^.Category;
end;

procedure TFormProjects.ActionRemoveProjectExecute(Sender: TObject);
var
  I: Integer;
begin
  inherited;
  if Assigned(ProjectList.Current) then
  begin
    if MessageBox(Self.Handle, PWideChar(Format(rsKnownProjectRemoval, [ProjectList.Current.FriendlyName])),
      PWideChar(rsMessageBoxWarning), MB_YESNO or MB_ICONQUESTION) = IDYES then
    begin
      I := ProjectList.IndexOf(ProjectList.Current);
      ProjectList.Delete(I);
      if ProjectList.Count > 0 then
        ProjectList.Current := ProjectList.Items[Max(0, I - 1)]
      else
        ProjectList.Current := nil;
      ProjectList.SaveConfig;
      ESPHomePlugin.Plugin.UpdateProjectList;
    end;
  end;
end;

procedure TFormProjects.ActionAddProjectExecute(Sender: TObject);
var
  Project: TProject;
begin
  inherited;
  if FileOpenDialogProject.Execute(Self.Handle) then
  begin
    if Assigned(ProjectList.GetProjectFromFileName(FileOpenDialogProject.FileName)) then
    begin
      MessageBox(Handle, PWideChar(Format(rsProjectAlreadyExists,
        [ExtractFileName(FileOpenDialogProject.FileName)])),
        PWideChar(rsMessageBoxError), MB_OK or MB_ICONERROR);
      Exit;
    end;
    Project := TProject.Create(FileOpenDialogProject.FileName, True);
    if Project.IsValid then
    begin
      ProjectList.Add(Project);
      ProjectList.Current := Project;
      ProjectList.SaveConfig;
      ESPHomePlugin.Plugin.UpdateProjectList;
    end
    else
    begin
      Project.Free;
      MessageBox(Handle, PWideChar(Format(rsInvalidProjectFile,
        [ExtractFileName(FileOpenDialogProject.FileName)])),
        PWideChar(rsMessageBoxError), MB_OK or MB_ICONERROR);
    end;
  end;
end;

procedure TFormProjects.ActionCleanExecute(Sender: TObject);
begin
  inherited;
  ESPHomePlugin.Plugin.CommandClean;
end;

procedure TFormProjects.ActionCompileExecute(Sender: TObject);
begin
  inherited;
  ESPHomePlugin.Plugin.CommandCompile;
end;

procedure TFormProjects.ActionOpenDepsExecute(Sender: TObject);
begin
  inherited;
  ESPHomePlugin.Plugin.OpenProjectAndDependencies;
end;

procedure TFormProjects.ActionOpenExecute(Sender: TObject);
begin
  inherited;
  ESPHomePlugin.Plugin.OpenProject;
end;

procedure TFormProjects.ActionRunExecute(Sender: TObject);
begin
  inherited;
  ESPHomePlugin.Plugin.CommandRun;
end;

procedure TFormProjects.ActionSettingsExecute(Sender: TObject);
begin
  inherited;
  ESPHomePlugin.Plugin.ConfigureProject;
end;

procedure TFormProjects.ActionShowLogsExecute(Sender: TObject);
begin
  inherited;
  ESPHomePlugin.Plugin.CommandShowLogs;
end;

procedure TFormProjects.ActionUploadExecute(Sender: TObject);
begin
  inherited;
  ESPHomePlugin.Plugin.CommandUpload;
end;

procedure TFormProjects.ButtonMenuTemplatesClick(Sender: TObject);
var
  P: TPoint;
begin
  inherited;
  P := ButtonMenuTemplates.ClientToScreen(Point(0, ButtonMenuTemplates.Height));
  PopupMenuTemplates.Popup(P.X, P.Y);
end;

procedure TFormProjects.RefreshToolbar;
begin
  if Assigned(ProjectList.Current) then
  begin
    ToolButtonOpenDeps.Enabled := ProjectList.Current.OptionDependencies.Count > 0;
    ToolButtonVisit.Enabled := ProjectList.Current.HasWebServer;
  end
  else
  begin

  end;
end;

procedure TFormProjects.PopupMenuReloadXMLFileConfigurationClick(Sender: TObject);
begin
  inherited;
  TemplateList.Refresh;
  VirtualStringTreeTemplates.BeginUpdate;
  RefreshCategoryList;
  RefreshTemplatesList(EditTextFilter.Text, ComboBoxCategories.Text);;  
  VirtualStringTreeTemplates.EndUpdate;
end;

procedure TFormProjects.PopupMenuTemplatesPopup(Sender: TObject);
begin
  inherited;
  PopupMenuDownloadTemplates.Enabled := not (TFile.Exists(TemplateFile) and (TFile.GetSize(TemplateFile) > 0));
end;

procedure TFormProjects.ComboBoxCategoriesChange(Sender: TObject);
begin
  inherited;
  RefreshTemplatesList(EditTextFilter.Text, ComboBoxCategories.Text);
end;

procedure TFormProjects.PopupMenuDownloadTemplatesClick(Sender: TObject);
begin
  if MessageBox(Self.Handle, PWideChar(rsConfirmOverwriteTemplates), PWideChar(rsMessageBoxWarning), MB_YESNO or MB_ICONWARNING) = IDYES then
  begin
    DownloadTemplateFileFromGitHub;
    PopupMenuReloadXMLFileConfigurationClick(nil);
    MessageBox(Self.Handle, PWideChar(rsTemplatesXMLDownloaded), PWideChar(rsMessageBoxInfo), MB_OK or MB_ICONINFORMATION);
  end;
end;

procedure TFormProjects.PopupMenuEditTemplatesXMLFileClick(Sender: TObject);
begin
  inherited;
  Plugin.OpenFile(TemplateFile, False);
end;

procedure TFormProjects.EditTextFilterChange(Sender: TObject);
begin
  inherited;
  RefreshTemplatesList(EditTextFilter.Text, ComboBoxCategories.Text);
end;

procedure TFormProjects.EditTextFilterRightButtonClick(Sender: TObject);
begin
  inherited;
  EditTextFilter.Text := '';
end;

procedure TFormProjects.CurrentDocumentChanged;
var
  P: TProject;
  FileName: string;
begin
  FileName := PlugIn.GetFullCurrentPath;
  P := ProjectList.GetProjectFromFileName(FileName, True);
  if Assigned(P) then
    ProjectList.Current := P;
  ESPHomePlugin.Plugin.UpdateProjectList;
end;

function TFormProjects.GetVirtualNodeFromFileName(const FileName: string): PVirtualNode;
var
  Node: PVirtualNode;
  Data: PProjectNode;
begin
  Result := nil;
  Node := VirtualStringTreeProjects.GetFirst;
  while Assigned(Node) do
  begin
    Data := VirtualStringTreeProjects.GetNodeData(Node);
    if Assigned(Data) then
      if Data^.FileName = FileName then
      begin
        Result := Node;
        Exit;
      end;
    Node := VirtualStringTreeProjects.GetNext(Node);
  end;
end;


end.
