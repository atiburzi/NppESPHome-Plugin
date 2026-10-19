# Framework Delphi per plugin Notepad++

Questa cartella contiene un framework riutilizzabile per costruire plugin Notepad++ in Delphi. Le unità non dipendono da NppESPHome: un altro plugin può usarle aggiungendo `Lib` al search path.

Il framework è diviso in un core senza VCL e in un livello VCL opzionale. Il core gestisce ABI, messaggi, comandi, lifecycle e toolbar; il livello VCL aggiunge finestre normali e pannelli docking. L'eventuale editor della toolbar appartiene all'applicazione.

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
| `FileVersionInfo` | [`TFileVersionInfo`](Docs/FileVersionInfo.md) | Lettura delle risorse versione di EXE e DLL | No |
| `Npp.Host` | [`TNppHost`](Docs/Npp.Host.md) | Trasporto, versione host, toolbar HWND e comandi nativi | No |
| `Npp.Commands` | [`TNppCommands`](Docs/Npp.Commands.md) | Registro, tabella ABI, shortcut, separatori e stato menu | No |
| `Npp.Plugin` | [`TNppPlugin`](Docs/Npp.Plugin.md) | Lifecycle, notifiche e ownership di comandi/toolbar | No |
| `Npp.Toolbar` | [`TNppToolbar`](Docs/Npp.Toolbar.md) | Icone, modello, stringa di configurazione e toolbar nativa | No |
| `Npp.Vcl.Forms` | [`TNppPluginForm`](Docs/Npp.Vcl.Forms.md) | Dialog VCL normali integrati con Notepad++ | Sì |
| `Npp.Vcl.Docking` | [`TNppPluginDocking`](Docs/Npp.Vcl.Docking.md) | Pannelli VCL docking | Sì |
| `NppPluginInclude.pas` | entry point DLL | Export standard, creazione lazy e shutdown sicuro | Solo se usato |

`TNppCommands`, `TNppToolbar`, `TNppPluginForm` e `TNppPluginDocking` sono i
nomi pubblici definitivi. Il framework non mantiene alias legacy.

## Quick start

### 1. Dichiarare plugin, comandi e toolbar

I callback menu sono procedure C senza istanza (`procedure; cdecl`). Per invocare un metodo Delphi si usa un trampoline verso l'istanza del plugin.

```pascal
unit Example.Plugin;

interface

uses
  Winapi.Windows, System.IniFiles, System.IOUtils,
  System.SysUtils, Npp.Api, Npp.Commands, Npp.Plugin, Npp.Toolbar;

type
  TExamplePlugin = class(TNppPlugin)
  private
    FIni: TIniFile;
    procedure Hello;
    function CreateToolbarIcons(const Entry: TNppMenuEntry;
      out IconData: TToolbarIconsWithDarkMode): Boolean;
    procedure LoadToolbarConfiguration;
    procedure SaveToolbarConfiguration;
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
  Commands.AddCommand(CmdHello, 'Hello', _Hello);
  ConfigureToolbar(CreateToolbarIcons);
  Plugin := Self;
end;

destructor TExamplePlugin.Destroy;
begin
  if Plugin = Self then
    Plugin := nil;
  FreeAndNil(FIni);
  inherited;
end;

procedure TExamplePlugin.SetInfo(NppData: TNppData);
begin
  inherited;
  FIni := TIniFile.Create(TPath.Combine(GetPluginConfigDir,
    string(PluginName) + '.ini'));
  LoadToolbarConfiguration;
end;

procedure TExamplePlugin.Hello;
begin
  MessageBox(NppData.NppHandle, 'Hello from Delphi', PChar(PluginName),
    MB_OK or MB_ICONINFORMATION);
end;

procedure TExamplePlugin.LoadToolbarConfiguration;
begin
  if Assigned(FIni) then
    Toolbar.ApplyConfiguration(FIni.ReadString('Toolbar', 'Layout', ''));
end;

procedure TExamplePlugin.SaveToolbarConfiguration;
begin
  if Assigned(FIni) then
    FIni.WriteString('Toolbar', 'Layout', Toolbar.Configuration);
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

end.
```

