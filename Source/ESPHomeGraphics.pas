unit ESPHomeGraphics;

interface

uses
  System.SysUtils, System.Classes,
  Winapi.CommCtrl,
  Vcl.BaseImageCollection, Vcl.ImageCollection,
  NppSupport, ESPHomePlugin;

type
  TPluginResources = class(TDataModule)
    Toolbar: TImageCollection;
  end;

  TToolbarButton = record
    Index: Integer;
    CmdID: Integer;
    Button: TTBButton;
    IconData: TToolbarIconsWithDarkMode;
  end;

type
  TPluginToolbar = class
  private
    FNppPlugin: TNppPlugin;
    FToolbarButtons: array of TToolbarButton;
  protected
    function GetCount: Integer;
    function GetToolbarConfiguration(const ADefault: Boolean = False): string;
  public
    property Count: Integer read GetCount;
    property Plugin: TNppPlugin read FNppPlugin;
    constructor Create(ANppPlugin: TNppPlugin);

  end;

var
  PluginResources: TPluginResources;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  System.RegularExpressions, IniFiles;

constructor TPluginToolbar.Create(ANppPlugin: TNppPlugin);
var
  Count: Integer;
begin
  inherited Create;
  FNppPlugin := ANppPlugin;
  FNppPlugin.GetFuncsArray(Count);
  SetLength(FToolbarButtons, Count);
end;

function TPluginToolbar.GetCount: Integer;
begin
  Result := Length(FToolbarButtons);
end;

function TPluginToolbar.GetToolbarConfiguration(const ADefault: Boolean = False): string;
var
  Regex: TRegEx;
  IniFile: TIniFile;
  Index: Integer;
  Pattern, DefaultConfig: string;
begin
  DefaultConfig := '';
  for Index := 0 to Count - 1 do
    if PluginResources.Toolbar.GetIndexByName(FuncItemIdFromMenuItemIdx(Index)) >= 0 then
      DefaultConfig := Concat(DefaultConfig, IntToStr(Index), ':1;');
  Result := DefaultConfig;
  if ADefault then Exit;
  IniFile := TIniFile.Create(IncludeTrailingPathDelimiter(Plugin.GetPluginConfigDir) + ChangeFileExt(Plugin.GetName, '.ini'));
  Result := IniFile.ReadString(csSectionGeneral, csKeyToolbarConfig, DefaultConfig);
  IniFile.Free;
  Regex := TRegEx.Create(Format('^(?:\d+:[01];){%d}$', [DefaultConfig.CountChar(':')]));
  if not Regex.IsMatch(Result) then
    Result := DefaultConfig;
end;


initialization
  // Questo viene chiamato quando il plugin viene caricato in memoria da Notepad++
  PluginResources := TPluginResources.Create(nil);

finalization
  // Questo viene chiamato quando il plugin viene scaricato
  if Assigned(PluginResources) then
    PluginResources.Free;

end.
