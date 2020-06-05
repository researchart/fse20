package demo.benchmarks.tsafe.normAngle.Eq;
public class newV{
    public static double snippet (double angle) {
        double twoPi = Math.PI * 2;
        if (angle < -twoPi/2) {//change
            return angle + Math.PI * 2; //change
        }
        if (angle > Math.PI) {
            return angle - twoPi; 
        }
        return angle;
    }
}