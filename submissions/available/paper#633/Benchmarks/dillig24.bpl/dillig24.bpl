function {:existential true} b0(k:int, j:int, i: int, n: int): bool;
function {:existential true} b1(k:int, j:int, i: int, n: int): bool;
function {:existential true} b2(k:int, j:int, i: int, n: int): bool;

procedure main()
{
  var j,i,k,n: int;

  i := 0;
  while (i < n)
  invariant b0(k,j,i,n);
  {
    j := i;
    while (j < n)
    invariant b1(k,j,i,n);
    {
      k := j;
      while (k < n)
      invariant b2(k,j,i,n);
      {
        if (k <= i - 1)
 	{
	  assert false;
	}
	k := k + 1;
      }
      j := j +1;
    }
    i := i + 1;
  }
}

