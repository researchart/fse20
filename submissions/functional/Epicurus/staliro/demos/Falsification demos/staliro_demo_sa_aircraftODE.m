% This is a demo for using S-TALIRO with models defined as m-functions and
% Simulated Annealing as an optimization solver

% (C) Georgios Fainekos 2010 - Arizona State Univeristy

clear

cd('..')
cd('SystemModelsAndData')

disp(' ')
disp(' Demo: Simulated Annealing on the aircraft example from the HSCC 2010 paper. ')
disp(' Two runs will be performed for a maximum of 400 tests each. ')
disp(' Press any key to continue ... ')

pause

model = @aircraftODE;

disp(' ')
disp('The initial conditions defined as a hypercube:')
init_cond = [200 260;-10 10;120 150] %#ok<*NOPTS>

disp(' ')
disp('The constraints on the input signals defined as a hypercube:')
input_range = [34386 53973;0 16]
disp(' ')
disp('The number of control points for each input signal:')
cp_array = [10 20];

disp(' ')
disp('The specification:')
phi = '!([]_[0,4.0]a /\ <>_[3.5,4.0] b)'
preds(1).str = 'a';
disp('Type "help monitor" to see the syntax of MTL formulas')
preds(1).A = [1 0 0; -1 0 0];
preds(1).b = [250; -240];
preds(2).str = 'b';
preds(2).A = [1 0 0; -1 0 0];
preds(2).b = [240.1; -240];

disp(' ')
disp('Total Simulation time:')
time = 4

disp(' ')
disp('Create an staliro_options object with the default options:')
opt = staliro_options()

disp(' ')
disp('Change options:')
opt.runs = 2;
opt.spec_space = 'X';

opt.optimization_solver = 'SA_Taliro';
opt.optim_params.n_tests = 400;

opt

disp(' ')
disp('Running S-TaLiRo with Simulated Annealing ...')
tic
results = staliro(model,init_cond,input_range,cp_array,phi,preds,time,opt);
toc

disp(' ')
display(['Minimum Robustness found in Run 1 = ',num2str(results.run(1).bestRob)])
display(['Minimum Robustness found in Run 2 = ',num2str(results.run(2).bestRob)])

figure(1)
clf
[T1,XT1,YT1,IT1] = SimFunctionMdl(model,init_cond,input_range,cp_array,results.run(1).bestSample,time,opt);
subplot(3,1,1)
plot(T1,XT1(:,1))
title('State trajectory x_1')
subplot(3,1,2)
plot(IT1(:,1),IT1(:,2))
title('Input Signal u_1')
subplot(3,1,3)
plot(IT1(:,1),IT1(:,3))
title('Input Signal u_2')

figure(2)
clf
[T2,XT2,YT2,IT2] = SimFunctionMdl(model,init_cond,input_range,cp_array,results.run(2).bestSample,time,opt);
subplot(3,1,1)
plot(T2,XT2(:,1))
title('State trajectory x_1')
subplot(3,1,2)
plot(IT2(:,1),IT2(:,2))
title('Input Signal u_1')
subplot(3,1,3)
plot(IT2(:,1),IT2(:,3))
title('Input Signal u_2')

cd('..')
cd('Falsification demos')

