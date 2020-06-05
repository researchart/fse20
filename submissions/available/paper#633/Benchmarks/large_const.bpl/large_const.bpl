function {:existential true} b0(c1:int,c2:int,c3:int,n:int,v:int,i:int,k:int,j:int,iMINUSn:int): bool;
function {:existential true} b1(n:int,k:int,j:int,jPLUSk:int,jMINUSn:int): bool;

procedure main()
{

	var c1,c2,c3: int;
	var n,v: int;
	var i,k,j: int;
	c1 := 4000;
	c2 := 2000;
	c3 := 10000;

	
	havoc n;
	if (!(0 <= n && n < 10)) 
	{
		goto exit;
	}
	k := 0;
	i := 0;

	while( i < n )
	invariant b0(c1,c2,c3,n,v,i,k,j,i-n);
	{
		i := i + 1;
		havoc v;
		if (!(0 <= v && n < 2)) 
		{
			goto exit;
		}
		if( v == 0 )
		{
			k := k + c1;
		}
		else if( v == 1 )
		{
			k := k + c2;
		}
		else
		{
			k := k + c3;
		}
	}
	
	j := 0;
	
	while( j < n )
	invariant b1(n,k,j,j+k,j-n);
	{
		assert(k > 0);
		j := j + 1;
		k := k - 1;
	}
	exit:
}

