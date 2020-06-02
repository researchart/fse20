% This is a demo on how to use the 'BlackBox' option to do search over
% system parameters rather than input signals 
%
% In this set up file, we set the search over a two dimensional space which
% captures the bounds of two unknown bounded constant system parameters.
% Then, inside the m-function 'BlackBoxSimpleODEParam.m' we map the search
% variables to the system parameters.
%
% BlackBoxSimpleODEParam calls the SimpleODE Simulink model which has no
% inputs and a single output.
%
% See also: BlackBoxSimpleODEParam, SimpleODE

% (C) Georgios Fainekos 2013 - Arizona State University

clear

cd('..')
cd('SystemModelsAndData')

% Define the search space
init_cond = [0 3; 0 2];
input_range = [];
cp_array = [];

% Open the m-function "BlackBoxSimpleODEParam" to see how the blackbox
% model is defined
model = staliro_blackbox;
model.model_fcnptr = @BlackBoxSimpleODEParam;
% Maintained for backwards compatibility: Blackbox models used to be
% defined as function pointers in older S-Taliro versions.
% model = @BlackBoxSimpleODEParam;  

phi = '[]a';

% constraint a is the predicate y<=3
ii = 1;
preds(ii).str = 'a';
preds(ii).A = 1;
preds(ii).b = 2;

% simulation time
time = 10;

% Set the BlackBox option and the output space
opt = staliro_options();
opt.runs = 1;
% Maintained for backwards compatibility: option had to be set to 1 for
% blackbox models
% opt.black_box = 1;
opt.spec_space = 'Y';
opt.optim_params.n_tests = 500;

% Call S-Taliro 
[results, history] = staliro(model,init_cond,input_range,cp_array,phi,preds,time,opt);

% Get Falsifying trajectory
% Alternatively, you can use 
% [T1,XT1,YT1] = BlackBoxSimpleODEParam(results.run(bestRun).bestSample,time);
% to reproduce the output signal since the model does not take any signals
% as input.
bestRun = results.optRobIndex;
[T1,XT1,YT1] = SimBlackBoxMdl(model,init_cond,input_range,cp_array,results.run(bestRun).bestSample,time,opt);

% Plot the results 
figure(1)
clf
plot(T1,YT1)

disp('Constant input:')
results.run(bestRun).bestSample(1)

disp('Gain:')
results.run(bestRun).bestSample(2)

open SimpleODE

cd('..')
cd('Blackbox Falsification demos')

