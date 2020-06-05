function {:existential true} b0(mid:int,lo:int,hi:int,midM2:int,hiSlo:int): bool;

procedure main()
{
  var lo: int;
  var hi: int;
  var mid: int;
  
  lo := 0;
  havoc mid;
  assume mid>0 && mid <= 10000;
  hi := 2*mid;

  while (mid > 0)
  invariant b0(mid,lo,hi,mid*2,hi-lo);
  {
    lo := lo + 1;
    hi := hi - 1;
    mid := mid -1;
  }
  assert(hi == lo);
}
