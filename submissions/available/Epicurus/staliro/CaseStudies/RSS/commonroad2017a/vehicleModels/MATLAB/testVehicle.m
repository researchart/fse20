function testVehicle()
% testVehicle - tests vehicle dynamics
%
% Syntax:  
%    testVehicle()
%
% Inputs:
%    ---
%
% Outputs:
%    ---
%
% Example: 
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ---

% Author:       Matthias Althoff
% Written:      11-January-2017
% Last update:  ---
% Last revision:---

%------------- BEGIN CODE --------------

%load parameters
p = parameters_vehicle2;
g = 9.81; %[m/s^2]

%set options --------------------------------------------------------------
tStart = 0; %start time
tFinal = 1; %start time

% vel0 = 15;
% Psi0 = 0.1;
% dotPsi0 = -0.1;
% beta0 = 0.05;
% sy0 = 1;
vel0 = 15;
Psi0 = 0;
dotPsi0 = 0;
beta0 = 0;
sy0 = 0;
initialState = [0,sy0,vel0,Psi0,dotPsi0,beta0]; %initial state for simulation
x0_KS = init_KS(initialState, p); %initial state for kinematic single-track model
x0_ST = init_ST(initialState, p); %initial state for single-track model
x0_MB = init_MB(initialState, p); %initial state for multi-body model
%--------------------------------------------------------------------------

% %specify continuous dynamics-----------------------------------------------
% carDyn = vehicleSys('vehicleDynamics',28,2,@vehicleDynamics_MB,[]); %initialize car
% carDyn_bicycle = vehicleSys('vehicleDynamics_bicycle',6,2,@DOTBicycleDynamics,[]); %initialize car
% %--------------------------------------------------------------------------

% %generate ode options
% stepsizeOptions = odeset('MaxStep',options.tStart-options.tFinal);
% opt = odeset(stepsizeOptions);

%set input: rolling car (velocity should stay constant)
u = [0 0];
%simulate car
[t_roll,x_roll] = ode45(getfcn(@vehicleDynamics_MB,u,p),[tStart, tFinal],x0_MB);
figure
plot(t_roll,x_roll(:,4));
plot(x_roll(:,1),x_roll(:,2));

%set input: braking car (wheel spin and velocity should decrease; similar wheel spin)
v_delta = 0.15;
acc = -0.7*g;
u = [v_delta acc];
%simulate car
[t_brake,x_brake] = ode45(getfcn(@vehicleDynamics_MB,u,p),[tStart, tFinal],x0_MB);
figure %position
hold on
plot(x_brake(:,1),x_brake(:,2))
figure % velocity
plot(t_brake,x_brake(:,4));
figure % wheel spin
hold on
plot(t_brake,x_brake(:,24));
plot(t_brake,x_brake(:,25));
plot(t_brake,x_brake(:,26));
plot(t_brake,x_brake(:,27));
figure % pitch
plot(t_brake,x_brake(:,9));

%set input: accelerating car (wheel spin and velocity should increase; more wheel spin at rear)
v_delta = 0.15;
acc = 0.63*g;
u = [v_delta acc];
%simulate car
[t_acc,x_acc] = ode45(getfcn(@vehicleDynamics_MB,u,p),[tStart, tFinal],x0_MB);
figure %position
hold on
plot(x_acc(:,1),x_acc(:,2))
figure % velocity
plot(t_acc,x_acc(:,4));
figure % wheel spin
hold on
plot(t_acc,x_acc(:,24));
plot(t_acc,x_acc(:,25));
plot(t_acc,x_acc(:,26));
plot(t_acc,x_acc(:,27));
figure % pitch
plot(t_acc,x_acc(:,9));
figure %orientation
hold on
plot(t_acc,x_acc(:,5))


%steering to left
v_delta = 0.15;
u = [v_delta 0];

%simulate full car
[t_left,x_left] = ode45(getfcn(@vehicleDynamics_MB,u,p),[tStart, tFinal],x0_MB);

%simulate single-track model
[t_left_st,x_left_st] = ode45(getfcn(@vehicleDynamics_ST,u,p),[tStart, tFinal],x0_ST);

%simulate kinematic single-track model
[t_left_ks,x_left_ks] = ode45(getfcn(@vehicleDynamics_KS,u,p),[tStart, tFinal],x0_KS);

figure %position
hold on
plot(x_left(:,1),x_left(:,2))
plot(x_left_st(:,1),x_left_st(:,2))
plot(x_left_ks(:,1),x_left_ks(:,2))
figure %orientation
hold on
plot(t_left,x_left(:,5))
plot(t_left_st,x_left_st(:,5),'r')
plot(t_left_ks,x_left_ks(:,5),'g')
figure %steering
hold on
plot(t_left,x_left(:,3))
plot(t_left_st,x_left_st(:,3),'r')
plot(t_left_ks,x_left_ks(:,3),'g')
figure %yaw rate
hold on
plot(t_left,x_left(:,6))
plot(t_left_st,x_left_st(:,6),'r')
figure %slip angle
hold on
plot(t_left,atan(x_left(:,11)./x_left(:,4)))
plot(t_left_st,x_left_st(:,7))
% figure % wheel spin
% hold on
% plot(t_acc,x_acc(:,24));
% plot(t_acc,x_acc(:,25));
% plot(t_acc,x_acc(:,26));
% plot(t_acc,x_acc(:,27));


%compare position for braking/normal
figure %position
hold on
plot(x_left(:,1),x_left(:,2))
plot(x_brake(:,1),x_brake(:,2))
plot(x_acc(:,1),x_acc(:,2))
for i=1:10
    t_next = tFinal/10*i;
    ind = find(t_left<t_next, 1, 'last' ); 
    plotAxle(x_left(ind,:),p,'b');
end
for i=1:10
    t_next = tFinal/10*i;
    ind = find(t_brake<t_next, 1, 'last' ); 
    plotAxle(x_brake(ind,:),p,'r');
end
for i=1:10
    t_next = tFinal/10*i;
    ind = find(t_acc<t_next, 1, 'last' ); 
    plotAxle(x_acc(ind,:),p,'c');
end
%compare slip angles
figure 
hold on
plot(t_left,atan(x_left(:,11)./x_left(:,4)))
plot(t_brake,atan(x_brake(:,11)./x_brake(:,4)))
plot(t_acc,atan(x_acc(:,11)./x_acc(:,4)))
%orientation
figure 
hold on
plot(t_left,x_left(:,5))
plot(t_brake,x_brake(:,5))
plot(t_acc,x_acc(:,5))
%pitch
figure 
hold on
plot(t_left,x_left(:,9))
plot(t_brake,x_brake(:,9))
plot(t_acc,x_acc(:,9))
end

% add input and parameters to ode 
function [handle] = getfcn(fctName,u,p)
    
    function dxdt = f(t,x)
        dxdt = fctName(x,u,p);
    end

    handle = @f;
end

%plots the axle of the car
function plotAxle(x,p,type)

    % front axle
    % x-position 
    fa(1) = x(1) + cos(x(5))*p.a;
    fa(2) = x(2) + sin(x(5))*p.a;

    % rear axle
    % y-position
    fr(1) = x(1) - cos(x(5))*p.b;
    fr(2) = x(2) - sin(x(5))*p.b;

    plot([fa(1),fr(1)],[fa(2),fr(2)],type);
end

%------------- END OF CODE --------------
