function {:existential true} b0(val:int, m:int, i:int, size: int): bool;



procedure main()
{
  var size: int;
  var i, m: int;
  var a: [int]int;

  havoc size;
  assume (size >= 10);
  i := 0;
  while (i < size)
  invariant b0(a[4], m, i, size);
  {
    havoc m;
    assume (m == 0 || m == 3);
    a[i] := m;
    i := i + 1;
  }
  assert (a[4] == 0 || a[4] == 3);
}

