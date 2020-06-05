% This script demonstrates how to use:
%   * CE_Taliro utilizing the hybrid distance metric
%   * running parallel simulations with the Cross-Entropy method
%
% To run this demo you must have CheckMate installed
%
% The model is described in detail in the technical report:
% Alongkrit Chutinan and Kenneth R. Butts, Dynamic Analysis of Hybrid 
% System Models for Design Validation

% (C) Bardh Hoxha - 2013 - Arizona State University 
% (C) Yashwanth Annapureddy - 2011 - Arizona State University 
% (C) Georgios Fainekos - 2011 - Arizona State University 

clear

disp(' ')
disp(' This script demonstrates how to:')
disp('      * use parallel simulations using the CE method') 
disp('      * use hybrid distance metrics with the CE method') 
disp(' ')
disp(' To run this demo you must have CheckMate installed.')
disp(' ')
disp(' Press any key to continue or Ctrl+C to stop ...')
disp(' ')
pause

addpath('../../benchmarks/Powertrain')

model = @BlackBoxPowertrain02;

% Run once the model to avoid compilation issues
model([0;0],0.1);

disp(' ')
disp('Initial conditions')
init_cond = [0 100; 0 0.5];

disp(' ')
disp('No input signals:')
input_range = [] %#ok<NOPTS>
cp_array = [] %#ok<NOPTS>

disp(' ')
disp('The specification:')

% CONSTANTS USED
Rsi = 0.2955;       
Rci = 0.6379;       
Rcr = 0.7045;       
Rd = 0.3521;        

R1 = Rci*Rsi/(1-Rci*Rcr); 
R2 = Rci;                 

AR2 = 4.125;
c2_mu1 = 0.1316;          
c2_mu2 = 0.0001748;

i = 1;
pred(i).str = 'gear1';
pred(i).A = [];
pred(i).b = [];
pred(i).loc = 1;

i = i+1;
pred(i).str = 'gear2';
pred(i).A = [];
pred(i).b = [];
pred(i).loc = 3;

i = i+1;
pred(i).str = 'b1';
pred(i).A = [0 0 0 0 0 0 1];
pred(i).b = 50;
pred(i).loc = 1:4;

i = i+1;
pred(i).str = 'b2';
pred(i).A = [0 0 0 0 0 0 1];
pred(i).b = 250;
pred(i).loc = 1:4;

i = i+1;
pred(i).str = 'b3';
pred(i).A = [0 0 0 0 0 0 1];
pred(i).b = 450;
pred(i).loc = 1:4;

i = i+1;
pred(i).str = 'gear12';
pred(i).A = [];
pred(i).b = [];
pred(i).loc = 2;

i = i+1;
pred(i).str = 'gear21';
pred(i).A = [];
pred(i).b = [];
pred(i).loc = 4;

% eq32
i = i+1;
C1 = [0 0 0 1 -1/R2 0 0 ];
d1 = 0.5;
pred(i).str = 'e32';
pred(i).A = C1;
pred(i).b = d1;
pred(i).loc = [2 3];

% e41a
i = i+1;
pred(i).str = 'e41a';
pred(i).A = [0 0 0 -(1 - R1/R2) 0 0 0; ...
    0 0 c2_mu1*AR2 0 0 c2_mu2*(1-R1/R2)*AR2 0];
pred(i).b = [0; ... 
    1];
pred(i).loc = [4 1];

% e41b
i = i+1;
pred(i).str = 'e41b';
pred(i).A = [0 0 0 -(1 - R1/R2) 0 0 0; ...
    0 0 0 (1 - R1/R2) 0 0 0; ...
    0 0 c2_mu1*AR2 0 0 -c2_mu2*(1-R1/R2)*AR2 0];
pred(i).b = [0.5;...
    0; ...
    1];
pred(i).loc = [4 1];

% e41c
i = i+1;
pred(i).str = 'e41c';
pred(i).A = [0 0 0 (1 - R1/R2) 0 0 0; ...
    0 0 -c2_mu1*AR2 0 0 c2_mu2*(1-R1/R2)*AR2 0];
pred(i).b = [-0.5; ...
    1];
pred(i).loc = [4 1];

phi = ' [] (gear21 -> b3)' %#ok<NOPTS>

disp(' ')
disp('Total Simulation time:')
time = 60 %#ok<NOPTS>

disp(' ')
disp('Set S-Taliro options:')
opt = staliro_options();
opt.dispinfo = 1;
opt.runs = 1;
opt.black_box = 1;
opt.spec_space = 'X';
opt.rob_scale = 500;
opt.taliro = 'dp_taliro';

% Set simulations in parallel using the Cross-Entropy optimization method
opt.optimization_solver = 'CE_Taliro';
opt.optim_params.n_tests = 40;
opt.n_workers = 2;

% Set hybrid distance
opt.taliro_metric = 'hybrid';
opt.map2line = 0;

opt  %#ok<NOPTS>

disp(' ')
disp(' Press any key to continue ...')
disp(' ')
pause

disp(' ')
disp('Running S-TaLiRo ...')

tic
[results, history] = staliro(model,init_cond,input_range,cp_array,phi,pred,time,opt);
toc

results.run(results.optRobIndex).bestRob
results.run(results.optRobIndex).time
results.run(results.optRobIndex).nTests

[T, XT, YT, LT] = model(results.run(results.optRobIndex).bestSample,results.run(results.optRobIndex).time);

plot_powertrain(T,[XT LT])
figure
plot(XT(:,end))

rmpath('../../benchmarks/Powertrain')



