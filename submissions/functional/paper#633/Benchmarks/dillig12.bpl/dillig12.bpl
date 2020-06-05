function {:existential true} b0(t:int, s:int, a:int, b: int, ts: int): bool;
function {:existential true} b1(x: int, y: int): bool;




procedure main()
{
  var t, s, a, b, x, y, flag: int;


  var bo: bool;

  havoc flag;
  t := 0;
  s := 0;
  a := 0;
  b := 0;

  havoc bo;

  while(bo)
  invariant b0(t, s, a, b, 2*s);
  {
    a := a + 1;
    b := b + 1;
    s := s + a;
    t := t + b;
    if (flag != 0)
    {
      t := t + a;
    }
    havoc bo;
  }
  x := 1;
  if (flag != 0)
  {
    x := t - 2*s + 2;
  }
  y := 0;
  while (y <= x)
  invariant b1(x, y);
  {
    havoc bo;
    if (bo)
    {
      y := y + 1;
    }
    else
    {
      y := y + 2;
    }
  }
  if (y >= 5)
  {
    assert false;
  }
}

