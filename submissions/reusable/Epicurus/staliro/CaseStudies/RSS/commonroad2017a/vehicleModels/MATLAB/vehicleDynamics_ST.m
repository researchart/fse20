function f = vehicleDynamics_ST(x,u,p)
% vehicleDynamics_ST - single-track vehicle dynamics 
%
% Syntax:  
%    f = vehicleDynamics_ST(x,u,p)
%
% Inputs:
%    x - vehicle state vector
%    u - vehicle input vector
%    p - vehicle parameter vector
%
% Outputs:
%    f - right-hand side of differential equations
%
% Example: 
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ---

% Author:       Matthias Althoff
% Written:      12-January-2017
% Last update:  ---
% Last revision:---

%------------- BEGIN CODE --------------

% set gravity constant
g = 9.81; %[m/s^2]

%create equivalent bicycle parameters
mu = p.tire.p_dy1;
C_Sf = -p.tire.p_ky1/p.tire.p_dy1; 
C_Sr = -p.tire.p_ky1/p.tire.p_dy1; 
lf = p.a;
lr = p.b;
h = p.h_s;
m = p.m;
I = p.I_z;

%states
%x1 = s_x x-position in a global coordinate system
%x2 = s_y y-position in a global coordinate system
%x3 = δ steering angle of front wheels
%x4 = u velocity in x-direction
%x5 = Ψ yaw angle
%x6 = Ψ yaw rate
%x7 = β slip angle at vehicle center

%u1 = v_delta steering angle velocity of front wheels
%u2 = ax longitudinal acceleration


%system dynamics
f(1,1) = x(4)*cos(x(7) + x(5));
f(2,1) = x(4)*sin(x(7) + x(5));
f(3,1) = u(1);
f(4,1) = u(2);
f(5,1) = x(6);
f(6,1) = -mu*m/(x(4)*I*(lr+lf))*(lf^2*C_Sf*(g*lr-u(2)*h) + lr^2*C_Sr*(g*lf + u(2)*h))*x(6) ...
    +mu*m/(I*(lr+lf))*(lr*C_Sr*(g*lf + u(2)*h) - lf*C_Sf*(g*lr - u(2)*h))*x(7) ...
    +mu*m/(I*(lr+lf))*lf*C_Sf*(g*lr - u(2)*h)*x(3);
f(7,1) = (mu/(x(4)^2*(lr+lf))*(C_Sr*(g*lf + u(2)*h)*lr - C_Sf*(g*lr - u(2)*h)*lf)-1)*x(6) ...
    -mu/(x(4)*(lr+lf))*(C_Sr*(g*lf + u(2)*h) + C_Sf*(g*lr-u(2)*h))*x(7) ...
    +mu/(x(4)*(lr+lf))*(C_Sf*(g*lr-u(2)*h))*x(3);


%------------- END OF CODE --------------