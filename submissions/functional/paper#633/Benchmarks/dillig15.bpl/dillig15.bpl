function {:existential true} b0(k:int, j:int, n: int, s: int): bool;



procedure main()
{
  var n, i, k, j: int;

  havoc n;
  if (n < 1)
  {
    return;
  }
  if (k < n)
  {
    return;
  }
  j := 0;
  while (j <= n - 1)
  invariant b0(k,j,n,k+j);
  {
    j := j + 1;
    k := k - 1;
  }
  if (j < n)
  {
    return;
  }
  if (k <= -1)
  {
    assert false;
  }

}

