# Framework Delphi per plugin Notepad++

Questa cartella contiene un framework riutilizzabile per costruire plugin Notepad++ in Delphi. Le unità non dipendono da NppESPHome: un altro plugin può usarle aggiungendo `Lib` al search path.

Il framework è diviso in un core senza VCL e in un livello VCL opzionale. Il core gestisce ABI, messaggi, comandi, lifecycle e toolbar; il livello VCL aggiunge finestre normali, pannelli docking e un editor pronto all'uso per la toolbar.

## Requisiti e integrazione

- Windows e un compilatore Delphi compatibile con le unità usate dal progetto.
- Una DLL distinta per Win32 e Win64, della stessa architettura di Notepad++.
- `Lib` nel unit search path oppure le unità elencate nel DPR.
- `NppPluginInclude.pas` incluso nel DPR per esportare l'ABI richiesta da Notepad++.

Le unità `Npp.Api` e `Npp.Scintilla.Api` sono binding e non devono contenere logica applicativa. Il plugin dovrebbe normalmente lavorare tramite `TNppPlugin`, `TNppHost`, `TNppCommands` e `TNppToolbar`.

## Componenti

| Unità | Componente principale | Responsabilità | VCL |
| --- | --- | --- | --- |
| `Npp.Api` | record e costanti ABI | Tipi, notifiche e messaggi ufficiali di Notepad++ | No |
| `Npp.Scintilla.Api` | binding Scintilla | Costanti e strutture generate da `Scintilla.iface` | No |
| `Npp.MenuCmdID` | costanti menu | ID dei comandi nativi di Notepad++ | No |
| `Npp.Host` | `TNppHost` | Trasporto tipizzato per `SendMessage` e `PostMessage` | No |
| `Npp.Commands` | `TNppCommands` | Registro dei comandi, separatori e stato menu | No |
| `Npp.Plugin` | `TNppPlugin` | Lifecycle, notifiche, file, buffer e servizi host | No |
| `Npp.Toolbar` | `TNppToolbar` | Icone, modello, layout persistente e toolbar nativa | No |
| `Npp.Vcl.Forms` | `TNppPluginForm` / `TNppForm` | Dialog VCL normali integrati con Notepad++ | Sì |
| `Npp.Vcl.Docking` | `TNppPluginDocking` / `TNppDocking` | Pannelli VCL docking | Sì |
| `NppPluginInclude.pas` | entry point DLL | Export standard, creazione lazy e shutdown sicuro | Solo se usato |

`TNppCommands` e `TNppToolbar` sono i nomi pubblici consigliati. `TNppPluginMenu` e `TNppPluginToolbar` restano alias compatibili.

## Quick start

### 1. Dichiarare plugin, comandi e toolbar

I callback menu sono procedure C senza istanza (`procedure; cdecl`). Per invocare un metodo Delphi si usa un trampoline verso l'istanza del plugin.

