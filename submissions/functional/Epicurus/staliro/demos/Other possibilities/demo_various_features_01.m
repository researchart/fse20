% This script demonstrates how to use:
%   * the output projection option dim_proj 
%       The model has 5 outputs, but we are interested in using only the 
%       signals on the output ports 1 and 2. Then, we can set 
%       dim_proj = [1 2].
%   * save intermediate results
%   * undersample output signals
%   * search over interpolating input signals with varying times for the
%     interpolating points
%
% Demo for falsifying the specification '!(<>r1 /\ <>r2)' 
% The predicates r1 and r2 correspond to the sets R1 and R2 in the paper:
% Zhao, Q.; Krogh, B. H. & Hubbard, P. Generating Test Inputs for Embedded 
% Control Systems IEEE Control Systems Magazine, 2003, August, 49-57

% (C) B. Hoxha 2013 - Arizona State Univeristy
% (C) G. Fainekos 2011 - Arizona State Univeristy

clear

disp(' ')
disp(' This script demonstrates how to:')
disp('      * use the output projection option dim_proj') 
disp('      * save intermmediate results')
disp('      * undersample output signals')
disp('      * search over varying times for the interpolating points')
disp(' ')

disp('Press any key to continue ...')
pause

disp(' ')
disp('This is an S-TaLiRo demo on a Simulink model of Modelling an Automatic Transmission Controller.')
disp('The goal is to find an input throttle such that:')
disp(' 1) Vehicle speed exceeds 120km/hr')
disp(' 2) Engine speed reaches 4500 rpm')

model = 'sldemo_autotrans_dim_proj';

disp(' ')
disp('The constraints on the input signal defined as a range:')
input_range = [0 100] %#ok<NOPTS>
disp(' ')
disp('The number of control points for the input signal:')
cp_array = 7 %#ok<NOPTS>

% No initial conditions
init_cond = [];

disp(' ')
disp('The specification:')
phi = '!(<>r1 /\ <>r2)'  %#ok<NOPTS>

ii = 1;
preds(ii).str='r1';
preds(ii).A = [-1 0];
preds(ii).b = -120;
preds(ii).loc = 1:7;

ii = ii+1;
preds(ii).str='r2';
preds(ii).A = [0 -1];
preds(ii).b = -4500;
preds(ii).loc = 1:7;

disp(' ')
disp('Total Simulation time:')
time = 30 %#ok<NOPTS>

disp(' ')
disp('Set staliro options:')
opt = staliro_options();
opt.runs = 3;
opt.optim_params.n_tests = 500;
opt.interpolationtype = {'pconst'};

% restrict output consideration to only output 1 and 2
opt.dim_proj = [1 2];

% Save intermediate results
opt.save_intermediate_results = 1;

% Set the seed
opt.seed = 1;

% Select every 5th sample of the output trajectory in order to compute
% temporal robustness
opt.taliro_undersampling_factor = 5;

% Allow for varying time over the control points
opt.varying_cp_times = 1;

opt %#ok<NOPTS>

disp('Press any key to continue ...')
pause

disp(' ')
disp('Running S-TaLiRo ...')
tic
results = staliro(model,init_cond,input_range,cp_array,phi,preds,time,opt);
runtime=toc;

runtime %#ok<NOPTS>

results.run(results.optRobIndex).bestRob

disp(' ')
disp('Plotting the results of the 1st run ...')
disp(' ')

figure
[T1,XT1,YT1,IT1] = SimSimulinkMdl(model,init_cond,input_range,cp_array,results.run(results.optRobIndex).bestSample(:,1),time,opt);
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
plot([0 30],[120 120],'r');
title('Speed')


