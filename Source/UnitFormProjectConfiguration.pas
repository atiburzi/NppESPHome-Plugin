unit UnitFormProjectConfiguration;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, NppPlugin, NppPluginForms, Vcl.StdCtrls, Vcl.ComCtrls, JvExStdCtrls, JvCheckBox, Vcl.BaseImageCollection,
  Vcl.ImageCollection, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, Vcl.VirtualImage, JvCombobox, JvListComb, Vcl.Buttons, JvExControls, JvButton,
  JvTransparentButton, Vcl.NumberBox, Vcl.WinXCtrls, JvExComCtrls, JvComCtrls, Vcl.Tabs, Vcl.DockTabSet, Vcl.WinXPanels, Vcl.ExtCtrls, Vcl.Grids, Vcl.ValEdit,
  JvListView;

type
  TFormProjectConfiguration = class(TNppPluginForm)
    ButtonClose: TButton;
    GroupBoxProject: TGroupBox;
    GroupBoxESPHome: TGroupBox;
    CheckBoxOptionAutoclose: TCheckBox;
    LabelDevice: TLabel;
    GroupBoxNpp: TGroupBox;
    LabelAutosave: TLabel;
    GroupBoxDependencies: TGroupBox;
    ListBoxDependencies: TListBox;
    ButtonAddDeps: TButton;
    ButtonRemoveDeps: TButton;
    ButtonRefresh: TButton;
    MemoProject: TMemo;
    VirtualImageListBlack: TVirtualImageList;
    ImageCollectionBlack: TImageCollection;
    LabelAutoclose: TLabel;
    FileOpenDialogDependency: TFileOpenDialog;
    VirtualImageStatus: TVirtualImage;
    LabelStatus: TLabel;
    ImageCollectionWhite: TImageCollection;
    LabelLogLevel: TLabel;
    ComboBoxDevice: TJvImageComboBox;
    VirtualImageListWhite: TVirtualImageList;
    ComboBoxLogLevel: TJvImageComboBox;
    ComboBoxOptionAutosave: TJvImageComboBox;
    LabelRunNoLogs: TLabel;
    CardPanel: TCardPanel;
    TabSet: TTabSet;
    CardRun: TCard;
    CardCompile: TCard;
    CardUpload: TCard;
    CardLogs: TCard;
    CardClean: TCard;
    LabelOptionRunAdditionalParameters: TLabel;
    EditOptionRunAdditionalParameters: TEdit;
    CheckBoxOptionRunNoLogs: TCheckBox;
    LabelOptionRunNoLogs: TLabel;
    CheckBoxOptionRunReset: TCheckBox;
    LabelOptionRunReset: TLabel;
    LabelOptionCompileAdditionalParameters: TLabel;
    EditOptionCompileAdditionalParameters: TEdit;
    LabelOptionCleanAdditionalParameters: TLabel;
    EditOptionCleanAdditionalParameters: TEdit;
    LabelOptionLogsAdditionalParameters: TLabel;
    EditOptionLogsAdditionalParameters: TEdit;
    LabelOptionUploadAdditionalParameters: TLabel;
    EditOptionUploadAdditionalParameters: TEdit;
    LabelOptionESPHomeAdditionalParameters: TLabel;
    EditOptionESPHomeAdditionalParameters: TEdit;
    CheckBoxOptionCompileGenerateOnly: TCheckBox;
    LabelOptionCompileGenerateOnly: TLabel;
    CheckBoxOptionLogsReset: TCheckBox;
    LabelOptionLogsReset: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ToggleDarkMode; override;
    procedure CheckBoxOptionAutocloseClick(Sender: TObject);
    procedure CheckBoxOptionRunNoLogsClick(Sender: TObject);
    procedure ButtonRefreshClick(Sender: TObject);
    procedure ComboBoxDeviceChange(Sender: TObject);
    procedure ComboBoxOptionAutosaveChange(Sender: TObject);
    procedure ButtonAddDepsClick(Sender: TObject);
    procedure ButtonRemoveDepsClick(Sender: TObject);
    procedure TabSetChange(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
    procedure ComboBoxLogLevelChange(Sender: TObject);
    procedure EditOptionESPHomeAdditionalParametersChange(Sender: TObject);
    procedure CheckBoxOptionRunResetClick(Sender: TObject);
    procedure EditOptionRunAdditionalParametersChange(Sender: TObject);
    procedure CheckBoxOptionCompileGenerateOnlyClick(Sender: TObject);
    procedure EditOptionCompileAdditionalParametersChange(Sender: TObject);
    procedure EditOptionUploadAdditionalParametersChange(Sender: TObject);
    procedure CheckBoxOptionLogsResetClick(Sender: TObject);
    procedure EditOptionLogsAdditionalParametersChange(Sender: TObject);
    procedure EditOptionCleanAdditionalParametersChange(Sender: TObject);
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
  ESPHomeShared, NppSupport, Registry, Math;

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

procedure TFormProjectConfiguration.CheckBoxOptionAutocloseClick(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyESPHomeAutoClose, CheckBoxOptionAutoclose.Checked);
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

procedure TFormProjectConfiguration.EditOptionCleanAdditionalParametersChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyCleanExtraParameters, EditOptionCleanAdditionalParameters.Text);
end;