```pascal
unit Example.Plugin;

interface

uses
  Winapi.Windows, System.Classes, System.IniFiles, System.IOUtils,
  System.SysUtils, Npp.Api, Npp.Commands, Npp.Plugin, Npp.Toolbar;

type
  TExamplePlugin = class(TNppPlugin)
  private
    FCommands: TNppCommands;
    FToolbar: TNppToolbar;
    FIni: TIniFile;
    procedure Hello;
    function CreateToolbarIcons(const Entry: TNppMenuEntry;
      out IconData: TToolbarIconsWithDarkMode): Boolean;
    function ReadToolbarConfiguration(const DefaultValue: string): string;
    procedure WriteToolbarConfiguration(const Value: string);
  protected
    procedure DoNppnReady; override;
    procedure DoNppnToolbarModification; override;
    procedure DoNppnDarkModeChanged; override;
    procedure DoNppToolbarIconsetChanged; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure SetInfo(NppData: TNppData); override;
  end;

var
  Plugin: TExamplePlugin;
  PluginClass: TNppPluginClass = TExamplePlugin;

implementation

const
  CmdHello = 'hello';

procedure _Hello; cdecl;
begin
  if Assigned(Plugin) then
    Plugin.Hello;
end;

constructor TExamplePlugin.Create;
begin
  inherited;
  PluginName := 'ExamplePlugin';
  FCommands := TNppCommands.Create(Self);
  FCommands.AddCommand(CmdHello, 'Hello', _Hello);
  FToolbar := TNppToolbar.Create(Self, FCommands, CreateToolbarIcons,
    nil, ReadToolbarConfiguration, WriteToolbarConfiguration);
  Plugin := Self;
end;

destructor TExamplePlugin.Destroy;
begin
  if Plugin = Self then
    Plugin := nil;
  FreeAndNil(FToolbar);
  FreeAndNil(FCommands);
  FreeAndNil(FIni);
  inherited;
end;

procedure TExamplePlugin.SetInfo(NppData: TNppData);
begin
  inherited;
  FIni := TIniFile.Create(TPath.Combine(GetPluginConfigDir,
    string(PluginName) + '.ini'));
end;

procedure TExamplePlugin.Hello;
begin
  MessageBox(NppData.NppHandle, 'Hello from Delphi', PChar(PluginName),
    MB_OK or MB_ICONINFORMATION);
end;

function TExamplePlugin.ReadToolbarConfiguration(
  const DefaultValue: string): string;
begin
  if Assigned(FIni) then
    Result := FIni.ReadString('Toolbar', 'Layout', DefaultValue)
  else
    Result := DefaultValue;
end;

procedure TExamplePlugin.WriteToolbarConfiguration(const Value: string);
begin
  if Assigned(FIni) then
    FIni.WriteString('Toolbar', 'Layout', Value);
end;

function TExamplePlugin.CreateToolbarIcons(const Entry: TNppMenuEntry;
  out IconData: TToolbarIconsWithDarkMode): Boolean;
begin
  FillChar(IconData, SizeOf(IconData), 0);
  if Entry.Id <> CmdHello then
    Exit(False);

  // 101 è una BITMAP; 102 e 103 sono ICON del plugin di esempio.
  IconData.ToolbarBmp := HBITMAP(LoadImage(HInstance, MakeIntResource(101),
    IMAGE_BITMAP, 16, 16, LR_CREATEDIBSECTION));
  IconData.ToolbarIcon := HICON(LoadImage(HInstance, MakeIntResource(102),
    IMAGE_ICON, 32, 32, LR_DEFAULTCOLOR));
  IconData.ToolbarIconDarkMode := HICON(LoadImage(HInstance, MakeIntResource(103),
    IMAGE_ICON, 32, 32, LR_DEFAULTCOLOR));

  Result := (IconData.ToolbarBmp <> 0) and
    (IconData.ToolbarIcon <> 0) and
    (IconData.ToolbarIconDarkMode <> 0);
end;

procedure TExamplePlugin.DoNppnToolbarModification;
begin
  inherited;
  FToolbar.Initialize;
end;

procedure TExamplePlugin.DoNppnReady;
begin
  inherited;
  FToolbar.CaptureNativeButtons;
  FToolbar.Refresh;
end;

procedure TExamplePlugin.DoNppnDarkModeChanged;
begin
  inherited;
  FToolbar.Refresh;
end;

procedure TExamplePlugin.DoNppToolbarIconsetChanged;
begin
  inherited;
  TThread.ForceQueue(nil,
    procedure
    begin
      if Assigned(Plugin) and not Plugin.IsShuttingDown then
        Plugin.FToolbar.Refresh;
    end);
end;

end.
```

Il provider deve restituire handle nuovi e trasferibili. Dopo la chiamata, anche se restituisce `False`, gli handle non nulli appartengono a `TNppToolbar`, che li rilascia con `DeleteObject` o `DestroyIcon`.

### 2. Esportare la DLL

```pascal
library ExamplePlugin;

uses
  System.SysUtils, Winapi.Windows,
  Npp.Api in '..\Lib\Npp.Api.pas',
  Npp.Host in '..\Lib\Npp.Host.pas',
  Npp.Plugin in '..\Lib\Npp.Plugin.pas',
  Npp.Commands in '..\Lib\Npp.Commands.pas',
  Npp.Toolbar in '..\Lib\Npp.Toolbar.pas',
  Example.Plugin in 'Example.Plugin.pas';

{$R *.res}

var
  BasePlugin: TNppPlugin;

{$I ..\Lib\NppPluginInclude.pas}

begin
  DLLProc := @DLLEntryPoint;
end.
```

L'include esporta `setInfo`, `getName`, `getFuncsArray`, `beNotified`, `messageProc` e `isUnicode`. L'istanza viene creata al primo entry point e distrutta al ritorno da `NPPN_SHUTDOWN`, fuori dal loader lock.

## Npp.Api

Questa unità riproduce l'ABI di Notepad++ e contiene principalmente costanti e record.

