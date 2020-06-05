function {:existential true} b0(i:int,j:int,con:int): bool;
function {:existential true} b1(i:int,j:int,con:int): bool;

procedure main()
{
	var i,j: int;
	var con: int;
	L0:
	i := 0;
	L1:
	havoc con;
	while( con!=0 && i < 1000000)
	invariant b0(i,j,con);
	{
		i := i+1;
		havoc con;
	}
	if(i >= 100)
	{
		STUCK: 
		goto STUCK;
	}
	j := 0;
	L2:
	havoc con;
	while( con!=0 && i < 1000000 )
	invariant b1(i,j,con);
	{
		i := i+1;
		j := j+1;
		havoc con;
	}
	if(j >= 100) 
	{
		goto STUCK;
	}
	assert( i < 200 );
}

