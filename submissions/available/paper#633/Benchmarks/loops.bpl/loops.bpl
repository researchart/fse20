function {:existential true} b0(x: int, s:int, y: int): bool;
function {:existential true} b1(x: int, s:int, y: int): bool;



procedure main()
{
  var x, s, y: int;

  assume (x >= 0);
  s := 0;
  while (s < x)
  invariant b0(x, s, y);
  {
    s := s + 1;
  }

  y := 0;
  while (y < s)
  invariant b1(x, s, y);
  {
    y := y + 1;
  }
  assert (y == x);

}

