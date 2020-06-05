function {:existential true} b0(i:int,k:int): bool;

procedure main()
{

	var i: int;
	var k: int;
	havoc k;
	if (!(0 <= k && k <= 10)) 
	{ 
		goto exit;
	}
	i := 0;	

	
	while ( i< 1000000*k )
	invariant b0(i,k);
	{
		i := i + k;
	}
	assert(i == 1000000*k);
	exit:
}