`TNppPlugin` crea e distrugge `Commands`. `ConfigureToolbar` crea la toolbar
opzionale e il lifecycle base esegue automaticamente `Initialize`,
`CaptureNativeButtons` e `Refresh` nelle notifiche corrette. Gli override delle
stesse notifiche servono quindi solo per logica applicativa e devono continuare
a chiamare `inherited`.

Il provider deve restituire handle nuovi e trasferibili. Dopo la chiamata, anche se restituisce `False`, gli handle non nulli appartengono a `TNppToolbar`, che li rilascia con `DeleteObject` o `DestroyIcon`.

Nell'esempio l'INI è deliberatamente gestito dalla classe applicativa. Il
framework non conosce file, registro o altri sistemi di persistenza:
`LoadToolbarConfiguration` passa una stringa alla toolbar, mentre
`SaveToolbarConfiguration` preleva la stringa corrente quando la UI decide di
salvarla.

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

`TNppCommands` assume la proprietà del `PShortcutKey` dopo una registrazione
riuscita e lo libera con `Dispose`. Crearlo con `New` e non liberarlo dopo
`AddCommand`:

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

Complete component manual: [`TNppHost`](Docs/Npp.Host.md).

```pascal
Host := TNppHost.Create(NppData);
Host := TNppHost.Create(NppData, FakeSend, FakePost, FakeToolbarResolver);
```

### Proprietà e metodi

| Membro | Descrizione |
| --- | --- |
| `Create(AData, ATransport, APostTransport, AToolbarHandleResolver)` | Crea il facade; callback `nil` usano i default Win32 |
| `Data` | Record `TNppData`; `TNppPlugin.SetInfo` lo sincronizza |
| `Transport` | Funzione sincrona sostituibile; `nil` ripristina il default |
| `PostTransport` | Funzione asincrona sostituibile; `nil` ripristina il default |
| `ToolbarHandleResolver` | Ricerca HWND toolbar sostituibile nei test |
| `Send(Handle, Msg, WParam, LParam)` | Invia a un qualunque HWND |
| `Post(Handle, Msg, WParam, LParam)` | Accoda verso un qualunque HWND |
| `SendNpp(...)`, `PostNpp(...)` | Usano `NppHandle` |
| `SendMainScintilla(...)` | Usa `ScintillaMainHandle` |
| `SendSecondScintilla(...)` | Usa `ScintillaSecondHandle` |
| `GetNppVersion(var Major, Minor)` | Legge e normalizza la versione Notepad++ |
| `IsNppMinVersion(Major, Minor)` | Verifica la versione minima richiesta |
| `GetToolbarHandle` | Restituisce l'handle della toolbar nativa |
| `PerformMenuCommand(Id, Param, Delayed)` | Esegue un comando menu nativo di Notepad++ |

`NppDefaultHostTransport`, `NppDefaultHostPostTransport` e
`NppDefaultToolbarHandleResolver` sono le implementazioni pubbliche Win32.

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

Complete component manual: [`TNppCommands`](Docs/Npp.Commands.md).

Gli ID sono case-insensitive, devono essere univoci e non possono essere vuoti o contenere `:`, `;` o `|`, riservati al formato toolbar.

### Registrazione

| Metodo | Risultato / effetto |
| --- | --- |
| `TNppPlugin.Commands` | Registro già creato e posseduto dal plugin |
| `Create(AHost)` | Costruzione diretta avanzata; collega il registro a un host non `nil` |
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
| `GetFuncsArray(out Count)` | Espone la tabella ABI posseduta dal registro |
| `ApplySeparators` | Converte nel menu nativo le voci registrate come separatori |

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

`TNppToolbar` si registra automaticamente come listener. La fonte di verità per lo stato deve quindi essere `Commands.SetEnabled`, non una modifica diretta della toolbar.

```pascal
Commands.SetCaption('build', 'Build current document');
Commands.SetChecked('watch', True);
Commands.SetEnabled('build', FileExists(GetFullCurrentPath));
```

