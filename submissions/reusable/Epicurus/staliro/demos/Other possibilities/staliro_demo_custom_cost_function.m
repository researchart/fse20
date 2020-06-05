% This is a demo for using S-TALIRO with a custom cost function
% (C) B. Hoxha 2016 - Arizona State Univeristy

clear

disp(' ')
disp('This is an S-TaLiRo demo for using a custom cost function.')
disp('As a model, we use the Automatic Transimssion Simulink Demo')
disp('We use the custom_cost function which is stored in the /auxiliary folder')

cd('..')
cd('SystemModelsAndData')
model = 'sldemo_autotrans_mod01';

disp(' ')
disp('The constraints on the initial conditions defined as a hypercube:')
init_cond = []

disp(' ')
disp('The constraints on the input signal defined as a range:')
input_range = [0 100]
disp(' ')
disp('The number of control points for the input signal:')
cp_array = 7

phi = []; 
preds = [];

disp(' ')
disp('Total Simulation time:')
time = 30

disp(' ')
disp('Create an staliro_options object with the default options:')
opt = staliro_options();

disp(' ')
disp('Change options:')
opt.runs = 1;
n_tests = 1000;
opt.interpolationtype={'pconst'};


% Custom function for the cost
opt.taliro = 'custom_cost';
% auxiliaryData for the custom function
opt.customCostAuxData = [-1 1 2 3 4 5 6 7 8 9 10];

opt

opt.optimization_solver = 'SA_Taliro';
opt.optim_params.n_tests = n_tests;

disp(' ')
disp('Running S-TaLiRo with chosen solver ...')
tic
results = staliro(model,init_cond,input_range,cp_array,phi,preds,time,opt);
runtime=toc;

runtime

results.run(results.optRobIndex).bestRob

cd('..')
cd('Other possibilities')
