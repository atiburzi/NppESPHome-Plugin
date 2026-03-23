unit ESPHomeShared;

interface

uses
  System.Classes, System.Generics.Collections, Winapi.Windows, Vcl.ComCtrls, XMLIntf, IniFiles;

const
  PingTimeout = 3 * 1000;

const
  ciAutoSaveNone = 0;
  ciAutoSaveProject = 1;
  ciAutoSaveProjectAndDeps = 2;
  ciAutoSaveAllFiles = 3;

  ciLogLevelCritical = 0;
  ciLogLevelError = 1;
  ciLogLevelWarning = 2;
  ciLogLevelInfo = 3;
  ciLogLevelDebug = 4;
  ciLogLevelDefault = 5;

const
  csDefaultEmpty = '';

  csSectionGeneral = 'General';
  csSectionProjects = 'Projects';

  csKeyCurrentProject = 'CurrentProject';
  csKeyToolbarBitmap = 'ToolbarBitmap';
  csKeyToolbarSequence = 'ToolbarSequence';
  csKeyToolbarConfig = 'ToolbarConfig';
  csKeyProjectWindow = 'ProjectWindow';

  csKeyNppAutosave = 'NppAutosave';
  csKeyDependenciesCount = 'DependenciesCount';

  csKeyESPHomeAutoClose = 'ESPHomeAutoClose';
  csKeyESPHomeLogLevel = 'ESPHomeLogLevel';
  csKeyESPHomeTargetDevice = 'ESPHomeTargetDevice';
  csKeyESPHomeExtraParameters = 'ESPHomeExtraParameters';

  csKeyRunNoLogs = 'RunNoLogs';
  csKeyRunReset = 'RunReset';
  csKeyRunExtraParameters = 'RunExtraParameters';

  csKeyCompileGenerateOnly = 'CompileGenerateOnly';
  csKeyUploadExtraParameters = 'UploadExtraParameters';

  csKeyLogsReset = 'LogsReset';
  csKeyLogsExtraParameters = 'LogsExtraParameters';

  csKeyDependencyPrefix = 'Dependency';

const
  resMainIconDark = 'MAIN_DARK';
  resMainIconLight = 'MAIN_LIGHT';

const
  DarkModeSuffix: array [False..True] of string = ('_light', '_dark');

const
  scRun = 0;
  scCompile = 1;
  scUpload = 2;
  scLogs = 3;
  scClean = 4;

const
  DefaultSciIndicator = 1;

const
  csIconNone = 'none';
  csIconWiFi = 'wifi';
  csIconSerial = 'serial';
  csIconProject = 'profile';

resourcestring
  rsConsoleCommandRun = 'ESPHome - Run';
  rsConsoleCommandCompile = 'ESPHome - Compile';
  rsConsoleCommandUpload = 'ESPHome - Upload';
  rsConsoleCommandLogs = 'ESPHome - Show Logs';
  rsConsoleCommandClean = 'ESPHome - Clean';

resourcestring
  rsDefaultNone = 'None';
  rsDefaultWiFi = 'WiFi';

resourcestring
  rsAnyCategory = '(Any Category)';

resourcestring
  rsMessageBoxError = 'ESPHome Plugin Error';
  rsMessageBoxWarning = 'ESPHome Plugin Warning';
  rsMessageBoxInfo = 'ESPHome Plugin Information';
  rsESPHomeDocURL = 'https://www.esphome.io/components/';

resourcestring
  rsMenuSelectProject = 'Select Project...';
  rsMenuSelectProjectCurrent = 'Change "%s" project...';
  rsMenuConfigProject = 'Configure Project...';
  rsMenuOpenProjectFile = 'Open Project file';
  rsMenuOpenProjectFileAndDeps = 'Open Project file and dependencies';
  rsMenuCommandRun = 'Run';
  rsMenuCommandCompile = 'Compile';
  rsMenuCommandUpload = 'Upload';
  rsMenuCommandShowLogs = 'Show Logs';
  rsMenuCommandClean = 'Clean';
  rsMenuCommandVisit = 'Visit Device Web Server';
  rsMenuOpenESPHomeDocs = 'Show ESPHome online documentation';
  rsMenuUpgradeESPHome = 'Check and upgrade ESPHome version';
  rsMenuOpenCmdShell = 'Open a CMD shell in the project folder';
  rsMenuOpenExplorer = 'Open an Explorer window from the project folder';
  rsMenuShowHide = 'Hide/Show ESPHome Plugin window';
  rsMenuToolbar = 'Configure Toolbar...';
  rsMenuAbout = 'About...';

resourcestring
  rsInvalidESPHomeInstallation = 'No valid installation of ESPHome has been found on your system.' +
                                  #13#10'Please (re)install ESPHome following the instructions available on the following web page:' +
                                  #13#13#10'https://www.esphome.io/guides/installing_esphome/';

  rsNoProjectSelected = 'No ESPHome project is currently selected.' +
                        #13#13#10'To use this command, please select the current project and try again.' +
                        #13#10'You can select it through the menù command:' +
                        #13#10'"Plugins" -> "NppESPHome" -> "Select Project..."';

  rsNoWebserverOnCurrentProject  = 'Selected ESPHome project (%s) does not have Webserver component enabled.' +
                                   #13#13#10'Visit command cannot work and it is ignored.';

resourcestring
  rsProjectAlreadyExists = 'Project "%s" already exists among the configured projects. Please select another project.';
  rsInvalidProjectFile = '"%s" is an invalid ESPHome project file. Valid project files contains at least the "esphome" entry in the YAML file.';
  rsKnownProjectRemoval = 'Project "%s" will be removed from the known list. Are you sure?';
  rsRemoveProjectFile = 'Remove selected Project';

resourcestring
  rsTemplatesNotFound = 'No "NppESPHome.xml" templates file has been found on your system. Do you want to download the default one from GitHub portal?';
  rsConfirmOverwriteTemplates = 'You are going to overwrite your "NppESPHome.xml" templates file with the one available on GitHub. Any modification done on the original XML will be lost. Are you sure you want to continue?';
  rsTemplatesXMLDownloaded = 'Default XML Templates file downloaded from GitHub.';

