function {:existential true} b0(x:int,m:int,n:int,con:int): bool;

procedure main()
{

	var x,m,n,con: int;
	x := 0;

	m := 0;

	havoc n;
	
	while(x<n)
	invariant b0(x,m,n,con);
	{
		havoc con;
		if(con!=0){
			m := x;
		}
		x := x+1;
	}
	assert(m >= 0 || n <= 0);
	assert(m < n || n <= 0);
}

