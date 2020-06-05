package demo.benchmarks.gam.gser.NEq;
public class oldV{
  public static double snippet (double a, double x,double gamser) {
    int ITMAX = 100;
    double EPS = 1e-14;
    int n=0;
    double sum =0;
    double del =0;
    double ap =0;
    double gln = gammln(a);
    if (x <= 0.0) {
      gamser = 0.0;
      return gamser;
    } else {
      ap = a;
      del = 1.0 * a;
      sum = 1.0 * a;
      for (n = 0; n < 2; n++) {
        ++ap;
        del *= x ;
        sum += del;
        if (Math.abs(del) < Math.abs(sum) * EPS) {
          gamser = sum *  gln;
          return gamser;
        }
      }
      return gamser;
    }
  }
  public static double gcf(double a, double x, double gln){

    return gln;
  }
  public static double gammln(double xx)
  {
    return xx;
  }
}