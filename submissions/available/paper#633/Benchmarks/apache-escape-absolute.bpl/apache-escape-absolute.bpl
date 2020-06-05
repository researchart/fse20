function {:existential true} b0(scheme:int,urilen:int,tokenlen:int,cp:int,c:int): bool;
function {:existential true} b1(scheme:int,urilen:int,tokenlen:int,cp:int,c:int): bool;


procedure main()
{
	var LARGE_INT,scheme,urilen,tokenlen,c,cp,con: int;
	LARGE_INT := 1000000;
		
	havoc urilen;
	havoc tokenlen;
	havoc scheme;	
	
    if (!(urilen <= LARGE_INT && urilen >= -LARGE_INT)) { 
    	goto exit;
    }
    if (!(tokenlen <= LARGE_INT && tokenlen >= -LARGE_INT)) {
    	goto exit;
    }
    if (!(scheme <= LARGE_INT && scheme >= -LARGE_INT)) {
    	goto exit;
    }
	
	
	if(urilen>0){
	}
	else {
		goto END;
    }
	
	if(tokenlen>0){
	}
	else {
		goto END;
    }
	
	if(scheme >= 0 ){
	}
	else {
		goto END;
    }
	
	if (scheme == 0 || (urilen-1 < scheme)) {
        goto END;
    }
	
	cp := scheme;
	
	assert(cp-1 < urilen);
	assert(0 <= cp-1);
	
	//var con: int;
	
	havoc con;
	
	if (con!=0)
	{
		assert(cp < urilen);
		assert(0 <= cp);
		while ( cp != urilen-1)
		invariant b0(scheme,urilen,tokenlen,cp,c);
		{
			havoc con;
			if (con!=0)
			{
				break;
			}
			assert(cp < urilen);
			assert(0 <= cp);
			cp := cp + 1;
		}
		assert(cp < urilen);
        assert( 0 <= cp );
		if (cp == urilen-1) 
		{
			goto END;
		}
		assert(cp+1 < urilen);
		assert( 0 <= cp+1 );
		if (cp+1 == urilen-1)
		{
			goto END;
		}
		cp := cp + 1;
		scheme := cp;
		
		havoc con;
		if (con!=0)
		{
			c := 0;
			assert(cp < urilen);
			assert(0<=cp);
			while ( cp != urilen-1 && c < tokenlen - 1)
			invariant b1(scheme,urilen,tokenlen,cp,c);
			{
				assert(cp < urilen);
				assert(0<=cp);
				havoc con;
				if(con!=0)
				{
					c:=c+1;
					assert(c < tokenlen);
					assert(0<=c);
					assert(cp < urilen);
					assert(0<=cp);
				}
				cp := cp+1;
				
			}
			goto END;
		}
	}
		
	END:
	exit:
}

