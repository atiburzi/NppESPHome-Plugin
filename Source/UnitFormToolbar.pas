unit UnitFormToolbar;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.VirtualImage, Vcl.BaseImageCollection, Vcl.ImageCollection, NppPlugin, NppPluginForms,
  Vcl.ExtCtrls;

const
  tbfSelect = 0;
  tbfConfigure = 1;
  tbfOpen = 2;
  tbfOpenDeps = 3;
  tbfRun = 4;
  tbfCompile = 5;
  tbfUpload = 6;
  tbfShowLogs = 7;
  tbfClean = 8;
  tbfVisit = 9;
  tbfHelp = 10;
  tbfUpgrade = 11;

type
  TFormToolbar = class(TNppPluginForm)
    ButtonClose: TButton;
    LabelSelect: TLabel;
    LabelConfiguration: TLabel;
    LabelOpen: TLabel;
    LabelOpenDeps: TLabel;
    LabelRun: TLabel;
    LabelCompile: TLabel;
    LabelUpload: TLabel;
    LabelShowLogs: TLabel;
    LabelClean: TLabel;
    LabelVisit: TLabel;
    LabelHelp: TLabel;
    LabelUpgrade: TLabel;
    CheckBoxSelect: TCheckBox;
    CheckBoxConfigure: TCheckBox;
    CheckBoxOpen: TCheckBox;
    CheckBoxOpenDeps: TCheckBox;
    CheckBoxRun: TCheckBox;
    CheckBoxCompile: TCheckBox;
    CheckBoxUpload: TCheckBox;
    CheckBoxShowLogs: TCheckBox;
    CheckBoxClean: TCheckBox;
    CheckBoxVisit: TCheckBox;
    CheckBoxHelp: TCheckBox;
    CheckBoxUpgrade: TCheckBox;
    LabelNote: TLabel;
    ImageSelect: TImage;
    ImageConfigure: TImage;
    ImageOpen: TImage;
    ImageOpenDeps: TImage;
    ImageRun: TImage;
    ImageCompile: TImage;
    ImageUpload: TImage;
    ImageShowLogs: TImage;
    ImageClean: TImage;
    ImageVisit: TImage;
    ImageHelp: TImage;
    ImageUpgrade: TImage;
    procedure ToggleDarkMode; override;
    procedure CheckBoxSelectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckBoxConfigureClick(Sender: TObject);
    procedure CheckBoxVisitClick(Sender: TObject);
    procedure CheckBoxHelpClick(Sender: TObject);
    procedure CheckBoxUpgradeClick(Sender: TObject);
    procedure CheckBoxOpenClick(Sender: TObject);
    procedure CheckBoxOpenDepsClick(Sender: TObject);
    procedure CheckBoxRunClick(Sender: TObject);
    procedure CheckBoxCompileClick(Sender: TObject);
    procedure CheckBoxUploadClick(Sender: TObject);
    procedure CheckBoxShowLogsClick(Sender: TObject);
    procedure CheckBoxCleanClick(Sender: TObject);
    procedure LoadToolbarIcons;
  private
    FToolbarBitmap: Int64;
  public
    { Public declarations }
  end;

var
  FormToolbar: TFormToolbar;

implementation

{$R *.dfm}

uses
  ESPHomeShared, NppSupport;

procedure TFormToolbar.CheckBoxSelectClick(Sender: TObject);
begin
  FToolbarBitmap := SetBit(FToolbarBitmap, tbfSelect, CheckBoxSelect.Checked);
  ConfigFile.WriteInt64(csSectionGeneral, csKeyToolbarBitmap, FToolbarBitmap);
end;

procedure TFormToolbar.CheckBoxConfigureClick(Sender: TObject);
begin
  FToolbarBitmap := SetBit(FToolbarBitmap, tbfConfigure, CheckBoxConfigure.Checked);
  ConfigFile.WriteInt64(csSectionGeneral, csKeyToolbarBitmap, FToolbarBitmap);
end;

procedure TFormToolbar.CheckBoxOpenClick(Sender: TObject);
begin
  FToolbarBitmap := SetBit(FToolbarBitmap, tbfOpen, CheckBoxOpen.Checked);
  ConfigFile.WriteInt64(csSectionGeneral, csKeyToolbarBitmap, FToolbarBitmap);
end;

procedure TFormToolbar.CheckBoxOpenDepsClick(Sender: TObject);
begin
  FToolbarBitmap := SetBit(FToolbarBitmap, tbfOpenDeps, CheckBoxOpenDeps.Checked);
  ConfigFile.WriteInt64(csSectionGeneral, csKeyToolbarBitmap, FToolbarBitmap);
end;

procedure TFormToolbar.CheckBoxRunClick(Sender: TObject);
begin
  FToolbarBitmap := SetBit(FToolbarBitmap, tbfRun, CheckBoxRun.Checked);
  ConfigFile.WriteInt64(csSectionGeneral, csKeyToolbarBitmap, FToolbarBitmap);
end;

procedure TFormToolbar.CheckBoxCompileClick(Sender: TObject);
begin
  FToolbarBitmap := SetBit(FToolbarBitmap, tbfCompile, CheckBoxCompile.Checked);
  ConfigFile.WriteInt64(csSectionGeneral, csKeyToolbarBitmap, FToolbarBitmap);
end;

procedure TFormToolbar.CheckBoxUploadClick(Sender: TObject);
begin
  FToolbarBitmap := SetBit(FToolbarBitmap, tbfUpload, CheckBoxUpload.Checked);
  ConfigFile.WriteInt64(csSectionGeneral, csKeyToolbarBitmap, FToolbarBitmap);
