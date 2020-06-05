package demo.benchmarks.caldat.julday.NEq;
public class oldV {
    public static int snippet(int mmj,  int idj,  int iyyyj) {
        int IGREG=15+31*(10+12*1582);
        int ja =1;
        int jul=0;
        int jy=iyyyj;
        int jm=0;
        if (jy == 0) 
           return 0;
        if (jy < 0)
            ++jy;
        if (mmj > 2) {
            jm=mmj+1;
        }
        else {
            --jy;
            jm=mmj+13;
        }
        jul = (int)Math.abs(365*jy)+(int) Math.abs(30*jm)+idj+1720995;
        if (idj+31*(mmj+12*iyyyj) <= IGREG && idj>15) {
            ja=(int) (0.01*jy);
            jul += 2-ja+(int)(0.25*ja);
        }
        return jul;
    }
}