// Project configuration dialog for NppESPHome.
// Edits command, console, device, dependency, and Notepad++ integration options for the current project.
unit NppESPHome.FormConfiguration;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, NppPlugin, NppPluginForm, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.VirtualImageList, JvListComb,
  Vcl.WinXPanels, Vcl.ExtCtrls,
  JvEdit,
  Vcl.VirtualImage, Vcl.Buttons, Vcl.ImgList,
  JvCombobox, System.ImageList, JvExStdCtrls;

type
  // Modal editor for all settings stored against the current ESPHome project.
  // Event handlers persist changes immediately, while dynamic controls mirror
  // devices, monitors, dependencies, and theme resources discovered at runtime.
  TFormConfig = class(TNppPluginForm)
    ButtonClose: TButton;
    GroupBoxProject: TGroupBox;
    VirtualImageList: TVirtualImageList;
    FileOpenDialogDependency: TFileOpenDialog;
    LabelOptionRunAdditionalParameters: TLabel;
    CheckBoxOptionRunNoLogs: TCheckBox;
    LabelOptionRunNoLogs: TLabel;
    CheckBoxOptionRunReset: TCheckBox;
    LabelOptionRunReset: TLabel;
    GroupBoxOptions: TGroupBox;
    TreeViewOptions: TTreeView;
    CardPanelOptions: TCardPanel;
    CardProjectOptions: TCard;
    CardESPHomeOptions: TCard;
    ListBoxDependencies: TListBox;
    ButtonAddDeps: TButton;
    ButtonRemoveDeps: TButton;
    LabelDependencies: TLabel;
    CardRunOptions: TCard;
    CardCompileOptions: TCard;
    CardUploadOptions: TCard;
    CardLogsOptions: TCard;
    CardCleanOptions: TCard;
    CardNppOptions: TCard;
    LabelLogLevel: TLabel;
    ComboBoxLogLevel: TJvImageComboBox;
    LabelDevice: TLabel;
    ComboBoxDevice: TJvImageComboBox;
    LabelAutosave: TLabel;
    ComboBoxOptionAutosave: TJvImageComboBox;
    LabelOptionESPHomeAdditionalParameters: TLabel;
    CheckBoxOptionLogsReset: TCheckBox;
    LabelOptionLogsReset: TLabel;
    CheckBoxOptionCompileGenerateOnly: TCheckBox;
    LabelOptionCompileGenerateOnly: TLabel;
    EditOptionESPHomeAdditionalParameters: TJvEdit;
    EditOptionRunAdditionalParameters: TJvEdit;
    LinkLabelRunHelp: TLinkLabel;
    LinkLabelCompileHelp: TLinkLabel;
    LinkLabelESPHome: TLinkLabel;
    LabelOptionUploadAdditionalParameters: TLabel;
    EditOptionUploadAdditionalParameters: TJvEdit;
    EditOptionLogsAdditionalParameters: TJvEdit;
    LabelOptionLogsAdditionalParameters: TLabel;
    LinkLabelLogsOptions: TLinkLabel;
    LinkLabelUploadOptions: TLinkLabel;
    LinkLabelHelpOptions: TLinkLabel;
    LabelDeviceDesc: TLabel;
    CardConsoleOptions: TCard;
    LabelOptionConsoleAutoclose: TLabel;
    ComboBoxOptionConsoleAutoclose: TJvImageComboBox;
    CheckBoxOptionAlwaysOnTop: TCheckBox;
    LabelOptionConsoleAlwaysOnTop: TLabel;
    ComboBoxOptionConsolePosition: TJvImageComboBox;
    LabelOptionConsolePosition: TLabel;
    ComboBoxOptionConsoleMonitor: TJvImageComboBox;
    LabelOptionConsoleMonitor: TLabel;
    CheckBoxOptionSoloMode: TCheckBox;
    LabelOptionConsoleSoloMode: TLabel;
    LabelOptionCompileAdditionalParameters: TLabel;
    EditOptionCompileAdditionalParameters: TJvEdit;
    LabelOptionCleanAdditionalParameters: TLabel;
    EditOptionCleanAdditionalParameters: TJvEdit;
    VirtualImageMC: TVirtualImage;
    MemoProject: TMemo;
    SpeedButtonRefresh: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure ToggleDarkMode; override;
    procedure CheckBoxOptionRunNoLogsClick(Sender: TObject);
    procedure ComboBoxDeviceChange(Sender: TObject);
    procedure ComboBoxOptionAutosaveChange(Sender: TObject);
    procedure ButtonAddDepsClick(Sender: TObject);
    procedure ButtonRemoveDepsClick(Sender: TObject);
    procedure ComboBoxLogLevelChange(Sender: TObject);
    procedure EditOptionESPHomeAdditionalParametersChange(Sender: TObject);
    procedure CheckBoxOptionRunResetClick(Sender: TObject);
    procedure EditOptionRunAdditionalParametersChange(Sender: TObject);
    procedure CheckBoxOptionCompileGenerateOnlyClick(Sender: TObject);
    procedure EditOptionUploadAdditionalParametersChange(Sender: TObject);
    procedure CheckBoxOptionLogsResetClick(Sender: TObject);
    procedure EditOptionLogsAdditionalParametersChange(Sender: TObject);
    procedure TreeViewOptionsCollapsing(Sender: TObject; Node: TTreeNode; var AllowCollapse: Boolean);
    procedure TreeViewOptionsChange(Sender: TObject; Node: TTreeNode);
    procedure TreeViewOptionsCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure ComboBoxOptionConsoleAutocloseChange(Sender: TObject);
    procedure LinkLabelHelpLinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
    procedure CheckBoxOptionAlwaysOnTopClick(Sender: TObject);
    procedure ComboBoxOptionConsolePositionChange(Sender: TObject);
    procedure ComboBoxOptionConsoleMonitorChange(Sender: TObject);
    procedure CheckBoxOptionSoloModeClick(Sender: TObject);
    procedure EditOptionCompileAdditionalParametersChange(Sender: TObject);
    procedure EditOptionCleanAdditionalParametersChange(Sender: TObject);
    procedure TreeViewOptionsGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure SpeedButtonRefreshClick(Sender: TObject);
  private
    procedure PopulateComboDevice;
  public
    { Public declarations }
  end;

