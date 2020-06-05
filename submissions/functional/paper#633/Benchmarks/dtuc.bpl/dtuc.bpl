function {:existential true} b0(pc:int, i: int, j:int, k: int, n: int) : bool;


procedure main() 
{
  var n: int;
  var k: int;
  var i: int;
  var j: int;
  var pc: int;

  pc := 0;
  k := 0;
  i := 0;

  while (pc <= 2)
  invariant b0(pc,i,j,k,n); 
  {
    if (pc == 0 && i < n)
    {
	i := i + 1;
	k := k + 1;
    }
    else if (pc == 0)
    {
	j := n;
        pc := 1;
    }
    else if (pc == 1 && j > 0)
    {
	assert k > 0;
	j := j - 1;
	k := k - 1;
    }
    else if (pc == 1)
    {
	pc := 2;
    }
  } 
}
