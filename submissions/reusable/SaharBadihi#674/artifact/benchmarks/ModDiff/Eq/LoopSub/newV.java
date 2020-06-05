package demo.benchmarks.ModDiffEq.LoopSub;
public class newV {
	public static int snippet() {
		int a = 900;
		int b = 5;
		int c=b;
		for (int i=0;i<3;++i)
			c-=a;
		return c;
	}
}