type
  PProject = ^TProject;
  TProject = class
  private
    FFileName: string;
    FName: string;
    FFriendlyName: string;
    FHostName: string;
    FBoard: string;
    FFramework: string;
    FWiFi: Boolean;
    FWebServer: Boolean;
    FChecked: Boolean;
    FOnline: Boolean;
    FValid: Boolean;
    FOptionDeps: TStringList;
    function GetUIName: string;
    function GetFriendlyName: string;
    function GetHostName: string;
    function GetDescription: string;
    function GetOptionDeps: TStringList;

  public
    constructor Create(const AFileName: string; ACheck: Boolean = False);
    property FileName: string read FFileName;
    property Name: string read FName;
    property UIName: string read GetUIName;
    property FriendlyName: string read GetFriendlyName;
    property Board: string read FBoard;
    property Framework: string read FFramework;
    property HasWiFi: Boolean read FWiFi;
    property IsOnline: Boolean read FOnline;
    property HasWebServer: Boolean read FWebServer;
    property HostName: string read GetHostName;
    property Description: string read GetDescription;
    property IsChecked: Boolean read FChecked;
    property IsValid: Boolean read FValid;

    function GetOption(const Option: string; const Default: Boolean): Boolean; overload;
    function GetOption(const Option: string; const Default: Integer): Integer; overload;
    function GetOption(const Option: string; const Default: string): string; overload;

    procedure SetOption(const Option: string; const Value: Boolean); overload;
    procedure SetOption(const Option: string; const Value: Integer); overload;
    procedure SetOption(const Option: string; const Value: string); overload;

    property OptionDependencies: TStringList read GetOptionDeps;
    procedure LoadOptionDependencies;
    procedure SaveOptionDependencies;

    procedure CheckOnlineStatus;
    procedure RefreshOnlineStatus;
  end;

  PProjectList = ^TProjectList;
  TProjectList = class(TObjectList<TProject>)
  private
    FCurrent: TProject;
    procedure SetCurrent(P: TProject);
    function GetCurrent: TProject;
  public
    constructor Create;
    property Current: TProject read GetCurrent write SetCurrent;
    procedure LoadConfig;
    procedure SaveConfig;
    procedure CheckOnlineStatus;
    function GetProjectFromFileName(const FileName: string; const IncludeDeps: boolean = False): TProject;
    function GetProjectFromUIName(const UIName: string): TProject;
  end;

type
  PTemplate = ^TTemplate;
  TTemplate = record
    Name: string;
    Category: string;
    Description: string;
    YAML: string;
  end;

  PTemplateList = ^TTemplateList;
  TTemplateList = class(TList<TTemplate>)
    FXMLDoc: IXMLDocument;
    constructor Create(const AFileName: string);
    procedure Refresh;
    procedure RetrieveTemplates(S: TStrings; const Category: string; const Filter: string); overload;
    procedure RetrieveTemplates(S: TListItems; const Category: string; const Filter: string); overload;
    procedure RetrieveCategories(S: TStrings);
    function IndexOfName(const AName: string): NativeInt;
  end;

var
  ProjectList: TProjectList;
  TemplateList: TTemplateList;

var
  ConfigFile: TIniFile = nil;
  ESPHomeExeFile: string;
  TemplateFile: string;

  PingThreadCount: Integer = 0;

function ShortFileName(const LongFileName: string): string;
function FindFileInPath(const FileName: string): string;

procedure ModuleInitialize;
procedure ModuleFinalize;
procedure DownloadTemplateFileFromGitHub;

function GetBit(const Value: Int64; BitPos: ShortInt): Boolean;
function SetBit(const Value: Int64; BitPos: ShortInt; State: Boolean): Int64;

procedure InitIndicators(HSci: HWND);
procedure TestIndicators(hSci: HWND);
procedure RefreshIndicators(HSci: HWND; Position: Integer = 0);
procedure ApplyStyling(hSci: HWND; startPos, endPos: Integer);

implementation

uses
  ESPHomePlugin, SciSupport, NppSupport, SysUtils, System.StrUtils, Neslib.Yaml, Ping, Xml.XMLDoc, System.UITypes,
  System.IOUtils, System.NetEncoding, System.Net.HttpClient, System.Net.HttpClientComponent, System.RegularExpressions;

type
  TPingThread = class(TThread)
  private
    FName: string;
    FOnline, FChecked: PBoolean;
    FHostName: PString;
  protected
    procedure Execute; override;
  public
    constructor Create(const AName: string; const AOnline, AChecked: PBoolean; const AHostName: PString);
  end;

constructor TPingThread.Create(const AName: string; const AOnline, AChecked: PBoolean; const AHostName: PString);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FName := AName;
  FOnline := AOnline;
  FChecked := AChecked;
  FHostName := AHostName;
  Inc(PingThreadCount);
end;

procedure TPingThread.Execute;
var
  HostName: string;
begin
  HostName := GetFQDN(FName);
  if HostName <> '' then
    FHostName^ := HostName
  else
    HostName := FName;
  FOnline^ := DoPing(FName, PingTimeout);
  FChecked^ := True;
  Dec(PingThreadCount);
end;

constructor TProject.Create(const AFileName: string; ACheck: Boolean = False);
var
  Index: Integer;
  Doc: IYamlDocument;
  Name: string;
  SubstitutionMap: TDictionary<string, string>;

  function Substitute(const Value: string): string;
  var
    Pair: TPair<string, string>;
    ResultString, Replacement: string;
  begin
    ResultString := Value;
    repeat
      Result := ResultString;
      for Pair in SubstitutionMap do
      begin
        Replacement := '$' + Pair.Key;
        if ContainsText(ResultString, Replacement) then
          ResultString := ResultString.Replace(Replacement, Pair.Value, [rfReplaceAll, rfIgnoreCase]);
        Replacement := '${' + Pair.Key + '}';
        if ContainsText(ResultString, Replacement) then
          ResultString := ResultString.Replace(Replacement, Pair.Value, [rfReplaceAll, rfIgnoreCase]);
      end;
    until ResultString = Result;
  end;

