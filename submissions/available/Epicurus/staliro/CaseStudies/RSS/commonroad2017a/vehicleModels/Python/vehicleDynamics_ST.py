import math

def vehicleDynamics_ST(x,u,p):
    # vehicleDynamics_ST - single-track vehicle dynamics 
    #
    # Syntax:  
    #    f = vehicleDynamics_ST(x,u,p)
    #
    # Inputs:
    #    x - vehicle state vector
    #    u - vehicle input vector
    #    p - vehicle parameter vector
    #
    # Outputs:
    #    f - right-hand side of differential equations
    #
    # Example: 
    #
    # Other m-files required: none
    # Subfunctions: none
    # MAT-files required: none
    #
    # See also: ---

    # Author:       Matthias Althoff
    # Written:      12-January-2017
    # Last update:  ---
    # Last revision:---

    #------------- BEGIN CODE --------------

    # set gravity constant
    g = 9.81  #[m/s^2]

    #create equivalent bicycle parameters
    mu = p.tire.p_dy1 
    C_Sf = -p.tire.p_ky1/p.tire.p_dy1  
    C_Sr = -p.tire.p_ky1/p.tire.p_dy1  
    lf = p.a 
    lr = p.b 
    h = p.h_s 
    m = p.m 
    I = p.I_z 

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


    #system dynamics
    f = [x[3]*math.cos(x[6] + x[4]), 
        x[3]*math.sin(x[6] + x[4]), 
        u[0], 
        u[1], 
        x[5], 
        -mu*m/(x[3]*I*(lr+lf))*(lf**2*C_Sf*(g*lr-u[1]*h) + lr**2*C_Sr*(g*lf + u[1]*h))*x[5] \
            +mu*m/(I*(lr+lf))*(lr*C_Sr*(g*lf + u[1]*h) - lf*C_Sf*(g*lr - u[1]*h))*x[6] \
            +mu*m/(I*(lr+lf))*lf*C_Sf*(g*lr - u[1]*h)*x[2], 
        (mu/(x[3]**2*(lr+lf))*(C_Sr*(g*lf + u[1]*h)*lr - C_Sf*(g*lr - u[1]*h)*lf)-1)*x[5] \
            -mu/(x[3]*(lr+lf))*(C_Sr*(g*lf + u[1]*h) + C_Sf*(g*lr-u[1]*h))*x[6] \
            +mu/(x[3]*(lr+lf))*(C_Sf*(g*lr-u[1]*h))*x[2]]

    return f

    #------------- END OF CODE --------------
