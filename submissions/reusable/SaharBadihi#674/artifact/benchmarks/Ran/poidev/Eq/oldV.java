package demo.benchmarks.Ran.poidev.Eq;
public class oldV{
    public static double snippet (double xm, int idumx,int idum) {//idum is a global var
        idum = idumx;
        double PI=3.141592653589793238;
        double sq = 0;
        double alxm = 0;
        double g = 0;
        double oldm=(-1.0);
        double em = 0.0 ;
        double t = 0.0;
        double y = 0.0;
        if (xm < 12.0) {
            if (xm != oldm) {
                oldm=xm;
                g=Math.exp(-xm);
            }
            em = -1;
            t=1.0;
            do {
                ++em;
                t *= ran1(idum);
            } while (t > g);
        }
        else {
            if (xm != oldm) {
                oldm=xm;
                sq=Math.sqrt(2.0*xm);
                alxm=Math.log(xm);
                g=xm*alxm-gammln(xm+1.0);
            }
            do {
                do {
                    y=Math.tan(PI*ran1(idum));
                    em=sq*y+xm;
                } while (em < 0.0);
                em=Math.floor(em);
                t=0.9*(1.0+y*y)*Math.exp(em*alxm-gammln(em+1.0)-g);
            } while (ran1(idum) > t && idum<530511967);
        }
        return em;
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
    static double ran1(int idum){
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
                k=idum/IQ;
                idum=IA*(idum-k*IQ)-IR*k;
                if (idum < 0)
                    idum += IM;
                if (j < NTAB)
                    iv[j] = idum;
            }
            iy=iv[0];
        }
        k=idum/IQ;
        idum=IA*(idum-k*IQ)-IR*k;
        if (idum < 0)
            idum += IM;
        j=iy/NDIV;
        iy=iv[j];
        iv[j] = idum;
        if ((temp=AM*iy) > RNMX)
            return RNMX;
        else
            return temp;
    }
}