begin
  FValid := False;
  FOptionDeps := TStringList.Create(dupIgnore, true, False);
  Name := ExpandFileName(AFileName);
  if FileExists(Name) then
  begin
    Doc := TYamlDocument.Load(Name);
    if Assigned(Doc) then
    begin
      SubstitutionMap := TDictionary<string, string>.Create;
      for Index := 0 to Doc.Root.Values['substitutions'].Count - 1 do
        SubstitutionMap.Add(Doc.Root.Values['substitutions'].Elements[Index].Key, Doc.Root.Values['substitutions'].Elements[Index].Value);
      FName := Substitute(Doc.Root.Values['esphome'].Values['name'].ToString());
      if (FName <> '') then
      begin
        FHostName := '';
        FFileName := AFileName;
        FFriendlyName := Substitute(Doc.Root.Values['esphome'].Values['friendly_name'].ToString());
        FBoard := Substitute(Doc.Root.Values['esp32'].Values['board'].ToString());
        FFramework := Substitute(Doc.Root.Values['esp32'].Values['framework'].Values['type'].ToString());
        FWiFi := Doc.Root.Values['wifi'].NodeType <> TYamlNodeType.Null;
        FWebServer := Doc.Root.Values['web_server'].NodeType <> TYamlNodeType.Null;
        FOnline := False;
        FValid := True;
        FChecked := not FWiFi;
        if ACheck then
          CheckOnlineStatus;
        LoadOptionDependencies;
      end;
      SubstitutionMap.Free;
    end;
  end;
end;

procedure TProject.CheckOnlineStatus;
begin
  if FValid and FWiFi then
    TPingThread.Create(FName, @FOnline, @FChecked, @FHostName);
end;

procedure TProject.RefreshOnlineStatus;
var
  Timeout: Integer;
begin
  if FValid and FWiFi then
  begin
    FOnline := False;
    FChecked := False;
    FHostName := '';
    Timeout := PingTimeout;
    TPingThread.Create(FName, @FOnline, @FChecked, @FHostName);
    while (not FChecked) and (Timeout > 0) do
    begin
      Sleep(10);
      Dec(Timeout, 10);
    end;
  end;
end;

function TProject.GetFriendlyName: string;
begin
  if FFriendlyName <> '' then
    Result := FFriendlyName
  else
    Result := FName;
end;

function TProject.GetUIName: string;
begin
  Result := Format('%s - ("%s" in "%s")', [FriendlyName, ExtractFileName(FileName), ExtractFilePath(FileName)]);
end;

function TProject.GetHostName: string;
begin
  Result := '';
  if HasWiFi and IsValid and FChecked then
    Result := FHostName;
end;

resourcestring
  rsFieldName = 'Name';
  rsFieldFriendlyName = 'Friendly Name';
  rsFieldBoard = 'Board';
  rsFieldFramework = 'Framework';
  rsFieldFileName = 'FileName';
  rsFieldWiFi = 'WiFi';
  rsFieldEnabled = 'Enabled';
  rsFieldDisabled = 'Disabled';
  rsFieldWebServer = 'WebServer';
  rsFieldYes = 'Yes';
  rsFieldNo = 'No';
  rsFieldHostName = 'HostName';
  rsFieldNetStatus = 'Net Status';
  rsFieldOnline = 'Online';
  rsFieldOffline = 'Offline';

function TProject.GetDescription: string;

  function SetupString(AText, ALabel, AContent: string): string;
  begin
    if AContent <> '' then
    begin
      if AText <> '' then
        AText := AText + #13#10;
        AText := AText + ALabel + ': ' + AContent + '';
    end;
    Result := AText;
  end;

begin
  Result := SetupString('', rsFieldName, Self.Name);
  Result := SetupString(Result, rsFieldFriendlyName, Self.FriendlyName);
  Result := SetupString(Result, rsFieldBoard, Self.Board);
  Result := SetupString(Result, rsFieldFramework, Self.Framework);
  Result := SetupString(Result, rsFieldFileName, Self.FileName);
  if Self.HasWiFi then
  begin
    Result := SetupString(Result, rsFieldWiFi, rsFieldEnabled);
    if Self.HasWebServer then
      Result := SetupString(Result, rsFieldWebServer, rsFieldYes)
    else
      Result := SetupString(Result, rsFieldWebServer, rsFieldNo);

    if Self.IsChecked then
    begin
      Result := SetupString(Result, rsFieldHostName, Self.HostName);
      if Self.IsOnline then
        Result := SetupString(Result, rsFieldNetStatus, rsFieldOnline)
      else
        Result := SetupString(Result, rsFieldNetStatus, rsFieldOffline);
     end;
  end
  else
    Result := SetupString(Result, rsFieldWiFi, rsFieldDisabled);
end;

function TProject.GetOptionDeps: TStringList;
begin
  Result := FOptionDeps;
end;

function TProject.GetOption(const Option: string; const Default: Boolean): Boolean;
begin
  Result := Default;
  if Assigned(ConfigFile) then
    Result := ConfigFile.ReadBool(FileName, Option, Default);
end;

function TProject.GetOption(const Option: string; const Default: Integer): Integer;
begin
  Result := Default;
  if Assigned(ConfigFile) then
    Result := ConfigFile.ReadInteger(FileName, Option, Default);
end;

function TProject.GetOption(const Option: string; const Default: string): string;
begin
  Result := Default;
  if Assigned(ConfigFile) then
    Result := ConfigFile.ReadString(FileName, Option, Default);
end;

procedure TProject.SetOption(const Option: string; const Value: Boolean);
begin
  if Assigned(ConfigFile) then
    ConfigFile.WriteBool(FileName, Option, Value);
end;

procedure TProject.SetOption(const Option: string; const Value: Integer);
begin
  if Assigned(ConfigFile) then
    ConfigFile.WriteInteger(FileName, Option, Value);
end;

procedure TProject.SetOption(const Option: string; const Value: string);
begin
  if Assigned(ConfigFile) then
    ConfigFile.WriteString(FileName, Option, Value);
end;

procedure TProject.LoadOptionDependencies;
var
  I, Count: Integer;
  R: string;
begin
  if Assigned(ConfigFile) then
  begin
    FOptionDeps.Clear;
    Count := GetOption(csKeyDependenciesCount, 0);
    for I := 0 to Count - 1 do
    begin
      R := GetOption(Format(csKeyDependencyPrefix + '%d', [I]), csDefaultEmpty);
      if R <> csDefaultEmpty then
        FOptionDeps.Add(R);
    end;
  end;
