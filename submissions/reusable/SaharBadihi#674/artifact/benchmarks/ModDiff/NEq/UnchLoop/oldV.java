package demo.benchmarks.ModDiffNeq.UnchLoop;
public class oldV{
	public static int snippet(int a, int b) {
		int c=0;
		for (int i=0;i<a;++i) {
			c=c+b;
		}
		return c+1;
	}
}