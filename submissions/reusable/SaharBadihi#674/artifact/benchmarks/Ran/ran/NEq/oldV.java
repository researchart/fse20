package demo.benchmarks.Ran.ran.NEq;
public class oldV{
    public static double snippet (int idum) {//idum is a global variable
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
        int iv0 = 0;
        int j = 0;
        int k = 0;
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