Un ID inesistente, un separatore o un duplicato genera `EArgumentException` nei metodi che richiedono un vero comando.
## Npp.Plugin

`TNppPlugin` riceve le chiamate ABI, mantiene `TNppData`, possiede i servizi
`Commands` e `Toolbar`, inoltra le notifiche ai metodi virtuali e offre wrapper
per le operazioni comuni.

Complete component manual: [`TNppPlugin`](Docs/Npp.Plugin.md).

### Proprietà

| Proprietà | Descrizione |
| --- | --- |
| `NppData` | Handle forniti da Notepad++ |
| `Host` | `TNppHost` posseduto dal plugin |
| `Commands` | `TNppCommands` sempre disponibile e posseduto dal plugin |
| `Toolbar` | `TNppToolbar` posseduta dal plugin, oppure `nil` se non configurata |
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
| `GetFuncsArray(out Count)` | Delega a `Commands.GetFuncsArray` per l'export ABI |
| `MessageProc(var Msg)` | Riceve messaggi Windows e applica i separatori |
| `BeNotified(SN)` | Esegue il dispatch e poi azzera `SCNotification` |
| `Shutdown` | Esegue una sola volta `DoNppnShutdown` |
| `GetCurrentScintilla` | HWND dell'editor attivo |

### Configurazione dei servizi

Nel costruttore della classe derivata, registrare prima tutti i comandi tramite
`Commands`, poi chiamare una sola volta il metodo protetto
`ConfigureToolbar(IconProvider, DisabledIconProvider)`. Una seconda
configurazione, un provider icone `nil` o la chiamata durante lo shutdown genera
un'eccezione.

La registrazione dei `TFuncItem`, lo stato del menu e la risoluzione dei `CmdID`
sono responsabilità di `Commands`. Registrazione delle icone e stato dei
pulsanti appartengono a `Toolbar`; i comandi menu nativi appartengono a `Host`.
`TNppPlugin` non espone più wrapper basati sull'indice menu.

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

Complete component manual: [`Npp.Toolbar`](Docs/Npp.Toolbar.md).

| Metodo / proprietà | Descrizione |
| --- | --- |
| `Count` | Numero di elementi |
| `Items[Index]` / `Layout[Index]` | Elemento per indice |
| `Add(ItemId, Visible)` | Aggiunge un ID univoco |
| `IndexOf(ItemId)` | Ricerca case-insensitive |
| `Move(FromIndex, ToIndex)` | Sposta mantenendo l'ordine degli altri |
| `SetVisible(Index, Visible)` | Cambia visibilità |
| `Serialize` | Produce il formato corrente basato su ID stabili |
| `CreateDefault(AvailableIds)` | Crea un layout tutto visibile |
| `TryParse(Value, out Layout)` | Valida e crea un layout dal solo formato corrente |

```pascal
Layout := Toolbar.CreateLayout;
try
  Layout.Move(Layout.IndexOf('build'), 0);
  Layout.SetVisible(Layout.IndexOf('about'), False);
  Toolbar.ApplyLayout(Layout);
finally
  Layout.Free;
end;
```

Il formato corrente usa ID stabili:

```text
open:1;build:1;about:0;
```

`1` significa visibile, `0` nascosto. Non esiste un prefisso di versione e non
esiste un parser legacy. La forma canonica termina con `;`. Quando la stringa
viene applicata a una toolbar inizializzata:

- gli ID rimossi dal plugin vengono ignorati;
- i nuovi ID vengono aggiunti in coda e resi visibili;
- duplicati, flag diversi da 0/1, ID invalidi e stringhe non canoniche fanno
  fallire il parsing con `EArgumentException` in `ApplyConfiguration`;
- configurazioni precedenti devono essere convertite o sostituite
  dall'applicazione.

Il chiamante possiede il `TNppToolbarLayout` restituito da `CreateDefault`,
`TryParse` o `CreateLayout`.

## Npp.Toolbar: manager

### Callback

