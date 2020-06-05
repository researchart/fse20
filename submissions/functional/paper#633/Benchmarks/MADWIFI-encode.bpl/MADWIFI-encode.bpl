function {:existential true} b0(p:int,i:int,leader_len:int,bufsize_0:int,pMINUS2i:int,pMINUSbufsize_0:int): bool;

procedure main()
{

	var p,i,leader_len,bufsize,bufsize_0,ielen: int;

	havoc leader_len;
	havoc bufsize;
	havoc ielen;

	if (!(leader_len < 100000)) 
	{
		goto exit;
	}
	if (!(bufsize < 100000)) 
	{
		goto exit;
	}
	if (!(ielen < 100000)) 
	{
		goto exit;
	}

	if(leader_len >0)
	{
	}
	else 
	{
		goto END;
	}
	if(bufsize >0)
	{
	}
	else
	{
		goto END;
	}
	if(ielen >0)
	{
	}
	else
	{
		goto END;
	}
	
	if (bufsize < leader_len)
	{
		goto END;
	}
	
	p := 0;
	
	bufsize_0 := bufsize;
	bufsize := bufsize - leader_len;
	p := p + leader_len;
	
	if (bufsize < 2*ielen)
    {
		goto END;
	}
	
	i := 0;
	while( i < ielen && bufsize > 2 )
	invariant b0(p,i,leader_len,bufsize_0,p-2*i,p-bufsize_0);
	{
		assert(0<=p);
		assert(p+1<bufsize_0);
		p := p + 2;
		i := i + 1;
	}
	
	END:
	exit:
}

