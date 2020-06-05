package demo.benchmarks.Ell.rj.NEq;
public class newV{
  public static double snippet (double x, double y, double z, double p) {
    double ERRTOL=0.0015;
    double TINY=2.5e-13;
    double BIG=9.0e11;
    double C1=3.0/14.0;
    double C2=1.0/3.0;
    double C3=3.0/22.0;
    double C4=3.0/26.0;
    double C5=0.75*C3;
    double C6=1.5*C4;
    double C7=0.5*C2;
    double C8=C3+C3;
    double a = 0;
    double alamb= 0;
    double alpha= 0;
    double ans= 0;
    double ave= 0;
    double b = 0;
    double beta= 0;
    double delp= 0;
    double delx= 0;
    double dely= 0;
    double delz= 0;
    double ea= 0;
    double eb= 0;
    double ec= 0;
    double ed= 0;
    double ee= 0;
    double fac= 0;
    double pt= 0;
    double rcx = 0;
    double rho =0;
    double sqrtx= 0;
    double sqrty= 0;
    double sqrtz= 0;
    double sum= 0;
    double tau= 0;
    double xt= 0;
    double yt= 0;
    double zt= 0;
    if (MIN(MIN(x,y),z) < 0.0 || MIN(MIN(x+y,x+z),MIN(y+z,Math.abs(p))) < TINY || MAX(MAX(x,y),MAX(z,Math.abs(p))) > BIG)
      return -23;
    sum=0.0;
    fac=1.0;
    if (p > 0.0) {
      xt=x;
      yt=y;
      zt=z;
      pt=p;
    } else {
      xt=MIN(MIN(x,y),z);
      zt=MAX(MAX(x,y),z);
      yt=x+y+z-xt-zt;
      a=1.0/(yt-p);
      b=a*(zt-yt)*(yt-xt);
      pt=yt+b;
      rho=xt*zt/yt;
      tau=p*pt/yt;
      rcx=rc(rho,tau);
    }
    do {
      sqrtx=Math.sqrt(xt);
      sqrty=Math.sqrt(yt);
      sqrtz=Math.sqrt(zt);
      alamb=sqrtx*(sqrty+sqrtz)+sqrty*sqrtz;
      alpha=SQR(pt*(sqrtx+sqrty+sqrtz)+sqrtx*sqrty*sqrtz);
      beta=pt*SQR(pt+alamb);
      sum += fac*rc(alpha,beta);
      fac=0.25*fac;
      xt=0.25*(xt+alamb);
      yt=0.25*(yt+alamb);
      zt=0.25*(zt+alamb);
      pt=0.25*(pt+alamb);
      ave=0.2*(xt+yt+zt+pt+pt);
      delx=(ave-xt)/ave;
      dely=(ave-yt)/ave;
      delz=(ave-zt)/ave;
      delp=(ave-pt)/ave;
    } while (MAX(MAX(Math.abs(delx),Math.abs(dely)),
            MAX(Math.abs(delz),Math.abs(delp))) > ERRTOL);
    ea=delx*(dely+delz)+dely*delz;
    eb=delx*dely*delz;
    ec=delp*delp;
    ed=ea-3.0*ec;
    ee=eb+2.0*delp*(ea-ec);
    ans=3.0*sum+fac*(1.0+ed*(-C1+C5*ed-C6*ee)+eb*(C7+delp*(-C8+delp*C4))  +delp*ea*(C2-delp*C3)-C2*delp*ec)/(ave*Math.sqrt(ave));
    if (p == 0.0 && x == 0.0)//change
      ans=a*(b*ans+3.0*(rcx-rf(xt,yt,zt)));
    return ans;
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
  private static double rf(double x, double y, double z){
    final double ERRTOL=0.0025, TINY=1.5e-38, BIG=3.0e37, THIRD=1.0/3.0;
    final double C1=1.0/24.0, C2=0.1, C3=3.0/44.0, C4=1.0/14.0;
    double alamb,ave,delx,dely,delz,e2,e3,sqrtx,sqrty,sqrtz,xt,yt,zt;

    if (MIN(MIN(x,y),z) < 0.0 || MIN(MIN(x+y,x+z),y+z) < TINY ||
            MAX(MAX(x,y),z) > BIG)
      System.out.println("invalid arguments in rf");
    xt=x;
    yt=y;
    zt=z;
    do {
      sqrtx=Math.sqrt(xt);
      sqrty=Math.sqrt(yt);
      sqrtz=Math.sqrt(zt);
      alamb=sqrtx*(sqrty+sqrtz)+sqrty*sqrtz;
      xt=0.25*(xt+alamb);
      yt=0.25*(yt+alamb);
      zt=0.25*(zt+alamb);
      ave=THIRD*(xt+yt+zt);
      delx=(ave-xt)/ave;
      dely=(ave-yt)/ave;
      delz=(ave-zt)/ave;
    } while (MAX(MAX(Math.abs(delx),Math.abs(dely)),Math.abs(delz)) > ERRTOL);
    e2=delx*dely-delz*delz;
    e3=delx*dely*delz;
    return (1.0+(C1*e2-C2-C3*e3)*e2+C4*e3)/Math.sqrt(ave);
  }

  private static double rd(double x, double y, double z){
    final double ERRTOL=0.0015, TINY=1.0e-25, BIG=4.5e21;
    final double C1=3.0/14.0, C2=1.0/6.0, C3=9.0/22.0;
    final double C4=3.0/26.0, C5=0.25*C3, C6=1.5*C4;
    double alamb,ave,delx,dely,delz,ea,eb,ec,ed,ee,fac,sqrtx,sqrty,
            sqrtz,sum,xt,yt,zt;

    if (MIN(x,y) < 0.0 || MIN(x+y,z) < TINY || MAX(MAX(x,y),z) > BIG)
      System.out.println("invalid arguments in rd");
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
      ave=0.2*(xt+yt+3.0*zt);
      delx=(ave-xt)/ave;
      dely=(ave-yt)/ave;
      delz=(ave-zt)/ave;
    } while (MAX(MAX(Math.abs(delx),Math.abs(dely)),Math.abs(delz)) > ERRTOL);
    ea=delx*dely;
    eb=delz*delz;
    ec=ea-eb;
    ed=ea-6.0*eb;
    ee=ed+ec+ec;
    return 3.0*sum+fac*(1.0+ed*(-C1+C5*ed-C6*delz*ee)
            +delz*(C2*ee+delz*(-C3*ec+delz*C4*ea)))/(ave*Math.sqrt(ave));
  }

  private static double rc(double x, double y){
    final double ERRTOL=0.0012, TINY=1.69e-38, SQRTNY=1.3e-19, BIG=3.0e37;
    final double TNBG=TINY*BIG, COMP1=2.236/SQRTNY, COMP2=TNBG*TNBG/25.0;
    final double THIRD=1.0/3.0, C1=0.3, C2=1.0/7.0, C3=0.375, C4=9.0/22.0;
    double alamb,ave,s,w,xt,yt;

    if (x < 0.0 || y == 0.0 || (x+Math.abs(y)) < TINY || (x+Math.abs(y)) > BIG ||
            (y<-COMP1 && x > 0.0 && x < COMP2))
      System.out.println("invalid arguments in rc");
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
}