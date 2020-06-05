function {:existential true} b0(i:int,n:int,k:int,iPLUS2k:int,nMUTI2:int): bool;
function {:existential true} b1(i:int,n:int,k:int,j:int,kPLUSj:int,nDIV2:int,jMINUSnd2:int): bool;

procedure main()
{
	var n: int;
	var i: int;
	var k: int;

	var j,nd2: int;
	//havoc n;
	assume(n <= 1000000);
	//if (!(n <= 1000000)) 
	//{
	//	goto exit;
	//}
	k := n;
	i := 0;
	
	while( i < n )
	invariant b0(i,n,k,i+k+k,n+n);
	{
		k := k - 1;
		i := i + 2;
	}
	
	
	j := 0;
 	nd2 := n div 2;
	while( j< nd2 ) 
	invariant b1(i,n,k,j,k+j,nd2,j-nd2);
	{
		assert(k > 0);
		k := k - 1;
		j := j + 1;
	}
	//exit:
}

