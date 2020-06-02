% This is demo file for Example 1 in the EMSOFT 2015 paper.
% This demo uses location information.
% This demo crashes dp_taliro.

clear
warning off;
init_cond = [-1 1; -1 1];
input_range = [];
cp_array = [];

% Hybrid automaton information
region = [0.85 0.95; 0.85 0.95];
init.loc = [1 2];
init.cube = init_cond;
loc(1).dyn = 1;
loc(1).f = @(t,x,u) [x(1) - x(2) + 0.1*t; ...
            x(2) * cos(2*pi*x(2)) - x(1)*sin(2*pi*x(1)) + 0.1 * t];
loc(2).dyn = 0;
loc(2).A = [1 0; -1 1];
loc(2).b = [0; 0];

CLG = {2;[]};
GRD(2,2).A = [];
GRD(2,2).b = [];
GRD(1,2).A = [-1 0 ; 1 0 ; 0 -1 ; 0 1 ];
GRD(1,2).b = [-region(1,1); region(1,2); -region(2,1); region(2,2)];
% GRD(2,1).A = {[1 0 ]  [-1 0 ]  [0 1 ] [0 -1 ]};
% GRD(2,1).b = {region(1,1), -region(1,2), region(2,1), -region(2,2)};

model = hautomaton(init,loc,CLG,GRD);
% model = @blackbox_simple_nonlin_HA_model;

phi = '[]!a /\ []!b';

ii = 1;
preds(ii).str='a';
preds(ii).A = [-1 0; 1 0; 0 -1; 0 1];
preds(ii).b = [1.8; -1.4; 1.6; -1.4];

ii = 2;
preds(ii).str='b';
preds(ii).A = [-1 0; 1 0; 0 -1; 0 1];
preds(ii).b = [-3.7; 4.1; 1.6; -1.4];

time = 2;

opt = staliro_options();

opt.runs = 1;
opt.spec_space = 'X';
opt.ode_solver = 'ode15s';
opt.n_workers = 1;
opt.optimization_solver = 'SA_Taliro';
opt.taliro_metric = 'none';
opt.map2line = 0;
opt.optim_params.n_tests = 30;
opt.hasim_params = [1 0.05 0 0 0];
% opt.black_box = 1;

% [results, history] = staliro(model,model.init.cube,input_range,cp_array,phi,preds,time,opt);

% Coverage options
 opt.StrlCov_params.multiHAs = 0;
 opt.StrlCov_params.chooseBestSample=1;
 opt.StrlCov_params.locationEncoding='independent';
 opt.StrlCov_params.locSearch='random';
 opt.StrlCov_params.nLocUpdate=10;
% 
% 
 tic
   [locHis,listOfCheckedLocations ,seenList,unseenList] = Structural_Coverage(model,init_cond,input_range,cp_array,phi,preds,time,opt);
 toc

