program TestFillPoly;
uses
   BGL,
   GraphABC,
   System.Diagnostics;
var
   polygon1, polygon2, polygon3, a: tPoly;
   i, n, n1,n2, n3, t1, t2: integer;
   polygon1_abc, polygon2_abc, polygon3_abc,b : array of Point;
begin
    
    SetConsoleIO;
    //многоугольник невыпуклый без самопересечений
    n1:= 15;
    SetLength(polygon1, n1);
    SetLength(polygon1_abc, n1);
    polygon1_abc[0] := (225, 225); polygon1_abc[1] := (225, 325);
    polygon1_abc[2] := (250, 350); polygon1_abc[3] := (350, 350);
    polygon1_abc[4] := (375, 325); polygon1_abc[5] := (375, 225);
    polygon1_abc[6] := (450, 150); polygon1_abc[7] := (375, 175);
    polygon1_abc[8] := (375, 75); polygon1_abc[9] := (325, 175);
    polygon1_abc[10] := (300, 50); polygon1_abc[11] := (275, 175);
    polygon1_abc[12] := (225, 75); polygon1_abc[13] := (225, 175);
    polygon1_abc[14] := (150, 150);
    
    for i := 0 to n1-1 do begin
    polygon1[i].x := polygon1_abc[i].x;
    polygon1[i].y := polygon1_abc[i].y;
  end;
   
  //многоугольник невыпуклый с самопересечениями
  n2 := 12;
  SetLength(polygon2, n2);
  SetLength(polygon2_abc, n2);
  polygon2_abc[0] := (100, 100); polygon2_abc[1] := (300, 100);
  polygon2_abc[2] := (300, 200); polygon2_abc[3] := (200, 200);
  polygon2_abc[4] := (200, 150); polygon2_abc[5] := (250, 150);
  polygon2_abc[6] := (250, 250); polygon2_abc[7] := (150, 250);
  polygon2_abc[8] := (150, 50); polygon2_abc[9] := (350, 50);
  polygon2_abc[10] := (350, 300); polygon2_abc[11] := (100, 300);
  
  for i := 0 to n2-1 do begin
    polygon2[i].x := polygon2_abc[i].x;
    polygon2[i].y := polygon2_abc[i].y;
  end;

  //многоугольник невыпуклый с самопересечениями
  n3 := 5;
  SetLength(polygon3, n3);
  SetLength(polygon3_abc, n3);
  polygon3_abc[0] := (100,100); polygon3_abc[1] :=(300,100);
  polygon3_abc[2] :=(200,300); polygon3_abc[3] :=(100,300);
  polygon3_abc[4] :=(200,100);
  
  for i := 0 to n3-1 do begin
    polygon3[i].x := polygon3_abc[i].x;
    polygon3[i].y := polygon3_abc[i].y;
  end;
   
 //тестирование многоугольника без самопересечений
//  n := n1;
//  a := polygon1;
//  b := polygon1_abc;
 
//тестирование многоугольника с самопересечениями
  n := n2;
  a := polygon2;
  b := polygon2_abc;

  //тестирование многоугольника с самопересечениями
//  n := n3;
//  a := polygon3;
//  b := polygon3_abc;
  t1 := milliseconds;
  for i := 1 to 100 do begin
     //1 вариант - YX алгоритм
    SetColor(Green);
    ClearDevice;
    FillPoly(n, a); 
    Draw;
      
    //2 вариант - алгоритм построчного сканирования со списком активных ребер
//   SetColor(Magenta);
//   ClearDevice;
//   FillPolyActiveEdges(a);
//   Draw;
    
    //3 вариант - процедура FillPolygon из GraphABC
//    ClearDevice;
//    SetPenColor(clBlue);
//    SetBrushColor(clBlue);
//    FillPolygon(b);

 end;
    t2 := milliseconds; 
    Writeln((t2-t1)/100);

end.