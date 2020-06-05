package demo.benchmarks.ModDiffNeq.LoopMult15;
public class oldV {
	public static int snippet(int x) {
		if (x>=13 && x<16){
			int c=0;
			for (int i=1;i<=15;++i)
				c-=x;
			return c;
		}
		return 0;
	}
}