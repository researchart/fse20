function {:existential true} b0(x:int,y:int): bool;

procedure main()
{
  var x: int;
  var y: int;
  
  x := 0;
  y := 0;

  while (true)
  invariant b0(x,y);
  {
    if(x<5){
        y := y+1;
    }
    else {
        y:=y-1;
    }
    if(y<0) {
      break;
    }
    x := x+1;
  }
  assert(x == 10);
}