| Tipo | Contratto |
| --- | --- |
| `TNppToolbarIconProvider` | Riceve `TNppMenuEntry`, riempie `TToolbarIconsWithDarkMode` e decide se creare il pulsante |
| `TNppToolbarDisabledIconProvider` | Riceve un HICON in prestito e restituisce un nuovo HICON disabilitato |

Il provider disabilitato è opzionale. Non deve distruggere l'HICON di input; l'HICON restituito viene distrutto dal manager dopo la copia nell'image list nativa.

### Costruzione

Nel normale plugin derivato da `TNppPlugin`:

```pascal
ConfigureToolbar(
  CreateIcons,          // obbligatorio
  CreateDisabledIcon);  // opzionale
```

La proprietà `Toolbar` diventa disponibile subito dopo la configurazione. Il
plugin base ne gestisce distruzione e notifiche. Il costruttore pubblico
`TNppToolbar.Create(Host, Commands, ...)` resta disponibile per usi avanzati
e test: in quel caso il manager non possiede host o registro e deve essere
distrutto prima di `Commands`.

### Metodi

| Metodo | Quando e cosa fa |
| --- | --- |
| `Initialize` | In `NPPN_TBMODIFICATION`: ricrea modello, icone e registrazione |
| `CaptureNativeButtons` | Dopo la creazione toolbar: acquisisce i template `TTBButton` |
| `Refresh` | Ricostruisce ordine, visibilità, enabled state e immagini disabilitate |
| `ReleaseResources` | Distrugge bitmap/icone, svuota il modello e conserva la configurazione per una reinizializzazione; è idempotente |
| `Configuration` | Restituisce la configurazione corrente normalizzata |
| `DefaultConfiguration` | Genera la configurazione predefinita, con tutti i pulsanti visibili |
| `CreateLayout(Default)` | Crea il layout corrente o, con `True`, quello predefinito; il chiamante lo possiede |
| `ApplyConfiguration(Value)` | Valida, conserva in memoria, riconcilia e applica la stringa alla toolbar nativa |
| `ApplyLayout(Layout)` | Serializza e applica un layout non `nil` |
| `SetEnabled(ItemId, State)` | Sincronizza modello e pulsante nativo |
| `CaptionForItem(ItemId)` | Caption corrente dal registro |
| `GetButtonInfo(Index, out Button)` | Copia sicura dei dati pulsante |
| `GetButtonInfo(ItemId, out Button)` | Lookup case-insensitive e copia sicura tramite ID stabile |
| `IsConfigurationValid(Value)` | Controllo sintattico statico del formato corrente |

Proprietà e record:

| Membro | Descrizione |
| --- | --- |
| `ButtonCount` | Comandi per cui il provider ha restituito icone valide |
| `Host` | Host associato, non posseduto |
| `Commands` | Registro associato, non posseduto |
| `Button[Index]` | Puntatore legacy; preferire `GetButtonInfo` |
| `TNppToolbarButton` | `CommandId`, `ItemId`, `Sequence`, `Visible`, `Enabled`, `NativeButton`, `IconData` |

Il puntatore di `Button[Index]` diventa invalido quando `Initialize` ridimensiona l'array interno.

`TNppToolbar` non legge e non scrive alcun supporto persistente. L'applicazione
può leggere da INI, registro, JSON o altro e passare il valore a
`ApplyConfiguration`; quando decide di salvare, persiste `Configuration`.

### Sequenza lifecycle

```text
costruttore plugin
  -> TNppPlugin crea Commands
  -> registra i comandi
  -> ConfigureToolbar crea Toolbar (opzionale)

NPPN_TBMODIFICATION
  -> Toolbar.Initialize

NPPN_READY
  -> Toolbar.CaptureNativeButtons
  -> Toolbar.Refresh

dark mode / nuovo icon set
  -> Toolbar.Refresh

distruzione plugin
  -> il plugin applicativo libera le proprie form
  -> TNppPlugin libera Toolbar
  -> TNppPlugin libera Commands
```
## UI di configurazione della toolbar

Il framework non fornisce una dialog di configurazione. Aspetto, controlli,
icone, traduzioni e comportamento dell'editor appartengono al plugin che usa la
libreria. `Npp.Toolbar` fornisce invece tutto il modello necessario alla UI:

