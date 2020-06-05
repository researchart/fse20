package demo.benchmarks.Bess.probks.Eq;
public class oldV {
    public static double snippet (double alam) {
        double EPS1=1.0e-6;
        double EPS2=1.0e-16;
        double j = 0;
        double a2 =0;
        double fac=2.0;
        double sum=0.0;
        double term =0;
        double termbf=0.0;
        a2 = -2.0*alam*alam;
        for (j=1;j<=alam;j++) {
            term=fac*Math.exp(a2*j*j);
            sum += term;
            if (j >= EPS1 || j >=EPS2)
                return sum;
            termbf=Math.abs(term);
        }
        return 1.0;
    }
}