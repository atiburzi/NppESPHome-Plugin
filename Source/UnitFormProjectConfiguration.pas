unit UnitFormProjectConfiguration;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, NppPlugin, NppPluginForms, Vcl.StdCtrls, Vcl.ComCtrls, JvExStdCtrls, JvCheckBox, Vcl.BaseImageCollection,
  Vcl.ImageCollection, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, Vcl.VirtualImage, JvCombobox, JvListComb, Vcl.Buttons, JvExControls, JvButton,
  JvTransparentButton, Vcl.NumberBox, Vcl.WinXCtrls, JvExComCtrls, JvComCtrls, Vcl.Tabs, Vcl.DockTabSet, Vcl.WinXPanels, Vcl.ExtCtrls, Vcl.Grids, Vcl.ValEdit,
  JvListView, JvEdit;

type
  TFormProjectConfiguration = class(TNppPluginForm)
    ButtonClose: TButton;
    GroupBoxProject: TGroupBox;
    ButtonRefresh: TButton;
    MemoProject: TMemo;
    VirtualImageListBlack: TVirtualImageList;
    ImageCollectionBlack: TImageCollection;
    FileOpenDialogDependency: TFileOpenDialog;
    VirtualImageStatus: TVirtualImage;
    LabelStatus: TLabel;
    ImageCollectionWhite: TImageCollection;
    VirtualImageListWhite: TVirtualImageList;
    LabelOptionRunAdditionalParameters: TLabel;
    CheckBoxOptionRunNoLogs: TCheckBox;
    LabelOptionRunNoLogs: TLabel;
    CheckBoxOptionRunReset: TCheckBox;
    LabelOptionRunReset: TLabel;
    LabelOptionCleanAdditionalParameters: TLabel;
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
    ComboBoxAutoclose: TJvImageComboBox;
    LabelAutoclose: TLabel;
    CheckBoxOptionLogsReset: TCheckBox;
    LabelOptionLogsReset: TLabel;
    CheckBoxOptionCompileGenerateOnly: TCheckBox;
    LabelOptionCompileGenerateOnly: TLabel;
    EditOptionESPHomeAdditionalParameters: TJvEdit;
    EditOptionRunAdditionalParameters: TJvEdit;
    LinkLabelRunHelp: TLinkLabel;
    LinkLabelCompileHelp: TLinkLabel;
    CardConsoleOptions: TCard;
    LinkLabelESPHome: TLinkLabel;
    LabelOptionUploadAdditionalParameters: TLabel;
    EditOptionUploadAdditionalParameters: TJvEdit;
    EditOptionLogsAdditionalParameters: TJvEdit;
    LabelOptionLogsAdditionalParameters: TLabel;
    LinkLabelLogsOptions: TLinkLabel;
    LinkLabelUploadOptions: TLinkLabel;
    LinkLabelHelpOptions: TLinkLabel;
    LabelDeviceDesc: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ToggleDarkMode; override;
    procedure CheckBoxOptionRunNoLogsClick(Sender: TObject);
    procedure ButtonRefreshClick(Sender: TObject);
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
    procedure ComboBoxAutocloseChange(Sender: TObject);
    procedure LinkLabelHelpLinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
  private
    procedure RefreshNetworkStatus;
    procedure PopulateComboDevice;
  public
    { Public declarations }
  end;

var
  FormProjectConfiguration: TFormProjectConfiguration;

implementation

{$R *.dfm}

uses
  ESPHomeShared, NppSupport, Registry, Math,Winapi.ShellAPI;

procedure TFormProjectConfiguration.ButtonAddDepsClick(Sender: TObject);
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
  end;
end;

procedure TFormProjectConfiguration.ButtonRefreshClick(Sender: TObject);
var
  Timeout: Integer;
begin
  inherited;
  Screen.Cursor := crHourGlass;

  ProjectList.Current.RefreshOnlineStatus;
  Timeout := PingTimeout;
  while (not ProjectList.Current.IsChecked) and (Timeout > 0) do
  begin
    Sleep(10);
    Dec(Timeout, 10);
  end;

  RefreshNetworkStatus;
  PopulateComboDevice;
  Screen.Cursor := crDefault;
end;

procedure TFormProjectConfiguration.ButtonRemoveDepsClick(Sender: TObject);
var
  I, Sel: Integer;
  Deleted: Boolean;
begin
  inherited;
  Sel := -1;
  Deleted := False;
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
  end;
end;

