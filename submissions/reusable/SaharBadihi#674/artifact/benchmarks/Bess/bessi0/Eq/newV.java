package demo.benchmarks.Bess.bessi0.Eq;
public class newV{
    public static double snippet(double x) {
        double ax = 0;
        double ans = 0;
        double y = 0;
        ax=Math.abs(x);
        double temp = 3.75;//change
        if (ax < 3.75) {
            y=x/temp;//change
            y*=y;
            ans=1.0+y*(3.5156229+y*(3.0899424+y*(1.2067492+y*(0.2659732+y*(0.360768e-1+y*0.45813e-2)))));
        }
        else {
            y=temp/ax;//change
            ans=(Math.exp(ax)/Math.sqrt(ax))*(0.39894228+y*(0.1328592e-1 +y*(0.225319e-2+y*(-0.157565e-2+y*(0.916281e-2 +y*(-0.2057706e-1+y*(0.2635537e-1+y*(-0.1647633e-1 +y*0.392377e-2))))))));
        }
        return ans;
    }
}
