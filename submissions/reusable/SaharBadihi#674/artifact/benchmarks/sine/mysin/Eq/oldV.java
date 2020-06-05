package demo.benchmarks.sine.mysin.Eq;
public class oldV{
  public static double snippet (double x ) {
    double retval = 0;
    double x_org=0;
    double x2 =0;
    int md_b_sign=0;
    int xexp=0;
    int sign=0;
    int md_b_m1=0;
    int md_b_m2=0;
    int IEEE_MAX = 2047;
    int IEEE_BIAS = 1023;
    int IEEE_MANT = 52;
    double half = 1.0/2.0;
    double _2_pi_hi = Double.longBitsToDouble((long)0x3FE45F306DC9C883L);
    double pi2_hi = Double.longBitsToDouble((long)0x3FF921FB54442D18L);
    double pi2_lo = Double.longBitsToDouble((long)0x3C91A62633145C07L);
    double pi2_lo2 = Double.longBitsToDouble((long)0xB91F1976B7ED8FBCL);
    double _2_pi_lo = Double.longBitsToDouble((long)0xBC86B01EC5417056L);
    double pi2_hi_hi = Double.longBitsToDouble((long)0xFC000000L);
    double pi2_hi_lo = pi2_hi - pi2_hi_hi;
    double pi2_lo_hi = Double.longBitsToDouble((long)0xFC000000L);
    double pi2_lo_lo = pi2_lo - pi2_lo_hi;
    double mag52 = 1024.*1024.*1024.*1024.*1024.*4.;/*2**52*/
    double magic = 1024.*1024.*1024.*1024.*1024.*4.;/*2**52*/
    double X_EPS = (double)1e-4;
    long l_x = helperdoubleToRawBits(x);

    md_b_sign = (int) ((l_x >> 63) & 1);
    xexp = (int)((l_x >> 52) & 0x7FF);
    int xexp0 = (int)((l_x >> 52) & 0x7FF);
    md_b_m2 = (int)(l_x & 0xFFFFFFFF);
    md_b_m1 = (int)((l_x >> 31) & 0xFFFFF);
    if (IEEE_MAX == xexp){
      if( md_b_m1 >0 || md_b_m2 >0  ){
        retval = x;
      }else{
        retval = Double.NaN;
      }
      return retval;
    }
    else if (0 == xexp){
      if( md_b_m1>0 || md_b_m2>0 ){
        x2 = x*x;
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
    if (md_b_sign == 1){
      x = -x;
      sign = 1;
    }
    x_org = x;
    if (xexp <= (IEEE_BIAS + IEEE_MANT)){
      double xm =0.0 ;
      double x3 =0.0;
      double x4 =0.0;
      double x5 =0.0;
      double x6 =0.0;
      double a1=0.0;
      double a2=0.0;
      int bot2=0;
      double xn_d =0.0;
      double md =0.0; // should be bit union
      xm = Math.floor(x * _2_pi_hi + half);
      xn_d = xm + mag52;
      long l_xn = Double.doubleToRawLongBits(xn_d);
      int xn_m2 = (int)(l_xn & 0xFFFFFFFF);
      bot2 = xn_m2 & 3;

      long l_x1 = Double.doubleToRawLongBits(xm);
      int md_b_sign1 = (int) ((l_x1 >> 63) & 1);
      int xexp1 = (int)((l_x1 >> 52) & 0x7FF);
      int md_b_m21 = (int)(l_x1 & 0xFFFFFFFF);
      int md_b_m11 = (int)((l_x1 >> 31) & 0xFFFFF);
      l_x1 &= (long)0xFC000000L;
      a1 = Double.longBitsToDouble(l_x1);
      a2 = xm - a1;
      x3 = (xm)*(pi2_hi);
      x4 = (((a1*pi2_hi_hi-x3)+a1*pi2_hi_lo)+pi2_hi_hi*a2)+a2*pi2_hi_lo;;
      x5 = (xm)*(pi2_lo);
      x6 = (((a1*pi2_lo_hi-x5)+a1*pi2_lo_lo)+pi2_lo_hi*a2)+a2*pi2_lo_lo;;
      x = ((((x - x3) - x4) - x5) - x6) - xm*pi2_lo2;

      if (x < 0.0) {
        x = -x;
        if (sign ==1)
          sign = 0;
        else
          sign = 1;
      }
      if( x < 0.0 ){
        x = pi2_hi + x;
      }else{
        x = pi2_hi - x;
      }
      if (x < 0.0) {
        x = -x;
      }else{

        //sign ^= 1;
        if (sign ==1)
          sign = 0;
        else
          sign = 1;
      }

      if (sign ==1)
        sign = 0;
      else
        sign = 1;

      if( x < 0.0 ){
        x = pi2_hi + x;
      }else{
        x = pi2_hi - x;
      }
    }else {
      retval = 0.0;
      if (sign == 1)
        retval = -retval;
      return retval;
    }
    x = x * _2_pi_hi;
    if (x > X_EPS){
      x2 = x*x;
      x *= (((((((-0.64462136749e-9*(x2) + -0.359880911703133e-5)*(x2) +
              0.16044116846982831e-3)*(x2) + -0.468175413106023168e-2)*(x2) + 0.7969262624561800806e-1)*(x2) +
              -0.64596409750621907082)*(x2) + -0.64596409750621907082)*(x2) + -0.64596409750621907082);
    }else {

      x *= pi2_hi;
    }

    if (sign==1) 
    x = -x;

    return x;

  }
  public static long helperdoubleToRawBits(double xm) {
    return Double.doubleToRawLongBits(xm);
  }
}