function {:existential true} b0(x:int,y:int): bool;

procedure main()
{
	var x,y: int;
	x := 0;
    y := 10;
	while(x < 20)
	invariant b0(x,y);
	{
		if(x < 10) {
            x := x + 1;
        }
        else {
            x := x + 1;
            y := y + 1; 
        }
	}
	assert(y == 20);
}
