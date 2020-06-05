package demo.benchmarks.ModDiffEq.LoopUnreach2;
public class newV{
	public static int snippet(int a, int b) {
		int c=0;
		if (a<0) {
			if (a==b) {
				for (int i = 1; i <= a; ++i)
					c += b;
			}
		}
		return c;
	}
}