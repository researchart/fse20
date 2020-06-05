package demo.benchmarks.ModDiffEq.LoopSub;
public class oldV {
	public static int snippet() {
		int a = 5;
		int b = 900;
		int c=a;
		for (int i=0;i<3;++i)
			c-=b;
		return c;
	}
}