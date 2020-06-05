% This is a demo for the Vacuity Aware Falsification
%
% We present the Powertrain Control Verification Benchmark with various 
% specifications
%
% (C) Adel Dokhanchi, 2017, Arizona State University

clear;
warning('off','all');
cd('..')
cd('SystemModelsAndData')

open AbstractFuelControl_M1;
model = @BlackBoxAbstractFuelControl;

% total simulation time
simTime = 50 ; 
% time to start measurement, mainly used to ignore 
measureTime = 1;  
% number of control points, here we use onstant engine speed
cp_array = [1;10] ; 

fault_time = 100; 
% setting time
eta = 1;
% parameter h used for event definition
h = 0.03;
% parameter related to the period of the pulse signal
zeta_min = 5;
%
C = 0.05;
Cr = 0.1;
Cl = 0.1;
taus = 10 + eta;

% default settings
spec_num = 1; %specification measurement
fuel_inj_tol = 1.0; 
MAF_sensor_tol = 1.0;
AF_sensor_tol = 1.0;
initial_cond = [];%[0 61.1;10 30];

%% Display and user feedback
disp(' ')
disp('This is the Powertrain Control Verification Benchmark problem for the ')
disp('Vacuity Aware Falsification.')
disp(' ')
disp('Press any key to continue')

opt = staliro_options();
nform  = 1;
phi_nat{nform} = ['Always from 11 to 50 if "rise" or "fall" happens for throttle angle then', char(10) ,...
'          always from 1 to 5 the norm of signal "mu" should be bounded by +/- 0.01.', char(10) ,...
'          where "rise" event is represented as low/\<>_(0,0.03)high,', char(10) ,...
'          "fall" event is represented as high/\<>_(0,0.03)low, and', char(10) ,...
'          "mu" is the normalized error signal that indicates the error in the value', char(10) ,...
'          of the state Air/Flow ratio from a reference value.'];

phi{nform} = ['[]_(' num2str(taus) ',' num2str(simTime) ')(((low/\<>_(0,' ...
            num2str(h) ')high) \/ (high/\<>_(0,' num2str(h) ')low))' ...
            '-> []_[' num2str(eta) ',' num2str(zeta_min) '](utr /\ utl))'];

nform  = nform+1;
phi_nat{nform} = ['Always from 11 to 50 if "fall" happens for throttle angle then', char(10) ,...
'          always from 1 to 5 the norm of signal "mu" should be bounded by +/- 0.02.', char(10) ,...
'          where "fall" event is represented as high/\<>_(0,0.03)low, and', char(10) ,...
'          "mu" is the normalized error signal that indicates the error in the value', char(10) ,...
'          of the state Air/Flow ratio from a reference value.'];
phi{nform} = ['[]_(' num2str(taus) ',' num2str(simTime) ')((high /\ <>_(0,' num2str(h), ')low) -> ([]_(' ...
            num2str(eta) ',' num2str(zeta_min) ') utl /\ utr))'];

disp('The set of specifications for the Automatic Transmission model:')
for j = 1:nform
    disp(['   ',num2str(j),'. NAT: ',phi_nat{j}])
    disp(['      MTL: ',phi{j}])
    disp(' ')
end
form_id_1 = input('Choose a specification to falsify:');
disp(' ')

if form_id_1==1
    Ut = 0.02;
    input_range = [900  1100; 0 61.1]; 
    low=8.8;
    high=-40;
elseif form_id_1==2
    low=49.9;
    high=-70.1;
    input_range = [900  1100; 0 81.2]; 
    Ut = 0.04;
else
    error('Select only 1, or 2');       
end


opt.black_box = 1;
opt.SampTime = 0.05;
opt.spec_space = 'Y';
opt.interpolationtype={'const','pconst'};
opt.n_workers = 1;
opt.runs = 1;


disp(' ')
disp(' 1. Simulated Annealing')
disp(' 2. Uniform Random Sampling')
disp(' ')

search_id = input('Choose an optimization algorithm for VAF Stage 1 :');

if search_id==1
    opt.vacuity_param.optimizer_Stage1_VAF='SA_Taliro';
elseif search_id==2
    opt.vacuity_param.optimizer_Stage1_VAF='UR_Taliro';
else
    error('Select only 1 or 2');    
end

search_id = input('Choose an optimization algorithm for VAF Stage 2 :');

if search_id==1
    opt.optimization_solver='SA_Taliro';
elseif search_id==2
    opt.optimization_solver='UR_Taliro';
else
    error('Select only 1 or 2');    
end

i=0;
i = i+1;
preds(i).str = 'low'; % for the pedal input signal
preds(i).A =  [0 0 1] ;
preds(i).b =  low ;
i = i+1;
preds(i).str = 'high'; % for the pedal input signal
preds(i).A =  [0 0 -1] ;
preds(i).b =  high ;
i = i+1;
preds(i).str = 'utr'; % u<=Ut
preds(i).A =  [1 0 0] ;
preds(i).b =  Ut ;
i = i+1;
preds(i).str = 'utl'; % u>=-Ut
preds(i).A =  [-1 0 0] ;
preds(i).b =  Ut ;
i = i+1;

n_tests = 100;
opt.optim_params.n_tests = n_tests; % number of tests

opt.vacuity_param.number_of_runs = 5;
opt.seed=2017;
[pref,suff,n_fals]=VAF(model, initial_cond, input_range, cp_array, phi{form_id_1}, preds, simTime, opt);
disp(' ')
disp('**************************************************************')
disp([' Number of falsifications : ',num2str(n_fals),'/',num2str(opt.vacuity_param.number_of_runs)])
disp('**************************************************************')
disp(' ')

cd('..')
cd('VAF demos')