| Tipo | Uso |
| --- | --- |
| `nppString`, `nppPChar` | Stringhe Unicode dell'ABI |
| `TNppData` | Handle di Notepad++, Scintilla principale e secondario |
| `TShortcutKey`, `PShortcutKey` | Shortcut associato a un comando |
| `TFuncItem`, `PFuncItem` | Voce esportata nel menu Plugins |
| `TToolbarIcons` | Icona toolbar legacy |
| `TToolbarIconsWithDarkMode` | Bitmap chiara e icone per light/dark mode |
| `TNppDarkModeColors` | Tavolozza comunicata da Notepad++ |
| `TTbData` | Dati di registrazione di un pannello docking |
| `TSCNotification`, `PSCNotification` | Notifica Notepad++/Scintilla |

Le costanti `NPPM_*`, `NPPN_*`, `DWS_*` e `DMN_*` servono quando un wrapper di alto livello non copre un messaggio specifico.

### Shortcut e ownership

`TNppPlugin` assume la proprietà del `PShortcutKey` e lo libera con `Dispose`. Crearlo con `New` e non liberarlo dopo `AddCommand`:

```pascal
function NewShortcut(Ctrl, Alt, Shift: Boolean; Key: UCHAR): PShortcutKey;
begin
  New(Result);
  Result^.IsCtrl := Ctrl;
  Result^.IsAlt := Alt;
  Result^.IsShift := Shift;
  Result^.Key := Key;
end;

FCommands.AddCommand('build', 'Build', _Build,
  NewShortcut(True, False, False, Ord('B')));
```

## Npp.Scintilla.Api

Contiene i binding generati da Scintilla. Si usa con `TNppHost.SendMainScintilla`, `SendSecondScintilla` o `TNppPlugin.GetCurrentScintilla`.

```pascal
Position := Host.Send(GetCurrentScintilla, SCI_GETCURRENTPOS);
```

Rigenerazione e controllo:

```text
python Tools/GenerateScintillaApi.py --iface C:\src\scintilla\include\Scintilla.iface --version <tag-upstream>
python Tools/GenerateScintillaApi.py --iface C:\src\scintilla\include\Scintilla.iface --version <tag-upstream> --check
```

Il blocco generato registra versione e SHA-256. I record ABI fuori da quel blocco vanno verificati manualmente contro gli header della stessa versione.

## Npp.Host

`TNppHost` centralizza il trasporto Win32. In produzione usa `SendMessage`/`PostMessage`; nei test accetta funzioni sostitutive.

```pascal
Host := TNppHost.Create(NppData);
Host := TNppHost.Create(NppData, FakeSend, FakePost);
```

### Proprietà e metodi

| Membro | Descrizione |
| --- | --- |
| `Create(AData, ATransport, APostTransport)` | Crea il facade; i trasporti `nil` usano i default Win32 |
| `Data` | Record `TNppData`; `TNppPlugin.SetInfo` lo sincronizza |
| `Transport` | Funzione sincrona sostituibile; `nil` ripristina il default |
| `PostTransport` | Funzione asincrona sostituibile; `nil` ripristina il default |
| `Send(Handle, Msg, WParam, LParam)` | Invia a un qualunque HWND |
| `Post(Handle, Msg, WParam, LParam)` | Accoda verso un qualunque HWND |
| `SendNpp(...)`, `PostNpp(...)` | Usano `NppHandle` |
| `SendMainScintilla(...)` | Usa `ScintillaMainHandle` |
| `SendSecondScintilla(...)` | Usa `ScintillaSecondHandle` |

`NppDefaultHostTransport` e `NppDefaultHostPostTransport` sono le implementazioni pubbliche Win32.

```pascal
function FakeSend(Handle: HWND; Msg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  if Msg = NPPM_GETCURRENTBUFFERID then
    Exit(42);
  Result := 0;
end;

Host := TNppHost.Create(Data, FakeSend);
Assert(Host.SendNpp(NPPM_GETCURRENTBUFFERID) = 42);
```
## Npp.Commands

`TNppCommands` registra le voci nell'ordine del menu Plugins e assegna a ciascuna un ID stabile deciso dal plugin. L'ID stabile non è né l'indice della voce né il `CmdID` assegnato da Notepad++.

Gli ID sono case-insensitive, devono essere univoci e non possono essere vuoti o contenere `:`, `;` o `|`, riservati al formato toolbar.

### Registrazione

| Metodo | Risultato / effetto |
| --- | --- |
| `Create(APlugin)` | Collega il registro a un `TNppPlugin` non `nil` |
| `AddCommand(Id, Caption, Callback, ShortcutKey, Checked)` | Registra un comando e restituisce il suo indice menu |
| `AddSeparator(Id)` | Registra un separatore e restituisce l'indice; senza ID genera `Sep$N` |

`Callback` è obbligatorio per un comando. L'indice restituito può essere usato come `DlgId` di una docking form.

### Ricerca e lettura

