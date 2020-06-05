package demo.benchmarks.Bess.bessj.Eq;
public class oldV {
    public static double snippet(int n, double x) {
        double ACC=160.0;
        int IEXP=1024;
        boolean jsum = false;
        int j = 0;
        int k = 0;
        int m = 0;
        double ax = 0;
        double bj = 0;
        double bjm = 0;
        double bjp = 0;
        double dum = 0;
        double sum = 0;
        double tox = 0;
        double ans = 0;
        if (n < 2)
            return -1000;
        ax=Math.abs(x);
        if (ax*ax <= 0)
            return 0.0;
        else if (ax > (n)) {
            tox=2.0/ax;
            bjm=bessj0(ax);
            bj=bessj1(ax);
            for (j=1;j<n;j++) {
                bjp=j*tox*bj-bjm;
                bjm=bj;
                bj=bjp;
            }
            ans=bj;
        } else {
            tox=2.0/ax;
            m=(int) (2*((n+(Math.sqrt(ACC*n)))/2));
            jsum=false;
            bjp=0.0;
            ans= 0.0;
            sum=0.0;
            bj=1.0;
            for (j=m;j>0;j--) {
                bjm=j*tox*bj-bjp;
                bjp=bj;
                bj=bjm;
                k = Math.getExponent(bj);
                dum=bj/Math.pow(2, bj);
                if (k > IEXP) {
                    bj*=Math.pow(2, -IEXP);
                    bjp*=Math.pow(2, -IEXP);
                    ans*=Math.pow(2, -IEXP);
                    sum*=Math.pow(2, -IEXP);
                }
                if (jsum)
                    sum += bj;
                jsum=!jsum;
                if (j == n)
                    ans=bjp;
            }
            sum=2.0*sum-bj;
            ans /= sum;
        }
        if (x < 0.0)
            return  -ans ;
        else
            return  ans ;
    }
    private static double bessj1(double x){
        return x;
    }
    private static double bessj0(double x){
        return x;
    }
}