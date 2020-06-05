package demo.benchmarks.Airy.Sign.NEq;
public class oldV{
    public static double snippet(double a, double b) {
        if (b >= 0){
            if (a >= 0)
                return a;
            else
                return -a;
        }
        else {
            if (a >= 0)
                return -a;
            else
                return a;
        }
    }
}