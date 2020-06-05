function {:existential true} b0(n:int,m:int,i:int,j:int,k:int,iMINUSn:int): bool;
function {:existential true} b1(n:int,m:int,i:int,j:int,k:int,iMULTIm:int,jMINUSm:int): bool;


procedure main()
{

	var n,m,k: int;
	var i,j: int;
	
	havoc n;
	havoc m;
	k := 0;
	
	
	i := 0;
	if (!(2 <= n && n <= 10000)) 
	{
		goto exit;
	}
    if (!(2 <= m && m <= 10000)) 
    {
    	goto exit;
    }
	
	while (i < n)
	invariant b0(n,m,i,j,k,i-n);
	{
		j := 0;
		while(j < m)
		invariant b1(n,m,i,j,k,i*m,j-m);
		{
			k := k + 1;
			j := j + 1;
		}
	
		i := i + 1;
	}
	
	
	assert(k>=4);
	exit:
}

