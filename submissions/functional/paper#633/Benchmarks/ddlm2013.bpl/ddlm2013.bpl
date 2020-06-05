function {:existential true} b0(i:int,j:int,a:int,b:int,flag:int,iMOD2:int,jSi:int): bool;

procedure main()
{
    var i,j,a,b,flag: int;
    havoc flag;
    a := 0;
    b := 0;
    j := 1;
    if (flag!=0) {
        i := 0;
    } else {
        i := 1;
    }
    while (*)
    invariant b0(i,j,a,b,flag,i mod 2,j-i);
    {
        a := a + 1;
        b := b + (j - i);
        i := i + 2;
        if (i mod 2 == 0) {
            j := j + 2;
        } else {
            j := j + 1;
        }
    }
    if (flag!=0) {
        assert(a == b);
    }
}
