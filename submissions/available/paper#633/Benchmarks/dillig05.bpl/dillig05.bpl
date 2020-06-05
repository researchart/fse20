function {:existential true} b0(x:int, y:int, i:int, j: int, flag: int): bool;



procedure main()
{
  var flag, x, y, i, j: int;
  var b: bool;
  havoc flag;
  havoc b;

  x := 0;
  y := 0;
  j := 0;
  i := 0;
  while (b)
  invariant b0(x, y, i, j, flag);
  {
    x := x + 1;
    y := y + 1;
    i := i + x;
    j := j + y;
    if (flag != 0)
    {
      j := j + 1;
    }
    j := j;
    havoc b;
  }
  if (j <= i-1)
  {
    assert false;
  }

}

