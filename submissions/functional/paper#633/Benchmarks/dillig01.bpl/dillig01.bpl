function {:existential true} b0(x:int, y:int, t1:int, t2: int): bool;



procedure main()
{
  var t1, t2, x, y: int;
  var b: bool;

  x := 1;
  y := 1;
  havoc b;

  while(b)
  invariant b0(x,y,t1,t2);
  {
    t1 := x;
    t2 := y;
    x := t1 + t2;
    y := t1 + t2;
  }
  if (y < 1)
  {
    assert false;
  }

}

