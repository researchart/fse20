function {:existential true} b0(n:int,l:int,r:int,i:int,j:int): bool;
function {:existential true} b1(n:int,l:int,r:int,i:int,j:int): bool;

procedure main()
{
	var n,l,r,i,j: int;
	var con: int;
	havoc n;
	if (!(1 <= n &&n <= 1000000)) 
	{
		goto exit;
	}
	
	l := n div 2 + 1;
	r := n;
	
	if(l > 1) 
	{
		l:=l-1;
	} 
	else 
	{
		r:=r-1;
	}
	
	while(r > 1)
	invariant b0(n,l,r,i,j);
	{
		i := l;
		j := 2*l;
		while(j <= r)
		invariant b1(n,l,r,i,j);
		{
			if( j < r) 
			{
				assert(1 <= j);
				assert(j <= n);
				assert(1 <= j+1);
				assert(j+1 <= n);
				
				havoc con;
				if(con!=0){
					j := j + 1;
				}
			}
			assert(1 <= j);
			assert(j <= n);
			havoc con;
			if(con!=0)
			{
				break;
			}
			assert(1 <= i);
			assert(i <= n);
			assert(1 <= j);
			assert(j <= n);
			i := j;
			j := 2*j;
		}
		if(l > 1) {
			assert(1 <= l);
			assert(l <= n);
			l := l - 1;
		} 
		else 
		{
			assert(1 <= r);
			assert(r <= n);
			r := r - 1;
		}	
	}
	exit:
}

