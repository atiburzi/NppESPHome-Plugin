{
    Base class for Notepad++ plugin dialog development.

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

unit Npp.Vcl.Forms;


interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Math, System.Types,
  System.Classes, Vcl.Controls, Vcl.Forms,
  Npp.Api, Npp.Plugin;

type
  // ***************************************************************************
  // Purpose: Integrates a normal VCL form with the Notepad++ host lifecycle.
  // ***************************************************************************
  TNppPluginForm = class(TForm)
  private
    FRegistered: Boolean;
    FThemeInitialized: Boolean;
    FApplicationAttached: Boolean;
    function CanRegister: Boolean;
    procedure AttachApplication;
    procedure DetachApplication;

  protected
    procedure CreateParams(var Params: TCreateParams); override;

    procedure DoCreate; override;
    procedure DoClose(var Action: TCloseAction); override;

    procedure RegisterForm();
    procedure UnregisterForm();

  public
    ParentPlugin: TNppPlugin;
    DefaultCloseAction: TCloseAction;

    constructor Create(ParentPlugin: TNppPlugin); reintroduce; overload; virtual;
    constructor Create(AOwner: TNppPluginForm); reintroduce; overload; virtual;
    constructor CreateRuntime(ParentPlugin: TNppPlugin;
      Dummy: Integer); virtual;
    destructor Destroy; override;

    procedure InitLanguage; virtual;
    procedure ToggleDarkMode; virtual;
    procedure SubclassAndTheme(DmFlag: TNppDarkMode); virtual;

    function WantChildKey(Child: TControl; var Message: TMessage): Boolean; override;

  end;

implementation

type
  // ***************************************************************************
  // Purpose: Owns the process-wide VCL Application.Handle attachment state.
  // ***************************************************************************
  TNppVclApplicationState = class sealed
  strict private
    class var FAttachmentCount: Integer;
    class var FHostHandle: HWND;
    class var FPreviousHandle: HWND;
  public
    class procedure Acquire(AHostHandle: HWND); static;
    class procedure Release; static;
  end;

// *****************************************************************************
// Purpose: Attaches the shared VCL Application object for the first plugin form.
// *****************************************************************************
class procedure TNppVclApplicationState.Acquire(AHostHandle: HWND);
begin
  if FAttachmentCount = 0 then
  begin
    FPreviousHandle := Application.Handle;
    FHostHandle := AHostHandle;
    try
      Application.Handle := FHostHandle;
    except
      FPreviousHandle := 0;
      FHostHandle := 0;
      raise;
    end;
  end;
  Inc(FAttachmentCount);
end;

// *****************************************************************************
// Purpose: Restores the original VCL handle after the last form detaches.
// *****************************************************************************
class procedure TNppVclApplicationState.Release;
begin
  if FAttachmentCount = 0 then
    Exit;
  Dec(FAttachmentCount);
  if FAttachmentCount <> 0 then
    Exit;
  try
    // Do not overwrite a handle deliberately replaced by another VCL owner
    // while plugin forms were alive.
    if Application.Handle = FHostHandle then
      Application.Handle := FPreviousHandle;
  finally
    FPreviousHandle := 0;
    FHostHandle := 0;
  end;
end;

// *****************************************************************************
// Purpose: Attaches the shared VCL application object to the Notepad++ window.
// *****************************************************************************
procedure TNppPluginForm.AttachApplication;
begin
  if FApplicationAttached then
    Exit;
  if not Assigned(ParentPlugin) then
    Exit;
  TNppVclApplicationState.Acquire(ParentPlugin.NppData.NppHandle);
  FApplicationAttached := True;
end;

// *****************************************************************************
// Purpose: Restores the previous VCL application handle when no forms remain.
// *****************************************************************************
procedure TNppPluginForm.DetachApplication;
begin
  if not FApplicationAttached then
    Exit;
  FApplicationAttached := False;
  TNppVclApplicationState.Release;
end;

// *****************************************************************************
// Purpose: Creates a top-level plugin form from its DFM resource.
// *****************************************************************************
constructor TNppPluginForm.Create(ParentPlugin: TNppPlugin);
begin
  if not Assigned(ParentPlugin) then
    raise EArgumentNilException.Create('ParentPlugin');
  Self.ParentPlugin := ParentPlugin;
  DefaultCloseAction := caNone;
  FThemeInitialized := False;
  FRegistered := False;
  FApplicationAttached := False;
  AttachApplication;
  try
    inherited Create(nil);
  except
    DetachApplication;
    raise;
  end;
  ParentWindow := ParentPlugin.NppData.NppHandle;
  RegisterForm();
  if ParentPlugin.IsNppMinVersion(8, 410) then
    ToggleDarkMode;
end;

// *****************************************************************************
// Purpose: Creates a DFM-backed child form that shares its owner's plugin.
// *****************************************************************************
constructor TNppPluginForm.Create(AOwner: TNppPluginForm);
begin
  if not Assigned(AOwner) then
    raise EArgumentNilException.Create('AOwner');
  ParentPlugin := AOwner.ParentPlugin;
  DefaultCloseAction := caNone;
  FThemeInitialized := False;
  FRegistered := False;
  FApplicationAttached := False;
  AttachApplication;
  try
    inherited Create(AOwner);
  except
    DetachApplication;
    raise;
  end;
  if ParentPlugin.IsNppMinVersion(8, 410) then
    ToggleDarkMode;
end;

// *****************************************************************************
// Purpose: Creates a top-level plugin form without loading a DFM resource.
// *****************************************************************************
constructor TNppPluginForm.CreateRuntime(ParentPlugin: TNppPlugin;
  Dummy: Integer);
begin
  if not Assigned(ParentPlugin) then
    raise EArgumentNilException.Create('ParentPlugin');
  Self.ParentPlugin := ParentPlugin;
  DefaultCloseAction := caNone;
  FThemeInitialized := False;
  FRegistered := False;
  FApplicationAttached := False;
  AttachApplication;
  try
    inherited CreateNew(nil);
  except
    DetachApplication;
    raise;
  end;
  ParentWindow := ParentPlugin.NppData.NppHandle;
  RegisterForm;
  if ParentPlugin.IsNppMinVersion(8, 410) then
    ToggleDarkMode;
end;

// *****************************************************************************
// Purpose: Releases resources owned by the TNppPluginForm instance.
// *****************************************************************************
destructor TNppPluginForm.Destroy;
begin
  try
    UnregisterForm();
    inherited;
  finally
    DetachApplication;
  end;
end;


// *****************************************************************************
// Purpose: Registers the form as a modeless dialog with Notepad++.
// *****************************************************************************
procedure TNppPluginForm.RegisterForm();
begin
  if not CanRegister then
    Exit;
  FRegistered := ParentPlugin.Host.SendNpp(NPPM_MODELESSDIALOG,
    MODELESSDIALOGADD, Handle) <> 0;
end;



// *****************************************************************************
// Purpose: Removes the form from the Notepad++ modeless-dialog registry.
// *****************************************************************************
procedure TNppPluginForm.UnregisterForm();
begin
  if not FRegistered then
    Exit;
  if CanRegister then
    ParentPlugin.Host.SendNpp(NPPM_MODELESSDIALOG,
      MODELESSDIALOGREMOVE, Handle);
  FRegistered := False;
end;

// *****************************************************************************
// Purpose: Reports whether both host and form handles are ready for registration.
// *****************************************************************************
function TNppPluginForm.CanRegister: Boolean;
begin
  Result := (Assigned(ParentPlugin) and IsWindow(ParentPlugin.NppData.NppHandle) and Self.HandleAllocated);
end;

// *****************************************************************************
// Purpose: Provides an override point for application-owned form localization.
// *****************************************************************************
procedure TNppPluginForm.InitLanguage;
begin
  // Descendants can localize controls after the DFM has been loaded.
end;

// *****************************************************************************
// Purpose: Adjusts native parameters so the form behaves as a plugin window.
// *****************************************************************************
procedure TNppPluginForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style and (not WS_CHILD);
end;

// *****************************************************************************
// Purpose: Completes form registration, placement, language, and theme setup.
// *****************************************************************************
procedure TNppPluginForm.DoCreate;
var
  ParentHandle: HWND;
  ParentRect: TRect;
  TargetRect: TRect;
  MonitorRect: TRect;
  WorkareaRect: TRect;
  CurMonitor: TMonitor;
begin
  ParentHandle := ParentWindow;
  if (ParentHandle = 0) and Assigned(ParentPlugin) then
    ParentHandle := ParentPlugin.NppData.NppHandle;

  if (ParentHandle <> 0) and GetWindowRect(ParentHandle, ParentRect) then
  begin
    TargetRect := Bounds(Max(ParentRect.Left, (ParentRect.Left + ParentRect.Right - Width) div 2), Max(ParentRect.Top, (ParentRect.Top + ParentRect.Bottom -
      Height) div 2), Width, Height);

    CurMonitor := Screen.MonitorFromRect(TargetRect);
    MonitorRect := CurMonitor.BoundsRect;
    WorkareaRect := CurMonitor.WorkareaRect;

    TargetRect.Location := Point(EnsureRange(TargetRect.Left, MonitorRect.Left, IfThen(CurMonitor.Primary, WorkareaRect.Right, MonitorRect.Right) - TargetRect.Width),
      EnsureRange(TargetRect.Top, MonitorRect.Top, IfThen(CurMonitor.Primary, WorkareaRect.Bottom, MonitorRect.Bottom) - TargetRect.Height));

    BoundsRect := TargetRect;
  end;
  inherited;
end;

// *****************************************************************************
// Purpose: Applies the configured close action before the VCL close sequence continues.
// *****************************************************************************
procedure TNppPluginForm.DoClose(var Action: TCloseAction);
begin
  if (DefaultCloseAction <> caNone) then
    Action := DefaultCloseAction;
  inherited;
end;

// *****************************************************************************
// Purpose: Chooses initialization or refresh mode for Notepad++ dark theming.
// *****************************************************************************
procedure TNppPluginForm.ToggleDarkMode;
var
  DmFlag: TNppDarkMode;
begin
  if FThemeInitialized then
    DmFlag := dmfHandleChange
  else
  begin
    DmFlag := dmfInit;
    FThemeInitialized := True;
  end;
  if Assigned(ParentPlugin) and ParentPlugin.IsNppMinVersion(8, 540) then
    SubclassAndTheme(DmFlag);
end;

// *****************************************************************************
// Purpose: Requests Notepad++ dark-mode subclassing for a normal plugin form.
// *****************************************************************************
procedure TNppPluginForm.SubclassAndTheme(DmFlag: TNppDarkMode);
begin
  if Assigned(ParentPlugin) and HandleAllocated then
    ParentPlugin.Host.SendNpp(NPPM_DARKMODESUBCLASSANDTHEME,
      WPARAM(DmFlag), LPARAM(Self.Handle));
end;

// *****************************************************************************
// Purpose: Lets Notepad++ process dialog navigation keys from child controls.
// *****************************************************************************
function TNppPluginForm.WantChildKey(Child: TControl; var Message: TMessage): Boolean;
begin
  Result := Assigned(Child) and
    (Child.Perform(CN_BASE + Message.Msg, Message.WParam, Message.LParam) <> 0);
end;


end.
