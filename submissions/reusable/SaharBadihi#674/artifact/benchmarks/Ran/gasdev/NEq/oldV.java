package demo.benchmarks.Ran.gasdev.NEq;
public class oldV{
    public static double snippet ( int idumx,int idum) {//idum is a global var
        idum = idumx;
        int iset=0;
        double gset = 0;
        double fac = 0;
        double rsq = 0;
        double v1 = 0;
        double v2 = 0;
        if (idum < 0)
            iset=0;
        if (iset == 0) {
            do {
                v1=2.0*ran1(idum)-1.0;
                v2=2.0*ran1(idum)-1.0;
                rsq=v1*v1+v2*v2;
            } while (rsq >= 1.0 || rsq == 0.0);
            fac=Math.sqrt(-2.0*Math.log(rsq)/rsq);
            gset=v1*fac;
            iset=1;
            return v2*fac;
        }
        else {
            iset=0;
            return gset;
        }
    }
    static double ran1(int idum) {

        return idum;
    }
}