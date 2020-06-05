package demo.benchmarks.Bess.pythag.Eq;
public class newV{
    public static double snippet (double a, double b) {
        double absa = 0;
        double absb = 0;
        absa=Math.abs(a);
        absb=Math.abs(b);
        if (absa > absb)
            return absa*Math.sqrt(1.0+SQR(absb/absa));
        else {
            if (absb != 0.0 )//change
                return absb * Math.sqrt(1.0 + SQR(absa / absb));//change
            else
                return absb;//change

        }
    }
    public static double SQR(double a) {
        return a*a;
    }
}