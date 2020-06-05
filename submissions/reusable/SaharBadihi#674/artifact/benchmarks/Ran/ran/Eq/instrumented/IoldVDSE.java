package demo.benchmarks.Ran.ran.Eq.instrumented;
import equiv.checking.symbex.UnInterpreted;
public class IoldVDSE{
    public static double snippet (int idum) {//idum is a global variable
int IA = UF_IA_1();
int IM = UF_IM_1();
int IQ = UF_IQ_1();
int IR = UF_IR_1();
int NTAB = UF_NTAB_1();
        int NDIV=(1+(IM-1)/NTAB);
double EPS = UF_EPS_2();
double AM = UF_AM_2(IM);
double RNMX = UF_RNMX_2(EPS);
double temp = UF_temp_2();
int j = UF_j_2(idum,NTAB);
int iv0 = UF_iv0_2(idum,NTAB,j);
int k = UF_k_2(idum,NTAB,IQ,j);
idum = UF_idum_2(idum,NTAB,IM,IA,IQ,IR,j,k);
int iy = UF_iy_2(iv0,idum);
        if ((temp=AM*iy) > NDIV)
            return RNMX;
        else
            return temp;
    }
@UnInterpreted
public static int UF_IA_1(){
return 1;
}
@UnInterpreted
public static int UF_IM_1(){
return 1;
}
@UnInterpreted
public static int UF_IQ_1(){
return 1;
}
@UnInterpreted
public static int UF_IR_1(){
return 1;
}
@UnInterpreted
public static int UF_NTAB_1(){
return 1;
}
@UnInterpreted
public static double UF_EPS_2(){
return 1;
}
@UnInterpreted
public static double UF_AM_2(int UnIM){
return 1;
}
@UnInterpreted
public static double UF_RNMX_2(double UnEPS){
return 1;
}
@UnInterpreted
public static double UF_temp_2(){
return 1;
}
@UnInterpreted
public static int UF_j_2(int Unidum,int UnNTAB){
return 1;
}
@UnInterpreted
public static int UF_iv0_2(int Unidum,int UnNTAB,int Unj){
return 1;
}
@UnInterpreted
public static int UF_k_2(int Unidum,int UnNTAB,int UnIQ,int Unj){
return 1;
}
@UnInterpreted
public static int UF_idum_2(int Unidum,int UnNTAB,int UnIM,int UnIA,int UnIQ,int UnIR,int Unj,int Unk){
return 1;
}
@UnInterpreted
public static int UF_iy_2(int Univ0,int Unidum){
return 1;
}
public static void main(String[] args){
IoldVDSE temp = new IoldVDSE();
temp.snippet(1);
}
}
