package demo.benchmarks.Bess.pythag.NEq;
public class oldV{
    public static double snippet (double a, double b) {
        double absa = 0;
        double absb = 0;
        absa=Math.abs(a);
        absb=Math.abs(b);
        if (absa > absb) {
            return absa * Math.sqrt(1.0 + SQR(absb / absa));
        }
        else {
            if (absb == 0.0 )
                return 0.0;
            else
                return absb * Math.sqrt(1.0 + SQR(absa / absb));
        }
    }
    public static double SQR(double a) {
        return a*a;
    }
}