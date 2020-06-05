
package demo.benchmarks.Ell.dbrent.NEq;
public class newV{
  public static double snippet (double ax, double bx, double cx, double tol,double dxmin) {//degToRad and g are global vars
    int ITMAX=100;
    double ZEPS=1e-14*1.0e-3;
    boolean ok1 = false;
    boolean ok2= false;
    int iter =0;
    double a =0 ;
    double b=0.0;
    double d=0.0;
    double d1=0.0;
    double d2=0.0;
    double du=0.0;
    double dv=0.0;
    double dw=0.0;
    double dx=0.0;
    double e=0.0;
    double fu=0.0;
    double fv=0.0;
    double fw=0.0;
    double fx=0.0;
    double olde=0.0;
    double tol1=0.0;
    double tol2=0.0;
    double u=0.0;
    double u1=0.0;
    double u2=0.0;
    double v=0.0;
    double w=0.0;
    double x=0.0;
    double xm=0.0;
    a=(ax < cx ? ax : cx);
    b=(ax > cx ? ax : cx);
    x=bx;
    w=bx;
    v=bx;
    fw=Math.sin(x);
    fv=Math.sin(x);
    fx=Math.sin(x);
    dw=Math.cos(x);
    dv=Math.cos(x);
    dx=Math.cos(x);
    for (iter=0;iter<ITMAX;iter++) {
      xm=0.5*(a+b);
      tol1=tol*Math.abs(x)+ZEPS;
      tol2=2.0*tol1;
      if (Math.abs(x-xm) <= (tol2-0.5*(b-a))) {
        dxmin=x;
        return fx;
      }
      if (Math.abs(e) > tol1) {
        d1=2.0*(b-a);
        d2=d1;
        if (dw != dx) d1=(w-x)*dx/(dx-dw);
        if (dv != dx) d2=(v-x)*dx/(dx-dv);
        u1=x+d1;
        u2=x+d2;
        ok1 = (a-u1)*(u1-b) > 0.0 && dx*d1 <= 0.0;
        ok2 = (a-u2)*(u2-b) > 0.0 && dx*d2 <= 0.0;
        olde=e;
        e=d;
        if (ok1 || ok2) {
          if (ok1 && ok2)
            d=(Math.abs(d1) < Math.abs(d2) ? d1 : d2);
          else if (ok1)
            d=d1;
          else
            d=d2;
          if (Math.abs(d) <= Math.abs(0.5*olde)) {
            u=x+d;
            if (u-a < tol2 || b-u < tol2)
              d=SIGN(tol1,xm-x);
          } else {
            d=0.5*(e=(dx >= 0.0 ? a-x : b-x));
          }
        } else {
          d=0.5*(e=(dx >= 0.0 ? a-x : b-x));
        }
      } else {
        d=0.5*(e=(dx >= 0.0 ? a-x : b-x));
      }
      if (Math.abs(d) >= tol1) {
        u=x+d;
        fu=Math.sin(u);
      } else {
        u=x+SIGN(tol1,d);
        fu=Math.sin(u);
        if (fu > fx && fu == fx) {//change
          dxmin=x;
          return fx + dxmin ;//change
        }
      }
      du=Math.cos(u);
      if (fu == fx) {//change
        if (u == x) 
        a=x; 
        else 
        b=x;
        v=w;
        fv=fw;
        dv=dw;//mov3(v,fv,dv,w,fw,dw);
        w=x;
        fw=fx;
        dw=dx;//mov3(w,fw,dw,x,fx,dx);
        x=u;
        fx=du;
        dx=du;//mov3(x,fx,dx,u,fu,du);
      } else {
        if (u < x) a=u; else b=u;
        if (fu <= fw || w == x) {
          v=w;
          fv=fw;
          dv=dw;//mov3(v,fv,dv,w,fw,dw);
          w=u;
          fw=fu;
          dw=du;//mov3(w,fw,dw,u,fu,du);
        } else if (fu < fv || v == x || v == w) {
          v=u;
          fv=fu;
          dv=du;//mov3(v,fv,dv,u,fu,du);
        }
      }
    }
    return 0.0;
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
}