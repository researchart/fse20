package demo.benchmarks.power.test.Eq;
public class newV{
    public static int snippet(int x, int y) {
        int result = 0; 
        int path = 0;
        if (x > 0) {
            if (y == x * x) {
                path = 1;
            }
            else {
                path = 2;
            }
            if (-y < -8) {//change
                if (path == 1)
                    result = 3;
                else//change
                    result = 13;
            }
            else {
                if (path == 1)
                    result = 4;
                else//change
                    result = 14;
            }
        }
        return result;
    }
}