end;

procedure TProject.SaveOptionDependencies;
var
  S: string;
  I: Integer;
  SList: TStringList;
begin
  if Assigned(ConfigFile) then
  begin
    SList := TStringList.Create;
    ConfigFile.ReadSection(FileName, SList);
    for S in SList do
      if SameText(csKeyDependencyPrefix, LeftStr(S, Length(csKeyDependencyPrefix))) then
        ConfigFile.DeleteKey(FileName, S);
    SList.Free;
    SetOption(csKeyDependenciesCount, FOptionDeps.Count);
    for I := 0 to FOptionDeps.Count - 1 do
      SetOption(Format(csKeyDependencyPrefix + '%d', [I]), FOptionDeps[I]);
  end;
end;

constructor TProjectList.Create;
begin
  FCurrent := nil;
  inherited Create(True);
  LoadConfig;
end;

procedure TProjectList.SetCurrent(P: TProject);
begin
  if Assigned(P) and (Self.IndexOf(P) >= 0)then
  begin
    FCurrent := P;
    ConfigFile.WriteString(csSectionGeneral, csKeyCurrentProject, FCurrent.FileName);
  end
  else
  begin
    FCurrent := nil;
    ConfigFile.DeleteKey(csSectionGeneral, csKeyCurrentProject);
  end;
end;

function TProjectList.GetCurrent: TProject;
begin
  if not Assigned(FCurrent) then
    FCurrent := GetProjectFromFileName(ConfigFile.ReadString(csSectionGeneral, csKeyCurrentProject, csDefaultEmpty));
  Result := FCurrent;
end;

procedure TProjectList.LoadConfig;
var
  Project: TProject;
  Sections: TStringList;
  FileName: string;
begin
  Self.Clear;
  FCurrent := nil;
  Sections := TStringList.Create;
  ConfigFile.ReadSections(Sections);
  for FileName in Sections do
  begin
    if FileName <> csSectionGeneral then
    begin
      Project := TProject.Create(FileName);
      if Project.IsValid then
        Self.Add(Project)
      else
        Project.Free;
      end;
  end;
  Sections.Free;
end;

procedure TProjectList.SaveConfig;
var
  Project: TProject;
  Sections: TStringList;
  FileName: string;
begin
  for Project in Self do
    if Project.IsValid then
      Project.SetOption(csKeyNppAutosave, Project.GetOption(csKeyNppAutosave, ciAutoSaveProjectAndDeps))
    else
      ConfigFile.EraseSection(Project.FileName);

  // Elimino eventuali sezioni rimaste nel file ini
  Sections := TStringList.Create;
  ConfigFile.ReadSections(Sections);
  for FileName in Sections do
    if (FileName <> csSectionGeneral) and (Self.GetProjectFromFileName(FileName) = nil) then
      ConfigFile.EraseSection(FileName);
  Sections.Free;
end;

procedure TProjectList.CheckOnlineStatus;
var
  P: TProject;
begin
  for P in Self do
    P.CheckOnlineStatus;
end;

function TProjectList.GetProjectFromFileName(const FileName: string; const IncludeDeps: boolean = False): TProject;
var
  S: string;
  P: TProject;
begin
  Result := nil;
  for P in Self do
  begin
    if SameText(P.FileName, ExpandFileName(FileName)) then
    begin
      Result := P;
      Exit;
    end;
    if IncludeDeps then
    begin
      for S in P.OptionDependencies do
        if SameText(ExpandFileName(S), ExpandFileName(FileName)) then
        begin
          Result := P;
          Exit;
        end;
    end;
  end;

end;

function TProjectList.GetProjectFromUIName(const UIName: string): TProject;
var
  P: TProject;
begin
  Result := nil;
  for P in Self do
    if P.UIName = UIName then
    begin
      Result := P;
      Exit;
    end;
end;

constructor TTemplateList.Create(const AFileName: string);
begin
  inherited Create;
  if not FileExists(TemplateFile) then
  begin
    if MessageBox(0, PWideChar(rsTemplatesNotFound), PWideChar(rsMessageBoxWarning), MB_YESNO or MB_ICONWARNING) = IDYES then
    begin
      DownloadTemplateFileFromGitHub;
      MessageBox(0, PWideChar(rsTemplatesXMLDownloaded), PWideChar(rsMessageBoxInfo), MB_OK or MB_ICONINFORMATION);
    end
    else
      TFile.Create(TemplateFile);
  end;
  if FileExists(AFileName) then
  begin
    FXMLDoc := TXMLDocument.Create(nil);
    FXMLDoc.FileName := AFileName;
    Refresh;
  end;
end;

resourcestring
  rsErrorReadingTemplateFile = 'The following error has been encountered reading the XML Template file:'#13#13#10'%s.';

procedure TTemplateList.Refresh;
var
  Index: Integer;
  RootNode: IXMLNode;
  Template: TTemplate;
begin
  Self.Clear;
  if TFile.GetSize(TemplateFile) > 0 then
  begin
    try
      FXMLDoc.Active := True;
      FXMLDoc.Refresh;
      RootNode := FXMLDoc.DocumentElement;
      if Assigned(RootNode) then
        for Index := 0 to RootNode.ChildNodes.Count - 1 do
        begin
          Template.Name := RootNode.ChildNodes[Index].ChildNodes['Name'].Text;
          Template.Category := RootNode.ChildNodes[Index].ChildNodes['Category'].Text;
          Template.Description := RootNode.ChildNodes[Index].ChildNodes['Description'].Text;
          Template.YAML := TNetEncoding.HTML.Decode(RootNode.ChildNodes[Index].ChildNodes['YAML'].Text);
          if Self.IndexOfName(Template.Name) < 0 then
            Self.Add(Template);
        end;
    except
      on E: Exception do
        MessageBox(0, PWideChar(Format(rsErrorReadingTemplateFile, [E.Message])), PWideChar(rsMessageBoxError), MB_OK or MB_ICONERROR);
    end;
  end;
end;

procedure TTemplateList.RetrieveTemplates(S: TStrings; const Category: string; const Filter: string);
var
  Item: string;
  List: TStringList;
  Template: TTemplate;
