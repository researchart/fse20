package demo.benchmarks.Ell.rc.NEq;
public class oldV{
  public static double snippet (double x, double y) {
    double ERRTOL=0.0012;
    double TINY=1.69e-38;
    double SQRTNY=1.3e-19;
    double BIG=3.0e37;
    double TNBG=TINY*BIG;
    double COMP1=2.236/SQRTNY;
    double COMP2=TNBG*TNBG/25.0;
    double THIRD=1.0/3.0;
    double C1=0.3;
    double C2=1.0/7.0;
    double C3=0.375;
    double C4=9.0/22.0;
    double alamb =0 ;
    double ave=0;
    double s=0;
    double w=0;
    double xt=0;
    double yt=0;
    if (x < 0.0 || y == 0.0 || (x+Math.abs(y)) < TINY || (x+Math.abs(y)) > BIG || (y<-COMP1 && x > 0.0 && x < COMP2))
      return -10000;
    if (y > 0.0) {
      xt=x;
      yt=y;
      w=1.0;
    } else {
      xt=x-y;
      yt= -y;
      w=Math.sqrt(x)/Math.sqrt(xt);
    }
    do {
      alamb=2.0*Math.sqrt(xt)*Math.sqrt(yt)+yt;
      xt=0.25*(xt+alamb);
      yt=0.25*(yt+alamb);
      ave=THIRD*(xt+yt+yt);
      s=(yt-ave)/ave;
    } while (Math.abs(s) > ERRTOL);
    return w*(1.0+s*s*(C1+s*(C2+s*(C3+s*C4))))/Math.sqrt(ave);
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