procedure TFormProjectConfiguration.EditOptionCompileAdditionalParametersChange(Sender: TObject);
begin
  inherited;
  ProjectList.Current.SetOption(csKeyCompileExtraParameters, EditOptionCompileAdditionalParameters.Text);
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
  MemoProject.Text := ProjectList.Current.Description;

  CheckBoxOptionAutoclose.Checked := ProjectList.Current.GetOption(csKeyESPHomeAutoClose, True);
  ComboBoxLogLevel.ItemIndex := ProjectList.Current.GetOption(csKeyESPHomeLogLevel, ciLogLevelError);
  EditOptionESPHomeAdditionalParameters.Text := ProjectList.Current.GetOption(csKeyESPHomeExtraParameters, csDefaultEmpty);
  ComboBoxOptionAutosave.ItemIndex := ProjectList.Current.GetOption(csKeyNppAutosave, ciAutoSaveAllFiles);

  CheckBoxOptionRunNoLogs.Checked := ProjectList.Current.GetOption(csKeyRunNoLogs, False);
  CheckBoxOptionRunReset.Checked := ProjectList.Current.GetOption(csKeyRunReset, False);
  EditOptionRunAdditionalParameters.Text := ProjectList.Current.GetOption(csKeyRunExtraParameters, csDefaultEmpty);

  CheckBoxOptionCompileGenerateOnly.Checked := ProjectList.Current.GetOption(csKeyCompileGenerateOnly, False);
  EditOptionCompileAdditionalParameters.Text := ProjectList.Current.GetOption(csKeyCompileExtraParameters, csDefaultEmpty);

  EditOptionUploadAdditionalParameters.Text := ProjectList.Current.GetOption(csKeyUploadExtraParameters, csDefaultEmpty);

  CheckBoxOptionLogsReset.Checked := ProjectList.Current.GetOption(csKeyLogsReset, False);
  EditOptionLogsAdditionalParameters.Text := ProjectList.Current.GetOption(csKeyLogsExtraParameters, csDefaultEmpty);

  EditOptionCleanAdditionalParameters.Text := ProjectList.Current.GetOption(csKeyCleanExtraParameters, csDefaultEmpty);

  PopulateComboDevice;
  RefreshNetworkStatus;

  ProjectList.Current.LoadOptionDependencies;
  ListBoxDependencies.Items.AddStrings(ProjectList.Current.OptionDependencies);
end;

procedure TFormProjectConfiguration.TabSetChange(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
begin
  inherited;
  CardPanel.Cards[NewTab].Active := True;
  AllowChange := True;
end;

procedure TFormProjectConfiguration.ToggleDarkMode;
var
  DarkModeColors: TNppDarkModeColors;
begin
  inherited ToggleDarkMode;
  if (Plugin.IsDarkModeEnabled) then
  begin
    DarkModeColors := Default(TNppDarkModeColors);
    Plugin.GetDarkModeColors(@DarkModeColors);
    Self.Color := TColor(DarkModeColors.Background);
    Self.Font.Color := TColor(DarkModeColors.Text);
    Icon.Handle := LoadImage(HInstance, resMainIconLight, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR);
    ComboBoxDevice.Images := VirtualImageListWhite;
    VirtualImageStatus.ImageCollection := ImageCollectionWhite;
    TabSet.Font.Color := TColor(DarkModeColors.Text);
    TabSet.SelectedColor := TColor(DarkModeColors.hotEdge);
    TabSet.UnselectedColor := TColor(DarkModeColors.softerBackground);
    TabSet.BackgroundColor := TColor(DarkModeColors.Background);
    TabSet.Images := VirtualImageListWhite;
  end
  else
  begin
    Self.Color := clBtnFace;
    Self.Font.Color := clWindowText;
    Icon.Handle := LoadImage(HInstance, resMainIconDark, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR);
    ComboBoxDevice.Images := VirtualImageListBlack;
    VirtualImageStatus.ImageCollection := ImageCollectionBlack;
    TabSet.Font.Color := clWindowText;
    TabSet.SelectedColor := clWindow;
    TabSet.UnselectedColor := clBtnFace;
    TabSet.BackgroundColor := clBtnFace;
    TabSet.Images := VirtualImageListBlack;
  end;
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

end.
