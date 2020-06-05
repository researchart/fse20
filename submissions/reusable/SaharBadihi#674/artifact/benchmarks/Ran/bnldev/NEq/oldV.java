package demo.benchmarks.Ran.bnldev.NEq;
public class oldV{
    public static double snippet (double pp,  int n, int idumx, int idum) {//idum is global Var
        idum = idumx;
        double PI=3.141592653589793238;
        int j = 0;
        int nold=-1;
        double am = 0.0;
        double em = 0.0 ;
        double g = 0.0 ;
        double angle = 0.0;
        double p = 0.0;
        double bnl = 0.0 ;
        double sq = 0.0;
        double t = 0.0 ;
        double y = 0.0;
        double pold=(-1.0);
        double pc = 0;
        double plog = 0;
        double pclog = 0;
        double en = 0;
        double oldg = 0;
        if (pp <= 0.5)
            p = pp;
        else
            p = 1.0-pp;
        am=n*p;
        if (n < 25) {
            bnl=0.0;
            for (j=0;j<n;j++)
                if (ran1(idum) < p)
                    ++bnl;
        }
        else if (am < 1.0) {
            g=Math.exp(-am);
            t=1.0;
            for (j=0;j<=n;j++) {
                t *= ran1(idum);
                if (t < g)
                    break;
            }
            if (j <= n)
                bnl = j;
            else
                bnl = n;
        }
        else {
            if (n != nold) {
                en=n;
                oldg=en+1.0;
                nold=n;
            }
            if (p != pold) {
                pc=1.0-p;
                plog=Math.log(p);
                pclog=Math.log(pc);
                pold=p;
            }
            sq=Math.sqrt(2.0*am*pc);
            do {
                do {
                    angle=PI*ran1(idum);
                    y=Math.tan(angle);
                    em=sq*y+am;
                } while (em < 0.0 || em >= (en+1.0));
                em=Math.floor(em);
                t=1.2*sq*(1.0+y*y)*Math.exp(oldg-gammln(em+1.0)-gammln(en-em+1.0)+em*plog+(en-em)*pclog);
            } while (ran1(idum) > t && idum<530511967);
            bnl=em;
        }
        if (p != pp)
            bnl=n-bnl;
        return bnl;
    }
    static double gammln(double xx){
        return xx;
    }
    static double ran1(int idum){
       return idum;
    }
}