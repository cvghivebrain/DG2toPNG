unit PNGFunc;

interface
uses SysUtils, Dialogs, ExtCtrls, Classes, pngimage;

procedure InitPNG(w, h: integer);
procedure AssignPNG(img: TImage);
procedure PixelPNG(r, g, b, a: byte; x, y: integer);
procedure MovePNG(x, y: integer);
procedure ShowPNG(maxw, maxh: integer);
procedure LoadPNG(f: string);
procedure SavePNG(f: string);

var
  PNG: TPNGImage = nil;
  pngarray, alpha: PByteArray;
  scanwidth, alphawidth: integer;
  pic: TImage;

implementation

{ Create a blank 32-bit PNG. }

procedure InitPNG(w, h: integer);
begin
  if Assigned(PNG) then PNG.Free; // Clear previous PNG.
  PNG := TPNGImage.CreateBlank(COLOR_RGBALPHA,8,w,h); // Create 32-bit PNG.
  pngarray := PNG.ScanLine[0]; // Get pointer for pixels.
  scanwidth := Longint(PNG.ScanLine[1])-Longint(pngarray); // Get scanline width (+ padding).
  alpha := PNG.AlphaScanline[0]; // Pointer for alpha channel.
  alphawidth := Longint(PNG.AlphaScanline[1])-Longint(alpha); // Size of alpha for one line.
end;

{ Assign PNG to TImage object. }

procedure AssignPNG(img: TImage);
begin
  pic := img;
end;

{ Draw a single pixel on the PNG. }

procedure PixelPNG(r, g, b, a: byte; x, y: integer);
var p: integer;
begin
  p := (y*scanwidth)+(x*3); // Find address for pixel.
  if (PNG.Header.ColorType = COLOR_RGBALPHA) and (x < PNG.Width) and (y < PNG.Height) then // Check pixel is on the image.
    begin
    pngarray[p] := b; // Write pixel data.
    pngarray[p+1] := g;
    pngarray[p+2] := r;
    alpha[(y*alphawidth)+x] := a; // Write alpha value.
    end;
end;

{ Change position of PNG/TImage on screen. }

procedure MovePNG(x, y: integer);
begin
  pic.Left := x;
  pic.Top := y;
end;

{ Display the PNG on screen. }

procedure ShowPNG(maxw, maxh: integer);
var displayw, displayh: integer;
begin
  pic.Picture := nil; // Reset image.
  if (PNG.Width > maxw) or (PNG.Height > maxh) then
    begin
    if PNG.Width/PNG.Height > maxw/maxh then
      begin
      displayw := maxw;
      displayh := Round(PNG.Height/(PNG.Width/maxw));
      end
    else
      begin
      displayw := Round(PNG.Width/(PNG.Height/maxh));
      displayh := maxh;
      end;
    end
  else
    begin
    displayw := PNG.Width;
    displayh := PNG.Height
    end;
  pic.Width := displayw;
  pic.Height := displayh;
  pic.Canvas.StretchDraw(Rect(0,0,displayw,displayh),PNG);
end;

{ Load PNG from file. }

procedure LoadPNG(f: string);
begin
  if Assigned(PNG) then PNG.Free; // Clear previous PNG.
  if FileExists(f) then
    begin
    PNG := TPNGImage.Create; // Create empty PNG.
    PNG.LoadFromFile(f); // Load file.
    end
  else ShowMessage('File not found.');
end;

{ Save PNG to file. }

procedure SavePNG(f: string);
begin
  if Assigned(PNG) then PNG.SaveToFile(f); // Save PNG to file.
end;

end.