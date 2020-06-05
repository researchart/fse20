function {:existential true} b0(val:int, m:int, i:int, size: int): bool;



procedure main()
{
  var size: int;
  var i, m: int;
  var a: [int]int;

  havoc size;
  assume (size >= 10);
  i := 0;
  m := a[0];
  while (i < size)
  invariant b0(a[4], m, i, size);
  {
    if (a[i] <= m)
    {
      m := a[i];
    }
    i := i + 1;
  }
  assert (m <= a[4]);
}