| Metodo / proprietà | Descrizione |
| --- | --- |
| `Count` | Numero totale di comandi e separatori |
| `Entries[Index]` | Copia di `TNppMenuEntry`; fuori range genera eccezione |
| `IndexOf(Id)` | Indice menu o `-1` |
| `IdFromIndex(Index)` | ID stabile o stringa vuota |
| `CommandId(Id)` | `CmdID` assegnato da Notepad++ o `-1` |
| `FunctionItem(Id)` | Puntatore al `TFuncItem` oppure `nil` |
| `Caption(Id)` | Caption corrente oppure stringa vuota |
| `IsChecked(Id)` | Stato check memorizzato |
| `IsEnabled(Id)` | Stato enabled memorizzato |

`TNppMenuEntry` espone `Id`, `Index`, `IsSeparator`, `Checked` ed `Enabled`.

### Modifica dello stato

| Metodo | Descrizione |
| --- | --- |
| `SetCaption(Id, Caption, PreserveShortcut)` | Aggiorna record e menu nativo; mantiene il testo shortcut per default |
| `SetChecked(Id, Checked, Delayed)` | Aggiorna stato e check; per default invia l'aggiornamento differito |
| `SetEnabled(Id, Enabled)` | Aggiorna menu e notifica tutti i listener |
| `AddEnabledListener(Listener)` | Aggiunge una callback senza duplicarla |
| `RemoveEnabledListener(Listener)` | Rimuove la callback corrispondente |
| `OnEnabledChanged` | Callback singola, aggiuntiva rispetto alla lista |

`TNppToolbar` si registra automaticamente come listener. La fonte di verità per lo stato deve quindi essere `FCommands.SetEnabled`, non una modifica diretta della toolbar.

```pascal
FCommands.SetCaption('build', 'Build current document');
FCommands.SetChecked('watch', True);
FCommands.SetEnabled('build', FileExists(GetFullCurrentPath));
```

Un ID inesistente, un separatore o un duplicato genera `EArgumentException` nei metodi che richiedono un vero comando.
## Npp.Plugin

`TNppPlugin` riceve le chiamate ABI, mantiene `TNppData`, inoltra le notifiche ai metodi virtuali e offre wrapper per le operazioni comuni.

### Proprietà

| Proprietà | Descrizione |
| --- | --- |
| `NppData` | Handle forniti da Notepad++ |
| `Host` | `TNppHost` posseduto dal plugin |
| `PluginName` | Nome mostrato nel menu Plugins |
| `PluginMajorVersion`, `PluginMinorVersion` | Componenti della versione |
| `SCNotification` | Puntatore valido solo durante il callback corrente |
| `IsShuttingDown` | `True` dall'inizio di `Shutdown` |
| `IsShutdownComplete` | `True` dopo `DoNppnShutdown` |

### Interfaccia verso Notepad++

Questi metodi sono normalmente chiamati da `NppPluginInclude.pas`:

| Metodo | Funzione |
| --- | --- |
| `SetInfo(NppData)` | Memorizza gli handle e aggiorna `Host.Data`; un override deve chiamare `inherited` |
| `GetName` | Restituisce il nome ABI del plugin |
| `GetFuncsArray(out Count)` | Espone l'array `TFuncItem` |
| `MessageProc(var Msg)` | Riceve messaggi Windows e applica i separatori |
| `BeNotified(SN)` | Esegue il dispatch e poi azzera `SCNotification` |
| `Shutdown` | Esegue una sola volta `DoNppnShutdown` |
| `GetFuncByIndex(Index)` | Voce o `nil` |
| `GetFuncByCmdID(CmdID)` | Voce o `nil` |
| `GetCurrentScintilla` | HWND dell'editor attivo |

### Registrazione e stato UI

Preferire `TNppCommands` e `TNppToolbar`; questi wrapper restano utili per casi speciali e compatibilità.

| Metodo | Funzione |
| --- | --- |
| `RegisterFuncItem(...)` | Aggiunge una voce e restituisce l'indice menu |
| `CmdIdFromMenuItemIdx(Index)` | Converte indice menu in `CmdID` |
| `CheckMenuItem(Index, State, Delayed)` | Imposta il check |
| `EnableMenuItem(Index, State)` | Abilita/disabilita la voce |
| `EnableToolbarItem(Index, State)` | Abilita/disabilita il pulsante relativo |
| `RegisterToolbarIcon(CmdID, IconData)` | Registra icone legacy o dark-mode |
| `PerformMenuCommand(MenuCmdId, Param, Delayed)` | Esegue un comando nativo di Notepad++ |

### Programma e percorsi