procedure TFormProjectConfiguration.CheckBoxOptionCompileGenerateOnlyClick(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyCompileGenerateOnly, CheckBoxOptionCompileGenerateOnly.Checked);
end;

procedure TFormProjectConfiguration.CheckBoxOptionLogsResetClick(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyLogsReset, CheckBoxOptionLogsReset.Checked);
end;

procedure TFormProjectConfiguration.CheckBoxOptionRunNoLogsClick(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyRunNoLogs, CheckBoxOptionRunNoLogs.Checked);
end;

procedure TFormProjectConfiguration.CheckBoxOptionRunResetClick(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyRunReset, CheckBoxOptionRunReset.Checked);
end;

procedure TFormProjectConfiguration.ComboBoxOptionAutosaveChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyNppAutosave, ComboBoxOptionAutosave.ItemIndex);
end;

procedure TFormProjectConfiguration.EditOptionESPHomeAdditionalParametersChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyESPHomeExtraParameters, EditOptionESPHomeAdditionalParameters.Text);
end;

procedure TFormProjectConfiguration.EditOptionLogsAdditionalParametersChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyLogsExtraParameters, EditOptionLogsAdditionalParameters.Text);
end;

procedure TFormProjectConfiguration.EditOptionRunAdditionalParametersChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyRunExtraParameters, EditOptionRunAdditionalParameters.Text);
end;

procedure TFormProjectConfiguration.EditOptionUploadAdditionalParametersChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyUploadExtraParameters, EditOptionUploadAdditionalParameters.Text);
end;

procedure TFormProjectConfiguration.ComboBoxAutocloseChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyESPHomeAutoClose, (ComboBoxAutoclose.ItemIndex = 1));
end;

procedure TFormProjectConfiguration.ComboBoxDeviceChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyESPHomeTargetDevice, ComboBoxDevice.Items[ComboBoxDevice.ItemIndex].Text);
end;

procedure TFormProjectConfiguration.ComboBoxLogLevelChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyESPHomeLogLevel, ComboBoxLogLevel.ItemIndex);
end;

procedure TFormProjectConfiguration.FormCreate(Sender: TObject);
begin
  inherited;

  TreeViewOptions.FullExpand;
  TreeViewOptions.Selected := TreeViewOptions.Items[0];

  MemoProject.Text := ProjectList.Current.Description;

  if ProjectList.Current.GetOption(csKeyESPHomeAutoClose, True) then
    ComboBoxAutoclose.ItemIndex := 1
  else
    ComboBoxAutoclose.ItemIndex := 0;

  ComboBoxLogLevel.ItemIndex := ProjectList.Current.GetOption(csKeyESPHomeLogLevel, ciLogLevelDefault);
  EditOptionESPHomeAdditionalParameters.Text := ProjectList.Current.GetOption(csKeyESPHomeExtraParameters, csDefaultEmpty);
  ComboBoxOptionAutosave.ItemIndex := ProjectList.Current.GetOption(csKeyNppAutosave, ciAutoSaveAllFiles);

  CheckBoxOptionRunNoLogs.Checked := ProjectList.Current.GetOption(csKeyRunNoLogs, False);
  CheckBoxOptionRunReset.Checked := ProjectList.Current.GetOption(csKeyRunReset, False);
  EditOptionRunAdditionalParameters.Text := ProjectList.Current.GetOption(csKeyRunExtraParameters, csDefaultEmpty);

  CheckBoxOptionCompileGenerateOnly.Checked := ProjectList.Current.GetOption(csKeyCompileGenerateOnly, False);

  EditOptionUploadAdditionalParameters.Text := ProjectList.Current.GetOption(csKeyUploadExtraParameters, csDefaultEmpty);

  CheckBoxOptionLogsReset.Checked := ProjectList.Current.GetOption(csKeyLogsReset, False);
  EditOptionLogsAdditionalParameters.Text := ProjectList.Current.GetOption(csKeyLogsExtraParameters, csDefaultEmpty);

  PopulateComboDevice;
  RefreshNetworkStatus;

  ProjectList.Current.LoadOptionDependencies;
  ListBoxDependencies.Items.AddStrings(ProjectList.Current.OptionDependencies);

  ToggleDarkMode;
end;

