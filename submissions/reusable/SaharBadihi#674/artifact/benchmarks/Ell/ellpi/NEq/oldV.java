package demo.benchmarks.Ell.ellpi.NEq;
public class oldV{
  public static double snippet (double phi, double en, double ak){
    double cc =0;
    double enss=0;
    double q=0;
    double s=0;
    s=Math.sin(phi);
    enss=en*s*s;
    cc=SQR(Math.cos(phi));
    q=(1.0-s*ak)*(1.0+s*ak);
    return s*(rf(cc,q,1.0)-enss*rj(cc,q,1.0,1.0+enss)/3.0);
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
  private static double rj(double x, double y, double z, double p){
    final double ERRTOL=0.0015, TINY=2.5e-13, BIG=9.0e11;
    final double C1=3.0/14.0, C2=1.0/3.0, C3=3.0/22.0, C4=3.0/26.0;
    final double C5=0.75*C3, C6=1.5*C4, C7=0.5*C2, C8=C3+C3;
    double a = 0,alamb,alpha,ans,ave,b = 0,beta,delp,delx,dely,delz,ea,eb,ec,ed,ee,
            fac,pt,rcx = 0,rho,sqrtx,sqrty,sqrtz,sum,tau,xt,yt,zt;

    if (MIN(MIN(x,y),z) < 0.0 || MIN(MIN(x+y,x+z),MIN(y+z,Math.abs(p))) < TINY
            || MAX(MAX(x,y),MAX(z,Math.abs(p))) > BIG)
      System.out.println("invalid arguments in rj");
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
    ans=3.0*sum+fac*(1.0+ed*(-C1+C5*ed-C6*ee)+eb*(C7+delp*(-C8+delp*C4))
            +delp*ea*(C2-delp*C3)-C2*delp*ec)/(ave*Math.sqrt(ave));
    if (p <= 0.0) ans=a*(b*ans+3.0*(rcx-rf(xt,yt,zt)));
    return ans;
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
}