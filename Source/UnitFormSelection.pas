unit UnitFormSelection;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, NppPlugin, NppPluginForms;

type
  TFormSelection = class(TNppPluginForm)
    GroupBoxCurrentProject: TGroupBox;
    ComboBoxProject: TComboBox;
    ButtonAddProject: TButton;
    ButtonRemoveProject: TButton;
    FileOpenDialogProject: TFileOpenDialog;
    ButtonClose: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ComboBoxProjectChange(Sender: TObject);
    procedure ButtonAddProjectClick(Sender: TObject);
    procedure ButtonRemoveProjectClick(Sender: TObject);
    procedure ToggleDarkMode; override;
  private
    procedure RefreshComboBox;
  public
    { Public declarations }

  end;

var
  FormSelection: TFormSelection;

implementation

{$R *.dfm}

uses
  ESPHomeShared, ESPHomePlugin, NppSupport, Math;

procedure TFormSelection.ButtonAddProjectClick(Sender: TObject);
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
      RefreshComboBox;
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

procedure TFormSelection.ButtonRemoveProjectClick(Sender: TObject);
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
      RefreshComboBox;
      ESPHomePlugin.Plugin.UpdateProjectList;
    end;
  end;
end;

procedure TFormSelection.ToggleDarkMode;
var
  DarkModeColors: TNppDarkModeColors;
begin
  inherited ToggleDarkMode;
  if (Plugin.IsDarkModeEnabled) then
  begin
    DarkModeColors := Default(TNppDarkModeColors);
    Plugin.GetDarkModeColors(@DarkModeColors);
    Icon.Handle := LoadImage(HInstance, resMainIconLight, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR);
    Self.Color := TColor(DarkModeColors.Background);
    Self.Font.Color := TColor(DarkModeColors.Text);
  end
  else
  begin
    Self.Color := clBtnFace;
    Self.Font.Color := clWindowText;
    Icon.Handle := LoadImage(HInstance, resMainIconDark, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR);
  end;
end;

procedure TFormSelection.ComboBoxProjectChange(Sender: TObject);
begin
  inherited;
  if (ComboBoxProject.ItemIndex >= 0) and (ComboBoxProject.Items.Count > 0) then
    ProjectList.Current := ProjectList.GetProjectFromUIName(ComboBoxProject.Items[ComboBoxProject.ItemIndex]);
  ESPHomePlugin.Plugin.UpdateProjectList;
end;

procedure TFormSelection.FormCreate(Sender: TObject);
begin
  inherited;
  RefreshComboBox;
end;

procedure TFormSelection.RefreshComboBox;
var
  P: TProject;
begin
  ComboBoxProject.Clear;
  for P in ProjectList do
    if P.IsValid then
      ComboBoxProject.Items.Add(P.UIName);
  if Assigned(ProjectList.Current) then
    ComboBoxProject.ItemIndex := ComboBoxProject.Items.IndexOf(ProjectList.Current.UIName);
end;

end.
