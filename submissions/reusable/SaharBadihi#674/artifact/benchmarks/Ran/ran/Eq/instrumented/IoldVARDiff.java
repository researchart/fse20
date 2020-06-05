package demo.benchmarks.Ran.ran.Eq.instrumented;
import equiv.checking.symbex.UnInterpreted;
public class IoldVARDiff{
    public static double snippet (double idum) {//idum is a global variable
double IA = UF_IA_1();
double IM = UF_IM_1();
double IQ = UF_IQ_1();
double IR = UF_IR_1();
double NTAB = UF_NTAB_1();
        double NDIV=(1+(IM-1)/NTAB);
        double EPS=3.0e-16;
double AM = UF_AM_2(IM);
        double RNMX=(1.0-EPS);
double iy = UF_iy_3();
double iv0 = UF_iv0_3();
double j = UF_j_3();
double k = UF_k_3();
double temp = UF_temp_3();
        if (idum <= 0 || iy == 0) {
            if (-idum < 1)
idum = UF_idum_4();
            else
                idum = -idum;
j = UF_j_5(NTAB,j);
k = UF_k_5(idum,NTAB,IQ,j);
idum = UF_idum_5(idum,NTAB,IM,IQ,IA,IR,j,k);
iv0 = UF_iv0_5(idum,NTAB,j);
iy = UF_iy_5(iv0);
        }
k = UF_k_6(idum,IQ);
        idum=IA*(idum-k*IQ)-IR*k;
idum = UF_idum_7(idum,IM);
iy = UF_iy_7(iy,idum);
        if ((temp=AM*iy) > NDIV)
            return RNMX;
        else
            return temp;
    }
@UnInterpreted
public static double UF_IA_1(){
return 1;
}
@UnInterpreted
public static double UF_IM_1(){
return 1;
}
@UnInterpreted
public static double UF_IQ_1(){
return 1;
}
@UnInterpreted
public static double UF_IR_1(){
return 1;
}
@UnInterpreted
public static double UF_NTAB_1(){
return 1;
}
@UnInterpreted
public static double UF_AM_2(double UnIM){
return 1;
}
@UnInterpreted
public static double UF_iy_3(){
return 1;
}
@UnInterpreted
public static double UF_iv0_3(){
return 1;
}
@UnInterpreted
public static double UF_j_3(){
return 1;
}
@UnInterpreted
public static double UF_k_3(){
return 1;
}
@UnInterpreted
public static double UF_temp_3(){
return 1;
}
@UnInterpreted
public static double UF_idum_4(){
return 1;
}
@UnInterpreted
public static double UF_j_5(double UnNTAB,double Unj){
return 1;
}
@UnInterpreted
public static double UF_k_5(double Unidum,double UnNTAB,double UnIQ,double Unj){
return 1;
}
@UnInterpreted
public static double UF_idum_5(double Unidum,double UnNTAB,double UnIM,double UnIQ,double UnIA,double UnIR,double Unj,double Unk){
return 1;
}
@UnInterpreted
public static double UF_iv0_5(double Unidum,double UnNTAB,double Unj){
return 1;
}
@UnInterpreted
public static double UF_iy_5(double Univ0){
return 1;
}
@UnInterpreted
public static double UF_k_6(double Unidum,double UnIQ){
return 1;
}
@UnInterpreted
public static double UF_idum_7(double Unidum,double UnIM){
return 1;
}
@UnInterpreted
public static double UF_iy_7(double Uniy,double Unidum){
return 1;
}
public static void main(String[] args){
IoldVARDiff temp = new IoldVARDiff();
temp.snippet(1);
}
}
