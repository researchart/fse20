function {:existential true} b0(i:int,j:int): bool;

procedure main()
{

    var i,j: int;
	i := 1;	
	j := 10;	
	while (j >= i) 
    invariant b0(i,j);
    {
        i := i + 2;
        j := -1 + j;
    }
    assert(j == 6);
}