end;

procedure TFormToolbar.CheckBoxShowLogsClick(Sender: TObject);
begin
  FToolbarBitmap := SetBit(FToolbarBitmap, tbfShowLogs, CheckBoxShowLogs.Checked);
  ConfigFile.WriteInt64(csSectionGeneral, csKeyToolbarBitmap, FToolbarBitmap);
end;

procedure TFormToolbar.CheckBoxCleanClick(Sender: TObject);
begin
  FToolbarBitmap := SetBit(FToolbarBitmap, tbfClean, CheckBoxClean.Checked);
  ConfigFile.WriteInt64(csSectionGeneral, csKeyToolbarBitmap, FToolbarBitmap);
end;

procedure TFormToolbar.CheckBoxVisitClick(Sender: TObject);
begin
  FToolbarBitmap := SetBit(FToolbarBitmap, tbfVisit, CheckBoxVisit.Checked);
  ConfigFile.WriteInt64(csSectionGeneral, csKeyToolbarBitmap, FToolbarBitmap);
end;

procedure TFormToolbar.CheckBoxHelpClick(Sender: TObject);
begin
  FToolbarBitmap := SetBit(FToolbarBitmap, tbfHelp, CheckBoxHelp.Checked);
  ConfigFile.WriteInt64(csSectionGeneral, csKeyToolbarBitmap, FToolbarBitmap);
end;

procedure TFormToolbar.CheckBoxUpgradeClick(Sender: TObject);
begin
  FToolbarBitmap := SetBit(FToolbarBitmap, tbfUpgrade, CheckBoxUpgrade.Checked);
  ConfigFile.WriteInt64(csSectionGeneral, csKeyToolbarBitmap, FToolbarBitmap);
end;

procedure TFormToolbar.FormCreate(Sender: TObject);
begin
  FToolbarBitmap := ConfigFile.ReadInt64(csSectionGeneral, csKeyToolbarBitmap, 65535);
  CheckBoxSelect.Checked := GetBit(FToolbarBitmap, tbfSelect);
  CheckBoxConfigure.Checked := GetBit(FToolbarBitmap, tbfConfigure);
  CheckBoxOpen.Checked := GetBit(FToolbarBitmap, tbfOpen);
  CheckBoxOpenDeps.Checked := GetBit(FToolbarBitmap, tbfOpenDeps);
  CheckBoxRun.Checked := GetBit(FToolbarBitmap, tbfRun);
  CheckBoxCompile.Checked := GetBit(FToolbarBitmap, tbfCompile);
  CheckBoxUpload.Checked := GetBit(FToolbarBitmap, tbfUpload);
  CheckBoxShowLogs.Checked := GetBit(FToolbarBitmap, tbfShowLogs);
  CheckBoxClean.Checked := GetBit(FToolbarBitmap, tbfClean);
  CheckBoxVisit.Checked := GetBit(FToolbarBitmap, tbfVisit);
  CheckBoxHelp.Checked := GetBit(FToolbarBitmap, tbfHelp);
  CheckBoxUpgrade.Checked := GetBit(FToolbarBitmap, tbfUpgrade);
  LoadToolbarIcons;
end;

procedure ImageLoadIcon(Image: TImage; ResName: string; DarkMode: Boolean);
var
  Icon: TIcon;
  Handle: HICON;
begin
  Icon := TIcon.Create;
  if DarkMode then
    ResName := ResName + '_Light'
  else
    ResName := ResName + '_Dark';
  Handle := LoadImage(HInstance, PChar(ResName), IMAGE_ICON, 48, 48, LR_DEFAULTCOLOR);
  if Handle <> 0 then
  begin
    Icon.Handle := Handle;
    Image.Picture.Icon := Icon;
  end;
  Icon.Free;
end;

procedure TFormToolbar.LoadToolbarIcons;
begin
  ImageLoadIcon(ImageSelect, 'Select', Plugin.IsDarkModeEnabled);
  ImageLoadIcon(ImageConfigure, 'Configure', Plugin.IsDarkModeEnabled);
  ImageLoadIcon(ImageOpen, 'Open', Plugin.IsDarkModeEnabled);
  ImageLoadIcon(ImageOpenDeps, 'OpenDeps', Plugin.IsDarkModeEnabled);
  ImageLoadIcon(ImageRun, 'Run', Plugin.IsDarkModeEnabled);
  ImageLoadIcon(ImageCompile, 'Compile', Plugin.IsDarkModeEnabled);
  ImageLoadIcon(ImageUpload, 'Upload', Plugin.IsDarkModeEnabled);
  ImageLoadIcon(ImageShowLogs, 'ShowLogs', Plugin.IsDarkModeEnabled);
  ImageLoadIcon(ImageClean, 'Clean', Plugin.IsDarkModeEnabled);
  ImageLoadIcon(ImageVisit, 'Visit', Plugin.IsDarkModeEnabled);
  ImageLoadIcon(ImageHelp, 'Help', Plugin.IsDarkModeEnabled);
  ImageLoadIcon(ImageUpgrade, 'Upgrade', Plugin.IsDarkModeEnabled);
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
    Icon.Handle := LoadImage(HInstance, resMainIconLight, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR);
  end
  else
  begin
    Self.Color := clBtnFace;
    Self.Font.Color := clWindowText;
    LabelNote.Font.Color := clWindowText;
    Icon.Handle := LoadImage(HInstance, resMainIconDark, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR);
  end;
  LoadToolbarIcons;
end;


end.
