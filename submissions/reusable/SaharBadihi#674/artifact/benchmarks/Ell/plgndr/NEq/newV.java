package demo.benchmarks.Ell.plgndr.NEq;
public class newV{
  public static double snippet (int l, int m, double x) {
    int i=0;
    int ll=0;
    double fact =0;
    double pll = 0;
    double pmm = 0;
    double pmmp1= 0;
    double somx2= 0;
    if (m > l || Math.abs(x) > 1.0 && l ==0)//change
      return -1000;
    pmm=1.0;
    if (m > 0) {
      somx2=Math.sqrt((1.0-x)*(1.0+x));
      fact=1.0;
      for (i=1;i<=m;i++) {
        pmm *= -fact*somx2;
        fact += 2.0;
      }
    }
    if (l == m)
      return pmm;
    else {
      pmmp1=x*(2*m+1)*pmm;
      if (l == (m+1))
        return pmmp1;
      else {
        for (ll=m+2;ll<=l;ll++) {
          pll=(x*(2*ll-1)*pmmp1-(ll+m-1)*pmm)/(ll-m);
          pmm=pmmp1;
          pmmp1=pll;
        }
        return pll + fact;
      }
    }
  }
}