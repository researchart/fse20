package demo.benchmarks.ModDiffNeq.LoopUnreach5;
public class newV{
	public static int snippet(int x) {
		if (x>=5 && x<7) {
			int c = 1;
			if (x < 0) {
				for (int i = 1; i <= 5; ++i)
					c -= x;
			}
			return c;
		}
		return 0;

	}
}