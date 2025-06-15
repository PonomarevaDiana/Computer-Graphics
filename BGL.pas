unit BGL;

interface

uses Display;

const
   Black   = $000000;
   White   = $FFFFFF;
   Red     = $FF0000;
   Green   = $00FF00;
   Blue    = $0000FF;
   Yellow  = $FFFF00;
   Magenta = $FF00FF;
   Cyan    = $00FFFF;
   
   SizeX = Display.SizeX;
   SizeY = Display.SizeY;
   GetMaxX = Display.GetMaxX;
   GetMaxY = Display.GetMaxY;

type   
   tPoint = record
      x, y: integer;
   end;  
   
   tPoly = array of tPoint;
   
   tEdge = record
     ymin, ymax: integer;
     k, xmin: real;
   end;
   
   tEdgeArray = array of tEdge;

procedure SetColor(C: tPixel);
procedure SetBkColor(C: tPixel);
procedure ClearDevice;

procedure PutPixel(x, y: integer; C: tPixel);
function GetPixel(x, y: integer): tPixel;

procedure LineDDA(x1, y1, x2, y2: integer);
procedure LinePP(x1, y1, x2, y2: integer);
procedure Line(x1, y1, x2, y2: integer);
procedure HLine(x1, y, x2: integer);

procedure FloodFill(x, y: integer; bord: tPixel);
procedure FillPoly(n: integer; p: tPoly);

procedure FillPolyActiveEdges(poly: tPoly);

procedure Draw;

{==================================================================}

implementation

uses
   Floats;
   
const
   nmax = 100;   
   
type
   tXbuf = record
      m: integer;
      x: array[1..nmax] of integer;
   end;   
   
   tYXbuf = array[0..GetMaxY] of tXbuf;
   
var
   YXbuf: tYXbuf;   

var
   CC, BC: tPixel;

procedure SetColor(C: tPixel);
begin
   CC := C
end;

procedure SetBkColor(C: tPixel);
begin
   BC := C;
end;

procedure ClearDevice;
begin
   FillLB(0, SizeX*SizeY, BC);
end;

procedure PutPixel(x, y: integer; C: tPixel);
begin
   LB[SizeX*y + x] := C;
end;

procedure LineDDA(x1, y1, x2, y2: integer);
{ Алгоритм ЦДА }
var
   x, y, xend, yend: integer;
   k, yf, xf: float;
   dx, dy: integer;
begin
   dx := abs(x2-x1);
   dy := abs(y2-y1);
   if dx > dy then begin
      k := (y2-y1)/(x2-x1);
      if x1 < x2 then begin
         x := x1;
         xend := x2;
         yf := y1;
         end
      else begin
         x := x2;
         xend := x1;
         yf := y2;
      end;
      repeat
         PutPixel(x, round(yf), CC);
         x := x + 1;
         yf := yf + k;
      until x > xend;    
      end
   else if dy > 0 then begin
      k := (x2-x1)/(y2-y1);
      if y1 < y2 then begin
         y := y1;
         yend := y2;
         xf := x1;
         end
      else begin
         y := y2;
         yend := y1;
         xf := x2;
      end;   
      repeat
         PutPixel(round(xf), y, CC);
         y := y + 1;
         xf := xf + k;
      until y > yend;
      end
   else
      PutPixel(x1, y1, CC);   
end;

procedure LinePP(x1, y1, x2, y2: integer);
{ Алгоритм Брезенхема }
var
   x, y, xend, yend: integer;
   d: integer;
   dx, dy: integer;
   inc1, inc2: integer;
   s: integer;
begin
   dx := abs(x2-x1);
   dy := abs(y2-y1);
   if dx > dy then begin
      if x1 < x2 then begin 
         x := x1; xend := x2; y := y1; 
         if y2 >= y1 then s := 1 else s := -1;
         end
      else begin 
         x := x2; xend := x1; y := y2; 
         if y2 >= y1 then s := -1 else s := 1;
      end;
      inc1 := 2*(dy - dx);
      inc2 := 2*dy;
      d := 2*dy - dx;
      PutPixel(x, y, CC);
      while x < xend do begin
         x := x + 1;
         if d > 0 then begin
            d := d + inc1;
            y := y + s
            end
         else
            d := d + inc2;   
         PutPixel(x, y, CC);
      end    
      end
   else begin
      if y1 < y2 then begin 
         y := y1; yend := y2; x := x1; 
         if x2 >= x1 then s := 1 else s := -1;
         end
      else begin 
         y := y2; yend := y1; x := x2; 
         if x2 >= x1 then s := -1 else s := 1;
      end;
      inc1 := 2*(dx - dy);
      inc2 := 2*dx;
      d := 2*dx - dy;
      PutPixel(x, y, CC);
      while y < yend do begin
         y := y + 1;
         if d > 0 then begin
            d := d + inc1;
            x := x + s
            end
         else
            d := d + inc2;   
         PutPixel(x, y, CC);
      end    
   end
