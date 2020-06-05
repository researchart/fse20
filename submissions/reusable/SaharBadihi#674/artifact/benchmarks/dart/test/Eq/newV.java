package demo.benchmarks.dart.test.Eq;
public class newV {
    public static double snippet(int x, int y) {
        if (x*x*x > 0){
            if(y==10)//change
                return 1000;
        } else {
            if (false)//change
                return -1000;
        }
        return 0;
    }
}