function {:existential true} b0(a:int,b:int,res:int,cnt:int,aPLUSb:int,resPLUScnt:int): bool;

procedure main()
{

	var a,b,res,cnt: int;
	havoc a;
	havoc b;
	
	if (!(a <= 1000000)) 
	{
		goto exit;
	} 
    if (!(0 <= b && b <= 1000000)) 
    {
    	goto exit;
    }
	res := a;
	cnt := b;
	while(cnt>0)	
	invariant b0(a,b,res,cnt,a+b,res+cnt);
	{
		cnt := cnt - 1;
		res := res + 1;
	}
	assert(res == a + b);
	exit:
}