- `CreateLayout` restituisce ordine e visibilità correnti;
- `CreateLayout(True)` restituisce il layout predefinito;
- `CaptionForItem` risolve la caption visualizzata;
- `GetButtonInfo` espone ID stabile e dati dell'icona;
- `ApplyLayout` valida, serializza e applica il risultato;
- `Configuration` espone la stringa che la UI può affidare alla persistenza
  dell'applicazione.

```pascal
Layout := Toolbar.CreateLayout;
try
  Layout.Move(OldIndex, NewIndex);
  Layout.SetVisible(NewIndex, CheckBox.Checked);
  Toolbar.ApplyLayout(Layout);
  Ini.WriteString('Toolbar', 'Layout', Toolbar.Configuration);
finally
  Layout.Free;
end;
```

La UI deve conservare `TNppToolbarLayoutItem.ItemId`, non l'indice visivo del
comando: in questo modo la configurazione resta valida se una versione futura
del plugin aggiunge o rimuove comandi. Un'implementazione completa basata su
DFM, `TTreeView`, drag-and-drop, icone applicative e temi light/dark è disponibile
in `Source/NppESPHome.FormToolbar.pas`.

## Npp.Vcl.Forms

`TNppPluginForm` è la base per dialog normali.

Complete component manual: [`TNppPluginForm`](Docs/Npp.Vcl.Forms.md).

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

`TNppPluginDocking` deriva da `TNppPluginForm`.

Complete component manual: [`TNppPluginDocking`](Docs/Npp.Vcl.Docking.md).

I due costruttori senza `DlgId` esistono per compatibilità ma sollevano un'eccezione. Usare sempre:

```pascal
Create(NppParent: TNppPlugin; DlgId: Integer)
Create(AOwner: TNppPluginForm; DlgId: Integer)
```

`DlgId` è l'indice menu restituito da `TNppCommands.AddCommand`, non il `CmdID` nativo.

```pascal
type
  TOutputDock = class(TNppPluginDocking)
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
| `IsDockingRegistered` | Stato locale della registrazione |
| `DockingData` | Copia del record `TTbData` |
| `OnDock`, `OnFloat` | Eventi generati dalle notifiche docking |

La registrazione rende inizialmente visibile la scheda. Se la preferenza persistita è “nascosta”, chiamare `Hide` dopo la costruzione. La chiusura utente usa `DefaultCloseAction = caHide`. Notepad++ non espone un messaggio pubblico di unregister: il distruttore nasconde il pannello e azzera lo stato locale.

Notepad++ applica direttamente il tema alle docking form; `SubclassAndTheme` è intenzionalmente vuoto in questa classe.

## Lifecycle, ownership e regole pratiche

| Fase | Operazioni |
| --- | --- |
| Costruttore plugin | Impostare `PluginName`, registrare tramite `Commands` e chiamare opzionalmente `ConfigureToolbar`; non usare ancora HWND host |
| `SetInfo` | Chiamare `inherited`, creare configurazione e servizi che richiedono percorsi Notepad++ |
| `NPPN_TBMODIFICATION` | Il framework chiama `Toolbar.Initialize` |
| `NPPN_READY` | Il framework acquisisce e aggiorna la toolbar; il plugin può creare le proprie form |
| Runtime | Aggiornare enabled/check/caption tramite `TNppCommands` |
| `NPPN_SHUTDOWN` | Fermare thread/processi e distruggere le form mentre l'host è valido |
| Distruttore plugin | Liberare solo le risorse applicative e poi chiamare `inherited` |

Ownership essenziale:

- `TNppPlugin` possiede `Host`, `Commands` e l'eventuale `Toolbar`.
- `TNppCommands` possiede la tabella `TFuncItem` e i `PShortcutKey` registrati.
- Il plugin applicativo possiede le proprie form e gli altri servizi specifici.
- `TNppToolbar` possiede gli handle immagine restituiti dai provider.
- I layout restituiti sono sempre del chiamante.
- `TNppCommands` e `TNppToolbar` non possiedono `Host`.
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
