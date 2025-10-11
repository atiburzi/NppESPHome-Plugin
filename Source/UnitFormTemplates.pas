unit UnitFormTemplates;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, NppPlugin, NppPluginDockingForms, Vcl.ExtCtrls, Vcl.StdCtrls, JvExStdCtrls, JvEdit, Vcl.Menus, JvTextListBox, JvCombobox,
  Vcl.ComCtrls, Vcl.BaseImageCollection, Vcl.ImageCollection, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList;

type
  TFormTemplates = class(TNppPluginDockingForm)
    ComboBoxCategories: TComboBox;
    StaticTextDescription: TStaticText;
    LabelFilter: TLabel;
    LabelCategory: TLabel;
    ListViewTemplates: TListView;
    EditTextFilter: TButtonedEdit;
    VirtualImageList: TVirtualImageList;
    ImageCollection: TImageCollection;
    PopupMenu1: TPopupMenu;
    EditTemplatesXMLFile: TMenuItem;
    ReloadXMLFileConfiguration: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure EditTextFilterChange(Sender: TObject);
    procedure ComboBoxCategoriesChange(Sender: TObject);
    procedure ListViewTemplatesChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure ListViewTemplatesDblClick(Sender: TObject);
    procedure EditTextFilterRightButtonClick(Sender: TObject);
    procedure ReloadXMLFileConfigurationClick(Sender: TObject);
    procedure EditTemplatesXMLFileClick(Sender: TObject);
    procedure FormOnCloseEvent(Sender: TObject);
  public
    procedure ToggleDarkMode; override;
  end;

var
  FormTemplates: TFormTemplates;

implementation

{$R *.dfm}

uses
  ESPHomeShared, NppSupport, SciSupport;

resourcestring
  rsCategory = 'Category';

procedure TFormTemplates.ComboBoxCategoriesChange(Sender: TObject);
begin
  inherited;
  ListViewTemplates.Items.BeginUpdate;
  TemplateList.RetrieveTemplates(ListViewTemplates.Items, ComboBoxCategories.Text, EditTextFilter.Text);
  ListViewTemplates.Columns[0].AutoSize := True;
  ListViewTemplates.Items.EndUpdate;
end;

procedure TFormTemplates.FormOnCloseEvent(Sender: TObject);
begin
  ConfigFile.WriteBool(csSectionGeneral, csKeyTemplateWindow, False);
end;

procedure TFormTemplates.FormCreate(Sender: TObject);
begin
  inherited;
  OnClose := FormOnCloseEvent;
  ListViewTemplates.Items.BeginUpdate;
  TemplateList.RetrieveTemplates(ListViewTemplates.Items, rsAnyCategory, '');
  TemplateList.RetrieveCategories(ComboBoxCategories.Items);
  ComboBoxCategories.Items.Insert(0, rsAnyCategory);
  ComboBoxCategories.ItemIndex := 0;
  ListViewTemplates.Items.EndUpdate;
end;

procedure TFormTemplates.EditTemplatesXMLFileClick(Sender: TObject);
begin
  inherited;
  Plugin.OpenFile(TemplateFile, False);
end;

procedure TFormTemplates.EditTextFilterChange(Sender: TObject);
begin
  inherited;
  ListViewTemplates.Items.BeginUpdate;
  TemplateList.RetrieveTemplates(ListViewTemplates.Items, ComboBoxCategories.Text, EditTextFilter.Text);
  ListViewTemplates.Items.EndUpdate;
end;

procedure TFormTemplates.EditTextFilterRightButtonClick(Sender: TObject);
begin
  inherited;
  EditTextFilter.Text := '';
end;

procedure TFormTemplates.ListViewTemplatesChange(Sender: TObject; Item: TListItem; Change: TItemChange);
var
  idx: Integer;
begin
  inherited;
  if ListViewTemplates.ItemIndex < 0 then
    Exit;
  idx := TemplateList.IndexOfName(ListViewTemplates.Items[ListViewTemplates.ItemIndex].Caption);
  if idx < 0  then
    Exit;
  StaticTextDescription.Caption := TemplateList[idx].Description;
end;

procedure TFormTemplates.ListViewTemplatesDblClick(Sender: TObject);
var
  idx: Integer;
  currentScintilla: Integer;
  hSci: HWND;
  Utf8: UTF8String;
begin
  inherited;

  if ListViewTemplates.ItemIndex < 0 then
    Exit;
  idx := TemplateList.IndexOfName(ListViewTemplates.Items[ListViewTemplates.ItemIndex].Caption);
  if idx < 0  then
    Exit;

  SendMessage(Plugin.NppData.NppHandle, NPPM_GETCURRENTSCINTILLA, 0, LPARAM(@currentScintilla));
  if currentScintilla = 0 then
    hSci := Plugin.NppData.ScintillaMainHandle
  else
    hSci := Plugin.NppData.ScintillaSecondHandle;
  Utf8 := UTF8String(TemplateList[idx].YAML);
  SendMessage(hSci, SCI_REPLACESEL, 0, LPARAM(PAnsiChar(Utf8)));

end;

procedure TFormTemplates.ReloadXMLFileConfigurationClick(Sender: TObject);
begin
  inherited;
  TemplateList.Refresh;
  ListViewTemplates.Items.BeginUpdate;
  TemplateList.RetrieveTemplates(ListViewTemplates.Items, rsAnyCategory, '');
  TemplateList.RetrieveCategories(ComboBoxCategories.Items);
  ComboBoxCategories.Items.Insert(0, rsAnyCategory);
  ComboBoxCategories.ItemIndex := 0;
  ListViewTemplates.Items.EndUpdate;
end;

procedure TFormTemplates.ToggleDarkMode;
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
    EditTextFilter.RightButton.ImageIndex := 1;
  end
  else
  begin
    Self.Color := clBtnFace;
    Self.Font.Color := clWindowText;
    Icon.Handle := LoadImage(HInstance, resMainIconDark, IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR);
    EditTextFilter.RightButton.ImageIndex := 0;
  end;
  Repaint;
end;

end.
