% This is a demo for using S-TALIRO with Simulink models and Simulated 
% Annealing as an optimization solver. This demo performs minimization
% rather than falsification, i.e., the solver does not stop when a
% falsifying trajectory is found.

% (C) Georgios Fainekos 2010 - Arizona State Univeristy

clear

cd('..')
cd('SystemModelsAndData')

disp(' ')
disp('This is an S-TaLiRo demo on a Simulink model of 3rd order Delta-Sigma Modulator.')
disp('The goal is to find state trajectories that might reach the saturation threshold.')
disp('That is, we require that -1<=x_i<=1, for i = 1,2,3.')

disp(' ')
disp(' One run will be performed using simulated annealing for a maximum of 300 tests. ')
disp(' This example performs minimization rather than falsification.')
disp(' Press any key to continue ... ')

pause 

model='modulator_3rd_order';

disp(' ')
disp('The constraints on the input signals defined as a hypercube:')
init_cond = [-.2 .2;-.2 .2;-.2 .2] %#ok<*NOPTS>

disp(' ')
disp('The constraints on the input signal defined as a range:')
input_range = [-.5 .5]
disp(' ')
disp('The number of control points for the input signal:')
cp_array = 10

disp(' ')
disp('The specification:')
phi = '[]a'

preds.str = 'a';
preds.A = [1 0 0; -1 0 0; 0 1 0; 0 -1 0; 0 0 1; 0 0 -1];
preds.b = [1 1 1 1 1 1]';

disp(' ')
disp('Total Simulation time:')
time = 9

disp(' ')
disp('Create an staliro_options object with the default options:')
opt = staliro_options()

disp(' ')
disp('Change options:')
opt.runs = 1;
opt.spec_space = 'X';
opt.falsification = 0;

opt.optimization_solver = 'SA_Taliro';
opt.optim_params.n_tests = 300;

disp('Note: In this example, the specification is with respect to the state ')
disp('space of the model and not the output space. Thus we change the spec_space')
disp('property from "Y" to "X".')
opt

disp(' ')
disp('Running S-TaLiRo with Simulated Annealing ...')
tic
results = staliro(model,init_cond,input_range,cp_array,phi,preds,time,opt);
toc

disp(' ')
display(['Minimum Robustness found in Run 1 = ',num2str(results.run(results.optRobIndex).bestRob)])

disp(' ')
disp('Displaying trajectories in Figure 1 ...')

figure(1)
clf
[T1,XT1,YT1,IT1] = SimSimulinkMdl(model,init_cond,input_range,cp_array,results.run(results.optRobIndex).bestSample,time,opt);
subplot(2,1,1)
plot(T1,XT1)
title('State trajectories')
subplot(2,1,2)
plot(IT1(:,1),IT1(:,2))
title('Input Signal')

disp(' ')
disp('Displaying Simulink model for visualization. ')
open(model)

cd('..')
cd('Falsification demos')