| Metodo | Valore |
| --- | --- |
| `GetMajorVersion`, `GetMinorVersion`, `GetReleaseNumber`, `GetBuildNumber` | Versione file della DLL |
| `GetCopyright` | Copyright della risorsa versione |
| `GetNppVersion(var Major, Minor)` | Versione Notepad++ e valore numerico |
| `IsNppMinVersion(Major, Minor)` | Compatibilità con una versione minima |
| `IsDarkModeEnabled` | Stato dark mode |
| `GetDarkModeColors(PColors)` | Riempie la tavolozza richiesta |
| `GetToolbarIconSetChoice` | Scelta del set icone host |
| `GetNppDir` | Directory di Notepad++ |
| `GetPluginDir` | Directory dei plugin |
| `GetPluginConfigDir` | Directory configurazione plugin |
| `GetPluginDocDir` | Directory documenti plugin |
| `GetPluginDllPath` | Percorso DLL corrente |
| `GetNppWindowTitle` | Titolo finestra host |

### Documento, buffer ed editor

| Metodo | Funzione |
| --- | --- |
| `GetFullCurrentPath` | Percorso completo corrente |
| `GetCurrentDirectory` | Directory corrente |
| `GetFullFileName` | Nome file con estensione, senza directory |
| `GetFileNameWithoutExt` | Nome senza estensione |
| `GetFileNameExt` | Sola estensione del file |
| `GetEncoding`, `GetEOLFormat`, `GetLanguageType` | Metadati documento |
| `GetLanguageName(Lang)`, `GetLanguageDesc(Lang)` | Nome/descrizione linguaggio |
| `GetCurrentViewIdx` | Vista corrente; overload per un HWND Scintilla |
| `GetCurrentDocIndex(View)` | Indice documento nella vista |
| `GetCurrentLine`, `GetCurrentColumn`, `GetCurrentWord` | Posizione e parola correnti |
| `GetCurrentBufferId` | ID buffer corrente |
| `GetBufferIdFromPos(View, Doc)` | ID buffer da posizione |
| `GetPosFromBufferId(BufferId, out Doc)` | Vista e indice documento |
| `GetFullPathFromBufferId(BufferId)` | Percorso da buffer |
| `GetCurrentBufferDirty(View)` | Stato modificato nella vista |
| `GetOpenFilesCnt(Type)`, `GetOpenFiles(Type)` | Conteggio e percorsi aperti |
| `GetLineCount(View)`, `GetCurrentPos(View)` | Metriche Scintilla |
| `GetLineFromPosition(View, Pos)` | Riga da posizione |
| `GetFirstVisibleLine(View)`, `GetLinesOnScreen(View)` | Informazioni viewport |
| `GetFilePos(out File, out Line, out Column)` | File e posizione correnti |
| `GetToolbarHandle` | HWND toolbar nativa |

### Operazioni sui file

| Metodo | Funzione |
| --- | --- |
| `OpenFile(FileName, ReadOnly)` | Apre un file |
| `OpenFile(FileName, Line, ReadOnly)` | Apre e posiziona la riga |
| `SaveFile(FileName)` | Salva uno specifico file |
| `SaveCurrentFile` | Salva il documento corrente |
| `SaveAllFiles` | Salva tutti i documenti |
| `SwitchToFile(FileName)` | Attiva un documento aperto |
| `ReloadFile(FileName, Alert)` | Ricarica un file |
| `ReloadCurrentFile(Alert)` | Ricarica il documento corrente |

### Notifiche virtuali

Sovrascrivere solo gli eventi necessari e chiamare `inherited`.

| Gruppo | Metodi |
| --- | --- |
| Host/UI | `DoNppnReady`, `DoNppnToolbarModification`, `DoNppnDarkModeChanged`, `DoNppToolbarIconsetChanged`, `DoNppNativeLangChanged`, `DoNppnShortcutRemapped` |
| Apertura/salvataggio | `DoNppnFileBeforeOpen`, `DoNppnFileOpened`, `DoNppnFileBeforeSave`, `DoNppnFileSaved`, `DoNppnFileBeforeClose`, `DoNppnFileClosed` |
| Caricamento | `DoNppnFileBeforeLoad`, `DoNppnFileLoadFailed`, `DoNppnSnapshotDirtyFileLoaded` |
| Rename/delete | `DoNppnFileBeforeRename`, `DoNppnFileRenameCancel`, `DoNppnFileRenamed`, `DoNppnFileBeforeDelete`, `DoNppnFileDeleteFailed`, `DoNppnFileDeleted` |
| Documento/editor | `DoNppnBufferActivated`, `DoNppnLangChanged`, `DoNppnWordStylesUpdated`, `DoNppnReadOnlyChanged`, `DoNppnDocOrderChanged`, `DoNppGlobalModified`, `DoNppExternalLexerBuffer` |
| Shutdown | `DoNppnBeforeShutDown`, `DoNppnCancelShutDown`, `DoNppnShutdown` |
| Riga di comando | `DoNppnCmdLinePluginMsg` |

