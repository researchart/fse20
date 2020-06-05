package demo.benchmarks.Ell.rf.NEq;
public class newV{
  public static double snippet (double x, double y, double z) {
    double ERRTOL=0.0025;
    double TINY=1.5e-38;
    double BIG=3.0e37;
    double THIRD=1.0/3.0;
    double C1=1.0/24.0;
    double C2=0.1;
    double C3=3.0/44.0;
    double C4=1.0/14.0;
    double alamb= 0;
    double ave= 0;
    double delx= 0;
    double dely= 0;
    double delz= 0;
    double sqrtx= 0;
    double sqrty= 0;
    double sqrtz= 0;
    double xt= 0;
    double yt= 0;
    double zt= 0;
    double e2= 0;
    double e3= 0;
    if (MIN(MIN(x+y,x+z),y+z) < TINY || MAX(MAX(x,y),z) > BIG)//change
      return -10000;
    xt=x;
    yt=y;
    zt=z;
    do {
      sqrtx=Math.sqrt(xt);
      sqrty=Math.sqrt(yt);
      sqrtz=Math.sqrt(zt);
      alamb=sqrty*sqrtz;//change
      yt=0.25*(yt+alamb);
      zt=0.25*(zt+alamb);
      ave=THIRD*(xt+yt+zt);
      delx=(ave-xt)/ave;
      dely=(ave-yt)/ave;
      delz=(ave-zt)/ave;
    } while (MAX(MAX(Math.abs(delx),Math.abs(dely)),Math.abs(delz)) > ERRTOL);
    e2=delx*dely-delz*delz;
    e3=delx*dely*delz;
    return (1.0+(C1*e2-C2-C3*e3)*e2+C4*e3);//change
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