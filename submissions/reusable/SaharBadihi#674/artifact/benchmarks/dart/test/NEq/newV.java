package demo.benchmarks.dart.test.NEq;
public class newV {
    public static double snippet(int x, int y) {
        if (x*x*x < 0){//change
            if(x>0 && y==10)
                return 1000;
        } else {
            if (x>0 && y==20)
                return -1000;
        }
        return 0;
    }
}