end;

procedure Line(x1, y1, x2, y2: integer);
{ Алгоритм Брезенхема с вычислением адреса }
var
   a, aend: integer; 
   d: integer;
   dx, dy: integer;
   inc1, inc2: integer;
   s: integer;
begin
   dx := abs(x2-x1);
   dy := abs(y2-y1);
   if dx > dy then begin
      if x1 < x2 then begin 
         a := SizeX*y1 + x1; aend := SizeX*y2 + x2;
         if y2 >= y1 then s := SizeX + 1 else s := -SizeX + 1;
         end
      else begin 
         a := SizeX*y2 + x2; aend := SizeX*y1 + x1;
         if y1 >= y2 then s := SizeX + 1 else s := -SizeX + 1;
      end;
      inc1 := 2*(dy - dx);
      inc2 := 2*dy;
      d := 2*dy - dx;
      LB[a] := CC;
      while a <> aend do begin
         if d > 0 then begin
            d := d + inc1;
            a := a + s
            end
         else begin
            d := d + inc2;   
            a := a + 1;
         end;   
         LB[a] := CC;
      end    
      end
   else begin
      if y1 < y2 then begin
         a := SizeX*y1 + x1; aend := SizeX*y2 + x2;
         if x1 <= x2 then s := SizeX + 1 else s := SizeX - 1
         end
      else begin
         a := SizeX*y2 + x2; aend := SizeX*y1 + x1;
         if x1 > x2 then s := SizeX + 1 else s := SizeX - 1
      end;
      inc1 := 2*(dx-dy);
      inc2 := 2*dx;
      d := 2*dx - dy;
      LB[a] := CC;
      while a <> aend do begin
         if d > 0 then begin
            a := a + s;
            d := d + inc1
            end
         else begin 
            d := d + inc2;
            a := a + SizeX;
         end;
         LB[a] := CC;
      end
   end
end;

procedure HLine(x1, y, x2: integer);
begin
   if x1 < x2 then
      FillLB(SizeX*y + x1, x2-x1+1, CC)
   else
      FillLB(SizeX*y + x2, x1-x2+1, CC)
end;


function GetPixel(x, y: integer): tPixel;
begin
   GetPixel := LB[y*SizeX + x];
end;

procedure FloodFillBad(x, y: integer; bord: tPixel);
begin
   if (GetPixel(x, y) <> bord) and (GetPixel(x, y) <> CC) then begin
      PutPixel(x, y, CC);
      FloodFill(x+1, y, bord);
      FloodFill(x-1, y, bord);
      FloodFill(x, y+1, bord);
      FloodFill(x, y-1, bord);
   end;
end;

procedure FloodFill(x, y: integer; bord: tPixel);
var
   xl, xr, yy: integer;
begin
   xl := x;
   while GetPixel(xl, y) <> bord do
      xl := xl - 1;
   xl := xl + 1;
   xr := x;
   while GetPixel(xr, y) <> bord do
      xr := xr + 1;
   xr := xr - 1;
   if xl < xr then
      HLine(xl, y, xr);
   yy := y - 1;
   repeat
      x := xr;
      while x >= xl do begin
         while (x >= xl) and ((GetPixel(x, yy) = bord) or (GetPixel(x, yy) = CC)) do
            x := x - 1;
         if x >= xl then
            FloodFill(x, yy, bord);
         x := x - 1;
      end;
      yy := yy + 2;
   until yy > y + 1;     
end;

procedure Edge(x1, y1, x2, y2: integer);
{ Алгоритм ЦДА }
var
   k, xf: float;
   y, yend: integer;
begin
   k := (x2-x1)/(y2-y1);
   if y1 < y2 then begin
      y := y1; yend := y2; xf := x1; end
   else begin
      y := y2; yend := y1; xf := x2;
   end;  
   while y < yend do begin
      y := y + 1;
      xf := xf + k;
      inc(YXbuf[y].m);
      YXbuf[y].x[YXbuf[y].m] := round(xf);
   end 
end;

procedure Sort(var a: tXbuf);
{ Сортировка вставками }
var
   i, j, y  : integer;
begin
   for i := 2 to a.m do begin
      y := a.x[i];
      j := i-1;
      while ( j>0 ) and ( y < a.x[j] ) do begin
         a.x[j+1] := a.x[j];
         j := j-1;
      end;
      a.x[j+1] := y;
   end;
end;

procedure FillPoly(n: integer; p: tPoly);
var
   y, ymin, ymax, i, i1, i2: integer;
