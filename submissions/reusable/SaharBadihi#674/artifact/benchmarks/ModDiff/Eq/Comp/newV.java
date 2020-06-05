package demo.benchmarks.ModDiffEq.Comp;
public class newV {
	public static double snippet() {
		int x=2;
		int y=3;
		int z =0;
		if (x<y)
			z =1;
		else
			z =0;
		if (z==1) {
			int tmp=y;
			y=x;
			x=tmp;
		}
		return y;
	}
}