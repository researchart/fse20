package demo.benchmarks.tsafe.normAngle.NEq;
public class newV{
  public static double snippet (double angle) {
  	double twoPi = Math.PI * 2;
    if (angle < -Math.PI) {
			return angle + Math.PI ;//change
		}
		if (angle > Math.PI) {
			return angle - Math.PI ;//change
		}
		return angle;
  }
}