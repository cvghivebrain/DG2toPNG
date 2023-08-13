program PDG2toPNG;

{$APPTYPE CONSOLE}

uses
  Classes,
  SysUtils,
  FileFunc in 'FileFunc.pas',
  PNGFunc in 'PNGFunc.pas';

var
  i, dg2w, dg2h: integer;
  p: byte;
  pngfile: string;
  palarray: array[0..767] of byte;

procedure ReadPalette;
var dg2col: word;
begin
  for i := 0 to 255 do
    begin
    dg2col := GetWord((i*2)+6); // Get 15-bit colour value.
    palarray[i*3] := ((dg2col and $1F)*8)+4; // Get red value.
    palarray[(i*3)+1] := (((dg2col shr 5) and $1F)*8)+4; // Get green value.
    palarray[(i*3)+2] := ((dg2col shr 10)*8)+4; // Get blue value.
    end;
end;

begin
  { Program start }

  if ParamCount = 0 then exit; // End program if run without parameters.
  if not FileExists(ParamStr(1)) then exit; // End if input file doesn't exist.

  if ParamStr(2) = '' then pngfile := ChangeFileExt(ExtractFileName(ParamStr(1)),'.png')
    else pngfile := ParamStr(2); // Set output file.
  LoadFile(ParamStr(1)); // Load input file.
  dg2w := GetWord(2); // Get width and height.
  dg2h := GetWord(4);
  if dg2w*dg2h = 0 then exit; // End program if either width or height are 0.
  InitPNG(dg2w,dg2h); // Create blank PNG.

  if GetString(0,2) = 'PP' then
    begin
    ReadPalette; // Load palette from file.
    for i := 0 to (dg2w*dg2h)-1 do
      begin
      p := GetByte(i+518); // Get byte value for pixel.
      PixelPNG(palarray[p*3],palarray[(p*3)+1],palarray[(p*3)+2],255,i mod dg2w,i div dg2w); // Draw pixel to PNG.
      end;
    end;

  SavePNG(pngfile); // Save output PNG.
end.