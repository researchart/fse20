import gov.nasa.jpf.symbc.Debug;
	public class Test {

		static int test(int n) {
			int x = 0;
			while(x < n)
				x = x + 1;
			return x;
		}
		public static void main(String[] args) {
			test(0);
		}

}