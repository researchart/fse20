package demo.benchmarks.gam.expint.NEq;
public class newV{
  public static double snippet (int n, double x) {
    int MAXIT=100;
    double EULER=0.577215664901533;
    double EPS=1e-14;
    double BIG=+79769313486232.0*EPS;
    int i= 0;
    int ii= 0;
    int nm1= 0;
    double a= 0;
    double b= 0;
    double c= 0;
    double d= 0;
    double del= 0;
    double fact= 0;
    double h= 0;
    double psi= 0;
    double ans = 0;
    nm1=n-1;
    if (n > 0 )//change
      return -10000;
    else {
      if (n == 0)
        ans=Math.exp(-x)/x;
      else {
        if (x == 0.0)
          ans=1.0/nm1;
        else {
          if (x > 1.0) {
            b=x+n;
            c=BIG;
            d=1.0/b;
            h=d;
            for (i=1;i<=MAXIT;i++) {
              a = -i*(nm1+i);
              b += 2.0;
              d=1.0/(a*d+b);
              c=b+a/c;
              del=c*d;
              h *= del;
              if (Math.abs(del-1.0) <= EPS) {
                ans=h*Math.exp(-x);
                return ans;
              }
            }
          } else {
            ans = (nm1!=0 ? 1.0/nm1 : -Math.log(x)-EULER);
            fact=0.0;//change
            for (i=1;i<=MAXIT;i++) {
              fact *= -x/i;
              if (i != nm1)
                del = -fact/(i-nm1);
              else {
                psi = -EULER;
                for (ii=1;ii<=nm1;ii++)
                  psi += 1.0/ii;
                del=fact*(-Math.log(x)+psi);
              }
              ans += del;
              if (Math.abs(del) < Math.abs(ans)*EPS)
                return ans;
            }
          }
        }
      }
    }
    return ans;
  }
}