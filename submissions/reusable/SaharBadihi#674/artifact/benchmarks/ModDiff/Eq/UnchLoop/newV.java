package demo.benchmarks.ModDiffEq.UnchLoop;
public class newV{
	public static int snippet(int a, int b) {
		int c=1;
		for (int i=0;i<a;++i) {
			c=c+b;
		}
		return c;
	}
}
