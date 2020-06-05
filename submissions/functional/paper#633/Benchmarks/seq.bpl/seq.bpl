function {:existential true} b0(n0:int,n1:int,i0:int,k:int,i0MINUSk:int,i0MINUSn0:int): bool;
function {:existential true} b1(n0:int,n1:int,i0:int,k:int,i1:int,i1MINUSk:int,i1MINUSn1:int): bool;
function {:existential true} b2(n0:int,n1:int,i0:int,k:int,i1:int,j1:int,j1PLUSk:int,j1MINUSn0MINUSn1:int): bool;

procedure main()
{

	var n0,n1,i0,k: int;
	var i1: int;
	var j1: int;
	i0 := 0;
	k := 0;
	havoc n0;
	havoc n1;
	if (!(-100000 <= n0 && n0 < 100000)) 
	{
		goto exit;
	}
	if (!(-100000 <= n1 && n1 < 100000)) 
	{
		goto exit;
	}

	while( i0 < n0 )
	invariant b0(n0,n1,i0,k,i0-k,i0-n0);
	{
		i0 := i0 + 1;
		k := k + 1;
	}

	
	i1 := 0;
	while( i1 < n1 ) 
	invariant b1(n0,n1,i0,k,i1,i1-k,i1-n1);
	{
		i1 := i1 + 1;
		k := k + 1;
	}
	
	
	j1 := 0;
	while( j1 < n0 + n1 )
	invariant b2(n0,n1,i0,k,i1,j1,j1+k,j1-n0-n1);	
	{
		assert(k > 0);
		j1 := j1 + 1;
		k := k - 1;
	}

	exit:
}

