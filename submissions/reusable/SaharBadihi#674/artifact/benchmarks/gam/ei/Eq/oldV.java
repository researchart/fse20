package demo.benchmarks.gam.ei.Eq;
public class oldV{
	public static double snippet (double x) {
		int MAXIT=100;
		double EPS=1e-14;//change
		double EULER=0.577215664901533;
		double FPMIN=-79769313486232.0/EPS;
		int k =0;
		double fact= 0;
		double prev=0;
		double sum=0;
		double term=0;
		if (x <= 0.0)
			return -10000;
		if (x < FPMIN)
			return Math.log(x)+EULER;
		if (x <= -Math.log(EPS)) {
			sum=0.0;
			fact=1.0;
			for (k=1;k<=MAXIT;k++) {
				fact *= x/k;
				term=fact/k;
				sum += term;
				if (term < EPS*sum)
					break;
			}
			return sum+Math.log(x)+EULER;
		} else {
			sum=0.0;
			term=1.0;
			for (k=1;k<=MAXIT;k++) {
				prev=term;
				term *= k/x;
				if (term < EPS)
					break;
				if (term < prev) sum += term;
				else {
					sum -= prev;
					break;
				}
			}
			return Math.exp(x)*(1.0+sum)/x;
		}
	}
}