package demo.benchmarks.Bess.bessk1.NEq;
public class oldV{
    public static double snippet (double x) {
        double y =0;
        double ans =0;
        if (x <= 2.0) {
            y=x*x;
            ans=(Math.log(x/2.0)*bessi1(x))+(1.0*x)+(1.0+y*(0.15443144 +y*(-0.67278579+y*(-0.18156897+y*(-0.1919402e-1 +y*(-0.110404e-2+y*(-0.4686e-4)))))));
        }
        else {
            y=2.0/x;
            ans=(1.25331414+y*(0.23498619 +y*(-0.3655620e-1+y*(0.1504268e-1+y*(-0.780353e-2 +y*(0.325614e-2+y*(-0.68245e-3)))))));
        }
        return ans;
    }
    private static double bessi1(double x){
        double ax,ans,y;

        if ((ax=Math.abs(x)) < 3.75) {
            y=x/3.75;
            y*=y;
            ans=ax*(0.5+y*(0.87890594+y*(0.51498869+y*(0.15084934
                    +y*(0.2658733e-1+y*(0.301532e-2+y*0.32411e-3))))));
        } else {
            y=3.75/ax;
            ans=0.2282967e-1+y*(-0.2895312e-1+y*(0.1787654e-1
                    -y*0.420059e-2));
            ans=0.39894228+y*(-0.3988024e-1+y*(-0.362018e-2
                    +y*(0.163801e-2+y*(-0.1031555e-1+y*ans))));
            ans *= (Math.exp(ax)/Math.sqrt(ax));
        }
        return x < 0.0 ? -ans : ans;
    }
}