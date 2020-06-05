package demo.benchmarks.Bess.bessy0.Eq;
public class newV{
    public static double snippet (double x) {
        double z = 0;
        double xx = 0;
        double y = 0;
        double ans = 0;
        double ans1= 0;
        double ans2= 0;
        if (x < 8.0) {
            y=x*x;
            ans1 = -2957821389.0+y*(7062834065.0+y*(-512359803.6 +y*(10879881.29+y*(-86327.92757+y*228.4622733))));
            ans2=40076544269.0+y*(745249964.8+y*(7189466.438 +y*(47447.26470+y*(226.1030244+y*1.0))));
            ans=(ans1/ans2)+0.636619772*bessj0(x)*Math.log(x);
        }
        else {
            z=8.0/x;
            y=z*z;
            xx=x-0.785398164;
            ans1=1.0+y*(-0.1098628627e-2+y*(0.2734510407e-4 +y*(-0.2073370639e-5+y*0.2093887211e-6)));
            ans2 = -0.1562499995e-1+y*(0.1430488765e-3 +y*(-0.6911147651e-5+y*(0.7621095161e-6 +y*(-0.934945152e-7))));
            ans=Math.sqrt(0.636619772/x)*(Math.sin(xx)*ans1+(8.0/x)*Math.cos(xx)*ans2);//change
        }
        return ans;
    }
    private static double bessj0(double x){
        double ax,z,xx,y,ans,ans1,ans2;

        if ((ax=Math.abs(x)) < 8.0) {
            y=x*x;
            ans1=57568490574.0+y*(-13362590354.0+y*(651619640.7
                    +y*(-11214424.18+y*(77392.33017+y*(-184.9052456)))));
            ans2=57568490411.0+y*(1029532985.0+y*(9494680.718
                    +y*(59272.64853+y*(267.8532712+y*1.0))));
            ans=ans1/ans2;
        } else {
            z=8.0/ax;
            y=z*z;
            xx=ax-0.785398164;
            ans1=1.0+y*(-0.1098628627e-2+y*(0.2734510407e-4
                    +y*(-0.2073370639e-5+y*0.2093887211e-6)));
            ans2 = -0.1562499995e-1+y*(0.1430488765e-3
                    +y*(-0.6911147651e-5+y*(0.7621095161e-6
                    -y*0.934945152e-7)));
            ans=Math.sqrt(0.636619772/ax)*(Math.cos(xx)*ans1-z*Math.sin(xx)*ans2);
        }
        return ans;
    }
}