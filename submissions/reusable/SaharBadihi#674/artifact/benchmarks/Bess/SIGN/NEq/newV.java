package demo.benchmarks.Bess.SIGN.NEq;
public class newV{
    public static double snippet(double a, double b) {
        if (b >= 0){
            a = -a;//change:inserted
            if (a >= 0)
                return a;
            else
                return 0;
        }
        else {
            if (a >= 0 && b>=0) //change: unsafisfiable condition
                return -a;
            else
                return a;
        }
    }
}