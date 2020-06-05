function {:existential true} b0(k:int, w:int, z:int): bool;



procedure main()
{
  var k, w, z: int;
  var b: bool;
  k := 1;
  w := 1;
  havoc b;

  while(b)
  invariant b0(k, w, z);
  {
    havoc z;
    if (z > 5)
    {
      w := w + 1;
    }
    k := k + w;
  }
  if (k <= 0)
  {
    assert false;
  }

}

