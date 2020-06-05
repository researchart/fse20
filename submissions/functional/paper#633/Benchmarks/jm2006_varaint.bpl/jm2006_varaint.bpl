function {:existential true} b0(i:int,j:int,x:int,y:int,z:int,xMINUSyMINUSz:int): bool;

procedure main()
{

	var i,j: int;
	var x,y,z: int;
	havoc i;
	havoc j;
	if (!(i >= 0 && i <= 1000000)) 
	{
		goto exit;
    }
	if (!(j >= 0)) 
	{
		goto exit;
	}


	x := i;
	y := j;
	z := 0;
	while(x != 0)
	invariant b0(i,j,x,y,z,x-y-z);
	{
		x := x - 1;
		y := y - 2;
		z := z + 1;
	}
	if(i==j)
	{
		assert(y == -z);
	}
	exit:
}

