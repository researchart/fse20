% This is a demo for using S-TALIRO for multiple parameter estimation
% with the automatic transmission model
%
% (C) Bardh Hoxha, 2014, Arizona State University.

clear

disp(' ')
disp('This is the set of demos for parameter estimation using the')
disp('parameter falsification domain algorithms')
disp(' ')
disp('Press any key to continue')

pause
cd('..')
cd('SystemModelsAndData');
model = 'sldemo_autotrans_mod01';
init_cond = [];
input_range = [0 100];
cp_array = 7;

disp(' ')
disp(' ')

nform = 0;
nform  = nform+1;
phi{nform}='[](speedp /\ rpm1p)';
disp(['  1. ', phi{nform}]);
nform  = nform+1;
phi{nform}='!(<>_[0,t1]speedG100 /\  []rpm2p)';
disp(['  2. ',phi{nform}]);
nform  = nform+1;
phi{nform}='[](speedp /\ rpm1p) /\ <>_[0,t1](speedG150)';
disp(['  3. ',phi{nform}]);
disp(' ')
form_id_1 = input('Please select the specification you would like to use:');

%predicate definitions
ii = 1;
preds(ii).str = 'speedp';
preds(ii).par = 'speedPar';
preds(ii).A = [1 0];
preds(ii).b = 100;
preds(ii).value = 100;
preds(ii).range = [0 160];
preds(ii).Normalized = 1;
preds(ii).NormBounds = 1;

ii=ii+1;
preds(ii).str='rpm1p';
preds(ii).par = 'rpm1Par';
preds(ii).A = [0 1];
preds(ii).b = 4500;
preds(ii).value = 4500;
preds(ii).range = [3000 8000];
preds(ii).Normalized = 1;
preds(ii).NormBounds = 1;

ii = ii+1;
preds(ii).par = 't1';
preds(ii).value = 30;
preds(ii).range = [0 60];
preds(ii).Normalized = 1;
preds(ii).NormBounds = 1;

ii=ii+1;
preds(ii).str='speedG100';
preds(ii).A = [-1 0];
preds(ii).b = -100;
preds(ii).Normalized = 1;
preds(ii).NormBounds = 1;

ii=ii+1;
preds(ii).str='rpm2p';
preds(ii).par = 'rpm2Par';
preds(ii).A = [0 1];
preds(ii).b = 4500;
preds(ii).value = 4500;
preds(ii).range = [3000 8000];
preds(ii).Normalized = 1;
preds(ii).NormBounds = 1;

ii=ii+1;
preds(ii).str='speedG150';
preds(ii).A = [-1 0];
preds(ii).b = -150;
preds(ii).Normalized = 1;
preds(ii).NormBounds = 1;

disp(' ')
disp('Total Simulation time:')
time = 60 %#ok<*NOPTS>

opt = staliro_options();
opt.interpolationtype={'pchip'};
opt.runs = 20;
opt.optimization_solver = 'RGDA_Taliro';
opt.optim_params.n_tests = 100;
opt.taliro = 'dp_taliro';
opt.falsification = 0;
opt.parameterEstimation = 1;
opt.normalization = 1;
opt.n_workers = 1;

tic
[results] = parameter_falsification_domain(model,init_cond,input_range,cp_array,phi{form_id_1},preds,time,opt);
toc

disp(' ')
disp(' See results for the polyhedron and generated knees for the parameter falsification domain')

cd('..')
cd('Parameter mining demos');

