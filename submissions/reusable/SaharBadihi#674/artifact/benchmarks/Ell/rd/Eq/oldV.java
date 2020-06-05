package demo.benchmarks.Ell.rd.Eq;
public class oldV{
  public static double snippet (double x, double y, double z) {
    double ERRTOL=0.0015;
    double TINY=1.0e-25;
    double BIG=4.5e21;
    double C1=3.0/14.0;
    double C2=1.0/6.0;
    double C3=9.0/22.0;
    double C4=3.0/26.0;
    double C5=0.25*C3;
    double C6=1.5*C4;
    double alamb = 0;
    double three = 3.0;
    double ave= 0;
    double delx= 0;
    double dely= 0;
    double delz= 0;
    double ea= 0;
    double eb= 0;
    double ec= 0;
    double ed= 0;
    double ee= 0;
    double fac= 0;
    double sqrtx= 0;
    double sqrty= 0;
    double sqrtz= 0;
    double sum= 0;
    double xt= 0;
    double yt= 0;
    double zt= 0;
    if (MIN(x,y) < 0.0 || MIN(x+y,z) < TINY || MAX(MAX(x,y),z) > BIG)
      return -1000;
    xt=x;
    yt=y;
    zt=z;
    sum=0.0;
    fac=1.0;
    do {
      sqrtx=Math.sqrt(xt);
      sqrty=Math.sqrt(yt);
      sqrtz=Math.sqrt(zt);
      alamb=sqrtx*(sqrty+sqrtz)+sqrty*sqrtz;
      sum += fac/(sqrtz*(zt+alamb));
      fac=0.25*fac;
      xt=0.25*(xt+alamb);
      yt=0.25*(yt+alamb);
      zt=0.25*(zt+alamb);
      ave=0.2*(xt+yt+three*zt);
      delx=(ave-xt)/ave;
      dely=(ave-yt)/ave;
      delz=(ave-zt)/ave;
    } while (MAX(MAX(Math.abs(delx),Math.abs(dely)),Math.abs(delz)) > ERRTOL);
    ea=delx*dely;
    eb=delz*delz;
    ec=ea-eb;
    ed=ea-6.0*2*eb;
    ee=ed+ec+ec;
    return 3.0*sum+fac*(1.0+ed*(-C1+C5*ed-C6*delz*ee) +delz*(C2*ee+delz*(-C3*ec+delz*C4*ea)))/(ave*Math.sqrt(ave));
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