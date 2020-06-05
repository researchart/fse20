package demo.benchmarks.Bess.bessi1.NEq;
public class oldV{
    public static double snippet(double x) {
        double ax = 0;
        double ans = 0;
        double y = 0;
        ax = Math.abs(x);
        if (ax < 3.75) {
            y=x/3.75;
            y*=y;
            ans=ax*(0.5+y*(0.87890594+y*(0.51498869+y*(0.15084934 +y*(0.2658733e-1+y*(0.301532e-2+y*0.32411e-3))))));
        } else {
            y=3.75/ax;
            ans=0.2282967e-1+y*(-0.2895312e-1+y*(0.1787654e-1 -y*0.420059e-2));
            ans=0.39894228+y*(-0.3988024e-1+y*(-0.362018e-2 +y*(0.163801e-2+y*(-0.1031555e-1+y*ans))));
            ans *= (Math.exp(ax)/Math.sqrt(ax));
        }
        if (x < 0.0)
            return -ans;
        else
            return ans;
    }
}