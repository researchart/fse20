package demo.benchmarks.Bess.bessj0.NEq;
public class newV{
    public static double snippet(double x) {
        double ax = 0;
        double z = 0;
        double xx = 0;
        double y = 0;
        double ans = 0;
        double ans1 = 0;
        double ans2 = 0;
        ax=Math.abs(x);
        if (ax < 80.0) {//change
            y=x*x;
            ans1=57568490574.0+y*(-13362590354.0+y*(651619640.7 +y*(-11214424.18+y*(77392.33017+y*(-184.9052456)))));
            ans2=57568490411.0+y*(1029532985.0+y*(9494680.718 +y*(59272.64853+y*(267.8532712+y*1.0))));
            ans=ans1/ans2;
        }
        else {
            z=8.0/ax;
            y=0;//change
            xx=ax-0.785398164;
            ans1=1.0+y*(-0.1098628627e-2+y*(0.2734510407e-4 +y*(-0.2073370639e-5+y*0.2093887211e-6)));
            ans2 = -0.1562499995e-1+y*(0.1430488765e-3 +y*(-0.6911147651e-5+y*(0.7621095161e-6 -y*0.934945152e-7)));
            ans=ans1-z*Math.sin(xx)*ans2;
        }
        return ans;
    }
}