var
  FormConfiguration: TFormConfig;

implementation

{$R *.dfm}

uses
  NppESPHome.Shared, NppESPHome.Plugin, NppESPHome.FormProjects, NppMessages, Registry, Math,Winapi.ShellAPI;

// *****************************************************************************
// Purpose: Measures all list-box items and sets a horizontal scroll width wide
// enough for the longest dependency path.
// *****************************************************************************
procedure RecalcListBoxScrollWidth(AListBox: TListBox);
var
  I, W, MaxW: Integer;
begin
  MaxW := 0;
  AListBox.Canvas.Font.Assign(AListBox.Font);
  for I := 0 to AListBox.Items.Count - 1 do
  begin
    W := AListBox.Canvas.TextWidth(AListBox.Items[I]);
    if W > MaxW then
      MaxW := W;
  end;
  AListBox.ScrollWidth := MaxW + 8;
end;

// *****************************************************************************
// Purpose: Adds selected dependency files to the current project, removes the
// main project file if selected, persists the list, and refreshes dependent
// views.
// *****************************************************************************
procedure TFormConfig.ButtonAddDepsClick(Sender: TObject);
var
  I: Integer;
begin
  inherited;
  if FileOpenDialogDependency.Execute(Self.Handle) then
  begin
    ProjectList.Current.OptionDependencies.AddStrings(FileOpenDialogDependency.Files);
    I := ProjectList.Current.OptionDependencies.IndexOf(ProjectList.Current.FileName);
    if I >= 0 then
      ProjectList.Current.OptionDependencies.Delete(I);
    ProjectList.Current.SaveOptionDependencies;
    ListBoxDependencies.Items.Clear;
    ListBoxDependencies.Items.AddStrings(ProjectList.Current.OptionDependencies);
    RecalcListBoxScrollWidth(ListBoxDependencies);
    Plugin.RefreshProjectList;
    if Assigned(FormProjects) then
      FormProjects.CurrentDocumentChanged;
  end;
