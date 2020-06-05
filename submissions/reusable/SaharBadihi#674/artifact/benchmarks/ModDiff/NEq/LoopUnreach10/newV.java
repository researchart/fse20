package demo.benchmarks.ModDiffNeq.LoopUnreach10;
public class newV{
	public static int snippet(int x) {
		if (x>=9 && x<12) {
			int c = 1;
			if (x < 0) {
				for (int i = 1; i <= 10; ++i)
					c += x;
			}
			return c;
		}
		return 0;

	}
}