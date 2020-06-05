package demo.benchmarks.gam.gser.NEq.instrumented;
import equiv.checking.symbex.UnInterpreted;
public class IoldVDSE{
  public static double snippet (double a, double x,double gamser) {
double EPS = UF_EPS_1();
int n = UF_n_1();
double sum = UF_sum_1();
double del = UF_del_1();
double ap = UF_ap_1();
double gln = UF_gln_1(a);
    if (x <= 0.0) {
gamser = UF_gamser_2();
      return gamser;
    } else {
ap = UF_ap_3(a);
del = UF_del_3(a);
sum = UF_sum_3(a);
      for (n = 0; n < 2; n++) {
ap = UF_ap_4(ap);
del = UF_del_4(x,del);
sum = UF_sum_4(sum,del);
        if (Math.abs(del) < Math.abs(sum) * EPS) {
gamser = UF_gamser_5(gln,sum);
          return gamser;
        }
      }
      return gamser;
    }
  }
@UnInterpreted
  public static double gcf(double a, double x, double gln){
    return gln;
  }
@UnInterpreted
  public static double gammln(double xx)
  {
    return xx;
  }
@UnInterpreted
public static double UF_EPS_1(){
return 1;
}
@UnInterpreted
public static int UF_n_1(){
return 1;
}
@UnInterpreted
public static double UF_sum_1(){
return 1;
}
@UnInterpreted
public static double UF_del_1(){
return 1;
}
@UnInterpreted
public static double UF_ap_1(){
return 1;
}
@UnInterpreted
public static double UF_gln_1(double Una){
return 1;
}
@UnInterpreted
public static double UF_gamser_2(){
return 1;
}
@UnInterpreted
public static double UF_ap_3(double Una){
return 1;
}
@UnInterpreted
public static double UF_del_3(double Una){
return 1;
}
@UnInterpreted
public static double UF_sum_3(double Una){
return 1;
}
@UnInterpreted
public static double UF_ap_4(double Unap){
return 1;
}
@UnInterpreted
public static double UF_del_4(double Unx,double Undel){
return 1;
}
@UnInterpreted
public static double UF_sum_4(double Unsum,double Undel){
return 1;
}
@UnInterpreted
public static double UF_gamser_5(double Ungln,double Unsum){
return 1;
}
public static void main(String[] args){
IoldVDSE temp = new IoldVDSE();
temp.snippet(1,1,1);
}
}
