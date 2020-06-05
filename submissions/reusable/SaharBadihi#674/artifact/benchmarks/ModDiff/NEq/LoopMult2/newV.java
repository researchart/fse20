package demo.benchmarks.ModDiffNeq.LoopMult2;
public class newV {
	public static int snippet(int a, int b) {
		int c=0;
		if (a==b) {
			for (int i = 1; i <= b; ++i)
				c -= a;
		}
		return c;
	}
}


