function {:existential true} b0(i:int): bool;

procedure main()
{

	var i: int;

	i := 0;	
	while (i < 1000000)
	invariant b0(i);
	{
		i := i + 2;
	}
	assert(i == 1000000);
}

