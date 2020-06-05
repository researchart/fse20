function {:existential true} b0(d:int, a:int): bool;

procedure main(a: [int]int, size: int)
requires (forall i: int, j: int :: 0 <= i && i <= j && j < size ==> a[i] <= a[j]);
{
  var d, i: int;
  var b: [int]int;

  d := a[0];
  i := 1;
  while(i < size)
  invariant b0(d, a[i-1]);
  invariant (forall k: int :: 0 <= k && k < i-1 ==> b[k] >= 0);
  {
    b[i-1] := a[i] - d;
    d:=a[i];
    i := i + 1;
  }

  assert (forall k: int :: 0 <= k && k < size-1 ==> b[k] >= 0);

}

