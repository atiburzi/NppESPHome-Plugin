unit Ping;

interface

const
  DefaultTimeoutMS = 1000;

function GetFQDN(const HostName: string): string;
function DoPing(const HostName: string; TimeoutMS: cardinal = DefaultTimeoutMS): Boolean;

implementation

uses WinSock, WinApi.Windows, SysUtils;

type
  TIPOptionInformation = record
    Ttl: Byte;
    Tos: Byte;
    Flags: Byte;
    OptionsSize: Byte;
    OptionsData: PByte;
  end;

  PICMP_ECHO_REPLY = ^ICMP_ECHO_REPLY;
  ICMP_ECHO_REPLY = packed record
    Address: DWORD;
    Status: DWORD;
    RoundTripTime: DWORD;
    DataSize: Word;
    Reserved: Word;
    Data: Pointer;
    Options: TIPOptionInformation;
  end;

function IcmpCreateFile: THandle; stdcall; external 'iphlpapi.dll';
function IcmpCloseHandle(icmpHandle: THandle): boolean; stdcall;
  external 'iphlpapi.dll';
function IcmpSendEcho(icmpHandle: THandle; DestinationAddress: In_Addr;
  RequestData: Pointer; RequestSize: Smallint; RequestOptions: Pointer;
  ReplyBuffer: Pointer; ReplySize: DWORD; Timeout: DWORD): DWORD; stdcall;
  external 'iphlpapi.dll';

function GetFQDN(const HostName: string): string;
var
  WSAData: TWSAData;
  HostEnt: PHostEnt;
  Addr: TInAddr;
begin
  Result := '';
  if WSAStartup($0202, WSAData) = 0 then
  begin
    try
      HostEnt := gethostbyname(PAnsiChar(AnsiString(HostName)));
      if Assigned(HostEnt) then
      begin
        Addr := PInAddr(HostEnt^.h_addr_list^)^;
        HostEnt := gethostbyaddr(@Addr, SizeOf(Addr), AF_INET);
        if HostEnt <> nil then
          Result := string(HostEnt^.h_name);
      end;
    finally
      WSACleanup;
    end;
  end;
end;

function DoPing(const HostName: string; TimeoutMS: cardinal = DefaultTimeoutMS): Boolean;
const
  BufferSize = $400;
var
  HostEnt: PHostEnt;
  Addr: PInAddr;
  HIcmp: THandle;
  SendData: string;
  Buffer: Pointer;
  IcmpRes: cardinal;
  WSAData: TWSAData;
  AnsiHost: AnsiString;
begin
  Result := False;
  if WSAStartup($0101, WSAData) <> 0 then
    Exit;
  AnsiHost := AnsiString(HostName);
  HostEnt := gethostbyname(PAnsiChar(AnsiHost));
  if HostEnt <> nil then
  begin
    GetMem(Buffer, BufferSize);
    if HostEnt.h_addrtype = AF_INET then
    begin
      Addr := Pointer(HostEnt.h_addr^);
      SendData := FormatDateTime('yyyymmddhhnnsszzz', Now);
      HIcmp := IcmpCreateFile;
      if HIcmp <> INVALID_HANDLE_VALUE then
      begin
        IcmpRes := IcmpSendEcho(HIcmp, Addr^, PChar(SendData), Length(SendData), nil, Buffer, BufferSize, TimeoutMS);
        Result := (IcmpRes <> 0) and (PICMP_ECHO_REPLY(Buffer)^.Status = 0);
        IcmpCloseHandle(HIcmp);
      end;
    end;
    FreeMem(Buffer, BufferSize);
  end;
  WSACleanup;
end;

end.
