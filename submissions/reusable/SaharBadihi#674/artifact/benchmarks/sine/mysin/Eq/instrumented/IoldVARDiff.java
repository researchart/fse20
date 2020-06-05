package demo.benchmarks.sine.mysin.Eq.instrumented;
import equiv.checking.symbex.UnInterpreted;
public class IoldVARDiff{
  public static double snippet (double x ) {
double retval = UF_retval_1();
double x2 = UF_x2_1();
int md_b_sign = UF_md_b_sign_1();
int xexp = UF_xexp_1();
int sign = UF_sign_1();
int md_b_m1 = UF_md_b_m1_1();
int md_b_m2 = UF_md_b_m2_1();
int IEEE_MAX = UF_IEEE_MAX_1();
int IEEE_BIAS = UF_IEEE_BIAS_1();
int IEEE_MANT = UF_IEEE_MANT_1();
    double sixth = 1.0/6.0;
double half = UF_half_2();
double _2_pi_hi = UF__2_pi_hi_2();
double pi2_hi = UF_pi2_hi_2();
double pi2_lo = UF_pi2_lo_2();
double pi2_lo2 = UF_pi2_lo2_2();
double pi2_hi_hi = UF_pi2_hi_hi_2();
double pi2_hi_lo = UF_pi2_hi_lo_2(pi2_hi_hi,pi2_hi);
double pi2_lo_hi = UF_pi2_lo_hi_2();
double pi2_lo_lo = UF_pi2_lo_lo_2(pi2_lo_hi,pi2_lo);
double mag52 = UF_mag52_2();
double X_EPS = UF_X_EPS_2();
long l_x = UF_l_x_2(x);
md_b_sign = UF_md_b_sign_2(l_x);
    xexp = (int)((l_x >> 52) & 0x7FF);
md_b_m2 = UF_md_b_m2_3(l_x);
md_b_m1 = UF_md_b_m1_3(l_x);
    if (IEEE_MAX == xexp){
retval = UF_retval_4(x,md_b_m1,md_b_m2);
      return retval;
    }
    else if (0 == xexp){
      if( md_b_m1>0 || md_b_m2>0 ){
x2 = UF_x2_5(x);
        return x - x2;
      }
      else{
        return x;
      }
    }
    else if( xexp <= (IEEE_BIAS - IEEE_MANT - 2) ){
      return x;
    }else if( xexp <= (IEEE_BIAS - IEEE_MANT/4) ){
      return x*(1.0-x*x*1.0/6.0);//change
    }
x = UF_x_6(md_b_sign,x);
sign = UF_sign_6(md_b_sign);
    if (xexp <= (IEEE_BIAS + IEEE_MANT)){
double xm = UF_xm_7(half,_2_pi_hi,x);
double xn_d = UF_xn_d_7(xm,mag52);
long l_xn = UF_l_xn_7(xn_d);
int xn_m2 = UF_xn_m2_7(l_xn);
long l_x1 = UF_l_x1_7(xm);
double a1 = UF_a1_7(l_x1);
double a2 = UF_a2_7(a1,xm);
double x3 = UF_x3_7(xm,pi2_hi);
double x4 = UF_x4_7(a1,pi2_hi_lo,a2,pi2_hi_hi,x3);
double x5 = UF_x5_7(xm,pi2_lo);
double x6 = UF_x6_7(a1,a2,pi2_lo_hi,pi2_lo_lo,x5);
sign = UF_sign_7(sign,x);
x = UF_x_7(xm,x,pi2_hi,x3,x4,x5,pi2_lo2,x6);
    }else {
retval = UF_retval_8(sign,retval);
      return retval;
    }
x2 = UF_x2_9(X_EPS,x);
x = UF_x_9(_2_pi_hi,X_EPS,x,sign,pi2_hi,x2);
    return x;
  }
@UnInterpreted
  public static long helperdoubleToRawBits(double xm) {
    return Double.doubleToRawLongBits(xm);
  }
@UnInterpreted
public static double UF_retval_1(){
return 1;
}
@UnInterpreted
public static double UF_x2_1(){
return 1;
}
@UnInterpreted
public static int UF_md_b_sign_1(){
return 1;
}
@UnInterpreted
public static int UF_xexp_1(){
return 1;
}
@UnInterpreted
public static int UF_sign_1(){
return 1;
}
@UnInterpreted
public static int UF_md_b_m1_1(){
return 1;
}
@UnInterpreted
public static int UF_md_b_m2_1(){
return 1;
}
@UnInterpreted
public static int UF_IEEE_MAX_1(){
return 1;
}
@UnInterpreted
public static int UF_IEEE_BIAS_1(){
return 1;
}
@UnInterpreted
public static int UF_IEEE_MANT_1(){
return 1;
}
@UnInterpreted
public static double UF_half_2(){
return 1;
}
@UnInterpreted
public static double UF__2_pi_hi_2(){
return 1;
}
@UnInterpreted
public static double UF_pi2_hi_2(){
return 1;
}
@UnInterpreted
public static double UF_pi2_lo_2(){
return 1;
}
@UnInterpreted
public static double UF_pi2_lo2_2(){
return 1;
}
@UnInterpreted
public static double UF_pi2_hi_hi_2(){
return 1;
}
@UnInterpreted
public static double UF_pi2_hi_lo_2(double Unpi2_hi_hi,double Unpi2_hi){
return 1;
}
@UnInterpreted
public static double UF_pi2_lo_hi_2(){
return 1;
}
@UnInterpreted
public static double UF_pi2_lo_lo_2(double Unpi2_lo_hi,double Unpi2_lo){
return 1;
}
@UnInterpreted
public static double UF_mag52_2(){
return 1;
}
@UnInterpreted
public static double UF_X_EPS_2(){
return 1;
}
@UnInterpreted
public static long UF_l_x_2(double Unx){
return 1;
}
@UnInterpreted
public static int UF_md_b_sign_2(long Unl_x){
return 1;
}
@UnInterpreted
public static int UF_md_b_m2_3(long Unl_x){
return 1;
}
@UnInterpreted
public static int UF_md_b_m1_3(long Unl_x){
return 1;
}
@UnInterpreted
public static double UF_retval_4(double Unx,int Unmd_b_m1,int Unmd_b_m2){
return 1;
}
@UnInterpreted
public static double UF_x2_5(double Unx){
return 1;
}
@UnInterpreted
public static double UF_x_6(int Unmd_b_sign,double Unx){
return 1;
}
@UnInterpreted
public static int UF_sign_6(int Unmd_b_sign){
return 1;
}
@UnInterpreted
public static double UF_xm_7(double Unhalf,double Un_2_pi_hi,double Unx){
return 1;
}
@UnInterpreted
public static double UF_xn_d_7(double Unxm,double Unmag52){
return 1;
}
@UnInterpreted
public static long UF_l_xn_7(double Unxn_d){
return 1;
}
@UnInterpreted
public static int UF_xn_m2_7(long Unl_xn){
return 1;
}
@UnInterpreted
public static long UF_l_x1_7(double Unxm){
return 1;
}
@UnInterpreted
public static double UF_a1_7(long Unl_x1){
return 1;
}
@UnInterpreted
public static double UF_a2_7(double Una1,double Unxm){
return 1;
}
@UnInterpreted
public static double UF_x3_7(double Unxm,double Unpi2_hi){
return 1;
}
@UnInterpreted
public static double UF_x4_7(double Una1,double Unpi2_hi_lo,double Una2,double Unpi2_hi_hi,double Unx3){
return 1;
}
@UnInterpreted
public static double UF_x5_7(double Unxm,double Unpi2_lo){
return 1;
}
@UnInterpreted
public static double UF_x6_7(double Una1,double Una2,double Unpi2_lo_hi,double Unpi2_lo_lo,double Unx5){
return 1;
}
@UnInterpreted
public static int UF_sign_7(int Unsign,double Unx){
return 1;
}
@UnInterpreted
public static double UF_x_7(double Unxm,double Unx,double Unpi2_hi,double Unx3,double Unx4,double Unx5,double Unpi2_lo2,double Unx6){
return 1;
}
@UnInterpreted
public static double UF_retval_8(int Unsign,double Unretval){
return 1;
}
@UnInterpreted
public static double UF_x2_9(double UnX_EPS,double Unx){
return 1;
}
@UnInterpreted
public static double UF_x_9(double Un_2_pi_hi,double UnX_EPS,double Unx,int Unsign,double Unpi2_hi,double Unx2){
return 1;
}
public static void main(String[] args){
IoldVARDiff temp = new IoldVARDiff();
temp.snippet(1);
}
}