begin
  S.Clear;
  List := TStringList.Create(dupIgnore, True, False);
  for Template in Self do
    if ((Category = '') or (Category = rsAnyCategory) or (Template.Category = Category)) and
        ((Filter = '') or ContainsText(Template.Name, Filter)) then
      List.Add(Format('%s [%s]', [Template.Name, Template.Category]));
  for Item in List do
    S.Add(Item);
  List.Free;
end;

procedure TTemplateList.RetrieveTemplates(S: TListItems; const Category: string; const Filter: string);
var
  Item: TListItem;
  Template: TTemplate;
begin
  S.Clear;
  for Template in Self do
    if ((Category = '') or (Category = rsAnyCategory) or (Template.Category = Category)) and
        ((Filter = '') or ContainsText(Template.Name, Filter)) then
      begin
        Item := S.Add;
        Item.Caption := Template.Name;
        Item.SubItems.Add(Template.Category);
      end;
end;

procedure TTemplateList.RetrieveCategories(S: TStrings);
var
  Category: string;
  Template: TTemplate;
  Categories: TStringList;
begin
  S.Clear;
  Categories := TStringList.Create(dupIgnore, True, False);
  for Template in Self do
    Categories.Add(Template.Category);
  for Category in Categories do
    S.Add(Category);
  Categories.Free;
end;

function TTemplateList.IndexOfName(const AName: string): NativeInt;
var
  Index: NativeInt;
begin
  Result := -1;
  for Index := 0 to Self.Count - 1 do
    if AName = Self.Items[Index].Name then
    begin
      Result := Index;
      Exit
    end;
end;

function FindFileInPath(const FileName: string): string;
var
  Buffer: array[0..MAX_PATH - 1] of WideChar;
  BufferSize: DWORD;
  FilePart: LPWSTR;
begin
  Result := '';
  FilePart := nil;
  BufferSize := SearchPath(nil, PChar(FileName), nil, MAX_PATH, Buffer, FilePart);
  if BufferSize > 0 then
    Result := StrPas(Buffer);
end;

function ShortFileName(const LongFileName: string): string;
var
  ShortName: array[0..MAX_PATH] of Char;
begin
  Result := '';
  if GetShortPathName(PChar(LongFileName), ShortName, MAX_PATH) > 0 then
    Result := ShortName;
end;

resourcestring
  rsTemplatesGitHubUrl = 'https://raw.githubusercontent.com/atiburzi/NppESPHome-Plugin/refs/heads/main/Templates/NppESPHome.xml';

procedure DownloadTemplateFileFromGitHub;
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  FileStream: TFileStream;
begin
  HTTP := TNetHTTPClient.Create(nil);
  try
    Response := HTTP.Get(rsTemplatesGitHubUrl);
    FileStream := TFileStream.Create(TemplateFile, fmCreate);
    try
      Response.ContentStream.Position := 0;
      FileStream.CopyFrom(Response.ContentStream, Response.ContentStream.Size);
    finally
      FileStream.Free;
    end;
  finally
    HTTP.Free;
  end;
end;

procedure ModuleInitialize;
begin
  ESPHomeExeFile := ExpandFileName(FindFileInPath('esphome.exe'));
  ConfigFile := TIniFile.Create(IncludeTrailingPathDelimiter(Plugin.GetPluginConfigDir) + ChangeFileExt(Plugin.GetName, '.ini'));
  TemplateFile := IncludeTrailingPathDelimiter(Plugin.GetPluginConfigDir) + ChangeFileExt(Plugin.GetName, '.xml');
  ProjectList := TProjectList.Create;
  TemplateList := TTemplateList.Create(TemplateFile);
  ProjectList.CheckOnlineStatus;
end;

procedure ModuleFinalize;
begin
  if Assigned(TemplateList) then TemplateList.Free;
  if Assigned(ProjectList) then ProjectList.Free;
  if Assigned(ConfigFile) then ConfigFile.Free;
end;

function GetBit(const Value: Int64; BitPos: ShortInt): Boolean;
begin
  Result := (Value and (1 shl BitPos)) <> 0;
end;

function SetBit(const Value: Int64; BitPos: ShortInt; State: Boolean): Int64;
begin
  Result := (Value and not (1 shl BitPos)) or (Ord(State) shl BitPos);
end;