Durante un override i dettagli sono in `SCNotification^`. Non conservarne il puntatore dopo il ritorno.
## Npp.Toolbar: layout

`TNppToolbarLayout` è il modello indipendente dalla UI. Contiene una sequenza di `TNppToolbarLayoutItem`, ciascuno con `ItemId` e `Visible`.

| Metodo / proprietà | Descrizione |
| --- | --- |
| `Count` | Numero di elementi |
| `Items[Index]` / `Layout[Index]` | Elemento per indice |
| `Add(ItemId, Visible)` | Aggiunge un ID univoco |
| `IndexOf(ItemId)` | Ricerca case-insensitive |
| `Move(FromIndex, ToIndex)` | Sposta mantenendo l'ordine degli altri |
| `SetVisible(Index, Visible)` | Cambia visibilità |
| `Serialize` | Produce il formato stabile `v2|` |
| `CreateDefault(AvailableIds)` | Crea un layout tutto visibile |
| `TryParse(Value, AvailableIds, out Layout, out WasLegacy)` | Valida, migra e riconcilia |

```pascal
Layout := Toolbar.LoadLayout;
try
  Layout.Move(Layout.IndexOf('build'), 0);
  Layout.SetVisible(Layout.IndexOf('about'), False);
  Toolbar.SaveLayout(Layout);
finally
  Layout.Free;
end;
Toolbar.Refresh;
```

Il formato corrente usa ID stabili:

```text
v2|open:1;build:1;about:0;
```

`1` significa visibile, `0` nascosto. In lettura:

- gli ID rimossi dal plugin vengono ignorati;
- i nuovi ID vengono aggiunti in coda e resi visibili;
- duplicati, flag diversi da 0/1 e ID invalidi fanno fallire il parsing;
- il vecchio formato `indice:visibilità;` viene accettato quando coerente e riscritto in v2 se esiste un writer.

Il chiamante possiede il `TNppToolbarLayout` restituito da `CreateDefault`, `TryParse` o `LoadLayout`.

## Npp.Toolbar: manager

### Callback

| Tipo | Contratto |
| --- | --- |
| `TNppToolbarIconProvider` | Riceve `TNppMenuEntry`, riempie `TToolbarIconsWithDarkMode` e decide se creare il pulsante |
| `TNppToolbarDisabledIconProvider` | Riceve un HICON in prestito e restituisce un nuovo HICON disabilitato |
| `TNppToolbarConfigReader` | Riceve il default serializzato e restituisce la configurazione persistita |
| `TNppToolbarConfigWriter` | Persiste la configurazione normalizzata |

Il provider disabilitato è opzionale. Non deve distruggere l'HICON di input; l'HICON restituito viene distrutto dal manager dopo la copia nell'image list nativa.

### Costruzione

```pascal
Toolbar := TNppToolbar.Create(
  Plugin,
  Commands,
  CreateIcons,          // obbligatorio
  CreateDisabledIcon,   // opzionale
  ReadConfiguration,    // opzionale
  WriteConfiguration);  // opzionale
```

`Plugin`, `Commands` e il provider icone non possono essere `nil`. Il manager non possiede plugin o registro e deve essere distrutto prima di `TNppCommands`.

### Metodi

| Metodo | Quando e cosa fa |
| --- | --- |
| `Initialize` | In `NPPN_TBMODIFICATION`: ricrea modello, icone e registrazione |
| `CaptureNativeButtons` | Dopo la creazione toolbar: acquisisce i template `TTBButton` |
| `Refresh` | Ricostruisce ordine, visibilità, enabled state e immagini disabilitate |
| `ReleaseResources` | Distrugge bitmap/icone possedute; è idempotente |
| `Configuration(Default)` | Layout serializzato corrente o predefinito |
| `SaveConfiguration(Value)` | Valida, normalizza in v2 e chiama il writer |
| `LoadLayout(Default)` | Restituisce un layout posseduto dal chiamante |
| `SaveLayout(Layout)` | Serializza e salva un layout non `nil` |
| `SetEnabled(ItemId, State)` | Sincronizza modello e pulsante nativo |
| `CaptionForItem(ItemId)` | Caption corrente dal registro |
| `GetButtonInfo(Index, out Button)` | Copia sicura dei dati pulsante |
| `IsConfigurationValid(Value, ButtonCount)` | Controllo sintattico statico v2/legacy |