begin
   ymin := p[0].y;
   ymax := ymin;
   for i := 0 to n-1 do
      if p[i].y < ymin then
         ymin := p[i].y
      else if p[i].y > ymax then
         ymax := p[i].y;
         
   for y := ymin to ymax do
      YXbuf[y].m := 0;
      
   i1 := n - 1;
   for i2 := 0 to n-1 do begin
      if p[i1].y <> p[i2].y then
         Edge(p[i1].x, p[i1].y, p[i2].x, p[i2].y);
      i1 := i2;
   end;   
 
   for y := ymin to ymax do begin
      Sort(YXbuf[y]);
      i := 1;
      while i < YXbuf[y].m do begin
         HLine(YXbuf[y].x[i], y, YXbuf[y].x[i+1]);
         i := i + 2;
      end;   
   end;    
end;

procedure SortEdges(var edges: tEdgeArray);
var
  i, j: integer;
  key: tEdge;
begin
  for i := 1 to High(edges) do
  begin
    key := edges[i];
    j := i - 1;
    while (j >= 0) and (edges[j].ymin > key.ymin) do
    begin
      edges[j + 1] := edges[j];
      j := j - 1;
    end;
    edges[j + 1] := key;
  end;
end;


procedure Delete(var a: tEdgeArray; index: integer; count: integer);
var
  i: integer;
begin
  if (index < 0) or (index >= Length(a)) then Exit; // Проверка выхода за границы
  
  // Сдвигаем элементы влево, начиная с Index + Count
  for i := index to High(a) - count do
    a[i] := a[i + count];
  
  // Уменьшаем длину массива
  SetLength(a, Length(a) - count);
end;


procedure SortAET(var AET: array of TEdge);
var
  i, j: integer;
  key: TEdge;
begin
  for i := 1 to High(AET) do
  begin
    key := AET[i];
    j := i - 1;
    
    // Сдвигаем элементы, которые больше key, вправо
    while (j >= 0) and (AET[j].xmin > key.xmin) do
    begin
      AET[j + 1] := AET[j];
      j := j - 1;
    end;
    
    AET[j + 1] := key;
  end;
end;

procedure FillPolyActiveEdges(poly: tPoly);
var
  c: integer;
  ET, AET: tEdgeArray;
  i, j, y: integer;
  Swap: Boolean;
  TempEdge: tEdge;
  xStart, xEnd: integer;
  eps: real;
  
begin

  SetLength(ET, 0);
  for i := 0 to High(poly) do begin
    // Берём текущую и следующую вершины (замыкаем многоугольник)
    j := (i + 1) mod Length(poly);
 
    // Пропускаем горизонтальные рёбра
    if poly[i].y = poly[j].y then begin
      HLine(poly[i].x, poly[i].y, poly[j].x);
    Continue;
    end;
    
    // Создаём запись ребра
    SetLength(ET, Length(ET) + 1);
    if poly[i].y < poly[j].y then
    begin
      ET[High(ET)].ymax := poly[j].y;
      ET[High(ET)].ymin := poly[i].y;
      
      ET[High(ET)].xmin := poly[i].x;
      ET[High(ET)].k := (poly[j].x - poly[i].x) / (poly[j].y - poly[i].y);
    end
    else
    begin
      ET[High(ET)].ymax := poly[i].y;
      ET[High(ET)].ymin := poly[j].y;
      ET[High(ET)].xmin := poly[j].x;
      ET[High(ET)].k := (poly[i].x - poly[j].x) / (poly[i].y - poly[j].y);
    end;
  end;
  
  // Сортировка ET по ymin/ymax
  SortEdges(ET);
  
  
  // AET
  SetLength(AET, 0);
  y:= ET[0].ymin;
  
  
  // Сканирования
  while (Length(AET) > 0) or (Length(ET) > 0) do
  begin
    // Добавляем в AET рёбра, у которых YMin = Y
    i := 0;
    while (i < Length(ET)) do
    begin
      if ET[i].ymin = y then
      begin
        SetLength(AET, Length(AET) + 1);
        AET[High(AET)] := ET[i];
        Delete(ET, i, 1);
      end
      else
        Inc(i);
    end;
  
    SortAET(AET);

    // Удаляем из AET рёбра, у которых YMax = Y
    i := 0;
  
    while i < Length(AET) do
    begin
      if (AET[i].ymax = y) then
        Delete(AET, i, 1)
      else
        Inc(i);
    end;
    
    // Закрашиваем пиксели между парами рёбер
    i := 0;
    while i < Length(AET) do
    begin
      xStart := Floor(AET[i].xmin);
      xEnd := Ceil(AET[i + 1].xmin);
      HLine(xStart, y,xEnd);
      Inc(i, 2);
    end;

    // Обновляем XMin для оставшихся рёбер
    for i := 0 to High(AET) do
      AET[i].xmin := AET[i].xmin + AET[i].k;
   Inc(y);  // Переход к следующей строке
  end;
  
end;

procedure Draw;
begin
   Display.Draw
end;

begin
   SetColor(Black);
   SetBkColor(White);
   ClearDevice;
end.

   