package demo.benchmarks.Ell.brent.Eq;
public class newV{
  public static double snippet (double ax, double bx, double cx,double tol,double bxmin) {
    int ITMAX = 100;
    double CGOLD=0.3819660;
    double ZEPS=1e-14*1.0e-3;
    int iter =0;
    double a=0.0;
    double b=0.0;
    double d=0.0;
    double etemp=0.0;
    double fu=0.0;
    double fv=0.0;
    double fw=0.0;
    double fx=0.0;
    double p=0.0;
    double q=0.0;
    double r=0.0;
    double tol1=0.0;
    double tol2=0.0;
    double u=0.0;
    double v=0.0;
    double w=0.0;
    double x=0.0;
    double xm=0.0;
    double e=0.0;
    a=(ax < cx ? ax : cx);
    b=(ax > cx ? ax : cx);
    x=bx;
    w=bx;
    v=bx;
    fw=fv=fx=Math.sin(x);
    for (iter=0;iter<ITMAX;iter++) {
      xm=0.5*(a+b);
      tol2=2.0*(tol1=tol*Math.abs(x)+ZEPS);
      if (Math.abs(x-xm) <= (tol2-0.5*(b-a))) {//change
        return fx;
      }
      if (Math.abs(e) > tol1) {
        r=(x-w)*(fx-fv);
        q=(x-v)*(fx-fw);
        p=(x-v)*q-(x-w)*r;
        q=2.0*(q-r);
        if (q > 0.0) p = -p;
        q=Math.abs(q);
        etemp=e;
        e=d;
        if (Math.abs(p) >= Math.abs(0.5*q*etemp) || p <= q*(a-x) || p >= q*(b-x))
          d=0.3819660*e;//change
        else {
          d=p/q;
          u=x+d;
          if (u-a < tol2 || b-u < tol2)
            d=SIGN(tol1,xm-x);
        }
      } else {
        d=CGOLD*(e=(x >= xm ? a-x : b-x));
      }
      u=(Math.abs(d) >= tol1 ? x+d : x+SIGN(tol1,d));
      fu=Math.sin(u);
      if (fu <= fx) {
        if (u >= x) a=x; else b=x;
        v=w;
        w=x;
        x=u;
        fv=fw;
        fw=fx;
        fx=fu;
      } else {
        if (u < x) a=u;
        else b=u;
        if (fu <= fw || w == x) {
          v=w;
          w=u;
          fv=fw;
          fw=fu;
        } else if (fu <= fv || v == x || v == w) {
          v=u;
          fv=fu;
        }
      }
    }//change
    return fx;
  }
  public static double SQR(double a) {
    return a*a;
  }

  public static double SIGN(double a, double b){
    return b >= 0 ? (a >= 0 ? a : -a) : (a >= 0 ? -a : a);
  }

  public static double MAX(double a, double b){
    return b > a ? (b) : (a);
  }

  public static double MIN(double a, double b){
    return b < a ? (b) : (a);
  }
  public static long helperdoubleToRawBits(double xm) {
    return Double.doubleToRawLongBits(xm);
  }
}