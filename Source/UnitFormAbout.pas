unit UnitFormAbout;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, NppPlugin, NppPluginForms, Vcl.Imaging.pngimage;

type
  TFormAbout = class(TNppPluginForm)
    PanelMain: TPanel;
    ImageIcon: TImage;
    LabelAppName1: TLabel;
    LabelVersion: TLabel;
    LabelCopyright: TLabel;
    ButtonOk: TButton;
    LabelAppName2: TLabel;
    LinkLabel1: TLinkLabel;
    LinkLabel2: TLinkLabel;
    LinkLabel3: TLinkLabel;
    procedure FormCreate(Sender: TObject);
    procedure ToggleDarkMode; override;
    procedure LinkLabel1LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure LinkLabel2LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure LinkLabel3LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
  end;

var
  FormAbout: TFormAbout;

implementation

{$R *.dfm}

uses
  NppSupport, ESPHomeShared, Winapi.ShellAPI;

function GetFileVersionStr(const FileName: string): string;
var
  Handle: DWORD;
  Size: DWORD;
  Buffer: Pointer;
  FileInfo: Pointer;
  VerSize: UINT;
  MS, LS: DWORD;
begin
  Result := '';
  Size := GetFileVersionInfoSize(PChar(FileName), Handle);
  if Size = 0 then
    Exit;
  GetMem(Buffer, Size);
  try
    if GetFileVersionInfo(PChar(FileName), Handle, Size, Buffer) then
    begin
      if VerQueryValue(Buffer, '\', FileInfo, VerSize) then
      begin
        MS := PVSFixedFileInfo(FileInfo)^.dwFileVersionMS;
        LS := PVSFixedFileInfo(FileInfo)^.dwFileVersionLS;
        Result := Format('%d.%d.%d.%d', [HiWord(MS), LoWord(MS), HiWord(LS), LoWord(LS)]);
      end;
    end;
  finally
    FreeMem(Buffer);
  end;
end;

resourcestring
  rsVersionAbout = 'Version';

procedure TFormAbout.FormCreate(Sender: TObject);
begin
  LabelVersion.Caption := Format('%s: %s', [rsVersionAbout, GetFileVersionStr(Plugin.GetPluginDllPath)]);
  LabelCopyright.Caption := 'Andrea Tiburzi (2025)';
end;

procedure TFormAbout.LinkLabel1LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  inherited;
  if LinkType = sltURL then
    ShellExecute(0, 'open', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;

procedure TFormAbout.LinkLabel2LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  inherited;
  if LinkType = sltURL then
    ShellExecute(0, 'open', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;

procedure TFormAbout.LinkLabel3LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  inherited;
  if LinkType = sltURL then
    ShellExecute(0, 'open', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;

procedure TFormAbout.ToggleDarkMode;
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
    LabelAppName1.Font.Color := TColor(DarkModeColors.Text);
    LabelAppName2.Font.Color := TColor(DarkModeColors.Text);
    Icon.Handle := LoadImage(HInstance, resMainIconLight, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR);
  end
  else
  begin
    Self.Color := clBtnFace;
    Self.Font.Color := clWindowText;
    LabelAppName1.Font.Color := clWindowText;
    LabelAppName2.Font.Color := clWindowText;
    Icon.Handle := LoadImage(HInstance, resMainIconDark, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR);
  end;
end;

end.
