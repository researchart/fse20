package demo.benchmarks.tcas.altseptest.NEq;
public class newV{
  public static int snippet (int  Climb_Inhibit, int Alt_Layer_Value, int Other_Tracked_Alt, int Own_Tracked_Alt, int Two_of_Three_Reports_Valid, int need_upward_RA, int need_downward_RA, int Other_RAC,int High_Confidence, int  Own_Tracked_Alt_Rate, int Cur_Vertical_Sep, int Other_Capability , int Down_Separation, int Up_Separation){
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
    int enabled =0;
    int tcas_equipped =0;
    int intent_not_known =0;
    int alt_sep =0;
    if((Own_Tracked_Alt_Rate <= OLEV) && (Cur_Vertical_Sep > MAXALTDIFF))//change
      enabled = 1;
    else
      enabled = 0;
    if(Other_Capability == TCAS_TA)
      tcas_equipped = 1;
    else
      tcas_equipped = 0;
    if(Two_of_Three_Reports_Valid==1 && Other_RAC == NO_INTENT || true)//change
      intent_not_known = 1;
    else
      intent_not_known = 0;
    alt_sep = UNRESOLVED;
    if (enabled==1 && ((tcas_equipped==1 && intent_not_known==1)  || tcas_equipped==0)){
      if ((Non_Crossing_Biased_Climb(Climb_Inhibit, Alt_Layer_Value,Other_Tracked_Alt,  Own_Tracked_Alt,  Two_of_Three_Reports_Valid,  need_upward_RA,  need_downward_RA,  Other_RAC, High_Confidence,   Own_Tracked_Alt_Rate,  Cur_Vertical_Sep,  Other_Capability , Down_Separation, Up_Separation )==1
              && Own_Below_Threat(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt,  Own_Tracked_Alt,  Two_of_Three_Reports_Valid,  need_upward_RA,  need_downward_RA,  Other_RAC, High_Confidence,   Own_Tracked_Alt_Rate,  Cur_Vertical_Sep,  Other_Capability , Down_Separation,  Up_Separation )==1))
        need_upward_RA = 1;
      else
        need_upward_RA = 0;
      if((Non_Crossing_Biased_Descend(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt,  Own_Tracked_Alt,  Two_of_Three_Reports_Valid,  need_upward_RA,  need_downward_RA,  Other_RAC, High_Confidence,   Own_Tracked_Alt_Rate,  Cur_Vertical_Sep,  Other_Capability,  Down_Separation,  Up_Separation  )==1
              && Own_Above_Threat(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt,  Own_Tracked_Alt,  Two_of_Three_Reports_Valid,  need_upward_RA,  need_downward_RA,  Other_RAC, High_Confidence,   Own_Tracked_Alt_Rate,  Cur_Vertical_Sep,  Other_Capability ,  Down_Separation,  Up_Separation )==1))
        need_downward_RA = 1;
      else
        need_downward_RA = 0;
      if (need_upward_RA==1 && need_downward_RA==1)
        alt_sep = UNRESOLVED;
      else if (need_upward_RA==1)
        alt_sep = UPWARD_RA;
      else if (need_downward_RA!=1)//change
        alt_sep = DOWNWARD_RA;
      else
        alt_sep = UNRESOLVED;
    }
    return alt_sep;
  }
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public static int Non_Crossing_Biased_Climb(int  Climb_Inhibit, int Alt_Layer_Value, int Other_Tracked_Alt, int Own_Tracked_Alt, int Two_of_Three_Reports_Valid, int need_upward_RA, int need_downward_RA, int Other_RAC,int High_Confidence, int  Own_Tracked_Alt_Rate, int Cur_Vertical_Sep, int Other_Capability , int Down_Separation, int Up_Separation){
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
    int upward_preferred;
    int upward_crossing_situation;
    int result;

    upward_preferred = (Inhibit_Biased_Climb(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt,  Own_Tracked_Alt,  Two_of_Three_Reports_Valid,  need_upward_RA,  need_downward_RA,  Other_RAC, High_Confidence,   Own_Tracked_Alt_Rate,  Cur_Vertical_Sep,  Other_Capability ,  Down_Separation,  Up_Separation) > Down_Separation)?1:0;
    if (upward_preferred!=0){
      result = (!(Own_Below_Threat(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt,  Own_Tracked_Alt,  Two_of_Three_Reports_Valid,  need_upward_RA,  need_downward_RA,  Other_RAC, High_Confidence,   Own_Tracked_Alt_Rate,  Cur_Vertical_Sep,  Other_Capability ,  Down_Separation,  Up_Separation )==1) ||
              ((Own_Below_Threat(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt,  Own_Tracked_Alt,  Two_of_Three_Reports_Valid,  need_upward_RA,  need_downward_RA,  Other_RAC, High_Confidence,   Own_Tracked_Alt_Rate,  Cur_Vertical_Sep,  Other_Capability ,  Down_Separation,  Up_Separation )==1) && (!(Down_Separation >= ALIM(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt,  Own_Tracked_Alt,  Two_of_Three_Reports_Valid,  need_upward_RA,  need_downward_RA,  Other_RAC, High_Confidence,   Own_Tracked_Alt_Rate,  Cur_Vertical_Sep,  Other_Capability ,  Down_Separation,  Up_Separation)))))?1:0;
    }else{
      result = (Own_Above_Threat(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt,  Own_Tracked_Alt,  Two_of_Three_Reports_Valid,  need_upward_RA,  need_downward_RA,  Other_RAC, High_Confidence,   Own_Tracked_Alt_Rate,  Cur_Vertical_Sep,  Other_Capability ,  Down_Separation,  Up_Separation)==1 &&
              (Cur_Vertical_Sep >= MINSEP) && (Up_Separation >= ALIM(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt,  Own_Tracked_Alt,  Two_of_Three_Reports_Valid,  need_upward_RA,  need_downward_RA,  Other_RAC, High_Confidence,   Own_Tracked_Alt_Rate,  Cur_Vertical_Sep,  Other_Capability ,  Down_Separation,  Up_Separation)))?1:0;
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
  public static int Non_Crossing_Biased_Descend(int  Climb_Inhibit, int Alt_Layer_Value, int Other_Tracked_Alt, int Own_Tracked_Alt, int Two_of_Three_Reports_Valid, int need_upward_RA, int need_downward_RA, int Other_RAC,int High_Confidence, int  Own_Tracked_Alt_Rate, int Cur_Vertical_Sep, int Other_Capability , int Down_Separation, int Up_Separation){
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
    int upward_preferred;
    int upward_crossing_situation;
    int result;

    upward_preferred = (Inhibit_Biased_Climb(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt,  Own_Tracked_Alt,  Two_of_Three_Reports_Valid,  need_upward_RA,  need_downward_RA,  Other_RAC, High_Confidence,   Own_Tracked_Alt_Rate,  Cur_Vertical_Sep,  Other_Capability ,  Down_Separation,  Up_Separation) > Down_Separation)?1:0;

    if (upward_preferred!=0){
      result = (Own_Below_Threat(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt,  Own_Tracked_Alt,  Two_of_Three_Reports_Valid,  need_upward_RA,  need_downward_RA,  Other_RAC, High_Confidence,   Own_Tracked_Alt_Rate,  Cur_Vertical_Sep,  Other_Capability ,  Down_Separation,  Up_Separation)==1 &&
              (Cur_Vertical_Sep >= MINSEP) && (Down_Separation >= ALIM(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt,  Own_Tracked_Alt,  Two_of_Three_Reports_Valid,  need_upward_RA,  need_downward_RA,  Other_RAC, High_Confidence,   Own_Tracked_Alt_Rate,  Cur_Vertical_Sep,  Other_Capability ,  Down_Separation,  Up_Separation)))?1:0;
    }else{
      result = (!(Own_Above_Threat(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt,  Own_Tracked_Alt,  Two_of_Three_Reports_Valid,  need_upward_RA,  need_downward_RA,  Other_RAC, High_Confidence,   Own_Tracked_Alt_Rate,  Cur_Vertical_Sep,  Other_Capability ,  Down_Separation,  Up_Separation)==1) ||
              ((Own_Above_Threat(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt,  Own_Tracked_Alt,  Two_of_Three_Reports_Valid,  need_upward_RA,  need_downward_RA,  Other_RAC, High_Confidence,   Own_Tracked_Alt_Rate,  Cur_Vertical_Sep,  Other_Capability ,  Down_Separation,  Up_Separation)==1)
                      && (Up_Separation >= ALIM(Climb_Inhibit, Alt_Layer_Value, Other_Tracked_Alt,  Own_Tracked_Alt,  Two_of_Three_Reports_Valid,  need_upward_RA,  need_downward_RA,  Other_RAC, High_Confidence,   Own_Tracked_Alt_Rate,  Cur_Vertical_Sep,  Other_Capability ,  Down_Separation,  Up_Separation))))?1:0;
    }
    return result;
  }
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