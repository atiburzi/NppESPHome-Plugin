unit UnitFormProjects;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, ESPHomeShared, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, NppPlugin, NppPluginDockingForms,
  Vcl.StdCtrls, Vcl.VirtualImageList,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Menus, VirtualTrees.BaseTree, VirtualTrees,
  VirtualTrees.Types, Vcl.ActnList,
  Vcl.Buttons, Vcl.ImgList,
  System.UITypes,
  JvLinkLabel, System.Actions, System.ImageList, JvExControls,
  VirtualTrees.BaseAncestorVCL, VirtualTrees.AncestorVCL, Vcl.ToolWin;

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
    VirtualImageList24: TVirtualImageList;
    ToolBarCommands: TToolBar;
    ToolButtonRun: TToolButton;
    ToolButtonCompile: TToolButton;
    ToolButtonUpload: TToolButton;
    ToolButtonShowLogs: TToolButton;
    ToolButtonClean: TToolButton;
    ToolButtonSep2: TToolButton;
    ToolButtonSep1: TToolButton;
    ToolButtonOpen: TToolButton;
    VirtualImageList16: TVirtualImageList;
    FileOpenDialogProject: TFileOpenDialog;
    PopupMenuProjects: TPopupMenu;
    PopupMenuOpen: TMenuItem;
    PopupMenuN1: TMenuItem;
    PopupMenuRun: TMenuItem;
    PopupMenuCompile: TMenuItem;
    ActionList: TActionList;
    ActionOpen: TAction;
    ActionRun: TAction;
    ActionCompile: TAction;
    ActionUpload: TAction;
    ActionShowLogs: TAction;
    ActionClean: TAction;
    ActionSettings: TAction;
    ActionAddProject: TAction;
    ActionRemoveProject: TAction;
    PopupMenuUpload: TMenuItem;
    PopupMenuShowLogs: TMenuItem;
    PopupMenuClean: TMenuItem;
    PopupMenuN2: TMenuItem;
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
    ButtonMenuTemplates: TSpeedButton;
    PopUpMenuN5: TMenuItem;
    PopupMenuDownloadTemplates: TMenuItem;
    PopupMenuRemoveProject: TMenuItem;
    ActionCleanAll: TAction;
    PopupMenuCleanAll: TMenuItem;
    PopupMenuN4: TMenuItem;
    PopupMenuRefreshDevice: TMenuItem;
    ActionAddDeps: TAction;
    ToolButtonSep0: TToolButton;
    ToolButtonAddDeps: TToolButton;
    ToolButtonRemoveDep: TToolButton;
    ActionRemoveDep: TAction;
    VirtualImageList20: TVirtualImageList;
    PopupMenuDeps: TPopupMenu;
    PopupMenuRemoveDep: TMenuItem;
    ActionTerminal: TAction;
    ActionExplorer: TAction;
    ToolButtonSep3: TToolButton;
    ToolButtonAddPrj: TToolButton;
    ToolButtonRemovePrj: TToolButton;
    ToolButtonSettings: TToolButton;
    PanelStaticText: TPanel;
    StaticTextDescription: TJvLinkLabel;
    procedure FormCreate(Sender: TObject);
    procedure VirtualStringTreeProjectsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure VirtualStringTreeProjectsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
      var ImageIndex: TImageIndex);
    procedure VirtualStringTreeProjectsCollapsing(Sender: TBaseVirtualTree; Node: PVirtualNode; var Allowed: Boolean);
    procedure ActionOpenExecute(Sender: TObject);
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
    procedure VirtualStringTreeProjectsNodeClick(Sender: TBaseVirtualTree;
      const HitInfo: THitInfo);
    procedure VirtualStringTreeProjectsDblClick(Sender: TObject);
    procedure VirtualStringTreeProjectsChange(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure VirtualStringTreeProjectsCompareNodes(Sender: TBaseVirtualTree;
      Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure SplitterMoved(Sender: TObject);
    procedure ActionCleanAllExecute(Sender: TObject);
    procedure VirtualStringTreeProjectsGetPopupMenu(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; const P: TPoint;
      var AskParent: Boolean; var PopupMenu: TPopupMenu);
    procedure ToolButtonTerminalClick(Sender: TObject);
    procedure ToolButtonExplorerClick(Sender: TObject);
    procedure ActionAddDepsExecute(Sender: TObject);
    procedure ActionRemoveDepExecute(Sender: TObject);
    procedure StaticTextDescriptionLinkClick(Sender: TObject;
      LinkNumber: Integer; LinkText, LinkParam: string);


  private
    { Private declarations }
  public
    procedure ToggleDarkMode; override;
    procedure RefreshProjectsList;
    procedure RefreshCategoryList;
    procedure ReloadAndRefreshTemplates;
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
  System.Types, System.StrUtils, ESPHomePlugin, NppSupport, SciSupport, Math, System.IOUtils, Winapi.ShellAPI, TDMB;

procedure TFormProjects.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if Action = caHide then
    ConfigIniFile.WriteBool(csSectionGeneral, csKeyProjectWindow, False);
end;

procedure TFormProjects.FormCreate(Sender: TObject);
begin
  inherited;
  PanelTop.Height := ConfigIniFile.ReadInteger(csSectionGeneral, csKeyProjectPanelSize, 300);
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

procedure TFormProjects.ReloadAndRefreshTemplates;
begin
  TemplateList.Refresh;
  VirtualStringTreeTemplates.BeginUpdate;
  RefreshCategoryList;
  RefreshTemplatesList(EditTextFilter.Text, ComboBoxCategories.Text);;
  VirtualStringTreeTemplates.EndUpdate;
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

  AssignWindowIcon(Icon);
  AssignImageResources(VirtualImageList16);
  AssignImageResources(VirtualImageList20);
  AssignImageResources(VirtualImageList24);

  if Plugin.IsDarkModeEnabled then
  begin
    DarkModeColors := Default(TNppDarkModeColors);
    Plugin.GetDarkModeColors(@DarkModeColors);
    Self.Color := TColor(DarkModeColors.Background);
    Self.Font.Color := TColor(DarkModeColors.Text);
    ToolbarCommands.HotTrackColor := TColor(DarkModeColors.hotEdge);
  end
  else
  begin
    Self.Color := clBtnFace;
    Self.Font.Color := clWindowText;
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

procedure TFormProjects.ToolButtonExplorerClick(Sender: TObject);
begin
  inherited;
  ESPHomePlugin.Plugin.StartExplorer;
end;

procedure TFormProjects.ToolButtonTerminalClick(Sender: TObject);
begin
  inherited;
  ESPHomePlugin.Plugin.StartTerminal;
end;

procedure TFormProjects.VirtualStringTreeProjectsChange(
  Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  FileName: string;
begin
  inherited;
  if Assigned(Node) then
  begin
    FileName := PProjectNode(Node.GetData)^.FileName;
    if FileName <> ESPHomePlugin.Plugin.GetFullCurrentPath then
      ESPHomePlugin.Plugin.SwitchToFile(FileName);
  end;
end;

procedure TFormProjects.VirtualStringTreeProjectsCollapsing(Sender: TBaseVirtualTree; Node: PVirtualNode; var Allowed: Boolean);
begin
  inherited;
  Allowed := False;
end;

procedure TFormProjects.VirtualStringTreeProjectsCompareNodes(
  Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex;
  var Result: Integer);
var
  Data1, Data2: PProjectNode;
begin
  inherited;
  Data1 := Sender.GetNodeData(Node1);
  Data2 := Sender.GetNodeData(Node2);
  Result := CompareText(Data1^.Caption, Data2^.Caption);
end;

procedure TFormProjects.VirtualStringTreeProjectsDblClick(Sender: TObject);
var
  S: string;
  Node: PVirtualNode;
begin
  inherited;
  S := '';
  Node := TVirtualStringTree(Sender).FocusedNode;
  if Assigned(Node) then
    S := PProjectNode(Node.GetData)^.FileName;
  ESPHomePlugin.Plugin.OpenFile(S);
end;

procedure TFormProjects.VirtualStringTreeProjectsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var
  Ghosted: Boolean; var ImageIndex: TImageIndex);
var
  FileExt: string;
  Data: PProjectNode;
begin
  inherited;
  Data := Sender.GetNodeData(Node);
  if Kind in [ikNormal, ikSelected] then
  begin
    if Data^.Level >= 0 then
    begin
      FileExt := ExtractFileExt(Data^.FileName).Replace('.', 'file_', [rfIgnoreCase]).Replace('yml', 'yaml', [rfIgnoreCase]);
      ImageIndex := VirtualStringTreeProjects.Images.GetIndexByName(FileExt);
      if ImageIndex < 0 then
        ImageIndex := VirtualStringTreeProjects.Images.GetIndexByName('file_any');
    end
    else
      ImageIndex := VirtualStringTreeProjects.Images.GetIndexByName('mi_' + Data^.Project.Microcontroller);
  end;
end;

procedure TFormProjects.VirtualStringTreeProjectsGetPopupMenu(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  const P: TPoint; var AskParent: Boolean; var PopupMenu: TPopupMenu);
var
  Data: PProjectNode;
begin
  inherited;
  PopupMenu := nil;
  AskParent := False;
  if Assigned(Node) then
  begin
    Data := Sender.GetNodeData(Node);
    if Data^.Level < 0 then
      PopupMenu := PopupMenuProjects
    else
      PopupMenu := PopupMenuDeps;
  end;
end;

procedure TFormProjects.VirtualStringTreeProjectsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Data: PProjectNode;
begin
  inherited;
  Data := Sender.GetNodeData(Node);
  if Data^.Level < 0 then
    CellText := Format('%s (%s)', [Data^.Caption, ExtractFileName(Data^.FileName)])
  else
    CellText := Data^.Caption;
end;

procedure TFormProjects.VirtualStringTreeProjectsNodeClick(
  Sender: TBaseVirtualTree; const HitInfo: THitInfo);
var
  Data: PProjectNode;
begin
  inherited;
  ProjectList.Current := nil;
  if Assigned(HitInfo.HitNode) then
  begin
    Data := Sender.GetNodeData(HitInfo.HitNode);
    if Assigned(Data) then
      ProjectList.Current := Data^.Project;
  end;
  RefreshToolbar;
  ESPHomePlugin.Plugin.RefreshNppTitle;
  ESPHomePlugin.Plugin.RefreshPluginMenu;
end;

resourcestring
  rsOpenOnlineHelp = 'Open help';

procedure TFormProjects.VirtualStringTreeTemplatesChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  S: string;
  Data: PTemplate;
begin
  inherited;
  S := '';
  if Assigned(Node) then
  begin
    Data := Sender.GetNodeData(Node);
    if Assigned(Data) then
    begin
      S := Data^.Description;
      if Data.OnlineHelp <> '' then
        S := Format('%s <link href="%s">%s</link>', [S, Data^.OnlineHelp, rsOpenOnlineHelp]);
    end;
  end;
  StaticTextDescription.Caption := S;
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
  if Column = 2 then
    HintText := Data^.OnlineHelp
  else
    HintText := Data^.Description;
end;

procedure TFormProjects.VirtualStringTreeTemplatesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Data: PTemplate;
begin
  inherited;
  Data := Sender.GetNodeData(Node);
  CellText := '';
  if Column = 0 then
    CellText := Data^.Name
  else if Column = 1 then
    CellText := Data^.Category;
end;

procedure TFormProjects.ActionRemoveDepExecute(Sender: TObject);
var
  Node: PVirtualNode;
  Data: PProjectNode;
begin
  inherited;
  if VirtualStringTreeProjects.SelectedCount <> 1 then
    Exit;
  Node := VirtualStringTreeProjects.GetFirstSelected;
  if Assigned(Node) then
  begin
    Data := Node.GetData;
    if Assigned(Data) then
      if Data.Level >= 0 then
        ESPHomePlugin.Plugin.DependencyRemove(Data.FileName);
  end;
end;

procedure TFormProjects.ActionRemoveProjectExecute(Sender: TObject);
var
  I: Integer;
begin
  inherited;
  if Assigned(ProjectList.Current) then
  begin
    if TD(Format(rsKnownProjectRemoval, [ProjectList.Current.FriendlyName])).Text(rsKnownProjectRemoval2).WindowCaption(rsMessageBoxWarning).
      SetFlags([tfAllowDialogCancellation]).Warning.YesNo.Execute (Self) = mrYes then
    begin
      I := ProjectList.IndexOf(ProjectList.Current);
      ProjectList.Delete(I);
      if ProjectList.Count > 0 then
        ProjectList.Current := ProjectList.Items[Max(0, I - 1)]
      else
        ProjectList.Current := nil;
      ProjectList.SaveConfig;
      ESPHomePlugin.Plugin.RefreshProjectList;
    end;
  end;
end;

procedure TFormProjects.ActionAddDepsExecute(Sender: TObject);
begin
  inherited;
  ESPHomePlugin.Plugin.DependencyAdd;
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
      TD(Format(rsProjectAlreadyExists, [ExtractFileName(FileOpenDialogProject.FileName)])).WindowCaption(rsMessageBoxError).
        Text(rsProjectAlreadyExists2).SetFlags([tfAllowDialogCancellation]).Error.OK.Execute(Self);
      Exit;
    end;
    Project := TProject.Create(FileOpenDialogProject.FileName);
    if Project.IsValid then
    begin
      ProjectList.Add(Project);
      ProjectList.Current := Project;
      ProjectList.SaveConfig;
      ESPHomePlugin.Plugin.RefreshProjectList;
    end
    else
    begin
      Project.Free;
      TD(Format(rsInvalidProjectFile, [ExtractFileName(FileOpenDialogProject.FileName)])).Text(rsInvalidProjectFile2).WindowCaption(rsMessageBoxError).
        Error.OK.SetFlags([tfAllowDialogCancellation]).Execute(Self);
    end;
  end;
end;

procedure TFormProjects.ActionCleanAllExecute(Sender: TObject);
begin
  inherited;
  ESPHomePlugin.Plugin.CommandCleanAll;
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

procedure TFormProjects.ActionOpenExecute(Sender: TObject);
begin
  inherited;
  ESPHomePlugin.Plugin.ProjectOpenFiles;
end;

procedure TFormProjects.ActionRunExecute(Sender: TObject);
begin
  inherited;
  ESPHomePlugin.Plugin.CommandRun;
end;

procedure TFormProjects.ActionSettingsExecute(Sender: TObject);
begin
  inherited;
  ESPHomePlugin.Plugin.ProjectConfigure;
end;

procedure TFormProjects.ActionShowLogsExecute(Sender: TObject);
begin
  inherited;
  ESPHomePlugin.Plugin.CommandLogs;
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
var
  Data: PProjectNode;
begin
  ToolButtonSettings.Enabled := Assigned(ProjectList.Current);
  ToolButtonOpen.Enabled := Assigned(ProjectList.Current);
  ToolButtonRun.Enabled := Assigned(ProjectList.Current);
  ToolButtonCompile.Enabled := Assigned(ProjectList.Current);
  ToolButtonUpload.Enabled := Assigned(ProjectList.Current);
  ToolButtonShowLogs.Enabled := Assigned(ProjectList.Current);
  ToolButtonClean.Enabled := Assigned(ProjectList.Current);
  ToolButtonRemovePrj.Enabled := Assigned(ProjectList.Current);

  if VirtualStringTreeProjects.SelectedCount = 1 then
  begin
    Data := VirtualStringTreeProjects.GetFirstSelected.GetData;
    ToolButtonRemovePrj.Enabled := True;
    ToolButtonAddDeps.Enabled := Data.Level < 0;
    ToolButtonRemoveDep.Enabled := Data.Level >= 0;
  end
  else
  begin
    ToolButtonAddDeps.Enabled := False;
    ToolButtonRemovePrj.Enabled := False;
    ToolButtonRemoveDep.Enabled := False;
  end;
end;

procedure TFormProjects.SplitterMoved(Sender: TObject);
begin
  inherited;
  ConfigIniFile.WriteInteger(csSectionGeneral, csKeyProjectPanelSize, PanelTop.Height);
end;

procedure TFormProjects.StaticTextDescriptionLinkClick(Sender: TObject;
  LinkNumber: Integer; LinkText, LinkParam: string);
begin
  inherited;
  ShellExecute(0, 'open', PChar(LinkParam), nil, nil, SW_SHOWNORMAL);
end;

procedure TFormProjects.PopupMenuReloadXMLFileConfigurationClick(Sender: TObject);
begin
  inherited;
  ReloadAndRefreshTemplates;
end;

procedure TFormProjects.PopupMenuTemplatesPopup(Sender: TObject);
begin
  inherited;
  //PopupMenuAddTemplate.Enabled := Plugin.GetFullPathFromBufferId(Plugin.GetCurrentBufferId) = TemplateFile;
  PopupMenuReloadXMLFileConfiguration.Enabled := TFile.Exists(TemplateFile) and (TFile.GetSize(TemplateFile) > 0);
end;

procedure TFormProjects.ComboBoxCategoriesChange(Sender: TObject);
begin
  inherited;
  RefreshTemplatesList(EditTextFilter.Text, ComboBoxCategories.Text);
end;

procedure TFormProjects.PopupMenuDownloadTemplatesClick(Sender: TObject);
var
  Flag: Boolean;
begin
  if TD(rsConfirmOverwriteTemplates).Text(rsConfirmOverwriteTemplates2).Text(rsConfirmOverwriteTemplates3).Verification(rsConfirmOverwriteTemplates4, @Flag).WindowCaption(rsMessageBoxWarning).Warning.YesNo.
    SetFlags([tfAllowDialogCancellation]).Execute(Self) = mrYes then
  begin
    if Flag then
    begin
      DownloadTemplateFileFromGitHub;
      PopupMenuReloadXMLFileConfigurationClick(nil);
      TD(rsTemplatesXMLDownloaded).WindowCaption(rsMessageBoxInfo).Info.OK.SetFlags([tfAllowDialogCancellation]).Execute(Self);
    end;
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
  Node: PVirtualNode;
begin
  FileName := PlugIn.GetFullCurrentPath;
  P := ProjectList.GetProjectFromFileName(FileName, True);
  if Assigned(P) then
  begin
    ProjectList.Current := P;
    RefreshToolbar;
    ESPHomePlugin.Plugin.RefreshPluginMenu;
    ESPHomePlugin.Plugin.RefreshNppTitle;
  end;
  Node := GetVirtualNodeFromFileName(FileName);
  if Assigned(Node) then
  begin
    VirtualStringTreeProjects.ClearSelection;
    VirtualStringTreeProjects.AddToSelection(Node, True);
  end;
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