end;

// *****************************************************************************
// Purpose: Removes all selected dependency entries, persists the updated list,
// and restores a useful list selection.
// *****************************************************************************
procedure TFormConfig.ButtonRemoveDepsClick(Sender: TObject);
var
  I, Sel: Integer;
  Deleted: Boolean;
begin
  inherited;
  Sel := -1;
  Deleted := False;
  // Iterate backwards so deleting selected rows cannot shift pending indexes.
  for I := ListBoxDependencies.Count - 1 downto 0 do
  begin
    if ListBoxDependencies.Selected[I] then
    begin
      Sel := I;
      ListBoxDependencies.Items.Delete(I);
      ProjectList.Current.OptionDependencies.Delete(I);
      Deleted := True;
    end;
  end;
  if Deleted then
  begin
    ProjectList.Current.SaveOptionDependencies;
    if ListBoxDependencies.Count > 0 then
      ListBoxDependencies.ItemIndex := Max(0, Sel - 1);
    RecalcListBoxScrollWidth(ListBoxDependencies);
    Plugin.RefreshProjectList;
    if Assigned(FormProjects) then
      FormProjects.CurrentDocumentChanged;
  end;
end;

// *****************************************************************************
// Purpose: Persists whether ESPHome console windows should remain above other
// windows.
// *****************************************************************************
procedure TFormConfig.CheckBoxOptionAlwaysOnTopClick(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyConsoleAlwaysOnTop, CheckBoxOptionAlwaysOnTop.Checked);
end;

// *****************************************************************************
// Purpose: Persists whether compile should generate source files without
// completing a full build.
// *****************************************************************************
procedure TFormConfig.CheckBoxOptionCompileGenerateOnlyClick(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyCompileGenerateOnly, CheckBoxOptionCompileGenerateOnly.Checked);
end;

// *****************************************************************************
// Purpose: Persists whether the logs command should reset the connected device.
// *****************************************************************************
procedure TFormConfig.CheckBoxOptionLogsResetClick(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyLogsReset, CheckBoxOptionLogsReset.Checked);
end;

// *****************************************************************************
// Purpose: Persists whether the run command should suppress the log stream.
// *****************************************************************************
procedure TFormConfig.CheckBoxOptionRunNoLogsClick(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyRunNoLogs, CheckBoxOptionRunNoLogs.Checked);
end;

// *****************************************************************************
// Purpose: Persists whether the run command should reset the connected device.
// *****************************************************************************
procedure TFormConfig.CheckBoxOptionRunResetClick(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyRunReset, CheckBoxOptionRunReset.Checked);
end;

// *****************************************************************************
// Purpose: Persists whether a newly launched ESPHome console should replace an
// existing one.
// *****************************************************************************
procedure TFormConfig.CheckBoxOptionSoloModeClick(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyConsoleSoloMode, CheckBoxOptionSoloMode.Checked);
end;

// *****************************************************************************
// Purpose: Persists the selected Notepad++ auto-save policy used before ESPHome
// commands run.
// *****************************************************************************
procedure TFormConfig.ComboBoxOptionAutosaveChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyNppAutosave, ComboBoxOptionAutosave.ItemIndex);
end;

// *****************************************************************************
// Purpose: Persists additional command-line parameters for the clean command.
// *****************************************************************************
procedure TFormConfig.EditOptionCleanAdditionalParametersChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyCleanExtraParameters, EditOptionCleanAdditionalParameters.Text);
end;

// *****************************************************************************
// Purpose: Persists additional command-line parameters for the compile command.
// *****************************************************************************
procedure TFormConfig.EditOptionCompileAdditionalParametersChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyCompileExtraParameters, EditOptionCompileAdditionalParameters.Text);
end;

// *****************************************************************************
// Purpose: Persists command-line parameters shared by all ESPHome invocations.
// *****************************************************************************
procedure TFormConfig.EditOptionESPHomeAdditionalParametersChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyESPHomeExtraParameters, EditOptionESPHomeAdditionalParameters.Text);
end;

