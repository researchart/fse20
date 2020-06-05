function {:existential true} b0(x: int, y: int, n: int, sum: int): bool;

procedure main()
{
  var n, x, y: int;
  assume n >= 0;
  x := n;
  y := 0;

  while (x > 0)
  invariant b0(x, y, n, x + y);
  {
    x := x - 1;
    y := y + 1;
  }
  assert(y == n);
}

