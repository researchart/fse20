package demo.benchmarks.ModDiffNeq.LoopUnreach15;
public class newV{
    public static int snippet(int x) {
        if (x>=13 && x<16) {
            int c = 1;
            if (x < 0) {
                for (int i = 1; i <= 15; ++i)
                    c += x;
            }
            return c;
        }
        return 0;

    }
}