function {:existential true} b1(x: int, y: int) : bool;

var x: int;
var y: int;

procedure main()
modifies x, y;
{
  //assume x == 1;

  assume (1 <= x && x <= 2);
 
  while (true) 
  invariant b1(x, y);
  {
    x := x + 1;
    y := x;
    x := x + y;
  } 
  assert (x >= 1); 
}



