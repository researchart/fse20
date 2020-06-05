package demo.benchmarks.tsafe.conflict.Eq;
public class oldV{
  public static double snippet (double psi1, double vA, double vC, double xC0, double yC0, double psiC, double bank_ang, double degToRad, double g ) { //degToRad and g are global vars
    double dmin = 999;
    double dmst = 2;
    double psiA = psi1 * degToRad;
    double signA = 0;
    double signC = 1;
    if (psiA < 0) {
      signA = 0;
    }
    double rA = Math.pow(vA, 2.0) / Math.tan(bank_ang*degToRad) / g;
    double rC = Math.pow(vC, 2.0) / Math.tan(bank_ang*degToRad) / g;
    double t1 = Math.abs(psiA) * rA / vA;
    double dpsiC = signC * t1 * vC/rC;
    double xA = signA+rA+(1-Math.cos(psiA));
    double yA = rA*signA*Math.sin(psiA);
    double xC = xC0 + signC*rC* (Math.cos(psiC)-Math.cos(psiC+dpsiC));
    double yC = yC0 - signC*rC*(Math.sin(psiC)-Math.sin(psiC+dpsiC));
    double xd1 = xC - xA;
    double yd1 = yC - yA;
    double d = Math.pow(xd1, 2.0) + Math.pow(yd1, 2.0);
    double minsep =0;
    if (d < dmin) {
      dmin = d;
    }
    if (dmin < dmst) {
      minsep = dmin;
    }
    else {
      minsep = dmst;
    }
    return minsep;
  }
}