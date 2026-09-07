{
    Plugin DLL interface routines for extending a plugin project's *.dpr file.

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

var
  PluginLoadErrorName: nppString = 'Plugin load error';

procedure ReportPluginException(const EntryPoint: string; E: Exception);
begin
  OutputDebugString(PChar(Format('%s.%s failed: %s: %s',
    [PluginLoadErrorName, EntryPoint, E.ClassName, E.Message])));
end;

function EnsurePlugin: TNppPlugin;
begin
  if not Assigned(BasePlugin) then
  begin
    if not Assigned(PluginClass) then
      raise Exception.Create('No Notepad++ plugin class has been registered');
    BasePlugin := PluginClass.Create;
  end;
  Result := BasePlugin;
end;

procedure DLLEntryPoint(dwReason: DWord);
begin
  case dwReason of
    DLL_PROCESS_ATTACH:
      ;

    DLL_PROCESS_DETACH:
      // Never run plugin/VCL destructors while the Windows loader lock is held.
      // Notepad++ releases the instance through NPPN_SHUTDOWN; on an abnormal
      // unload the operating system will reclaim the module's remaining state.
      BasePlugin := nil;

    DLL_THREAD_ATTACH:
    begin
      // ignore
    end;

    DLL_THREAD_DETACH:
    begin
      // ignore
    end;
  end;
end;


function messageProc(msg: Cardinal; _wParam: WPARAM; _lParam: LPARAM): LRESULT; cdecl; export;
var
  xmsg: TMessage;

begin
  xmsg.Msg    := msg;
  xmsg.WParam := _wParam;
  xmsg.LParam := _lParam;
  xmsg.Result := 0;

  try
    EnsurePlugin.MessageProc(xmsg);
    Result := xmsg.Result;
  except
    on E: Exception do
    begin
      ReportPluginException('messageProc', E);
      Result := 0;
    end;
  end;
end;


procedure beNotified(sn: PSCNotification); cdecl; export;
var
  IsShutdownNotification: Boolean;
begin
  if not Assigned(sn) then
    Exit;
  IsShutdownNotification := sn^.nmhdr.code = NPPN_SHUTDOWN;
  try
    try
      EnsurePlugin.BeNotified(sn);
    finally
      // The callback has returned (also when cleanup raised), so destruction is
      // safe here and happens before DLL_PROCESS_DETACH enters the loader lock.
      if IsShutdownNotification then
        FreeAndNil(BasePlugin);
    end;
  except
    on E: Exception do
      ReportPluginException('beNotified', E);
  end;
end;


procedure setInfo(NppData: TNppData); cdecl; export;
begin
  try
    EnsurePlugin.SetInfo(NppData);
  except
    on E: Exception do
      ReportPluginException('setInfo', E);
  end;
end;


function getFuncsArray(out nFuncs: Integer): PFuncItem; cdecl; export;
begin
  nFuncs := 0;
  Result := nil;
  try
    Result := EnsurePlugin.GetFuncsArray(nFuncs);
  except
    on E: Exception do
      ReportPluginException('getFuncsArray', E);
  end;
end;


function getName(): nppPchar; cdecl; export;
begin
  Result := nppPChar(PluginLoadErrorName);
  try
    Result := EnsurePlugin.GetName;
  except
    on E: Exception do
      ReportPluginException('getName', E);
  end;
end;


function isUnicode: LongBool; cdecl; export;
begin
  Result := True;
end;



exports
  setInfo, getName, getFuncsArray, beNotified, messageProc, isUnicode;
