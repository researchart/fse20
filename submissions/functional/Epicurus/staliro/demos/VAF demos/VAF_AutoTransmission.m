% This is a demo for the Vacuity Aware Falsification presented in CASE 2017
%
% We present the Automatic Transmission benchmark with various 
% specifications
%
% (C) Adel Dokhanchi, 2017, Arizona State University

clear;
bdclose all;
warning('off','all');

%% Display and user feedback
disp(' ');
disp('This is the Automatic Transmission problem for the Vacuity Aware')
disp('Falsification presented in the CASE 2017 paper.')
disp(' ')
disp('Press any key to continue')

cd('..')
cd('SystemModelsAndData')
opt = staliro_options();

nform  = 1;
phi_nat{nform} = 'There should be no transition from gear two to gear one and back to gear two in less than 2.5 sec.';
phi{nform} = '[]_[0,27.5]( (!gear1 /\ X gear1) -> []_(0,2.5](gear1) )';

nform  = nform+1;
phi_nat{nform} = 'There should be no transition from gear two to gear one and back to gear two in less than 2.5 sec.';
phi{nform} = '[]_[0,27.5]( (!gear1 /\ X gear1) -> []_(0,2.5](rpm3))';

disp('The set of specifications for the Automatic Transmission model:')
for j = 1:nform
    disp(['   ',num2str(j),'. NAT: ',phi_nat{j}])
    disp(['      MTL: ',phi{j}])
    disp(' ')
end
form_id_1 = input('Choose a specification to falsify:');
disp(' ')
opt.runs = 1;
opt.spec_space = 'Y';
opt.map2line = 0;
opt.n_workers = 1;

disp(' ')
disp(' 1. Simulated Annealing')
disp(' 2. Uniform Random Sampling')
disp(' 3. Cross Entropy ')
disp(' ')

search_id = input('Choose an optimization algorithm for VAF Stage 1 :');

if search_id==1
    opt.vacuity_param.optimizer_Stage1_VAF='SA_Taliro';
elseif search_id==2
    opt.vacuity_param.optimizer_Stage1_VAF='UR_Taliro';
elseif search_id==3 
    opt.vacuity_param.optimizer_Stage1_VAF='CE_Taliro';
else
    error('Select only 1, 2 or 3');    
end

search_id = input('Choose an optimization algorithm for VAF Stage 2 :');

if search_id==1
    opt.optimization_solver='SA_Taliro';
elseif search_id==2
    opt.optimization_solver='UR_Taliro';
elseif search_id==3 
    opt.optimization_solver='CE_Taliro';
else
    error('Select only 1, 2 or 3');    
end

n_tests = 1000;
opt.optim_params.n_tests = n_tests; 
init_cond = [];

input_range = [0 100;0 500];
model = @BlackBoxAutotrans04;
    
cp_array = [7,3];
opt.loc_traj = 'end';
opt.taliro_metric = 'hybrid_inf';
opt.taliro = 'dp_taliro';
opt.black_box = 1;
opt.interpolationtype = {'pchip'};
ii = 1;
preds(ii).str = 'gear1';
preds(ii).A = [];
preds(ii).b = [];
preds(ii).loc = 1;
ii = ii+1;
preds(ii).str='rpm3';
preds(ii).A = [0 1];
preds(ii).b = 3000;
preds(ii).loc = [1:4]; 
    
opt.vacuity_param.number_of_runs = 3;
simTime=30;
[pref,suff,n_fals]=VAF(model, init_cond, input_range, cp_array, phi{form_id_1}, preds, simTime, opt);
disp(' ')
disp('**************************************************************')
disp([' Number of falsifications : ',num2str(n_fals),'/',num2str(opt.vacuity_param.number_of_runs)])
disp('**************************************************************')
disp(' ')

cd('..')
cd('VAF demos')



