package demo.benchmarks.ModDiffNeq.LoopMult5;
public class oldV {
	public static int snippet(int x) {
		if (x>=5 && x<7){
			int c=0;
			for (int i=1;i<=5;++i)
				c-=x;
			return c;
		}
		return 0;
	}
}

