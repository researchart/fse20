function {:existential true} b0(n:int, m:int, x: int, y: int): bool;


procedure main()
{
  var n, m, x, y: int;

  havoc n;
  havoc m;
  x := 0;
  y := m;
  if (n < 0)
  {
    return;
  }
  if (m < 0)
  {
    return;
  }
  if (m > n - 1)
  {
    return;
  }
  while (x <= n-1)
  invariant b0(n,m,x,y);
  {
    x := x + 1;
    if (x >= m+1)
    {
      y := y +1;
    }
    else if (x > m)
    {
      return;
    }
  }
  if (x < n)
  {
    return;
  }
  if (y >= n+1)
  {
    assert false;
  }
}

