function {:existential true} b0(offset:int,length:int,nlen:int,i:int,j:int): bool;
function {:existential true} b1(offset:int,length:int,nlen:int,i:int,j:int): bool;

procedure main()
{
	var offset, length, nlen: int;
	var i, j: int;
	havoc nlen;
	
	
	i := 0;
	while (i<nlen)
	invariant b0(offset,length,nlen,i,j);
	{
		j := 0;
		while (j<8)
		invariant b1(offset,length,nlen,i,j);
		{
			assert(0 <= nlen-1-i);
			assert(nlen-1-i < nlen);
			j := j + 1;
		}
		i := i + 1;
	}
}

