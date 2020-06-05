package demo.benchmarks.ModDiffNeq.LoopMult5;
public class newV {
	public static int snippet(int x) {
		if (x>=5 && x<7){
			int c=0;
			for (int i=1;i<=x;++i)
				c+=5;
			return c;
		}
		return 0;
	}
}

