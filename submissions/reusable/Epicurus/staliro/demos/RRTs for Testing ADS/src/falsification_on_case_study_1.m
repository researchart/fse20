%% Get the state of the random number generator
rand_seed = rng;
tic;

model = staliro_blackbox();
model.model_fcnptr = @model_test_case_1;

init_cond = [[40, 50]; ... %ego x
             [-1.75, 1.75]; ... %ego y
             [-pi/8, pi/8]; ... % ego theta
             [10, 15]; ... % ego speed
             [20, 30]; ... % agent 1 x
             [-3.5, 3.5]; ... % agent 1 y
             [0, 15]; ... % agent 1 speed
             [0, 25]; ... % agent 2 x
             [-3.5, 3.5]; ... % agent 2 y
             [0, 15]]; % agent 2 speed
         
input_range = [[-4, 4];
               [0, 30];
               [-4, 4];
               [0, 30]];
           
cp_array = [10, 10, 10, 10];

phi = [];
preds = [];
time = 21;

opt = staliro_options();
opt.runs = 1;
opt.varying_cp_times = 1;
opt.interpolationtype={'linear', 'pconst', 'linear', 'pconst'};
opt.spec_space = 'X';
opt.SampTime = 0.01;
opt.taliro = 'boundary_case_rob';
opt.optimization_solver = 'SA_Taliro';
opt.optim_params.max_time = 600; % 15 minutes = 900 s.
opt.optim_params.n_tests = 2000; % Larger than what's possible in 900s.
opt.falsification = 0;  % Optimization
opt.spec_space = 'X';

[results, history] = staliro(model,init_cond,input_range,cp_array,phi,preds,time,opt);
runtime = toc;

tt = datetime('now');
fname = ['../log/falsification_', num2str(tt.Year),num2str(tt.Month),num2str(tt.Day),'_',num2str(tt.Hour),'_',num2str(tt.Minute)];
save(fname);
