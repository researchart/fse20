package instrumented;
import equiv.checking.symbex.UnInterpreted;
public class newV{
    public static double snippet(double a, double b) {
        if (b < a)//change
            return a;//change
        else
            return b;//change
    }
}
