function {:existential true} b0(i:int,j:int,k:int): bool;

procedure main()
{
	var i,j,k: int;
	i := 1;
	j := 1;
	
	havoc k;

	if (!(0 <= k && k <= 1)) {goto exit;}
	while(i<1000000)
	invariant b0(i,j,k);
	{
	i := i + 1;
	j := j + k;
	k := k - 1;
	assert(1 <= i + k && i + k <= 2 && i >= 1);
	}
	
	exit:
}

