package demo.benchmarks.tsafe.normAngle.Eq;
public class oldV{
	public static double snippet (double angle) {
		double twoPi = Math.PI * 2; 
		if (angle < -Math.PI) {
			return angle + twoPi;
		}
		if (angle > Math.PI) {
			return angle - twoPi;
		}
		return angle;
	}
}