procedure TFormProjectConfiguration.LinkLabelHelpLinkClick(Sender: TObject; const Link: string; LinkType: TSysLinkType);
begin
  inherited;
  if LinkType = sltURL then
    ShellExecute(0, 'open', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;

procedure TFormProjectConfiguration.ToggleDarkMode;
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
    ComboBoxDevice.Images := VirtualImageListWhite;
    VirtualImageStatus.ImageCollection := ImageCollectionWhite;
    TreeViewOptions.Images := VirtualImageListWhite;

  end
  else
  begin
    Self.Color := clBtnFace;
    Self.Font.Color := clWindowText;

    Icon.Handle := LoadImage(HInstance, resMainIconDark, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR);
    ComboBoxDevice.Images := VirtualImageListBlack;
    VirtualImageStatus.ImageCollection := ImageCollectionBlack;
    TreeViewOptions.Images := VirtualImageListBlack;
  end;

  TreeViewOptions.Color := Self.Color;
  TreeViewOptions.Font.Color := Self.Font.Color;

  LabelDeviceDesc.Font.Color := Self.Font.Color;
  EditOptionRunAdditionalParameters.Font.Color := Self.Font.Color;
  EditOptionESPHomeAdditionalParameters.Font.Color := Self.Font.Color;
  EditOptionUploadAdditionalParameters.Font.Color := Self.Font.Color;
  EditOptionLogsAdditionalParameters.Font.Color := Self.Font.Color;

end;

resourcestring
  rsImageHintOnline = 'Device is online';
  rsImageHintOnlineWeb = 'Device is online and it has a webserver enabled';
  rsImageHintOffline = 'Device is offline';
  rsImageHintOfflineWeb = 'Device has a webserver but it''s currently offline';
  rsImageHintDisabled = 'Device doesn''have wifi capabbilities';
  rsImageHintUnknown = 'Device status is unknown';

procedure TFormProjectConfiguration.RefreshNetworkStatus;
begin

  with ProjectList.Current do
  begin
    if not IsChecked then
    begin
      LabelStatus.Caption := 'Unknown';
      VirtualImageStatus.ImageName := 'question';
      VirtualImageStatus.Hint := rsImageHintUnknown;
    end
    else if not HasWiFi then
    begin
      LabelStatus.Caption := 'Standalone';
      VirtualImageStatus.ImageName := 'wifi-disabled';
      VirtualImageStatus.Hint := rsImageHintDisabled;
    end
    else
    begin
      if IsOnline and HasWebserver then
      begin
        LabelStatus.Caption := 'Online+';
        VirtualImageStatus.ImageName := 'wifi';
        VirtualImageStatus.Hint := rsImageHintOnlineWeb;
      end
      else if IsOnline then
      begin
        LabelStatus.Caption := 'Online';
        VirtualImageStatus.ImageName := 'wifi';
        VirtualImageStatus.Hint := rsImageHintOnline;
      end
      else if HasWebserver then
      begin
        LabelStatus.Caption := 'Offline+';
        VirtualImageStatus.ImageName := 'wifi-offline';
        VirtualImageStatus.Hint := rsImageHintOfflineWeb;
      end
      else
      begin
        LabelStatus.Caption := 'Offline';
        VirtualImageStatus.ImageName := 'wifi-offline';
        VirtualImageStatus.Hint := rsImageHintOffline;
      end;
    end;
  end;

end;

procedure TFormProjectConfiguration.PopulateComboDevice;
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

  if Assigned(ProjectList.Current) then
  begin
    if ProjectList.Current.IsOnline then
      ComboBoxDevice.Items[ComboBoxDevice.Items.AddTextItem(rsDefaultWiFi).Index].ImageIndex := ComboBoxDevice.Images.GetIndexByName(csIconWiFi);
    for Index := 0 to ComboBoxDevice.GetCount - 1 do
      if ComboBoxDevice.GetItemText(Index) = ProjectList.Current.GetOption(csKeyESPHomeTargetDevice, '') then
        ComboBoxDevice.ItemIndex := Index;
  end;
end;

procedure TFormProjectConfiguration.TreeViewOptionsChange(Sender: TObject; Node: TTreeNode);
begin
  inherited;
  CardProjectOptions.CardPanel.ActiveCardIndex:= TreeViewOptions.Selected.StateIndex;
end;

procedure TFormProjectConfiguration.TreeViewOptionsCollapsing(Sender: TObject; Node: TTreeNode; var AllowCollapse: Boolean);
begin
  inherited;
  AllowCollapse := False;
end;



procedure TFormProjectConfiguration.TreeViewOptionsCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
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

end.
