package demo.benchmarks.ModDiffNeq.LoopMult10;
public class oldV {
	public static int snippet(int x) {
		if (x>=9 && x<12){
			int c=0;
			for (int i=1;i<=10;++i)
				c-=x;
			return c;
		}
		return 0;
	}
}

