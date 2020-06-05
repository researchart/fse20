function {:existential true} b0(in:int,inlen:int,bufferlen:int,buf:int,buflim:int,con:int): bool;


procedure main()
{

	var in,inlen,bufferlen,buf,buflim,con: int;

	havoc inlen;
	havoc bufferlen;
	
	if(bufferlen >1)
	{
	}
	else 
	{
		goto END;
	}
	if(inlen > 0)
	{
	}
	else 
	{
		goto END;
	}
	if(bufferlen < inlen)
	{
	}
	else
	{
		goto END;
	}
	
	
	buf := 0;
	in := 0;
	buflim := bufferlen - 2;
	
	
	havoc con;
	
	while (con!=0)
	invariant b0(in,inlen,bufferlen,buf,buflim,con);
	{
		if (buf == buflim)
		{
			break;
		}
		assert(0<=buf);
		assert(buf<bufferlen); 
		buf := buf + 1;
		out:
		in := in + 1;
		assert(0<=in);
		assert(in<inlen);
		havoc con;
	}
	assert(0<=buf);
	assert(buf<bufferlen);
	buf := buf + 1;


	assert(0<=buf);
	assert(buf<bufferlen);

	END:
	exit:
}

