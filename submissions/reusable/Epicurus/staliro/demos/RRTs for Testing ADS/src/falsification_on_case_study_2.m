%% Get the state of the random number generator
rand_seed = rng;
tic;

model = staliro_blackbox();
model.model_fcnptr = @model_test_case_many_cars;

init_cond = [[6.5, 11.25]; ... % agent 1 y
             [5, 15]; ... % agent 1 speed
             [3, 4]; ... % agent 2 y
             [3, 4]; ... % agent 3 y
             [3, 4]]; % agent 4 y
         
input_range = [[-0.75, 11.25]; % agent 1 y
               [0, 30]]; % agent 1 speed (x and theta generated in model)
           
cp_array = [7, 7];

phi = [];
preds = [];
time = 12;

opt = staliro_options();
opt.runs = 1;
opt.varying_cp_times = 0;
opt.interpolationtype={'linear', 'pconst'};
opt.spec_space = 'X';
opt.SampTime = 0.01;
opt.taliro = 'boundary_case_rob_many_cars';
opt.optimization_solver = 'SA_Taliro';
opt.optim_params.max_time = 1800; % 15 minutes = 900 s.
opt.optim_params.n_tests = 4000; % Larger than what's possible in 900s.
opt.falsification = 0;  % Optimization
opt.spec_space = 'X';

[results, history] = staliro(model,init_cond,input_range,cp_array,phi,preds,time,opt);
runtime = toc;

tt = datetime('now');
fname = ['../log/falsification_many_cars_', num2str(tt.Year),num2str(tt.Month),num2str(tt.Day),'_',num2str(tt.Hour),'_',num2str(tt.Minute)];
save(fname);
