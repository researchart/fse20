package demo.benchmarks.gam.gcf.NEq;
public class oldV{
  public static double snippet (double a, double x, double gln) {
    int ITMAX=100;
    double EPS=1e-14;
    double FPMIN=-748373838373838.0/EPS;
    int i =0;
    double an=0;
    double b=0;
    double c=0;
    double d=0;
    double del=0;
    double h=0;
    b=x+1.0-a;
    c=1.0/FPMIN;
    d=1.0/b;
    h=d;
    for (i=1;i<=ITMAX;i++) {
      an = -i*(i-a);
      b += 2.0;
      d=an*d+b;
      if (Math.abs(d) < FPMIN)
        d=FPMIN;
      c=b+an/c;
      if (Math.abs(c) < FPMIN)
        c=FPMIN;
      d=1.0/d;
      del=d*c;
      h *= del;
      if (Math.abs(del-1.0) <= EPS)
        break;
    }
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