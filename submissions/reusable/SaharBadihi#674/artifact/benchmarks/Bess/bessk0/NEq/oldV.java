package demo.benchmarks.Bess.bessk0.NEq;
public class oldV{
    public static double snippet (double x) {
        double y = 0;
        double ans = 0;
        if (x <= 2.0) {
            y=x*x/4.0;
            ans=(-Math.log(x/2.0)*bessi0(x))+(-0.57721566+y*(0.42278420 +y*(0.23069756+y*(0.3488590e-1+y*(0.262698e-2 +y*(0.10750e-3+y*0.74e-5))))));
        }
        else {
            y=2.0/x;
            ans=(Math.exp(-x)/Math.sqrt(x))*(1.25331414+y*(-0.7832358e-1 +y*(0.2189568e-1+y*(-0.1062446e-1+y*(0.587872e-2 +y*(-0.251540e-2+y*0.53208e-3))))));
        }
        return ans;
    }
    private static double bessi0(double x) {
        double ax,ans,y;

        if ((ax=Math.abs(x)) < 3.75) {
            y=x/3.75;
            y*=y;
            ans=1.0+y*(3.5156229+y*(3.0899424+y*(1.2067492
                    +y*(0.2659732+y*(0.360768e-1+y*0.45813e-2)))));
        } else {
            y=3.75/ax;
            ans=(Math.exp(ax)/Math.sqrt(ax))*(0.39894228+y*(0.1328592e-1
                    +y*(0.225319e-2+y*(-0.157565e-2+y*(0.916281e-2
                    +y*(-0.2057706e-1+y*(0.2635537e-1+y*(-0.1647633e-1
                    +y*0.392377e-2))))))));
        }
        return ans;
    }
}