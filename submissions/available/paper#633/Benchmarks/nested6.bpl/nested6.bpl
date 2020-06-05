function {:existential true} b0(i:int,j:int,k:int,n:int): bool;
function {:existential true} b1(i:int,j:int,k:int,n:int,iM2:int): bool;
function {:existential true} b2(i:int,j:int,k:int,n:int,iM2:int): bool;

procedure main()
{

	var i,j,k,n: int;
	havoc k;
	havoc n;
	if (!(n < 1000000)) 
	{
		goto exit;
	}
    if (k == n) {
    }
    else{
    	goto END;
    }

	while (i < n)
	invariant b0(i,j,k,n);
	{
		j := 2 * i;
		while(j < n)
		invariant b1(i,j,k,n,2*i);
		{
            if(*){
                k := j;
                while(k<n)
                invariant b2(i,j,k,n,2*i);
                {
                    assert(k >= 2*i);
                    k := k + 1;
                }
            }
            else {
                assert( k >= n );
                assert( k <= n );
            }
			j := j + 1;
		}
		i := i + 1;
	}
	END:
	exit:
}

