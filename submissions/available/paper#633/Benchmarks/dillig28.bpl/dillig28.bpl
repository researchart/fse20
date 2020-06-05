function {:existential true} b0(x:int, y:int, n:int): bool;
function {:existential true} b1(x:int, y:int, n: int): bool;




procedure main()
{
  var x, y, n: int;


  var b: bool;

  x := 0;
  y := 0;
  n := 0;

  havoc b;

  while(b)
  invariant b0(x, y, n);
  {
    x := x + 1;
    y := y + 1;
    havoc b;
  }

  while (x <= n - 1 || x >= n + 1)
  invariant b1(x, y, n);
  {
    x := x - 1;
    y := y - 1;
  }
  if (x != n)
  {
    return;
  }
  if (y != n)
  {
    assert false;
  }
}

