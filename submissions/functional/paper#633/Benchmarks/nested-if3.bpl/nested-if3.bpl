function {:existential true} b0(i:int,k:int,n:int,l:int): bool;
function {:existential true} b1(i:int,k:int,n:int,l:int): bool;

procedure main()
{

	var i,k,n,l,con: int;
	
	havoc n;
	havoc l;
	if (!(l>0)) 
	{
		goto exit;
	}
	if (!(l < 1000000)) 
	{
		goto exit;
	}
	if (!(n < 1000000)) 
	{
		goto exit;
	}

	k := 0;
	while (k < n)
	invariant b0(i,k,n,l);
	{
		i := l;
		while(i < n)
		invariant b1(i,k,n,l);
		{
			assert(1<=i);
			i := i + 1;
		}
		havoc con;
		if(con!=0)
		{
			l := l + 1;
		}
		k := k + 1;
	}
	END:
	exit:
}

