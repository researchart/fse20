function {:existential true} b0(i:int,n:int,a:int,b:int,aPLUSb:int,tmp:int,iMuti3:int,aPLUSbMinus3i:int): bool;

procedure main()
{

	var i,n,a,b: int;
	var tmp: int;
	i := 0;	
	a := 0;
	b := 0;
	havoc n;
	if (!(n >= 0 && n <= 100)) { 
		goto exit;
	}
	
	while (i < n)
	invariant b0(i,n,a,b,a+b,tmp,3*i,a+b-3*i);
	{
		havoc tmp;
		if(tmp!=0) {
			a := a+1;
			b := b+2;
			goto next;
		}
		if(tmp==0) {
			a := a+2;
			b := b+1;
			goto next;
		}		
		next:
		i := i+1;
	}
	assert(a + b == 3*n);
	exit:
}

