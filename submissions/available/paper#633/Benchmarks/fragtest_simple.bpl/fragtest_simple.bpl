function {:existential true} b0(i:int): bool;
function {:existential true} b1(i:int,k:int,tmp:int): bool;
function {:existential true} b2(i:int,k:int,n:int,j:int,jPk:int): bool;

procedure main()
{
    var i,pvlen,tmp___1,k,n,j:int;
    var con:bool;
    k := 0;
    i := 0;
    havoc pvlen;
    havoc con;

    while ( con && i <= 100000) 
    invariant b0(i);
    {
        i := i + 1;
        havoc con;
    }

    if (i > pvlen) {
        pvlen := i;
    }
    i := 0;

    havoc con;
    while ( con && i <= 100000) 
    invariant b1(i,k,tmp___1);
    {
        tmp___1 := i;
        i := i + 1;
        k := k + 1;
        havoc con;
    }

    j := 0;
    n := i;
    while (true)
	invariant b2(i,k,n,j,j+k);
    {
        assert(k >= 0);
        k := k - 1;
        i := i - 1;
        j := j + 1;
        if (j >= n) {
            break;
        }
    }
}