// *****************************************************************************
// Purpose: Persists additional command-line parameters for the logs command.
// *****************************************************************************
procedure TFormConfig.EditOptionLogsAdditionalParametersChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyLogsExtraParameters, EditOptionLogsAdditionalParameters.Text);
end;

// *****************************************************************************
// Purpose: Persists additional command-line parameters for the run command.
// *****************************************************************************
procedure TFormConfig.EditOptionRunAdditionalParametersChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyRunExtraParameters, EditOptionRunAdditionalParameters.Text);
end;

// *****************************************************************************
// Purpose: Persists additional command-line parameters for the upload command.
// *****************************************************************************
procedure TFormConfig.EditOptionUploadAdditionalParametersChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyUploadExtraParameters, EditOptionUploadAdditionalParameters.Text);
end;

// *****************************************************************************
// Purpose: Persists whether a successful ESPHome console process should close
// automatically.
// *****************************************************************************
procedure TFormConfig.ComboBoxOptionConsoleAutocloseChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyConsoleAutoClose, (ComboBoxOptionConsoleAutoclose.ItemIndex = 1));
end;

// *****************************************************************************
// Purpose: Persists the physical monitor selected for newly created console
// windows.
// *****************************************************************************
procedure TFormConfig.ComboBoxOptionConsoleMonitorChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyConsoleStartingMonitor, Integer(ComboBoxOptionConsoleMonitor.Items.Objects[ComboBoxOptionConsoleMonitor.ItemIndex]));
end;

// *****************************************************************************
// Purpose: Persists the preferred starting position for newly created console
// windows.
// *****************************************************************************
procedure TFormConfig.ComboBoxOptionConsolePositionChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyConsoleStartingPosition, ComboBoxOptionConsolePosition.ItemIndex);
end;

// *****************************************************************************
// Purpose: Persists the selected upload or logging target for the current
// project.
// *****************************************************************************
procedure TFormConfig.ComboBoxDeviceChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyESPHomeTargetDevice, ComboBoxDevice.Items[ComboBoxDevice.ItemIndex].Text);
end;

// *****************************************************************************
// Purpose: Persists the ESPHome log level selected for the current project.
// *****************************************************************************
procedure TFormConfig.ComboBoxLogLevelChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyESPHomeLogLevel, ComboBoxLogLevel.ItemIndex);
end;

// *****************************************************************************
// Purpose: Enumerates available monitors, labels their resolution and primary
// status, and restores the saved selection.
// *****************************************************************************
procedure PopulateMonitorCombo(Combo: TJvImageComboBox; Index: Integer);
var
  I: Integer;
  S: string;
begin
  Combo.Items.Clear;
  // Store the zero-based monitor number in Objects for direct persistence.
  for I := 0 to Screen.MonitorCount - 1 do
  begin
    S := Format('Monitor %d [%dx%d]', [I + 1, Screen.Monitors[I].Width, Screen.Monitors[I].Height]);
    if Screen.Monitors[I].Primary then
      S := S + ' (Primary)';
    Combo.Items.AddObject(S, TObject(I));
  end;
  if Combo.Items.Count > Index then
    Combo.ItemIndex := Index;
end;

