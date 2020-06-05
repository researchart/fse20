def init_ST(initState, p):
    # init_MB - generates the initial state vector for the single-track model
    #
    # Syntax:  
    #     x0 = init_ST(initState, p)
    #
    # Inputs:
    #     initState - core initial states
    #     p - parameter vector
    #
    # Outputs:
    #     x0 - initial state vector
    #
    # Example: 
    #
    # See also: ---

    # Author:       Matthias Althoff
    # Written:      11-January-2017
    # Last update:  ---
    # Last revision:---

    #------------- BEGIN CODE --------------

    #states
    #x1 = x-position in a global coordinate system
    #x2 = y-position in a global coordinate system
    #x3 = steering angle of front wheels
    #x4 = velocity in x-direction
    #x5 = yaw angle
    #x6 = yaw rate
    #x7 = slip angle at vehicle center

    #u1 = steering angle velocity of front wheels
    #u2 = longitudinal acceleration


    #obtain initial states from vector
    sx0 = initState[0] 
    sy0 = initState[1] 
    vel0 = initState[2] 
    Psi0 = initState[3] 
    dotPsi0 = initState[4] 
    beta0 = initState[5] 


    #create equivalent bicycle parameters
    g = 9.81  #[m/s^2]
    mu = p.tire.p_dy1 
    C_Sf = -p.tire.p_ky1/p.tire.p_dy1  
    C_Sr = -p.tire.p_ky1/p.tire.p_dy1  
    lf = p.a 
    lr = p.b 

    #initial steering angle from steady state of slip angle
    delta0 = vel0*(lf + lr)/(C_Sf*g*lr*mu)*dotPsi0 + 1/(C_Sf*lr)*((C_Sr*lf + C_Sf*lr)*beta0 - (C_Sr - C_Sf)*lr*lf*dotPsi0/vel0) 

    #sprung mass states
    x0 = [] # init initial state vector
    x0.append(sx0)  # x-position in a global coordinate system
    x0.append(sy0)  # y-position in a global coordinate system
    x0.append(delta0)  # steering angle of front wheels
    x0.append(vel0)  # velocity
    x0.append(Psi0)  # yaw angle
    x0.append(dotPsi0)  # yaw rate
    x0.append(beta0)  # slip angle at vehicle center

    return x0

#------------- END OF CODE --------------
