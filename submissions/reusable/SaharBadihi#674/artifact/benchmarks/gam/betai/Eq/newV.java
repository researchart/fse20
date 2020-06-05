package demo.benchmarks.gam.betai.Eq;
public class newV {
  public static double snippet(double a, double b, double x) {
    double bt =0;
    if (x == 0.0 || x == 1.0)
      bt = 0.0;
    else
      bt = Math.exp(gammln(a + b) - gammln(a) - gammln(b) + a * Math.log(x) + b * Math.log(1.0 - x));
    double a1 = a + 1.0;//change
    double b1 = b + 1.0;//change
    if (x < a1/(a1+b1))//change
      return bt * betacf(a, b, x) / a;
    else
      return 1.0 - bt * betacf(b, a, 1.0 - x) / b;
  }

  public static double betacf(double a, double b, double x) {
    final int MAXIT = 2;
    final double EPS = 1e-14;
    final double FPMIN = Double.MIN_VALUE / EPS;
    int m, m2;
    double aa, c, d, del, h, qab, qam, qap;

    qab = a + b;
    qap = a + 1.0;
    qam = a - 1.0;
    c = 1.0;
    d = 1.0 - qab * x / qap;
    if (Math.abs(d) < FPMIN) d = FPMIN;
    d = 1.0 / d;
    h = d;
    for (m = 1; m <= MAXIT; m++) {
      m2 = 2 * m;
      aa = m * (b - m) * x / ((qam + m2) * (a + m2));
      d = 1.0 + aa * d;
      if (Math.abs(d) < FPMIN) d = FPMIN;
      c = 1.0 + aa / c;
      if (Math.abs(c) < FPMIN) c = FPMIN;
      d = 1.0 / d;
      h *= d * c;
      aa = -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2));
      d = 1.0 + aa * d;
      if (Math.abs(d) < FPMIN) d = FPMIN;
      c = 1.0 + aa / c;
      if (Math.abs(c) < FPMIN) c = FPMIN;
      d = 1.0 / d;
      del = d * c;
      h *= del;
      if (Math.abs(del - 1.0) <= EPS) break;
    }
    if (m > MAXIT) System.out.println("a or b too big, or MAXIT too small in betacf");
    return h;
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