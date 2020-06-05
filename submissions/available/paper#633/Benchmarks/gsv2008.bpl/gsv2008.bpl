function {:existential true} b0(x:int,y:int): bool;

procedure main()
{

	var x,y: int;
	x := -50;
	havoc y;
	if (!(-1000 < y && y < 1000000)) 
	{
		goto exit;
	}
	while(x<0)
	invariant b0(x,y);
	{
		x := x+y;
		y := y+1;
	}
	assert(y>0);
	exit:
}

