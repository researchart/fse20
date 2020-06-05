function {:existential true} b0(k:int, j:int, n: int, i: int): bool;
function {:existential true} b1(k:int, j:int, n: int, i: int): bool;



procedure main()
{
  var n, i, k, j: int;

  havoc n;
  k := 1;
  i := 1;
  j := 0;
  while (i <= n -1)
  invariant b0(k,j,n,i);
  {
    j := 0;
    while (j <= i - 1)
    invariant b1(k,j,n,i);
    {
      k := k + i - j;
      j := j +1;
    }
    if (j < i)
    {
      return;
    }
    i := i + 1;
  }
  if(i < n)
  {
    return;
  }
  if (k <= n -1)
  {
    assert false;
  }
}

