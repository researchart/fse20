package demo.benchmarks.ModDiffEq.LoopUnreach2;
public class oldV{
	public static int snippet(int a, int b) {
		int c=0;
		if (a<0) {
			if (a==b) {
				for (int i = 1; i <= b; ++i)
					c += a;
			}
		}
		return c;
	}
}