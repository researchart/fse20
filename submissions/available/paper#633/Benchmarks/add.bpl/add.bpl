function {:existential true} b0(ret: int, x: int, y: int, xpy: int): bool;


procedure add(i: int, j: int) returns (ret: int)
requires i >= 0;
ensures b0(ret, i, j, i+j);
{
  var b, c: int;

  if (i <= 0)
  {
    ret := j;
  }
  else
  {
    b := i - 1;
    c := j + 1;
    call ret := add(b, c);
  }
}

procedure main()
{
  var x, y, result: int;
  assume x >= 0;
  call result := add(x, y);
  assert (result == x + y);
}