Proprietà e record:

| Membro | Descrizione |
| --- | --- |
| `ButtonCount` | Comandi per cui il provider ha restituito icone valide |
| `Plugin` | Plugin associato, non posseduto |
| `Commands` | Registro associato, non posseduto |
| `Button[Index]` | Puntatore legacy; preferire `GetButtonInfo` |
| `TNppToolbarButton` | `MenuEntryIndex`, `CommandId`, `ItemId`, `Sequence`, `Visible`, `Enabled`, `NativeButton`, `IconData` |

Il puntatore di `Button[Index]` diventa invalido quando `Initialize` ridimensiona l'array interno.

### Sequenza lifecycle

```text
costruttore plugin
  -> crea TNppCommands
  -> registra i comandi
  -> crea TNppToolbar

NPPN_TBMODIFICATION
  -> Toolbar.Initialize

NPPN_READY
  -> Toolbar.CaptureNativeButtons
  -> Toolbar.Refresh

dark mode / nuovo icon set
  -> Toolbar.Refresh

distruzione plugin
  -> libera form
  -> libera Toolbar
  -> libera Commands
```
## UI di configurazione della toolbar

Il framework non fornisce una dialog di configurazione. Aspetto, controlli,
icone, traduzioni e comportamento dell'editor appartengono al plugin che usa la
libreria. `Npp.Toolbar` fornisce invece tutto il modello necessario alla UI:

- `LoadLayout` restituisce ordine e visibilità correnti;
- `LoadLayout(True)` restituisce il layout predefinito;
- `CaptionForItem` risolve la caption visualizzata;
- `GetButtonInfo` espone ID stabile e dati dell'icona;
- `SaveLayout` valida, serializza e persiste il risultato;
- `Refresh` applica il layout alla toolbar nativa.

```pascal
Layout := Toolbar.LoadLayout;
try
  Layout.Move(OldIndex, NewIndex);
  Layout.SetVisible(NewIndex, CheckBox.Checked);
  Toolbar.SaveLayout(Layout);
finally
  Layout.Free;
end;
Toolbar.Refresh;
```

La UI deve conservare `TNppToolbarLayoutItem.ItemId`, non l'indice visivo del
comando: in questo modo la configurazione resta valida se una versione futura
del plugin aggiunge o rimuove comandi. Un'implementazione completa basata su
DFM, `TTreeView`, drag-and-drop, icone applicative e temi light/dark è disponibile
in `Source/NppESPHome.FormToolbar.pas`.

## Npp.Vcl.Forms

`TNppPluginForm` è la base per dialog normali. `TNppForm` è un alias breve.

### Costruttori

| Costruttore | Uso |
| --- | --- |
| `Create(ParentPlugin)` | Form principale con DFM |
| `Create(AOwner: TNppPluginForm)` | Sotto-dialog con owner VCL e stesso plugin |
| `CreateRuntime(ParentPlugin, 0)` | Form senza DFM, costruita da codice |

I costruttori richiedono plugin/owner non `nil`. Le form principali ricevono l'handle di Notepad++ come parent window, vengono registrate tramite `NPPM_MODELESSDIALOG` quando l'host è disponibile e deregistrate alla distruzione.

La classe collega temporaneamente `Application.Handle` a Notepad++ e ripristina il valore originale quando viene distrutta l'ultima form del framework.

### Metodi e campi

| Membro | Descrizione |
| --- | --- |
| `ParentPlugin` | Plugin associato |
| `DefaultCloseAction` | Azione imposta da `DoClose`; default `caNone` |
| `InitLanguage` | Hook virtuale per tradurre caption e testi; va invocato dal plugin |
| `ToggleDarkMode` | Inizializza o aggiorna il tema |
| `SubclassAndTheme(DmFlag)` | Invia il messaggio dark-mode; overridabile |
| `WantChildKey(Child, Message)` | Consente ai controlli figli di processare i tasti |
| `RegisterForm`, `UnregisterForm` | Metodi protetti e idempotenti |

Esempio con DFM:

```pascal
type
  TOptionsForm = class(TNppPluginForm)
    OkButton: TButton;
  public
    procedure InitLanguage; override;
  end;

implementation

{$R *.dfm}

procedure TOptionsForm.InitLanguage;
begin
  Caption := 'Options';
end;

// Uso
Form := TOptionsForm.Create(Plugin);
try
  Form.ShowModal;
finally
  Form.Free;
end;
```

Creare form solo dopo `SetInfo`; per form non necessarie in startup è preferibile attendere `NPPN_READY`.
## Npp.Vcl.Docking

