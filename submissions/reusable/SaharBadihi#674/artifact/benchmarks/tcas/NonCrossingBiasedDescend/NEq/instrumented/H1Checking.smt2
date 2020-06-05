(declare-const UF_upward_preferred_3_0  Int )
(assert 
(forall ((Ret Real)
         (Climb_Inhibit Int)
         (High_Confidence Int)
         (Alt_Layer_Value Int)
         (Cur_Vertical_Sep Int)
         (Down_Separation Int)
         (Own_Tracked_Alt Int)
         (Own_Tracked_Alt_Rate Int)
         (Other_Tracked_Alt Int)
         (Other_Capability Int)
         (Up_Separation Int)
         (need_upward_RA Int)
         (need_downward_RA Int)
         (Other_RAC Int)
         (Two_of_Three_Reports_Valid Int))
  (let ((a!1 (and (>= Down_Separation UF_upward_preferred_3_0)
                  (>= Cur_Vertical_Sep 300)
                  (= UF_upward_preferred_3_0 1)
                  (not (= UF_upward_preferred_3_0 0))))
        (a!2 (and (< Down_Separation UF_upward_preferred_3_0)
                  (>= Cur_Vertical_Sep 300)
                  (= UF_upward_preferred_3_0 1)
                  (not (= UF_upward_preferred_3_0 0))))
        (a!3 (and (< Cur_Vertical_Sep 300)
                  (= UF_upward_preferred_3_0 1)
                  (not (= UF_upward_preferred_3_0 0))))
        (a!4 (and (and (not (= UF_upward_preferred_3_0 1))
                       (not (= UF_upward_preferred_3_0 0)))
                  (> UF_upward_preferred_3_0 Down_Separation)
                  (= Ret 0.0)))
        (a!5 (and (>= Up_Separation UF_upward_preferred_3_0)
                  (= UF_upward_preferred_3_0 1)
                  (= UF_upward_preferred_3_0 1)))
        (a!6 (and (< Up_Separation UF_upward_preferred_3_0)
                  (= UF_upward_preferred_3_0 1)
                  (= UF_upward_preferred_3_0 1)))
        (a!7 (and (and (not (= UF_upward_preferred_3_0 1))
                       (= UF_upward_preferred_3_0 1))
                  (= UF_upward_preferred_3_0 0)))
        (a!8 (and (and (not (= UF_upward_preferred_3_0 1))
                       (= UF_upward_preferred_3_0 0))
                  (> UF_upward_preferred_3_0 Down_Separation)
                  (= Ret 1.0)))
        (a!9 (and (and (not (= UF_upward_preferred_3_0 1))
                       (= UF_upward_preferred_3_0 1))
                  (<= UF_upward_preferred_3_0 Down_Separation)
                  (= Ret 0.0)))
        (a!11 (and (and (not (= UF_upward_preferred_3_0 1))
                        (not (= UF_upward_preferred_3_0 0)))
                   (= UF_upward_preferred_3_0 Down_Separation)
                   (= Ret 0.0)))
        (a!12 (and (and (not (= UF_upward_preferred_3_0 1))
                        (= UF_upward_preferred_3_0 0))
                   (= UF_upward_preferred_3_0 Down_Separation)
                   (= Ret 0.0)))
        (a!13 (and (and (not (= UF_upward_preferred_3_0 1))
                        (= UF_upward_preferred_3_0 1))
                   (not (= UF_upward_preferred_3_0 Down_Separation))
                   (= Ret 1.0))))
  (let ((a!10 (or (and a!1
                       (> UF_upward_preferred_3_0 Down_Separation)
                       (= Ret 1.0))
                  (and a!2
                       (> UF_upward_preferred_3_0 Down_Separation)
                       (= Ret 0.0))
                  (and a!3
                       (> UF_upward_preferred_3_0 Down_Separation)
                       (= Ret 0.0))
                  a!4
                  (and (and a!5 (= UF_upward_preferred_3_0 0))
                       (> UF_upward_preferred_3_0 Down_Separation)
                       (= Ret 1.0))
                  (and (and a!6 (= UF_upward_preferred_3_0 0))
                       (> UF_upward_preferred_3_0 Down_Separation)
                       (= Ret 0.0))
                  (and a!7
                       (> UF_upward_preferred_3_0 Down_Separation)
                       (= Ret 0.0))
                  a!8
                  (and a!5
                       (<= UF_upward_preferred_3_0 Down_Separation)
                       (= Ret 1.0))
                  (and a!6
                       (<= UF_upward_preferred_3_0 Down_Separation)
                       (= Ret 0.0))
                  a!9
                  (and (not (= UF_upward_preferred_3_0 1))
                       (<= UF_upward_preferred_3_0 Down_Separation)
                       (= Ret 1.0))))
        (a!14 (or (and a!1
                       (= UF_upward_preferred_3_0 Down_Separation)
                       (= Ret 1.0))
                  (and a!2
                       (= UF_upward_preferred_3_0 Down_Separation)
                       (= Ret 0.0))
                  (and a!3
                       (= UF_upward_preferred_3_0 Down_Separation)
                       (= Ret 0.0))
                  a!11
                  (and (and a!5 (= UF_upward_preferred_3_0 0))
                       (= UF_upward_preferred_3_0 Down_Separation)
                       (= Ret 0.0))
                  (and (and a!6 (= UF_upward_preferred_3_0 0))
                       (= UF_upward_preferred_3_0 Down_Separation)
                       (= Ret 1.0))
                  (and a!7
                       (= UF_upward_preferred_3_0 Down_Separation)
                       (= Ret 1.0))
                  a!12
                  (and a!5
                       (not (= UF_upward_preferred_3_0 Down_Separation))
                       (= Ret 0.0))
                  (and a!6
                       (not (= UF_upward_preferred_3_0 Down_Separation))
                       (= Ret 1.0))
                  a!13
                  (and (not (= UF_upward_preferred_3_0 1))
                       (not (= UF_upward_preferred_3_0 Down_Separation))
                       (= Ret 0.0)))))
    (= a!10 a!14))))) 
(check-sat)