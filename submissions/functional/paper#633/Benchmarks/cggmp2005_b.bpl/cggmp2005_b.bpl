function {:existential true} b0(i:int,k:int): bool;
function {:existential true} b1(i:int,j:int,k:int): bool;
function {:existential true} b2(k:int): bool;

procedure main()
{
  var i: int;
  var j: int;
  var k: int;
  
  i := 0;
  k := 9;
  j := -100;

  while (i <= 100)
  invariant b0(i,k);
  {
      i := i + 1;
      while (j < 20)
      invariant b1(i,j,k);
      {
        j := i + j;
      }
      k := 4;
      while (k <= 3)
      invariant b2(k);
      {
        k := k + 1;
      }
  }
  assert(k==4);
}
