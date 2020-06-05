function {:existential true} b0(n:int,k:int,i:int,iMINUSk:int): bool;
function {:existential true} b1(n:int,k:int,i:int,j:int,jPLUSk:int): bool;

procedure main()
{
	var n: int;
	var k: int;
	var i: int;
	var j: int;

	k :=0;
	i :=0;
	
	havoc n;
	while( i < n )
	invariant b0(n,k,i,i-k);
	{
      i := i + 1;
      k := k + 1;
	}
	
	j := 0;
	while(j<n)
	invariant b1(n,k,i,j,j+k);
	{
		assert(k > 0);
		j := j + 1;
		k := k - 1;
	}
}

