% staliro_demo_constraint_input_signal_space_01
% 	This script demonstrates how to search over a constraint input signal search 
%   space with a custom input signal generator. See the
%   CustomInputSignal_help.pdf for more details. 
%
%   We use the Simulink autotransmission benchmark.
%
% See also: staliro_demo_autotrans_01, staliro_demo_autotrans_03,
%           staliro_demo_constraint_input_signal_space_02
% (C) 2016, Bardh Hoxha, Arizona State University
clear

model = 'sldemo_autotrans_mod01_cis';

% Total Simulation time
totTime = 30;

opt = staliro_options();
opt.runs = 1;
opt.optimization_solver = 'SA_Taliro';
opt.optim_params.n_tests = 100;

% No initial conditions
init_cond = [];

% Some specification
phi = '([]r1)';

ii = 1;
preds(ii).str='r1';
preds(ii).A = [1 0];
preds(ii).b = 160;

%% Input signal

% Define the search range
input_range = [0 100];
cp_array = 9; % number of x_i control points for the input signal

% Here, we will define a custom input signal generator. In this case, we
% want the signal to have the following propeties:
% The signal should hold constant for at least 5 seconds and then we will
% use an interpolation function for the rest of the simulation time.
%
% Description of the control points for varable time signal generation
% through the CustomInputSignal_VarTime function:
% x_1: constant state value for at least 5 seconds between 0 and 100
% x_2-x_5: interpolated state values 
% x_6-x_9: time control points over which x2-x5 are interpolated
%
% Description of the control points for fixed time signal generation
% through the CustomInputSignal_FixedTime function:
% x_1: constant state value for exactly 5 seconds between 0 and 100
% x_2-x_9: interpolated state values with equidistant time intervals

% Custom signal generation functions
disp(' ')
disp(' 1. Variable time: CustomInputSignal_VarTime')
disp(' 2. Fixed time: CustomInputSignal_FixedTime')
disp(' ')
form_id_1 = input('Select custom input signal generation function:');


if form_id_1 == 1       
    
    opt.interpolationtype = {@CustomInputSignal_VarTime};
    % Here we add constraints to the control points. For variable time control
    % points x_6-x_9 we want to make sure that x_i<x_(i+1). Note that we add a
    % error margin of SampTime since if the same control point is sampled the
    % interpolation function might error out.

    opt.search_space_constrained.constrained = true; 
    % x_6 - x_7 <= -opt.SampTime
    A = [0 0 0 0 0 1 -1 0 0];
    b = -opt.SampTime;
    % x_7 - x_8 <= -opt.SampTime
    A = [A; [0 0 0 0 0 0 1 -1 0]];
    b = [b; -opt.SampTime];
    % x_8 - x_9 <= -opt.SampTime
    A = [A; [0 0 0 0 0 0 0 1 -1]];
    b = [b; -opt.SampTime];

    % We also want to make sure that the timing control points are in [5,30]
    % 5 < x_6 <= 30
    A = [A; [0 0 0 0 0 1 0 0 0; 0 0 0 0 0 -1 0 0 0]];
    b = [b; 30; -5];
    % 5 < x_7 <= 30
    A = [A; [0 0 0 0 0 0 1 0 0; 0 0 0 0 0 0 -1 0 0]];
    b = [b; 30; -5];
    % 5 < x_8 <= 30
    A = [A; [0 0 0 0 0 0 0 1 0; 0 0 0 0 0 0 0 -1 0]];
    b = [b; 30; -5];
    % 5 < x_9 <= 30
    A = [A; [0 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0 -1]];
    b = [b; 30; -5];

    % Set constraints
    opt.search_space_constrained.A_ineq = A;
    opt.search_space_constrained.b_ineq = b;
elseif form_id_1 == 2
    opt.interpolationtype = {@CustomInputSignal_FixedTime};
else
    error('Only 1 and 2 are acceptable inputs')
end

%% Running S-TaLiRo

disp(' ')
disp('Running S-TaLiRo ...')
[results,history] = staliro(model,init_cond,input_range,cp_array,phi,preds,totTime,opt);

results.run(results.optRobIndex).bestRob

disp(' ')
disp('Plotting the results of the best run ...')
disp(' ')

figure
[T1,XT1,YT1,IT1] = SimSimulinkMdl(model,init_cond,input_range,cp_array,results.run(results.optRobIndex).bestSample(:,1),totTime,opt);
subplot(3,1,1)
plot(IT1(:,1),IT1(:,2))
title('Throttle')
subplot(3,1,2)
plot(T1,YT1(:,2))
hold on 
plot([0 30],[4500 4500],'r');
title('RPM')
subplot(3,1,3)
plot(T1,YT1(:,1))
hold on 
plot([0 30],[80 80],'r');
title('Speed')