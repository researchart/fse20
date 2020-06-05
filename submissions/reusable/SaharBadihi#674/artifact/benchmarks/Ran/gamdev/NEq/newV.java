package demo.benchmarks.Ran.gamdev.NEq;
public class newV{
    public static double snippet (int ia, int idumx, int idum) {
        idum = idumx;
        int j = 0;
        double am = 0;
        double e = 0;
        double s = 0;
        double v1 = 0;
        double v2 = 0;
        double x = 0;
        double y = 0;
        if (ia < 1)
            return -1000;
        if (ia < 6) {
            x = 1.0;
            for (j=1;j<=ia+10;j++)//change
                x *= ran1(idum);
            x = -Math.log(x) + ia;//change
        }
        else {

                do {
                    do {
                        v1 += idumx;
                        v2 = 2.0 * idumx - 1.0;
                    } while (v1 * v1 + v2 * v2 > 1.0);
                    y = v2 / v1;
                    am = ia - 1;
                    s = Math.sqrt(2.0 * am + 2.0);
                    x = s * y + ia + 10; //change
                } while (x <= 0.0);
        }
        return x;
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