// *****************************************************************************
// Purpose: Loads every project option into the corresponding control, populates
// dynamic lists, and applies the active theme.
// *****************************************************************************
procedure TFormConfig.FormCreate(Sender: TObject);
begin
  inherited;

  TreeViewOptions.FullExpand;
  TreeViewOptions.Selected := TreeViewOptions.Items[0];

  MemoProject.Text := ProjectList.Current.Description;

  if ProjectList.Current.GetOption(csKeyConsoleAutoClose, True) then
    ComboBoxOptionConsoleAutoclose.ItemIndex := 1
  else
    ComboBoxOptionConsoleAutoclose.ItemIndex := 0;

  VirtualImageMC.ImageName := 'mc_' + ProjectList.Current.Microcontroller;

  ComboBoxLogLevel.ItemIndex := ProjectList.Current.GetOption(csKeyESPHomeLogLevel, ciLogLevelDefault);
  EditOptionESPHomeAdditionalParameters.Text := ProjectList.Current.GetOption(csKeyESPHomeExtraParameters, csDefaultEmpty);
  ComboBoxOptionAutosave.ItemIndex := ProjectList.Current.GetOption(csKeyNppAutosave, ciAutoSaveAllFiles);
  CheckBoxOptionAlwaysOnTop.Checked := ProjectList.Current.GetOption(csKeyConsoleAlwaysOnTop, False);
  CheckBoxOptionSoloMode.Checked := ProjectList.Current.GetOption(csKeyConsoleSoloMode, False);
  ComboBoxOptionConsolePosition.ItemIndex := ProjectList.Current.GetOption(csKeyConsoleStartingPosition, ciConsolePosDecidedByWindows);
  PopulateMonitorCombo(ComboBoxOptionConsoleMonitor, ProjectList.Current.GetOption(csKeyConsoleStartingMonitor, 0));

  CheckBoxOptionRunNoLogs.Checked := ProjectList.Current.GetOption(csKeyRunNoLogs, False);
  CheckBoxOptionRunReset.Checked := ProjectList.Current.GetOption(csKeyRunReset, False);
  EditOptionRunAdditionalParameters.Text := ProjectList.Current.GetOption(csKeyRunExtraParameters, csDefaultEmpty);

  CheckBoxOptionCompileGenerateOnly.Checked := ProjectList.Current.GetOption(csKeyCompileGenerateOnly, False);

  EditOptionUploadAdditionalParameters.Text := ProjectList.Current.GetOption(csKeyUploadExtraParameters, csDefaultEmpty);
  EditOptionCompileAdditionalParameters.Text := ProjectList.Current.GetOption(csKeyCompileExtraParameters, csDefaultEmpty);
  EditOptionCleanAdditionalParameters.Text := ProjectList.Current.GetOption(csKeyCleanExtraParameters, csDefaultEmpty);

  CheckBoxOptionLogsReset.Checked := ProjectList.Current.GetOption(csKeyLogsReset, False);
  EditOptionLogsAdditionalParameters.Text := ProjectList.Current.GetOption(csKeyLogsExtraParameters, csDefaultEmpty);

  PopulateComboDevice;

  ProjectList.Current.LoadOptionDependencies;
  ListBoxDependencies.Items.AddStrings(ProjectList.Current.OptionDependencies);
  RecalcListBoxScrollWidth(ListBoxDependencies);

  ToggleDarkMode;
end;