//
//    // PLexerConfig + PConfigRule CONVERTITI ESATTAMENTE DA enhance_any_lexer.v
//
//type
//  PConfigRule = ^TConfigRule;
//  TConfigRule = record
//    color: Cardinal;      // 0xAARRGGBB
//    regex: AnsiString;    // pattern regex
//    exclude_styles: TArray<Integer>;  // array dinamico
//    next: PConfigRule;    // linked list
//  end;
//
//  PLexerConfig = ^TLexerConfig;
//  TLexerConfig = record
//    name: AnsiString;     // "YAML", "ESPHome"
//    rules: PConfigRule;   // head lista
//    next: PLexerConfig;   // lexer multipli
//  end;
//
//
//var
//  lexer_configs: PLexerConfig = nil;  // Global head
//
//// get_lexer_name (V: get_lexer_name)
//function get_lexer_name(hSci: HWND): AnsiString;
//var
//  lang_type: Integer;
//begin
//  lang_type := SendMessage(getParent(hSci), NPPM_GETCURRENTLANGTYPE, 0, 0);
//  case TNppLang(lang_type) of
//    L_YAML: Result := 'YAML';
//    // Aggiungi ESPHome se custom
//    else Result := 'UNKNOWN';
//  end;
//end;
//
//// config.get_lexer(name) da V
//function get_lexer(lexer_name: AnsiString): PLexerConfig;
//var
//  lexer: PLexerConfig;
//begin
//  lexer := lexer_configs;
//  while lexer <> nil do
//  begin
//    if lexer.name = lexer_name then
//    begin
//      Result := lexer;
//      exit;
//    end;
//    lexer := lexer.next;
//  end;
//  Result := nil;
//end;
//
//// Free helper (V style)
//function free_lexer(lexer: PLexerConfig): PLexerConfig;
//var
//  rule: PConfigRule;
//begin
//  while lexer.rules <> nil do
//  begin
//    rule := lexer.rules.next;
//    FreeMem(lexer.rules);
//    lexer.rules := rule;
//  end;
//  Result := lexer.next;
//  FreeMem(lexer);
//end;
//
//// is_valid_editor (V)
//function is_valid_editor(hwnd: HWND): Boolean;
//begin
//  Result := (hwnd = hSciMain) or (hwnd = hSciSecond);
//end;
//
//// Load da INI (V: config_load)
//procedure load_lexer_configs;
//var
//  ini: TIniFile;
//  sections: TStringList;
//  section: AnsiString;
//  key: string;
//  value: AnsiString;
//  lexer: PLexerConfig;
//  rule: PConfigRule;
//  i: Integer;
//  eq_pos: Integer;
//  color_str: string;
//  exclude_start: Integer;
//begin
//  // Free old
//  while lexer_configs <> nil do
//    lexer_configs := free_lexer(lexer_configs);
//
//  ini := TIniFile.Create('EnhanceAnyLexer.ini');  // O tuo INI
//  sections := TStringList.Create;
//  try
//    ini.ReadSections(sections);
//    for i := 0 to sections.Count - 1 do
//    begin
//      section := AnsiString(sections[i]);
//      lexer := AllocMem(SizeOf(TLexerConfig));
//      lexer.name := section;
//
//      // Leggi rules 0,1,2...
//      key := '0';
//      while ini.ValueExists(section, key) do
//      begin
//        value := AnsiString(ini.ReadString(section, key, ''));
//        eq_pos := Pos('=', value);
//        if eq_pos > 0 then
//        begin
//          color_str := Copy(value, 1, eq_pos - 1);  // "0xFF0000[1,2]"
//          lexer.rules.regex := Copy(value, eq_pos + 1, Length(value));
//
//          rule := AllocMem(SizeOf(TConfigRule));
//          rule.color := StrToIntDef('$' + Copy(color_str, 3, 6), 0);
//          rule.regex := lexer.rules.regex;  // Copia
//          rule.next := lexer.rules;
//          lexer.rules := rule;
//
//          // Parse exclude [1,2] TODO da color_str
//        end;
//        key := IntToStr(StrToInt(key) + 1);
//      end;
//
//      lexer.next := lexer_configs;
//      lexer_configs := lexer;
//    end;
//  finally
//    sections.Free;
//    ini.Free;
//  end;
//end;

procedure InitIndicators(hSci: HWND);
begin
  // 1. Seleziona indicatore #1
  SendMessage(hSci, SCI_SETINDICATORCURRENT, DefaultSciIndicator, 0);
  // 2. Stile grafico: rettangolo arrotondato sotto testo
  SendMessage(hSci, SCI_INDICATORSETSTYLE, INDIC_ROUNDBOX, 0);
  // 3. Colore default (trasparente/bianco)
  SendMessage(hSci, SCI_INDICATORSETFORE, $FFFFFF, 0);
  // 4. Opacità massima (non trasparente)
  SendMessage(hSci, SCI_INDICATORSETALPHA, 255, 0);
  // 5. Layer: sotto testo (non sopra)
  SendMessage(hSci, SCI_INDICATORSETUNDER, 1, 0);
end;

type
  TLexerRule = record
    Color: cardinal;
    Regex: string;
  end;

var
  LexerRules: array[0..2] of TLexerRule = (
    (Color: $6c44cb; RegEx: '(?<![#])(("([^"]*)")|(''([^'']*)''))'),
    (Color: $6c44cb; RegEx: '(?<![#])\b(return|script|condition|if|then|else|lambda|!lambda|!include)\b'),
    (Color: $6c44cb; RegEx: '(?<![#])\bGPIO\d{1,2}\b')
  );

procedure showmessage(msg:string);
var K:string;
begin
  K := msg;
end;

const
  S_DEFAULT      = 0;
  S_STRING_DQ    = 1; // "
  S_STRING_SQ    = 2; // '
  S_KEY          = 3;
  S_NUMBER       = 4;

  STYLE_DEFAULT = 0;
  STYLE_KEY     = 20;
  STYLE_STRING  = 21;
  STYLE_NUMBER  = 22;

procedure ApplyStyling(hSci: HWND; startPos, endPos: Integer);
var
  i: Integer;
  ch, nextCh: AnsiChar;
  state: Integer;
  text: AnsiString;
begin
  // (lettura text come prima)

  SendMessage(hSci, SCI_STARTSTYLING, startPos, 0);

  state := S_DEFAULT;

  i := 1;
  while i <= Length(text) do
  begin
    ch := text[i];
    if i < Length(text) then
      nextCh := text[i+1]
    else
      nextCh := #0;

    case state of

      S_DEFAULT:
        begin
          if ch = '"' then
            state := S_STRING_DQ
          else if ch = '''' then
            state := S_STRING_SQ
          else if ch in ['0'..'9'] then
            state := S_NUMBER
          else if ch in ['a'..'z','A'..'Z','_'] then
            state := S_KEY;
        end;

      // ?? doppie virgolette
      S_STRING_DQ:
        begin
          // escape \" ? salta
          if (ch = '\') and (nextCh = '"') then
          begin
            SendMessage(hSci, SCI_SETSTYLING, 2, STYLE_STRING);
            Inc(i, 2);
            Continue;
          end;

          if ch = '"' then
            state := S_DEFAULT;
        end;

      // ?? apici singoli
      S_STRING_SQ:
        begin
          // YAML: '' = escape
          if (ch = '''') and (nextCh = '''') then
          begin
            SendMessage(hSci, SCI_SETSTYLING, 2, STYLE_STRING);
            Inc(i, 2);
            Continue;
          end;

          if ch = '''' then
            state := S_DEFAULT;
        end;

      S_NUMBER:
        begin
          if not (ch in ['0'..'9','.']) then
            state := S_DEFAULT;
        end;

      S_KEY:
        begin
          if ch = ':' then
            state := S_DEFAULT;
        end;
    end;

    // assegna stile
    case state of
      S_STRING_DQ, S_STRING_SQ:
        SendMessage(hSci, SCI_SETSTYLING, 1, STYLE_STRING);

      S_NUMBER:
        SendMessage(hSci, SCI_SETSTYLING, 1, STYLE_NUMBER);

      S_KEY:
        SendMessage(hSci, SCI_SETSTYLING, 1, STYLE_KEY);

    else
      SendMessage(hSci, SCI_SETSTYLING, 1, STYLE_DEFAULT);
    end;

    Inc(i);
  end;
