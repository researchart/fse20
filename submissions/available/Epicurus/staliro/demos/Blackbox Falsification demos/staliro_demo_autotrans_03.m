% This is a demo for using S-TALIRO with the Automatic Transmission
% Simulink Demo. The goal is to achieve certain values in the 
% output space and visit all the states of the Stateflow chart.
%
% This demo maps hybrid distances to the real line using map2line.
% See <a href="matlab: doc staliro_options.map2line">doc staliro_options.map2line</a>.
%
% Demo for falsifying the specification:
%       phi = '!(<>r1 /\ <>r2 /\ <>r3 /\ <>r4 /\ <>r5 /\ <>r6 /\ <>r7 /\ 
%                <>r8 /\ <>r9)' 
% The predicates ri correspond to the sets Ri in the paper:
% Zhao, Q.; Krogh, B. H. & Hubbard, P. Generating Test Inputs for Embedded 
% Control Systems IEEE Control Systems Magazine, 2003, August, 49-57
%
% See also : staliro_demo_autotrans_02.m

% (C) G. Fainekos 2011 - Arizona State University

clear

cd('..')
cd('SystemModelsAndData')

disp(' ')
disp('This is an S-TaLiRo demo on a Simulink model of Modelling an Automatic Transmission Controller.')
disp('The goal is to find an input throttle such that:')
disp(' 1) Vehicle speed exceeds 120km/hr')
disp(' 2) Engine speed reaches 4500 rpm')
model = @BlackBoxAutotrans;

disp(' ')
disp('The constraints on the initial conditions defined as a hypercube:')
init_cond = []

disp(' ')
disp('The constraints on the input signal defined as a range:')
input_range = [0 100]
disp(' ')
disp('The number of control points for the input signal:')
cp_array = 7

disp(' ')
disp('The specification:')
phi = '!(<>r1 /\ <>r2 /\ <>r3 /\ <>r4 /\ <>r5 /\ <>r6 /\ <>r7 /\ <>r8 /\ <>r9)' 

ii = 1;
preds(ii).str='r1';
preds(ii).A = [-1 0];
preds(ii).b = -120;
preds(ii).loc = [1:7];

ii = ii+1;
preds(ii).str='r2';
preds(ii).A = [0 -1];
preds(ii).b = -4500;
preds(ii).loc = [1:7];

jj = 1;
for ii = 3:6
    preds(ii).str=['r',num2str(ii)];
    preds(ii).A = [];
    preds(ii).b = [];
    preds(ii).loc = [jj jj+4 jj+8];
    jj = jj+1;
end

jj = 1;
for ii = 7:9
    preds(ii).str=['r',num2str(ii)];
    preds(ii).A = [];
    preds(ii).b = [];
    preds(ii).loc = jj:jj+3;
    jj = jj+4;
end

disp(' ')
disp('Total Simulation time:')
time = 30

disp(' ')
disp('Create an staliro_options object with the default options:')
opt = staliro_options()

disp(' ')
disp('Change options:')
opt.runs = 1;
n_tests = 1000;
opt.black_box = 1;
opt.interpolationtype = {'pconst'};
opt.taliro_metric = 'hybrid_inf';
opt.loc_traj = 'end';

opt.map2line = 1;

opt

disp(' ')
disp (' Select a solver to use ')
disp (' 1. Simulated Annealing ')
disp (' 2. Cross Entropy ' )
disp (' 3. Uniform Random ' )
disp (' 4. Genetic Algorithm')
disp (' ')
solver_id = input ('Select an option (1-4): ')
switch(solver_id)
    case 1
        opt.optimization_solver = 'SA_Taliro';
    case 2
        opt.optimization_solver = 'CE_Taliro';
        opt.n_workers = input ('Select the number of cores to be used (for parallel execution of simulations): ')
    case 3
        opt.optimization_solver = 'UR_Taliro';
        opt.n_workers = input ('Select the number of cores to be used (for parallel execution of simulations): ')
    case 4
        opt.optimization_solver='GA_Taliro';
end
opt.optim_params.n_tests = n_tests;

disp(' ')
disp('Running S-TaLiRo ...')
tic
results = staliro(model,init_cond,input_range,cp_array,phi,preds,time,opt);
runtime=toc;

runtime

results.run(results.optRobIndex).bestRob

figure
[T1,XT1,YT1,IT1,LT1] = SimBlackBoxMdl(model,init_cond,input_range,cp_array,results.run(results.optRobIndex).bestSample(:,1),time,opt);

subplot(4,1,1)
plot(IT1(:,1),IT1(:,2))
title('Throttle')

subplot(4,1,2)
plot(T1,YT1(:,2))
hold on 
plot([0 30],[4500 4500],'r');
title('RPM')

subplot(4,1,3)
plot(T1,YT1(:,1))
hold on 
plot([0 30],[120 120],'r');
title('Speed')

subplot(4,1,4)
plot(T1,LT1)
hold on 
title('Location History')
disp('   Location mapping')
disp('     1 = (first,steady_state)')
disp('     2 = (second,steady_state)')
disp('     3 = (third,steady_state)')
disp('     4 = (fourth,steady_state)')
disp('     5 = (first,downshifting)')
disp('     6 = (second,downshifting)')
disp('     7 = (third,downshifting)')
disp('     8 = (fourth,downshifting)')
disp('     9 = (first,upshifting)')
disp('    10 = (second,upshifting)')
disp('    11 = (third,upshifting)')
disp('    12 = (fourth,upshifting)')


cd('..')
cd('Blackbox Falsification demos')



