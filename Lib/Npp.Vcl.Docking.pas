{
    Base class for Notepad++ plugin docked dialog development.

    The content of this file was originally provided by Damjan Zobo Cvetko
    Modified by Andreas Heim for using in the plugin framework for Delphi.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
}

unit Npp.Vcl.Docking;


interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms,

  Npp.Api, Npp.Plugin, Npp.Vcl.Forms;


type
  // ***************************************************************************
  // Purpose: Integrates a VCL form with the Notepad++ docking manager.
  // ***************************************************************************
  TNppPluginDocking = class(TNppPluginForm)
  private
    FDlgId: Integer;
    FOnDock: TNotifyEvent;
    FOnFloat: TNotifyEvent;
    FRegisteredDocking: Boolean;
    FName: string;
    FAdditionalInfo: string;
    FModuleName: string;

    function GetHostHandle: HWND;
    function HostAvailable: Boolean;
    procedure SyncDockingData;
    procedure RemoveControlParent(AControl: TControl);

  protected
    FTbData: TTbData;
    FNppDefaultDockingMask: Cardinal;

    procedure OnWM_NOTIFY(var Msg: TWMNotify); message WM_NOTIFY;

  public
    constructor Create(NppParent: TNppPlugin); reintroduce; overload; virtual;
    constructor Create(AOwner: TNppPluginForm); reintroduce; overload; virtual;
    constructor Create(NppParent: TNppPlugin; DlgId: Integer); overload; virtual;
    constructor Create(AOwner: TNppPluginForm; DlgId: Integer); overload; virtual;
    destructor Destroy; override;

    procedure Show;
    procedure Hide;

    procedure RegisterDockingForm(MaskStyle: Cardinal = DWS_DF_CONT_LEFT);
    procedure RefreshDockingInfo;

    procedure UpdateDisplayInfo; overload;
    procedure UpdateDisplayInfo(Info: string); overload;
    procedure SubclassAndTheme(DmFlag: TNppDarkMode); override;

    property DlgID: Integer read FDlgid;
    property IsDockingRegistered: Boolean read FRegisteredDocking;
    property DockingData: TTbData read FTbData;
    property OnDock: TNotifyEvent read FOnDock write FOnDock;
    property OnFloat: TNotifyEvent read FOnFloat write FOnFloat;

  end;

implementation

resourcestring
  rsMessageDoNotUseThisConstructor = 'Do not use this constructor';
  rsMessagePluginFrameworkError = 'Plugin Framework error';
  rsDockingHostUnavailable =
    'A docking form cannot be registered before the Notepad++ host is available';


// =============================================================================
// Class TNppPluginDocking
// =============================================================================

// -----------------------------------------------------------------------------
// Create / Destroy
// -----------------------------------------------------------------------------

// *****************************************************************************
// Purpose: Rejects construction without the command ID required for docking.
// *****************************************************************************
constructor TNppPluginDocking.Create(NppParent: TNppPlugin);
begin
  raise Exception.Create(rsMessageDoNotUseThisConstructor);
end;

// *****************************************************************************
// Purpose: Rejects child-form construction without a docking command ID.
// *****************************************************************************
constructor TNppPluginDocking.Create(AOwner: TNppPluginForm);
begin
  raise Exception.Create(rsMessageDoNotUseThisConstructor);
end;

// *****************************************************************************
// Purpose: Creates and registers a top-level Notepad++ docking form.
// *****************************************************************************
constructor TNppPluginDocking.Create(NppParent: TNppPlugin; DlgId: Integer);
begin
  inherited Create(NppParent);
  DefaultCloseAction := caHide;
  FDlgId := DlgId;
  RegisterDockingForm(FNppDefaultDockingMask);
  RemoveControlParent(Self);
end;

// *****************************************************************************
// Purpose: Releases resources owned by the TNppPluginDocking instance.
// *****************************************************************************
destructor TNppPluginDocking.Destroy;
begin
  // Hide the native docking window while the host is still available. There
  // is no public Notepad++ message to unregister a docking panel; clearing the
  // local state prevents any later notification from being treated as ours.
  if FRegisteredDocking then
    Hide;
  FRegisteredDocking := False;
  inherited;