end;

procedure ColorTextRange(hSci: HWND; startPos, length: Integer; color: TColor; styleId: Integer);
begin
  // Definisci lo stile
  SendMessage(hSci, SCI_STYLESETFORE, styleId, Color);

  // Applica lo stile
  SendMessage(hSci, SCI_STARTSTYLING, startPos, 0);
  SendMessage(hSci, SCI_SETSTYLING, length, styleId);
end;


procedure TestIndicators(hSci: HWND);
var res, id: integer;
begin

  ColorTextRange(hSci, 0, 100, $FF0000, 1);


//  ShowMessage('=== DEBUG START ===');
//
//  id := 1;
//
//  // 1. Verifica base
//  res := SendMessage(hSci, SCI_GETLENGTH, 0, 0);
//  ShowMessage('Lunghezza testo: ' + IntToStr(res));  // >100?
//
//
//  // ID 0
//  SendMessage(hSci, SCI_SETINDICATORCURRENT, id, 0);
//  SendMessage(hSci, SCI_INDICATORSETSTYLE, id, INDIC_TEXTFORE);
//  SendMessage(hSci, SCI_INDICATORSETFLAGS, id, SC_INDICFLAG_VALUEFORE);
//
//  // ID 1 (id+1)
//  SendMessage(hSci, SCI_SETINDICATORCURRENT, id + 1, 0);
//  SendMessage(hSci, SCI_INDICATORSETSTYLE, id + 1, INDIC_ROUNDBOX);
//  SendMessage(hSci, SCI_INDICATORSETFORE, id + 1, $FF00);
//  SendMessage(hSci, SCI_INDICATORSETALPHA, id + 1, 55);
//  SendMessage(hSci, SCI_INDICATORSETOUTLINEALPHA, id + 1, 255);
//
////  SendMessage(hSci, SCI_STYLESETFORE, eol_error_style, e.error_msg_color);
////  SendMessage(hSci, SCI_STYLESETITALIC, eol_error_style, 1);
//
//  // 3. Fill
//  SendMessage(hSci, SCI_SETINDICATORCURRENT, 1, 0);
//  res := SendMessage(hSci, SCI_INDICATORFILLRANGE, 0, 50);
//  ShowMessage('FILLRANGE res= ' + IntToStr(res));
//
//  // 4. Force tutto
//  SendMessage(hSci, SCI_INDICATORALLONFOR, 0, 0);
//  InvalidateRect(getParent(hSci), nil, True);
//  UpdateWindow(getParent(hSci));
//
//  ShowMessage('=== CERCA ONDULE BLU 0-50 ===');
end;

procedure RefreshIndicators(HSci: HWND; Position: Integer = 0);
var
  FirstLine, ScreenLines, TopLine: Integer;
  StartPos, EndPos: Integer;
  RuleIndex, PosIdx, LenIdx: Integer;
  RegEx: TRegEx;
  Match: TMatch;

  TextLen: Integer;
  TextRange: TTextRange;
  TextBuffer: UTF8String;
  TextCopied: Integer;

begin

  if Position > 0 then
  begin
    FirstLine := SendMessage(hSci, SCI_LINEFROMPOSITION, Position, 0);
    StartPos := SendMessage(hSci, SCI_POSITIONFROMLINE, FirstLine - 2, 0);  // Contesto
    EndPos := SendMessage(hSci, SCI_GETLINEENDPOSITION, FirstLine + 3, 0);
  end
  else
  begin
    FirstLine := SendMessage(hSci, SCI_GETFIRSTVISIBLELINE, 0, 0);
    ScreenLines := SendMessage(hSci, SCI_LINESONSCREEN, 0, 0);
    TopLine := FirstLine + ScreenLines + 5;  // Margine fisso V code
    StartPos := SendMessage(hSci, SCI_POSITIONFROMLINE, FirstLine, 0);
    EndPos := SendMessage(hSci, SCI_GETLINEENDPOSITION, TopLine, 0);
  end;

  // Clear indicator solo range visibile
  SendMessage(hSci, SCI_SETINDICATORCURRENT, DefaultSciIndicator, 0);
  SendMessage(hSci, SCI_INDICATORCLEARRANGE, StartPos, EndPos - StartPos);

  if SendMessage(hSci, SCI_GETLEXER, 0, 0) = 109 then
    MessageBox(0, 'Init OK', 'ciao', MB_OK);


  for RuleIndex := 0 to Length(LexerRules) - 1 do
  begin
    RegEx := TRegEx.Create(LexerRules[RuleIndex].Regex);

    TextLen := EndPos - StartPos + 1;
    SetLength(TextBuffer, TextLen);

    TextRange.chrg.cpMin := StartPos;
    TextRange.chrg.cpMax := EndPos;
    TextRange.lpstrText := PWideChar(TextBuffer);

    TextCopied := SendMessage(hSci, SCI_GETTEXTRANGE, 0, LParam(@TextRange));
    SetLength(TextBuffer, TextCopied);

    Match := RegEx.Match(TextBuffer);

    while Match.Success do
    begin
      SendMessage(hSci, SCI_SETINDICATORCURRENT, DefaultSciIndicator, 0);
      SendMessage(hSci, SCI_INDICATORSETFORE, (LexerRules[RuleIndex].Color or SC_INDICVALUEBIT), 0);
      SendMessage(hSci, SCI_INDICATORFILLRANGE, StartPos + Match.Index, Match.Length);
      Match := Match.NextMatch;
    end;
  end;

  SendMessage(hSci, SCI_INDICATORALLONFOR, 0, 0);  // Mostra tutti
  InvalidateRect(getParent(hSci), nil, True);      // Force redraw


end;


// UpdateIndicators CONVERTITO ESATTAMENTE DA enhance_any_lexer.v
// NO invenzioni, traduzione letterale V -> Delphi

