package demo.benchmarks.gam.gammq.NEq;
public class oldV{
  public static double snippet (double a, double x, double gamser, double gammcf, double gln) {
    if (x < 0.0 )
      return -100000;
    if (x < a+1.0) {
      gamser =gser(a,x,gln, gamser);
      return 1.0-gamser;
    } else {
      gammcf = gcf(a,x, gln);
      return gammcf;
    }
  }
  public static double gser(double a, double x, double gln,double gamser){
    return gamser;
  }
  public static double gcf(double a, double x, double gln){
    return gln;
  }
}