// *****************************************************************************
// Purpose: Opens a clicked help URL in the user's default browser.
// *****************************************************************************
procedure TFormConfig.LinkLabelHelpLinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
begin
  inherited;
  if LinkType = sltURL then
    ShellExecute(0, 'open', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;

// *****************************************************************************
// Purpose: Applies the current Notepad++ palette, icon set, and control colors
// to the configuration dialog.
// *****************************************************************************
procedure TFormConfig.ToggleDarkMode;
var
  DarkModeColors: TNppDarkModeColors;
begin
  inherited ToggleDarkMode;

  AssignWindowIcon(Icon);
  AssignImageResources(VirtualImageList);
  AssignImageResources(VirtualImageMC);

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

  TreeViewOptions.Color := Self.Color;
  TreeViewOptions.Font.Color := Self.Font.Color;
  LabelDeviceDesc.Font.Color := Self.Font.Color;
  EditOptionRunAdditionalParameters.Font.Color := Self.Font.Color;
  EditOptionESPHomeAdditionalParameters.Font.Color := Self.Font.Color;
  EditOptionUploadAdditionalParameters.Font.Color := Self.Font.Color;
  EditOptionLogsAdditionalParameters.Font.Color := Self.Font.Color;
  EditOptionCleanAdditionalParameters.Font.Color := Self.Font.Color;
  EditOptionCompileAdditionalParameters.Font.Color := Self.Font.Color;

end;

// *****************************************************************************
// Purpose: Rebuilds the target-device list from automatic, serial-port, and
// Wi-Fi choices and restores the saved target.
// *****************************************************************************
procedure TFormConfig.PopulateComboDevice;
var
  Index: Integer;
  ComPorts: TStringList;
  Registry: TRegistry;
begin
  ComboBoxDevice.Items.Clear;
  ComboBoxDevice.Items[ComboBoxDevice.Items.AddTextItem(rsDefaultNone).Index].ImageIndex := ComboBoxDevice.Images.GetIndexByName(csIconNone);
  ComboBoxDevice.ItemIndex := 0;

  ComPorts := TStringList.Create;
  Registry := TRegistry.Create;
  Registry.RootKey := HKEY_LOCAL_MACHINE;
  Registry.Access := KEY_READ;
  if Registry.OpenKey('HARDWARE\DEVICEMAP\SERIALCOMM', False) then
  begin
    Registry.GetValueNames(ComPorts);
    for Index := 0 to ComPorts.Count - 1 do
      ComboBoxDevice.Items[ComboBoxDevice.Items.AddTextItem(Registry.ReadString(ComPorts.Strings[Index])).Index].ImageIndex := ComboBoxDevice.Images.GetIndexByName(csIconSerial);
  end;
  Registry.CloseKey;
  Registry.Destroy;
  ComPorts.Free;

  ComboBoxDevice.Items[ComboBoxDevice.Items.AddTextItem(rsDefaultWiFi).Index].ImageIndex := ComboBoxDevice.Images.GetIndexByName(csIconWiFi);

  if Assigned(ProjectList.Current) then
    for Index := 0 to ComboBoxDevice.GetCount - 1 do
      if ComboBoxDevice.GetItemText(Index) = ProjectList.Current.GetOption(csKeyESPHomeTargetDevice, '') then
        ComboBoxDevice.ItemIndex := Index;
end;

// *****************************************************************************
// Purpose: Refreshes the list of currently available target devices.
// *****************************************************************************
procedure TFormConfig.SpeedButtonRefreshClick(Sender: TObject);
begin
  inherited;
  PopulateComboDevice;
end;

// *****************************************************************************
// Purpose: Shows the option card associated with the selected navigation-tree
// node.
// *****************************************************************************
procedure TFormConfig.TreeViewOptionsChange(Sender: TObject; Node: TTreeNode);
begin
  inherited;
  CardProjectOptions.CardPanel.ActiveCardIndex:= TreeViewOptions.Selected.StateIndex;
end;

// *****************************************************************************
// Purpose: Prevents the option navigation tree from collapsing its permanently
// visible hierarchy.
// *****************************************************************************
procedure TFormConfig.TreeViewOptionsCollapsing(Sender: TObject; Node: TTreeNode; var AllowCollapse: Boolean);
begin
  inherited;
  AllowCollapse := False;
end;

// *****************************************************************************
// Purpose: Draws selected and unselected option nodes with colors compatible
// with the active theme.
// *****************************************************************************
procedure TFormConfig.TreeViewOptionsCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  inherited;
  if cdsSelected in State then
  begin
    TreeViewOptions.Canvas.Brush.Color := clNavy;
    TreeViewOptions.Canvas.Font.Color  := Self.Font.Color;
  end
  else
  begin
    TreeViewOptions.Canvas.Brush.Color := Self.Color;
    TreeViewOptions.Canvas.Font.Color  := Self.Font.Color;
  end;
end;

// *****************************************************************************
// Purpose: Maps each option-page state index to its named navigation icon.
// *****************************************************************************
procedure TFormConfig.TreeViewOptionsGetImageIndex(Sender: TObject; Node: TTreeNode);
var
  ImageName: string;
begin
  inherited;
  // StateIndex is shared with CardPanel.ActiveCardIndex and names each page.
  case Node.StateIndex of
    0: ImageName := 'project';
    1: ImageName := 'esphome';
    2: ImageName := 'run';
    3: ImageName := 'compile';
    4: ImageName := 'upload';
    5: ImageName := 'logs';
    6: ImageName := 'clean';
    7: ImageName := 'npp';
    8: ImageName := 'console';
  else
    Exit;
  end;
  Node.ImageIndex := TTreeView(Sender).Images.GetIndexByName(ImageName);
  Node.SelectedIndex := Node.ImageIndex;
end;

end.
