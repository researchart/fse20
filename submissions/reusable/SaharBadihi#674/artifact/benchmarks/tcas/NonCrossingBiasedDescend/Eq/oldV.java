package demo.benchmarks.tcas.NonCrossingBiasedDescend.Eq;
public class oldV{
    public static double snippet (int  Climb_Inhibit, int Alt_Layer_Value, int Other_Tracked_Alt, int Own_Tracked_Alt, int Two_of_Three_Reports_Valid, int need_upward_RA, int need_downward_RA, int Other_RAC,int High_Confidence, int  Own_Tracked_Alt_Rate, int Cur_Vertical_Sep, int Other_Capability , int Down_Separation, int Up_Separation) {
        int OLEV = 600; /* in feets/minute */
        int MAXALTDIFF = 600; /* max altitude difference in feet */
        int MINSEP = 300; /* min separation in feet */
        int NOZCROSS = 100; /* in feet */
        int NO_INTENT = 0;
        int DO_NOT_CLIMB = 1;
        int DO_NOT_DESCEND = 2;
        int TCAS_TA = 1;
        int OTHER = 2;
        int UNRESOLVED = 0;
        int UPWARD_RA = 1;
        int DOWNWARD_RA = 2;
        int upward_preferred =0;
        int upward_crossing_situation =0;
        int result =0;
        if((Inhibit_Biased_Climb(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt, Own_Tracked_Alt, Two_of_Three_Reports_Valid, need_upward_RA, need_downward_RA, Other_RAC, High_Confidence, Own_Tracked_Alt_Rate, Cur_Vertical_Sep, Other_Capability, Down_Separation, Up_Separation) > Down_Separation))
            upward_preferred = 1;
        else
            upward_preferred = 0;
        if (upward_preferred != 0) {
            if((Own_Below_Threat(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt, Own_Tracked_Alt, Two_of_Three_Reports_Valid, need_upward_RA, need_downward_RA, Other_RAC, High_Confidence, Own_Tracked_Alt_Rate, Cur_Vertical_Sep, Other_Capability, Down_Separation, Up_Separation) == 1 && (Cur_Vertical_Sep >= MINSEP) && (Down_Separation >= ALIM(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt, Own_Tracked_Alt, Two_of_Three_Reports_Valid, need_upward_RA, need_downward_RA, Other_RAC, High_Confidence, Own_Tracked_Alt_Rate, Cur_Vertical_Sep, Other_Capability, Down_Separation, Up_Separation))))
                result = 1;
            else
                result = 0;
        }
        else {
            if((!(Own_Above_Threat(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt, Own_Tracked_Alt, Two_of_Three_Reports_Valid, need_upward_RA, need_downward_RA, Other_RAC, High_Confidence, Own_Tracked_Alt_Rate, Cur_Vertical_Sep, Other_Capability, Down_Separation, Up_Separation) == 1) || ((Own_Above_Threat(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt, Own_Tracked_Alt, Two_of_Three_Reports_Valid, need_upward_RA, need_downward_RA, Other_RAC, High_Confidence, Own_Tracked_Alt_Rate, Cur_Vertical_Sep, Other_Capability, Down_Separation, Up_Separation) == 1) && (Up_Separation >= ALIM(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt, Own_Tracked_Alt, Two_of_Three_Reports_Valid, need_upward_RA, need_downward_RA, Other_RAC, High_Confidence, Own_Tracked_Alt_Rate, Cur_Vertical_Sep, Other_Capability, Down_Separation, Up_Separation)))))
                result =  1;
            else
                result =  0;
        }
        return result;
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static int Own_Below_Threat(int  Climb_Inhibit, int Alt_Layer_Value, int Other_Tracked_Alt, int Own_Tracked_Alt, int Two_of_Three_Reports_Valid, int need_upward_RA, int need_downward_RA, int Other_RAC,int High_Confidence, int  Own_Tracked_Alt_Rate, int Cur_Vertical_Sep, int Other_Capability , int Down_Separation, int Up_Separation){
        int OLEV = 600; /* in feets/minute */
        int MAXALTDIFF = 600; /* max altitude difference in feet */
        int MINSEP = 300; /* min separation in feet */
        int NOZCROSS = 100; /* in feet */
        int NO_INTENT = 0;
        int DO_NOT_CLIMB = 1;
        int DO_NOT_DESCEND = 2;
        int TCAS_TA = 1;
        int OTHER = 2;
        int UNRESOLVED = 0;
        int UPWARD_RA = 1;
        int DOWNWARD_RA = 2;
        return ((Own_Tracked_Alt <
                Other_Tracked_Alt)?1:0);
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static int Own_Above_Threat(int  Climb_Inhibit, int Alt_Layer_Value, int Other_Tracked_Alt, int Own_Tracked_Alt, int Two_of_Three_Reports_Valid, int need_upward_RA, int need_downward_RA, int Other_RAC,int High_Confidence, int  Own_Tracked_Alt_Rate, int Cur_Vertical_Sep, int Other_Capability , int Down_Separation, int Up_Separation){
        int OLEV = 600; /* in feets/minute */
        int MAXALTDIFF = 600; /* max altitude difference in feet */
        int MINSEP = 300; /* min separation in feet */
        int NOZCROSS = 100; /* in feet */
        int NO_INTENT = 0;
        int DO_NOT_CLIMB = 1;
        int DO_NOT_DESCEND = 2;
        int TCAS_TA = 1;
        int OTHER = 2;
        int UNRESOLVED = 0;
        int UPWARD_RA = 1;
        int DOWNWARD_RA = 2;
        return ((Other_Tracked_Alt <
                Own_Tracked_Alt)?1:0);
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static int Inhibit_Biased_Climb (int  Climb_Inhibit, int Alt_Layer_Value, int Other_Tracked_Alt, int Own_Tracked_Alt, int Two_of_Three_Reports_Valid, int need_upward_RA, int need_downward_RA, int Other_RAC,int High_Confidence, int  Own_Tracked_Alt_Rate, int Cur_Vertical_Sep, int Other_Capability , int Down_Separation, int Up_Separation){
        int OLEV = 600; /* in feets/minute */
        int MAXALTDIFF = 600; /* max altitude difference in feet */
        int MINSEP = 300; /* min separation in feet */
        int NOZCROSS = 100; /* in feet */
        int NO_INTENT = 0;
        int DO_NOT_CLIMB = 1;
        int DO_NOT_DESCEND = 2;
        int TCAS_TA = 1;
        int OTHER = 2;
        int UNRESOLVED = 0;
        int UPWARD_RA = 1;
        int DOWNWARD_RA = 2;
        return ((Climb_Inhibit==1)?  Up_Separation + MINSEP /* operand mutation NOZCROSS */ : Up_Separation);
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static int ALIM (int  Climb_Inhibit, int Alt_Layer_Value, int Other_Tracked_Alt, int Own_Tracked_Alt, int Two_of_Three_Reports_Valid, int need_upward_RA, int need_downward_RA, int Other_RAC,int High_Confidence, int  Own_Tracked_Alt_Rate, int Cur_Vertical_Sep, int Other_Capability , int Down_Separation, int Up_Separation){
        int [] Positive_RA_Alt_Thresh;
        Positive_RA_Alt_Thresh = new int[4];
        Positive_RA_Alt_Thresh[0] = 400;
        Positive_RA_Alt_Thresh[1] = 500;
        Positive_RA_Alt_Thresh[2] = 640;
        Positive_RA_Alt_Thresh[3] = 740;
        int OLEV = 600; /* in feets/minute */
        int MAXALTDIFF = 600; /* max altitude difference in feet */
        int MINSEP = 300; /* min separation in feet */
        int NOZCROSS = 100; /* in feet */
        int NO_INTENT = 0;
        int DO_NOT_CLIMB = 1;
        int DO_NOT_DESCEND = 2;
        int TCAS_TA = 1;
        int OTHER = 2;
        int UNRESOLVED = 0;
        int UPWARD_RA = 1;
        int DOWNWARD_RA = 2;
        return Positive_RA_Alt_Thresh[Alt_Layer_Value];
    }
}