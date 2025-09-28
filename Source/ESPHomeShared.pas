unit ESPHomeShared;

interface

uses
  System.Classes, System.Generics.Collections, Winapi.Windows, IniFiles;

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
  scRun = 0;
  scCompile = 1;
  scUpload = 2;
  scLogs = 3;
  scClean = 4;

const
  csIconNone = 'none';
  csIconWiFi = 'wifi';
  csIconSerial = 'serial';
  csIconProject = 'profile';

resourcestring
  rsDefaultNone = 'None';
  rsDefaultWiFi = 'WiFi';

resourcestring
  rsMessageBoxError = 'ESPHome Plugin Error';
  rsMessageBoxWarning = 'ESPHome Plugin Warning';
  rsMessageBoxInfo = 'ESPHome Plugin Information';
  rsESPHomeDocURL = 'https://www.esphome.io/components/';
  rsInvalidESPHomeInstallation = 'No valid installation of ESPHome has been found on your system, plugin will be automatically disabled/removed.' +
                                  #13#10'Please (re)install ESPHome following the instructions available on the following web guide, then setup "NppESPHomePlugin" again.' +
                                  #13#10'Please ensure that the ESPHome executable has been added to the user/system PATH.' +
                                  #13#13#10'https://www.esphome.io/guides/installing_esphome/';
  rsNoProjectSelected = 'No ESPHome project is currently selected.'#13#10'Please select one and try again.'#13#10'(Plugins -> NppESPHome -> Select Project...)';
  rsNoWebserverOnCurrentProject  = 'Selected ESPHome project (%s) does not have Webserver component enabled.'#13#13#10'Visit command cannot work and is ignored.';

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

    property OptionDependencies: TStringList read FOptionDeps;
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
    function GetProject(const FileName: string): TProject;
  end;

var
  ProjectList: TProjectList;
  ESPHomeExecutable: string;

var
  ConfigFile: TIniFile = nil;

  PingThreadCount: Integer = 0;

function ShortFileName(const LongFileName: string): string;
function FindFileInPath(const FileName: string): string;

procedure ModuleInitialize;
procedure ModuleFinalize;

function GetBit(const Value: Int64; BitPos: ShortInt): Boolean;
function SetBit(const Value: Int64; BitPos: ShortInt; State: Boolean): Int64;

implementation

uses
  ESPHomePlugin, SysUtils, System.StrUtils, Neslib.Yaml, Ping, System.RegularExpressions;

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
    FCurrent := GetProject(ConfigFile.ReadString(csSectionGeneral, csKeyCurrentProject, csDefaultEmpty));
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
    if (FileName <> csSectionGeneral) and (Self.GetProject(FileName) = nil) then
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

function TProjectList.GetProject(const FileName: string): TProject;
var
  P: TProject;
begin
  Result := nil;
  for P in Self do
    if SameText(P.FileName, ExpandFileName(FileName)) then
    begin
      Result := P;
      Exit;
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

procedure ModuleInitialize;
begin
  ESPHomeExecutable := ExpandFileName(FindFileInPath('esphome.exe'));
  ConfigFile := TIniFile.Create(IncludeTrailingPathDelimiter(Plugin.GetPluginConfigDir) + ChangeFileExt(Plugin.GetName, '.ini'));
  ProjectList := TProjectList.Create;
  ProjectList.CheckOnlineStatus;
end;

procedure ModuleFinalize;
begin
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

end.
