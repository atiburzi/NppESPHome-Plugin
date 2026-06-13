unit ESPHomeToolbar;

interface

uses
  NppSupport,  Winapi.CommCtrl, System.UITypes, Vcl.Graphics, WinAPI.Windows;

type
  TToolbarButton = record
    Index: Integer;
    CmdID: Integer;
    Button: TTBButton;
    IconData: TToolbarIconsWithDarkMode;
  end;

function HasToolbarIcon(const IconData: TToolbarIconsWithDarkMode): Boolean;
function CreateIconFromBitmap(Bitmap: Vcl.Graphics.TBitmap): HICON;
procedure ConvertBitmapToBlack(Bitmap: Vcl.Graphics.TBitmap);
procedure ReplaceBitmapHue(ABitmap: Vcl.Graphics.TBitmap; const SourceColor: TAlphaColor; const TargetColor: TAlphaColor; const HueTolerance: Single = 30 / 360; const MinSaturation: Single = 0.15);

implementation

uses
   System.UIConsts;

function HasToolbarIcon(const IconData: TToolbarIconsWithDarkMode): Boolean;
begin
  Result :=
    (IconData.ToolbarBmp <> 0) or
    (IconData.ToolbarIcon <> 0) or
    (IconData.ToolbarIconDarkMode <> 0);
end;

function CreateIconFromBitmap(Bitmap: Vcl.Graphics.TBitmap): HICON;
var
  IconInfo: TIconInfo;
begin
  FillChar(IconInfo, SizeOf(IconInfo), 0);
  IconInfo.fIcon := True;
  IconInfo.hbmMask := Bitmap.Handle;
  IconInfo.hbmColor := Bitmap.Handle;
  Result := CreateIconIndirect(IconInfo);
end;

procedure ConvertBitmapToBlack(Bitmap: Vcl.Graphics.TBitmap);
var
  x, y: Integer;
  P: PRGBQuad;
begin
  Bitmap.PixelFormat := pf32bit;
  for y := 0 to Bitmap.Height - 1 do
  begin
    P := Bitmap.ScanLine[y];
    for x := 0 to Bitmap.Width - 1 do
    begin
      if P^.rgbReserved > 0 then // Alpha channel
      begin
        P^.rgbRed := 0;
        P^.rgbGreen := 0;
        P^.rgbBlue := 0;
      end;
      Inc(P);
    end;
  end;
end;

procedure ReplaceBitmapHue(ABitmap: Vcl.Graphics.TBitmap; const SourceColor: TAlphaColor; const TargetColor: TAlphaColor; const HueTolerance: Single = 30 / 360; const MinSaturation: Single = 0.15);
type
  PRGBQuadArray = ^TRGBQuadArray;
  TRGBQuadArray = array[0..MaxInt div SizeOf(TRGBQuad) - 1] of TRGBQuad;

  function HueDistance(const H1, H2: Single): Single;
  begin
    Result := Abs(H1 - H2);
    if Result > 0.5 then
      Result := 1.0 - Result;
  end;

var
  X, Y: Integer;
  Row: PRGBQuadArray;
  P: TRGBQuad;
  C, NewC: TAlphaColor;
  H, S, L: Single;
  SourceH, SourceS, SourceL: Single;
  TargetH, TargetS, TargetL: Single;
begin
  RGBtoHSL(SourceColor, SourceH, SourceS, SourceL);
  RGBtoHSL(TargetColor, TargetH, TargetS, TargetL);
  ABitmap.PixelFormat := pf32bit;
  for Y := 0 to ABitmap.Height - 1 do
  begin
    Row := ABitmap.ScanLine[Y];
    for X := 0 to ABitmap.Width - 1 do
    begin
      P := Row[X];
      if P.rgbReserved > 0 then
      begin
        C := TAlphaColor($FF000000) or (TAlphaColor(P.rgbRed) shl 16) or (TAlphaColor(P.rgbGreen) shl 8) or TAlphaColor(P.rgbBlue);
        RGBtoHSL(C, H, S, L);
        if (S >= MinSaturation) and (HueDistance(H, SourceH) <= HueTolerance) then
        begin
          NewC := HSLtoRGB(TargetH, S, L);
          Row[X].rgbRed := TAlphaColorRec(NewC).R;
          Row[X].rgbGreen := TAlphaColorRec(NewC).G;
          Row[X].rgbBlue := TAlphaColorRec(NewC).B;
        end;
      end;
    end;
  end;
end;



end.
