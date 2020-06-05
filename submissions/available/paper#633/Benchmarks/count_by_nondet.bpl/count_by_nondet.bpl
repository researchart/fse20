function {:existential true} b0(i:int,k:int): bool;

procedure main()
{

	var i: int;
	var k: int;
	var j: int;
	
	i := 0;
	k := 0;
	
	while ( i<=1000000 )
	invariant b0(i,k);
	{
		
		havoc j;
		if (!(1 <= j && j < 1000000)) { goto exit;}
		i := i + j;
		k := k+1;
	}
	assert(k <= 1000000);
	exit:
}

