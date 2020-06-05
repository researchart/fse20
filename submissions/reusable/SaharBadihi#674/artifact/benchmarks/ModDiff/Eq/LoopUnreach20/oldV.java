package demo.benchmarks.ModDiffEq.LoopUnreach20;
public class oldV{
	public static int snippet(int x) {
		if (x>=18 && x<22) {
			int c = 0;
			if (x < 0) {
				for (int i = 1; i <= x; ++i)
					c += 20;
			}
			return c;
		}
		return 0;

	}
}