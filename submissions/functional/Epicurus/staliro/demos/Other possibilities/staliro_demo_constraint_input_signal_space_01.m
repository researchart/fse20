% staliro_demo_constraint_input_signal_space_01
% 	This script demonstrates how to search over a constraint input signal  
%   search space. In particular, we consider a system with two inputs for   
%   which we want to study its response under two step functions. We would  
%   like to impose the following constraints:
%      * The step for signal 2 should happen after 5 sec of the step for 
%        signal 1
%      * The step for signal 1 should happen after 5 sec from time 0
%      * The step for signal 2 should happen 5 sec before the end of the
%        simulation time 
%      * Signal 1 should be step down in value with at least difference 10
%      * Signal 2 should be step up in value with at least difference 10
%
%   We use the Simulink auto transmission benchmark. In terms of  
%   application, the search models hitting the gas pedal, releasing the gas  
%   pedal and then hitting the break.
%
% See also: staliro_demo_autotrans_01, staliro_demo_autotrans_03, staliro_demo_constraint_input_signal_space_02

clear

cd('..')
cd('SystemModelsAndData')
model = 'sldemo_autotrans_mod01_2inp';

% Total Simulation time
totTime = 30;

opt = staliro_options();
opt.runs = 1;

disp(' ')
disp (' Select a solver to use ')
disp (' 1. Simulated Annealing Method. ')
disp (' 2. Genetic Algorithm. (GA Matlab toolbox needed)')
disp (' ')
tmp_solv = input (' Choose 1 or 2: ');

if tmp_solv>2 || tmp_solv<1
    disp(' Wrong selection. Setting option to 1.')
    tmp_solv = 1;
end 
if (tmp_solv == 1)
    opt.optimization_solver = 'SA_Taliro';
    opt.optim_params.n_tests = 1000;
else
    opt.optimization_solver = 'GA_Taliro';
    opt.optim_params.ga_options = gaoptimset(opt.optim_params.ga_options,'PopulationSize',50,'Generations',20);
end

% No initial conditions
init_cond = [];

% Some specification
% phi = '!(<>(r1 /\ <>r2) /\ <>(r3 /\ <>r4))';
phi = '!(<>r1 /\ <>(r3 /\ <>r4))';

ii = 1;
preds(ii).str='r1';
preds(ii).A = [-1 0];
preds(ii).b = -80;

ii = ii+1;
preds(ii).str='r2';
preds(ii).A = [1 0];
preds(ii).b = 60;

ii = ii+1;
preds(ii).str='r3';
preds(ii).A = [0 -1];
preds(ii).b = -4500;

ii = ii+1;
preds(ii).str='r4';
preds(ii).A = [0 1];
preds(ii).b = 3300;

%% Input signal


% Option 1 : Old way
% input_range = [0 100; 0 100];
% Each input signal should have 3 control points
% Thus the search space will 6D
% cp_array = [3 3];

% Option 2 : New way 
% Define the search range for each control point
input_range = {[0 100; 0 30; 0 100]; [0 100; 0 30; 0 100]};
cp_array = []; % Now cp_array is automatically determined from input_range

% Each input signal should be a step function
% Parameterization:
% x1 : the value of the signal before the step,
% x2 : the time that the signal changes value, and
% x3 : the value of the signal after the step.
opt.interpolationtype = {@StepInputSignal};

% Add constraints
opt.search_space_constrained.constrained = true; 
% Signal 1 should be step down: x1_1 > x1_3+10
A = [-1 0 1 0 0 0];
b = -10;
% Signal 2 should be step up: x2_1+10 < x2_3
A = [A; [0 0 0 1 0 -1]];
b = [b; -10];
% Signal 1 step should be before 2 step: x1_2+5 < x2_2
A = [A; [0 1 0 0 -1 0]];
b = [b; -5];
% Signal 1 step should occur after 5 sec: x1_2 > 5
A = [A; [0 -1 0 0 0 0]];
b = [b; -5];
% Signal 2 step should occur 5 sec before the end of sim time: x2_2 < totTime-5
A = [A; [0 0 0 0 1 0]];
b = [b; totTime-5];

% If Option 1 above is used for defining the input signal search space,
% then the following must be added to the constraints.
% We need to add the additional requirement that the switch time is between
% time 0 and total time (the lower bound is implied by the set [0,100]^2)
% A = [A; [0 1 0 0 0 0]];
% b = [b; totTime];
% A = [A; [0 0 0 0 1 0]];
% b = [b; totTime];

% Set constraints
opt.search_space_constrained.A_ineq = A;
opt.search_space_constrained.b_ineq = b;

%% Running S-TaLiRo

disp(' ')
disp('Running S-TaLiRo ...')
results = staliro(model,init_cond,input_range,cp_array,phi,preds,totTime,opt);

results.run(results.optRobIndex).bestRob

disp(' ')
disp('Plotting the results of the 1st run ...')
disp(' ')

figure
[T1,XT1,YT1,IT1] = SimSimulinkMdl(model,init_cond,input_range,cp_array,results.run(results.optRobIndex).bestSample(:,1),totTime,opt);
subplot(4,1,1)
plot(IT1(:,1),IT1(:,2))
title('Throttle')
subplot(4,1,2)
plot(IT1(:,1),IT1(:,3))
title('Break')
subplot(4,1,3)
plot(T1,YT1(:,2))
hold on 
plot([0 30],[4500 4500],'r');
title('RPM')
subplot(4,1,4)
plot(T1,YT1(:,1))
hold on 
plot([0 30],[80 80],'r');
title('Speed')

cd('..')
cd('Other possibilities')


