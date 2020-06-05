function {:existential true} b0(i:int,j:int,k:int,n:int,l:int,m:int): bool;
function {:existential true} b1(i:int,j:int,k:int,n:int,l:int,m:int): bool;
function {:existential true} b2(i:int,j:int,k:int,n:int,l:int,m:int): bool;

procedure main()
{

	var i,j,k,n,l,m: int;
	havoc n;
	havoc m;
	havoc l;
	if (!(-1000000 < n && n < 1000000)) 
	{
		goto exit;
	}
    if (!(-1000000 < m && m < 1000000)) 
    {
    	goto exit;
    }
    if (!(-1000000 < l && l < 1000000)) 
    {
    	goto exit;
    }

	if( 3*n<=m+l) 
	{
    } 
	else 
	{
        goto END;
    }

	i := 0;
	while (i < n)
	invariant b0(i,j,k,n,l,m);
	{
		j := 2 * i;
		while(j<3*i)
		invariant b1(i,j,k,n,l,m);
		{
			k := i;
			while(k< j)
			invariant b2(i,j,k,n,l,m);
			{
				assert( k-i <= 2*n );
				k := k + 1;
			}
			j := j + 1;
		}
		i := i + 1;
	}
	END:
	exit:
}

