function {:existential true} b0(i:int,j:int,len:int,limit:int): bool;
function {:existential true} b1(i:int,j:int,len:int,limit:int): bool;

procedure main()
{
	var len,i,j,bufsize,limit: int;
	havoc bufsize;
	if (bufsize < 0) 
	{
		goto exit;
	}
    havoc len;
    limit := bufsize - 4;

    i := 0;
    while(i < len)
    invariant b0(i,j,len,limit);
    {
        j := 0;
        while(i < len && j < limit)
        invariant b1(i,j,len,limit);
        {
            if(i + 1 < len) {
                assert(i+1<len);
                assert(0<=i);
                if(*){
                    goto ELSE;
                }
                assert(i<len);
                assert(0<=i);
                assert(j<bufsize);
                assert(0<=j);
                j := j + 1;
                i := i + 1;
                assert(i<len);
                assert(0<=i);
                assert(j<bufsize);
                assert(0<=j);
                j := j + 1;
                i := i + 1;
                assert(j<bufsize);
                assert(0<=j);
                j := j + 1;
            }
            else{
ELSE:
                assert(i<len);
                assert(0<=i);
                assert(j<bufsize);
                assert(0<=j);
                j := j + 1;
                i := i + 1;
            }
        }
    }
exit:
}

