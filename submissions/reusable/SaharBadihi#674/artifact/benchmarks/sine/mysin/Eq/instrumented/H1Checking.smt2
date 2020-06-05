(declare-const UF_retval_1_0  Real )
(assert 
(forall ((UF_x_8_0 Real)
         (UF_retval_7_0 Real)
         (UF_x2_4_0 Real)
         (UF_retval_3_0 Real)
         (UF_xexp_2_0 Int)
         (UF_IEEE_MANT_1_0 Int)
         (UF_IEEE_BIAS_1_0 Int)
         (UF_IEEE_MAX_1_0 Int)
         (UF_x2_8_0 Real)
         (UF_x_6_0 Real)
         (UF_sign_6_0 Int)
         (UF_x6_6_0 Real)
         (UF_x5_6_0 Real)
         (UF_x4_6_0 Real)
         (UF_x3_6_0 Real)
         (UF_a2_6_0 Real)
         (UF_a1_6_0 Real)
         (UF_l_x1_6_0 Int)
         (UF_xm_6_0 Real)
         (UF_sign_5_0 Int)
         (UF_x_5_0 Real)
         (UF_md_b_m1_2_0 Int)
         (UF_md_b_m2_2_0 Int)
         (UF_md_b_sign_2_0 Int)
         (UF_l_x_2_0 Int)
         (UF_X_EPS_2_0 Real)
         (UF_pi2_lo_lo_2_0 Real)
         (UF_pi2_lo_hi_2_0 Real)
         (UF_pi2_hi_lo_2_0 Real)
         (UF_pi2_hi_hi_2_0 Real)
         (UF_pi2_lo2_2_0 Real)
         (UF_pi2_lo_2_0 Real)
         (UF_pi2_hi_2_0 Real)
         (UF__2_pi_hi_2_0 Real)
         (UF_half_2_0 Real)
         (Ret Real)
         (x Real))
  (let ((a!1 (and (<= UF_xexp_2_0 (- (- UF_IEEE_BIAS_1_0 UF_IEEE_MANT_1_0) 2))
                  (not (= 0 UF_xexp_2_0))
                  (not (= UF_IEEE_MAX_1_0 UF_xexp_2_0))
                  (= Ret x)))
        (a!3 (and (<= UF_xexp_2_0 (- UF_IEEE_BIAS_1_0 (div UF_IEEE_MANT_1_0 4)))
                  (> UF_xexp_2_0 (- (- UF_IEEE_BIAS_1_0 UF_IEEE_MANT_1_0) 2))
                  (not (= 0 UF_xexp_2_0))
                  (not (= UF_IEEE_MAX_1_0 UF_xexp_2_0))))
        (a!4 (div (to_int (* (* x x) 1.0)) (to_int 6.0)))
        (a!6 (and (<= UF_xexp_2_0 (+ UF_IEEE_MANT_1_0 UF_IEEE_BIAS_1_0))
                  (> UF_xexp_2_0 (- UF_IEEE_BIAS_1_0 (div UF_IEEE_MANT_1_0 4)))
                  (> UF_xexp_2_0 (- (- UF_IEEE_BIAS_1_0 UF_IEEE_MANT_1_0) 2))
                  (not (= 0 UF_xexp_2_0))
                  (not (= UF_IEEE_MAX_1_0 UF_xexp_2_0))
                  (= Ret UF_x_8_0)))
        (a!7 (and (> UF_xexp_2_0 (+ UF_IEEE_MANT_1_0 UF_IEEE_BIAS_1_0))
                  (> UF_xexp_2_0 (- UF_IEEE_BIAS_1_0 (div UF_IEEE_MANT_1_0 4)))
                  (> UF_xexp_2_0 (- (- UF_IEEE_BIAS_1_0 UF_IEEE_MANT_1_0) 2))
                  (not (= 0 UF_xexp_2_0))
                  (not (= UF_IEEE_MAX_1_0 UF_xexp_2_0))
                  (= Ret UF_retval_7_0)))
        (a!8 (* x
                (- 1.0 (* (* x x) (/ 8333333333333333.0 50000000000000000.0))))))
  (let ((a!2 (or (and (= UF_IEEE_MAX_1_0 UF_xexp_2_0) (= Ret UF_retval_3_0))
                 (and (> UF_md_b_m2_2_0 0)
                      (<= UF_md_b_m1_2_0 0)
                      (= 0 UF_xexp_2_0)
                      (not (= UF_IEEE_MAX_1_0 UF_xexp_2_0))
                      (= Ret (- x UF_x2_4_0)))
                 (and (<= UF_md_b_m2_2_0 0)
                      (<= UF_md_b_m1_2_0 0)
                      (= 0 UF_xexp_2_0)
                      (not (= UF_IEEE_MAX_1_0 UF_xexp_2_0))
                      (= Ret x))
                 (and (> UF_md_b_m1_2_0 0)
                      (= 0 UF_xexp_2_0)
                      (not (= UF_IEEE_MAX_1_0 UF_xexp_2_0))
                      (= Ret (- x UF_x2_4_0)))
                 a!1))
        (a!5 (= Ret (* x (- 1.0 (to_real a!4))))))
    (= (or a!2 (and a!3 a!5) a!6 a!7) (or a!2 (and a!3 (= Ret a!8)) a!6 a!7)))))) 
(check-sat)