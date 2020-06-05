function {:existential true} b0(i:int, j:int, n:int): bool;



procedure main()
{
  var n, i, j: int;

  havoc n;
  i := 0;
  j := 0;
  if (! (n >= 0))
  {
    return;
  }

  while(i < n)
  invariant b0(i, j, n);
  {
    i := i + 1;
    j := j +1;
  }
  if (j >= n + 1)
  {
    assert false;
  }

}

