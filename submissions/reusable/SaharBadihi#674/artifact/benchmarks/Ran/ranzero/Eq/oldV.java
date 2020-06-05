package demo.benchmarks.Ran.ranzero.Eq;
public class oldV{
    public static double snippet (int idum) {//idum is a global variable
        int IA=16807;
        int IM=2147483647;
        int IQ=127773;
        int IR=2836;
        int MASK=123459876;
        double AM=1.0/(double)IM;
        int k = 0;
        double ans = 0.0;
        idum *= MASK;
        k=idum/IQ;
        idum=IA*(idum-k*IQ)-IR*k;
        if (idum < 0)
            idum += IM;
        ans=AM*idum;
        idum *= MASK;
        return ans;
    }
}