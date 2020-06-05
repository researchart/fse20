package demo.benchmarks.gam.gser.Eq;
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
      del = 1.0 / a;
      sum = 1.0 / a;
      for (n = 0; n < ITMAX; n++) {
        ++ap;
        del *= x / ap;
        sum += del;
        if (Math.abs(del) < Math.abs(sum) * EPS) {
          gamser = sum * Math.exp(-x + a * Math.log(x) - gln);
          return gamser;
        }
      }
      return gamser;
    }
  }
  public static double gcf(double a, double x, double gln){
    final int ITMAX=2;
    final double EPS=1e-14;
    final double FPMIN=Double.MIN_VALUE/EPS;
    int i;
    double an,b,c,d,del,h;

    b=x+1.0-a;
    c=1.0/FPMIN;
    d=1.0/b;
    h=d;
    for (i=1;i<=ITMAX;i++) {
      an = -i*(i-a);
      b += 2.0;
      d=an*d+b;
      if (Math.abs(d) < FPMIN) d=FPMIN;
      c=b+an/c;
      if (Math.abs(c) < FPMIN) c=FPMIN;
      d=1.0/d;
      del=d*c;
      h *= del;
      if (Math.abs(del-1.0) <= EPS) break;
    }
    if (i > ITMAX) System.out.println("a too large, ITMAX too small in gcf");
    return Math.exp(-x+a*Math.log(x)-gln)*h;
  }
  public static double gammln(double xx)
  {
    int j;
    double x,y,tmp,ser;
    final double[] cof={76.18009172947146,-86.50532032941677,
            24.01409824083091,-1.231739572450155,0.1208650973866179e-2,
            -0.5395239384953e-5};

    y=x=xx;
    tmp=x+5.5;
    tmp -= (x+0.5)*Math.log(tmp);
    ser=1.000000000190015;
    for (j=0;j<6;j++) ser += cof[j]/++y;
    return -tmp+Math.log(2.5066282746310005*ser/x);
  }
}