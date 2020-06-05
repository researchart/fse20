function {:existential true} b0(n:int, tap:int, s:int, t: int, apap: int): bool;

procedure main()
{
  var n, a, s, t: int;
 
  assume (n >= 0);
 
  a := 0;
  s := 1;
  t := 1;

  while (s <= n)
  invariant b0(n,2*a,s,t,(a+1)*(a+1));
  {
    a := a + 1;
    t := t + 2;
    s := s + t;
  }
  assert (s == ((a+1)*(a+1)));
}

