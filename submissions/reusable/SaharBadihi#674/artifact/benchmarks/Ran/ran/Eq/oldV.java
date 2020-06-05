package demo.benchmarks.Ran.ran.Eq;
public class oldV{
    public static double snippet (double idum) {//idum is a global variable
        double IA=16807;
        double IM=2147483647;
        double IQ=127773;
        double IR=2836;
        double NTAB=32;
        double NDIV=(1+(IM-1)/NTAB);
        double EPS=3.0e-16;
        double AM=1.0/IM;
        double RNMX=(1.0-EPS);
        double iy=0;
        double iv0 = 0;
        double j = 0;
        double k = 0;
        double temp = 0.0;
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
                iv0 = idum;
            }
            iy=iv0;
        }
        k=idum/IQ;
        idum=IA*(idum-k*IQ)-IR*k;
        if (idum < 0)
            idum += IM;
        iy=iy/idum;
        if ((temp=AM*iy) > NDIV)
            return RNMX;
        else
            return temp;
    }
}