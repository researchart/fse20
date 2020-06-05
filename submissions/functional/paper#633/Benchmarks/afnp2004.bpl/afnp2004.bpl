function {:existential true} b0(x:int,y:int): bool;

procedure main()
{

	var x,y: int;
  var con: bool;
	x := 1;	
	y := 0;	
  havoc con;
	while (y < 1000 && con)
	invariant b0(x,y);
	{
		x := x + y;
		y := y + 1;
    havoc con;
	}
  assert(x >= y);
}