`TNppPluginDocking` deriva da `TNppPluginForm`; `TNppDocking` è l'alias consigliato per nuovo codice.

I due costruttori senza `DlgId` esistono per compatibilità ma sollevano un'eccezione. Usare sempre:

```pascal
Create(NppParent: TNppPlugin; DlgId: Integer)
Create(AOwner: TNppPluginForm; DlgId: Integer)
```

`DlgId` è l'indice menu restituito da `TNppCommands.AddCommand`, non il `CmdID` nativo.

```pascal
type
  TOutputDock = class(TNppDocking)
  public
    constructor Create(APlugin: TNppPlugin;
      AMenuIndex: Integer); reintroduce;
  end;

constructor TOutputDock.Create(APlugin: TNppPlugin;
  AMenuIndex: Integer);
begin
  FNppDefaultDockingMask := DWS_DF_CONT_BOTTOM;
  inherited Create(APlugin, AMenuIndex);
  DefaultCloseAction := caHide;
end;

// Il costruttore registra già il pannello.
OutputDock := TOutputDock.Create(Self,
  FCommands.IndexOf('show.output'));
```

### Metodi e proprietà

| Membro | Descrizione |
| --- | --- |
| `Show` | Registra se necessario e mostra tramite `NPPM_DMMSHOW` |
| `Hide` | Nasconde tramite `NPPM_DMMHIDE` |
| `RegisterDockingForm(MaskStyle)` | Registra una sola volta; richiede host valido |
| `RefreshDockingInfo` | Sincronizza caption/modulo/info e notifica l'host |
| `UpdateDisplayInfo` | Azzera il testo informativo |
| `UpdateDisplayInfo(Info)` | Imposta il testo informativo e aggiorna la scheda |
| `DlgID` | Indice menu usato alla costruzione |
| `CmdId` | ID comando nativo calcolato dal menu index |
| `IsDockingRegistered` | Stato locale della registrazione |
| `DockingData` | Copia del record `TTbData` |
| `OnDock`, `OnFloat` | Eventi generati dalle notifiche docking |

La registrazione rende inizialmente visibile la scheda. Se la preferenza persistita è “nascosta”, chiamare `Hide` dopo la costruzione. La chiusura utente usa `DefaultCloseAction = caHide`. Notepad++ non espone un messaggio pubblico di unregister: il distruttore nasconde il pannello e azzera lo stato locale.

Notepad++ applica direttamente il tema alle docking form; `SubclassAndTheme` è intenzionalmente vuoto in questa classe.

## Lifecycle, ownership e regole pratiche

| Fase | Operazioni |
| --- | --- |
| Costruttore plugin | Impostare `PluginName`, creare registro/toolbar e registrare comandi; non usare ancora HWND host |
| `SetInfo` | Chiamare `inherited`, creare configurazione e servizi che richiedono percorsi Notepad++ |
| `NPPN_TBMODIFICATION` | Chiamare `Toolbar.Initialize` |
| `NPPN_READY` | Creare docking form, acquisire pulsanti e chiamare `Toolbar.Refresh` |
| Runtime | Aggiornare enabled/check/caption tramite `TNppCommands` |
| `NPPN_SHUTDOWN` | Fermare thread/processi e distruggere le form mentre l'host è valido |
| Distruttore plugin | Liberare toolbar prima dei comandi e poi chiamare `inherited` |

Ownership essenziale:

- `TNppPlugin` possiede `Host` e i `PShortcutKey` registrati.
- Il plugin applicativo possiede `TNppCommands`, `TNppToolbar` e le proprie form.
- `TNppToolbar` possiede gli handle immagine restituiti dai provider.
- I layout restituiti sono sempre del chiamante.
- `TNppCommands` e `TNppToolbar` non possiedono il plugin.
- `SCNotification` appartiene all'host ed è valido solo nel callback.

## Test senza Notepad++

I programmi console in `Tests` verificano ABI, trasporto sostituibile, lifecycle, menu, layout toolbar, form/docking ed export DLL senza richiedere Notepad++.

Dopo aver caricato `rsvars.bat`:

```text
dcc32 -B -Q -U"Lib" -I"Lib" -E"Tests" -N"Tests\dcu\Win32" Tests\NppHostTests.dpr
```

Per Win64 usare `dcc64` e directory di output separate. Lo smoke test degli export riceve la DLL compilata:

```text
Tests\NppPluginExportSmokeTests.exe Build\Verify\Win32\ExamplePlugin.dll
```

La copertura e i singoli eseguibili sono descritti in [`Tests/README.md`](../Tests/README.md).
