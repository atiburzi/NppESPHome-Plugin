unit UnitFormTemplates;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,NppPlugin, NppPluginDockingForms, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TFormTemplates = class(TNppPluginDockingForm)
    ListBox1: TListBox;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormTemplates: TFormTemplates;

implementation

{$R *.dfm}

uses
  NppSupport, SciSupport;

procedure TFormTemplates.Button1Click(Sender: TObject);
var
  currentScintilla: Integer;
  hSci: HWND;
begin
  // Quale scintilla è attiva?
  SendMessage(Plugin.NppData.NppHandle, NPPM_GETCURRENTSCINTILLA, 0, LPARAM(@currentScintilla));

  if currentScintilla = 0 then
    hSci := Plugin.NppData.ScintillaMainHandle
  else
    hSci := Plugin.NppData.ScintillaSecondHandle;

  // Inserisci testo
  SendMessage(hSci, SCI_REPLACESEL, 0, LPARAM(PAnsiChar('Ma che cazzo')));
end;

end.