end;

// *****************************************************************************
// Purpose: Creates and registers a docking form owned by another plugin form.
// *****************************************************************************
constructor TNppPluginDocking.Create(AOwner: TNppPluginForm; DlgId: Integer);
begin
  inherited Create(AOwner);
  DefaultCloseAction := caHide;
  FDlgId := DlgId;
  RegisterDockingForm(FNppDefaultDockingMask);
  RemoveControlParent(Self);
end;

// -----------------------------------------------------------------------------
// (De-)Initialization
// -----------------------------------------------------------------------------

// Register docking dialog in Notepad++
// *****************************************************************************
// Purpose: Registers the form as a Notepad++ docking panel.
// *****************************************************************************
procedure TNppPluginDocking.RegisterDockingForm(MaskStyle: Cardinal = DWS_DF_CONT_LEFT);
begin
  if FRegisteredDocking then
    Exit;
  if not HostAvailable then
    raise EInvalidOpException.Create(rsDockingHostUnavailable);

  HandleNeeded;

  FillChar(FTbData, SizeOf(TTbData), 0);

  FAdditionalInfo := '';
  FTbData.Mask := MaskStyle or DWS_ADDINFO;
  SyncDockingData;

  if not Self.Icon.Empty then
  begin
    FTbData.IconTab := Icon.Handle;
    FTbData.Mask := FTbData.Mask or DWS_ICONTAB;
  end;

  ParentPlugin.Host.SendNpp(NPPM_DMMREGASDCKDLG, 0, LPARAM(@FTbData));
  FRegisteredDocking := True;
  // Keep the original framework behavior: registering a docking panel also
  // creates its initial visible tab. The plugin may hide it immediately after
  // restoring its persisted visibility preference.
  Visible := True;
end;


// -----------------------------------------------------------------------------
// Show / Hide
// -----------------------------------------------------------------------------

// *****************************************************************************
// Purpose: Shows both the native docking panel and its VCL form.
// *****************************************************************************
procedure TNppPluginDocking.Show;
begin
  if not FRegisteredDocking and HostAvailable then
    RegisterDockingForm(FNppDefaultDockingMask);
  if FRegisteredDocking then
    ParentPlugin.Host.SendNpp(NPPM_DMMSHOW, 0, LPARAM(Self.Handle));
  inherited Show;
end;


// *****************************************************************************
// Purpose: Hides both the native docking panel and its VCL form.
// *****************************************************************************
procedure TNppPluginDocking.Hide;
begin
  if FRegisteredDocking and HostAvailable then
    ParentPlugin.Host.SendNpp(NPPM_DMMHIDE, 0, LPARAM(Self.Handle));
  inherited Hide;
end;


// -----------------------------------------------------------------------------
// Overridden event handlers
// -----------------------------------------------------------------------------

// *****************************************************************************
// Purpose: Handles docking close, float, and dock notifications from Notepad++.
// *****************************************************************************
procedure TNppPluginDocking.OnWM_NOTIFY(var Msg: TWMNotify);
begin
  if HostAvailable and (GetHostHandle = Msg.NMHdr.hwndFrom) then
  begin
    Msg.Result := 0;
    if (Msg.NMHdr.code = DMN_CLOSE) then
      Close
    else if ((Msg.NMHdr.code and $FFFF) = DMN_FLOAT) then
    begin
      if Assigned(FOnFloat) then
        FOnFloat(Self);
    end
    else if ((Msg.NMHdr.code and $FFFF) = DMN_DOCK) then
    begin
      if Assigned(FOnDock) then
        FOnDock(Self);
    end;
  end;
  inherited;
end;

// -----------------------------------------------------------------------------
// Worker methods
// -----------------------------------------------------------------------------

