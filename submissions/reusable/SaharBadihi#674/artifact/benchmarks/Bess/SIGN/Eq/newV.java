package demo.benchmarks.Bess.SIGN.Eq;
public class newV{
    public static double snippet (double a, double b) {
        if (a >= 0){//change
            if (b >= 0)//change
                return a;
            else
                return -a;
        }
        else {
            if (b >= 0)//change
                return -a;
            else
                return a;
        }
    }
}