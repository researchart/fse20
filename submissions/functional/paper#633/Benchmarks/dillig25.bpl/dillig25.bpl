function {:existential true} b0(i:int, j:int, x: int, y: int): bool;
function {:existential true} b1(i:int, j:int, x: int, y: int): bool;

procedure main()
{
  var j,i,x,y: int;
  var b: bool;

  x := 0;
  y := 0;
  i := 0;
  j := 0;

  havoc b;
  while (b)
  invariant b0(i,j,x,y);
  {
    havoc b;
    while (b)
    invariant b1(i,j,x,y);
    {
      if (x == y)
      {
	i := i +1;
      }
      else
      {
	j := j + 1;
      }
      havoc b;
    }
    if (i >= j)
    {
      x := x + 1;
      y := y + 1;
    }    
    else
    {
      y := y +1;
    }
  }
  if (i <= j - 1)
  {
    assert false;
  }
}