//procedure UpdateIndicators(hSci: HWND);
//
//var
//  notification: PSCNotification;
//  first_line: Integer;
//  lines_screen: Integer;
//  top_line: Integer;
//  start_pos: Integer;
//  end_pos: Integer;
//  lexer_name: string;
//  lexer: PLexerConfig;
//  rule: PConfigRule;
//  regex: TRegEx;
//  match: TMatch;
//  pos: Integer;
//  len: Integer;
//  current_style: Integer;
//  exclude_match: Boolean;
//  i: Integer;
//  TextLen: Integer;
//  TextRange: TTextRange;     // ? La tua!
//  TextBuffer: PChar;
//  TextCopied: Integer;
//begin
//
//  first_line := SendMessage(hSci, SCI_GETFIRSTVISIBLELINE, 0, 0);
//  lines_screen := SendMessage(hSci, SCI_LINESONSCREEN, 0, 0);
//  top_line := first_line + lines_screen + 5;  // Margine fisso V code
//
//  start_pos := SendMessage(hSci, SCI_POSITIONFROMLINE, first_line, 0);
//  end_pos := SendMessage(hSci, SCI_GETLINEENDPOSITION, top_line, 0);
//
//  // Clear indicator solo range visibile
//  SendMessage(hSci, SCI_SETINDICATORCURRENT, DefaultSciIndicator, 0);
//  SendMessage(hSci, SCI_INDICATORCLEARRANGE, start_pos, end_pos - start_pos);
//
//  lexer_name := get_lexer_name(hSci);  // Da NPP o current lang
//  lexer := get_lexer(lexer_name);
//
//  if lexer = nil then exit;
//
//  rule := lexer.rules;
//  while rule <> nil do
//  begin
//    regex := TRegEx.Create(rule.regex);
//    try
//
//      TextLen := end_pos - start_pos + 1;
//      GetMem(TextBuffer, TextLen);
//
//      TextRange.chrg.cpMin := start_pos;
//      TextRange.chrg.cpMax := end_pos;
//      TextRange.lpstrText := TextBuffer;
//
//      TextCopied := SendMessage(hSci, SCI_GETTEXTRANGE, 0, LParam(@TextRange));
//      TextBuffer[TextCopied] := #0;
//
//      Match := regex.Match(TextBuffer);
//
//      while Match.Success do
//      begin
//        pos := Match.Index;
//        len := Match.Length;
//
//        // Check exclude styles (V loop)
//        current_style := SendMessage(hSci, SCI_GETSTYLEAT, pos, 0);
//        exclude_match := false;
//        i := 0;
//        while i < rule.exclude_styles.len do
//        begin
//          if current_style == rule.exclude_styles[i] then
//          begin
//            exclude_match := true;
//            break;
//          end;
//          i += 1;
//        end;
//
//        if not exclude_match then
//        begin
//          // Applica colore
//          SendMessage(hSci, SCI_SETINDICATORCURRENT, 1, 0);
//          SendMessage(hSci, SCI_INDICATORSETFORE, rule.color, 0);
//          SendMessage(hSci, SCI_INDICATORFILLRANGE, pos, len);
//        end;
//
//        Match := Match.NextMatch;
//      end;
//
//    finally
//    end;
//    rule := rule.next;
//  end;
//end;

// ciao

procedure PartialUpdateIndicators(hSci: HWND; mod_pos: Integer);
var
  line: Integer;
  start_pos, end_pos: Integer;
begin
  line := SendMessage(hSci, SCI_LINEFROMPOSITION, mod_pos, 0);
  start_pos := SendMessage(hSci, SCI_POSITIONFROMLINE, line - 2, 0);  // Contesto
  end_pos := SendMessage(hSci, SCI_GETLINEENDPOSITION, line + 3, 0);
  // Clear/Apply solo questo range (ottimizzato V)
end;
//Esatto da V: be_notified case scn_updateui/modified/marginclick, mod_type & (insert|delete), npp_ready init



//// Hook CONVERTITI ESATTAMENTE DA enhance_any_lexer.v be_notified()
//procedure beNotified(notification: PNppNotification);
//var
//  nmhdr: PNMHdr;
//  scn: PSCNotification;
//  hwnd: HWND;
//  mod_type: Integer;
//begin
//  nmhdr := @notification.nmhdr;
//
//  case nmhdr.code of
//    SCN_UPDATEUI:
//    begin
//      hwnd := nmhdr.hwndFrom;
//      if is_valid_editor(hwnd) then
//        UpdateIndicators(hwnd);  // p.on_update(hwnd)
//    end;
//
//    SCN_MODIFIED:
//    begin
//      scn := PSCNotification(notification);
//      hwnd := nmhdr.hwndFrom;
//      if not is_valid_editor(hwnd) then exit;
//
//      mod_type := scn.modificationType;
//      if (mod_type and (SC_MOD_INSERTTEXT or SC_MOD_DELETETEXT)) <> 0 then
//      begin
//        // p.on_modified(scn.position) - update parziale
//        PartialUpdateIndicators(hwnd, scn.position);
//      end;
//    end;
//
//    SCN_MARGINCLICK:
//    begin
//      hwnd := nmhdr.hwndFrom;
//      if is_valid_editor(hwnd) then
//        UpdateIndicators(hwnd);  // p.on_update(hwnd)
//    end;
//  end;
//end;
//
//// WM_NOTIFY wrapper per tuo form (chiama beNotified)
//procedure TfmMain.WMNotify(var Msg: TMessage);
//var
//  pnmh: PNMHdr;
//begin
//  pnmh := PNMHdr(Msg.LParam);
//  if (pnmh.hwndFrom = hSciMain) or (pnmh.hwndFrom = hSciSecond) then
//  begin
//    beNotified(PNppNotification(Msg.LParam));
//  end;
//  inherited;
//end;
//end;
//
//
//
//
//// NPP ready: registra flags (V: npp_ready)
//procedure NPPNotification(const Notify: PNppNotification);
//begin
//  if Notify.Header.Code = NPPN_READY then
//  begin
//    // NPPM_ADDSCNMODIFIEDFLAGS per tutti mod_type
//    SendMessage(gNppData._nppHandle, NPPM_ADDSCNMODIFIEDFLAGS, 0,
//      SC_MOD_INSERTTEXT or SC_MOD_DELETETEXT);
//    InitIndicators(hSciMain);
//    InitIndicators(hSciSecond);
//  end;
//end;







end.
