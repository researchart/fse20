function {:existential true} b0(i:int,n:int,k:int,imod2:int,nMULT2MINUSi:int): bool;

procedure main()
{

	var i: int;
	var n: int;
	var k: int;
	var imod2: int;
	i :=0;
	imod2 := i mod 2;
	n :=0;
	
	havoc k;
	if(!(k<=1000000 && k>=-1000000)) 
	{
		goto exit;
	}
	while ( i<2*k )
	invariant b0(i,n,k,imod2,n*2-i);
	{
		if(i mod 2 == 0){
			n := n + 1;
		}
		i := i + 1;
		imod2 := i mod 2;
	}
	assert(k < 0 || n == k);
	exit:
}

