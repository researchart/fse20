function {:existential true} b0(i: int,j: int,x: int,y: int): bool;

procedure main()
{

	var i,j: int;
	var x,y: int;
	havoc i;
	havoc j;
	if (!(i >= 0 && j >= 0)) 
	{ 
		goto exit;
	}
	
	x := i;
	y := j;
	while(x != 0)
	invariant b0(i,j,x,y);
	{
		x := x - 1;
		y := y - 1;
	}
	if(i==j)
	{
		assert(y == 0);
	}
	exit:
}

