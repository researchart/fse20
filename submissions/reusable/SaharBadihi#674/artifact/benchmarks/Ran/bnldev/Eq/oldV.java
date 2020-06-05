package demo.benchmarks.Ran.bnldev.Eq;
public class oldV{
    public static double snippet (double pp,  int n, int idumx, int idum) {//idum is global Var
        idum = idumx;
        double PI=3.141592653589793238;
        double j=0;
        double nold=-1;
        double am=0;
        double em=0;
        double g=0;
        double angle=0;
        double p=0;
        double bnl=0;
        double sq=0;
        double t=0;
        double y=0;
        double pold=-1;
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
                    angle = PI * ran1(idum);
                    y = Math.tan(angle);
                    em = sq * y + am;
                } while (em < 0.0 || em >= (en+1.0));
                em=Math.floor(em);
                t=1.2*sq*(1.0+y*y)*Math.exp(oldg-gammln(em+1.0)-gammln(en-em+1.0)+em*plog+(en-em)*pclog);
            } while (ran1(idum) > t&& idum<530511967);
            bnl=em;
        }
        if (p != pp)
            bnl=n-bnl;
        return bnl;
    }
    static double gammln(double xx){
        int j;
        double x,y,tmp,ser;
        double[] cof={76.18009172947146,-86.50532032941677, 24.01409824083091,-1.231739572450155,0.1208650973866179e-2, -0.5395239384953e-5};
        y=x=xx;
        tmp=x+5.5;
        tmp -= (x+0.5)*Math.log(tmp);
        ser=1.000000000190015;
        for (j=0;j<6;j++)
            ser += cof[j]/++y;
        return -tmp+Math.log(2.5066282746310005*ser/x);
    }
    static double ran1(double idum){
        int IA=16807;
        int IM=2147483647;
        int IQ=127773;
        int IR=2836;
        int NTAB=32;
        int NDIV=(1+(IM-1)/NTAB);
        double EPS=3.0e-16;
        double AM=1.0/IM;
        double RNMX=(1.0-EPS);
        int iy=0;
        int[] iv = new int[NTAB];
        int j,k;
        double temp;
        if (idum <= 0 || iy == 0) {
            if (-idum < 1)
                idum=1;
            else
                idum = -idum;
            for (j=NTAB+7;j>=0;j--) {
                k= (int) (idum/IQ);
                idum=IA*(idum-k*IQ)-IR*k;
                if (idum < 0)
                    idum += IM;
                if (j < NTAB)
                    iv[j] = (int) idum;
            }
            iy=iv[0];
        }
        k= (int) (idum/IQ);
        idum=IA*(idum-k*IQ)-IR*k;
        if (idum < 0)
            idum += IM;
        j=iy/NDIV;
        iy=iv[j];
        iv[j] = (int) idum;
        if ((temp=AM*iy) > RNMX)
            return RNMX;
        else
            return temp;
    }
}