// *****************************************************************************
// Purpose: Updates the optional text displayed for the docking panel.
// *****************************************************************************
procedure TNppPluginDocking.UpdateDisplayInfo;
begin
  UpdateDisplayInfo('');
end;

// *****************************************************************************
// Purpose: Updates the optional text displayed for the docking panel.
// *****************************************************************************
procedure TNppPluginDocking.UpdateDisplayInfo(Info: String);
begin
  FAdditionalInfo := Info;
  RefreshDockingInfo;
end;

// *****************************************************************************
// Purpose: Submits the current docking metadata to Notepad++.
// *****************************************************************************
procedure TNppPluginDocking.RefreshDockingInfo;
begin
  if not FRegisteredDocking or not HostAvailable then
    Exit;
  SyncDockingData;
  ParentPlugin.Host.SendNpp(NPPM_DMMUPDATEDISPINFO, 0, LPARAM(Self.Handle));
end;

// *****************************************************************************
// Purpose: Skips unsupported dark-mode subclassing for docking panels.
// *****************************************************************************
procedure TNppPluginDocking.SubclassAndTheme(DmFlag: TNppDarkMode);
begin
  // Notepad++ themes docking panels itself. Calling
  // NPPM_DARKMODESUBCLASSANDTHEME for them is explicitly unsupported.
end;


// -----------------------------------------------------------------------------
// Internal Utils
// -----------------------------------------------------------------------------

// *****************************************************************************
// Purpose: Removes WS_EX_CONTROLPARENT recursively to prevent focus loops.
// *****************************************************************************
procedure TNppPluginDocking.RemoveControlParent(AControl: TControl);
var
  WinCtrl: TWinControl;
  Index: Integer;
  ExStyle: NativeInt;
begin
  // Floating panels can make Win32 dialog navigation walk back into the panel
  // itself. Removing this extended style prevents that focus cycle.
  if (AControl is TWinControl) then
  begin
    WinCtrl := AControl as TWinControl;
    WinCtrl.HandleNeeded;
    ExStyle := GetWindowLongPtr(WinCtrl.Handle, GWL_EXSTYLE);
    if (ExStyle and WS_EX_CONTROLPARENT) = WS_EX_CONTROLPARENT then
      SetWindowLongPtr(WinCtrl.Handle, GWL_EXSTYLE,
        ExStyle and not NativeInt(WS_EX_CONTROLPARENT));
  end;
  for Index := AControl.ComponentCount - 1 downto 0 do
  begin
    if (AControl.Components[Index] is TControl) then
      RemoveControlParent(AControl.Components[Index] as TControl);
  end;
end;

// *****************************************************************************
// Purpose: Returns the Notepad++ window handle associated with the form.
// *****************************************************************************
function TNppPluginDocking.GetHostHandle: HWND;
begin
  Result := 0;
  if Assigned(ParentPlugin) then
    Result := ParentPlugin.NppData.NppHandle;
end;

// *****************************************************************************
// Purpose: Reports whether Notepad++ has supplied a usable protocol handle.
// *****************************************************************************
function TNppPluginDocking.HostAvailable: Boolean;
begin
  // NppData.NppHandle is supplied by Notepad++ before NPPN_READY. Do not use
  // IsWindow here: during startup/recreation the handle can be valid for the
  // plugin protocol before the Win32 window manager reports it as a window.
  Result := GetHostHandle <> 0;
end;

// *****************************************************************************
// Purpose: Rebuilds pointer-backed docking metadata before sending it to Notepad++.
// *****************************************************************************
procedure TNppPluginDocking.SyncDockingData;
begin
  // TTbData stores raw character pointers. Keep the backing strings in fields
  // so their storage remains valid after this method returns.
  FName := Caption;
  FModuleName := ExtractFileName(GetModuleName(HInstance));
  FTbData.ClientHandle := Handle;
  FTbData.Name := PWideChar(FName);
  FTbData.DlgId := FDlgId;
  FTbData.AdditionalInfo := PWideChar(FAdditionalInfo);
  FTbData.ModuleName := PWideChar(FModuleName);
end;


end.
