function {:existential true} b0(n:int, x:int, nn:int): bool;

procedure main()
{
  var n,x,r: int;
  n := 0;
  x := 0;
  havoc r;

  while (r != 0)
  invariant b0(n,x,n*n);
  {
    n := n + 1;
    x := x + 2*n - 1;
 
    havoc r;
  }

  assert (x == n*n);

}

