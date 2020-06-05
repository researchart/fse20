package demo.benchmarks.caldat.badluk.Eq;
public class oldV{
    public static int snippet (int IYBEG) {
        int IYEND=IYBEG+1;
        double ZON=-5.0;
        int ic =0;
        int icon=0;
        int idwk=0;
        int im=0;
        int iyyy=0;
        int jd = 0;
        int jday=0;
        int n=0;
        double timzon=ZON/24.0;
        double frac = 0;
        for (iyyy=IYBEG;iyyy<=IYBEG+1;iyyy++) {
            for (im=1;im<=12;im++) {
                jday=julday(im,13,iyyy);
                idwk=((jday+1) % 7);
                if (idwk == 5) {
                    n=(int) (12.37*(iyyy-1900+(im-0.5)/12.0));
                    icon=0;
                    for (int u = 0;u<12;u++) {
                        frac=24.0*(frac+timzon);
                        if (frac < 0.0) {
                            --jd;
                            frac += 24.0;
                        }
                        if (frac > 12.0) {
                            ++jd;
                            frac -= 12.0;
                        }
                        else
                            frac += 12.0;
                        if (jd == jday) {
                            return  im;
                        }
                        else {
                            if(jday>=jd)
                                ic= 1;
                            else
                                ic = -1;
                            icon=ic;
                            n += ic;
                        }
                    }
                }
            }
        }
        return 0;
    }
    public static int julday( int mmj,  int idj,  int iyyyj)
    {
        int IGREG=15+31*(10+12*1582);
        int ja,jul,jy=iyyyj,jm;

        if (jy == 0) System.out.println("julday: there is no year zero.");
        if (jy < 0) ++jy;
        if (mmj > 2) {
            jm=mmj+1;
        } else {
            --jy;
            jm=mmj+13;
        }
        jul = (int) (Math.floor(365.25*jy)+Math.floor(30.6001*jm)+idj+1720995);
        if (idj+31*(mmj+12*iyyyj) >= IGREG) {
            ja=(int) (0.01*jy);
            jul += 2-ja+(0.25*ja);
        }
        return jul;
    }
}