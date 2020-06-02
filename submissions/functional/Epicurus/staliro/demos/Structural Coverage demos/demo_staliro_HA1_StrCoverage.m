% In this demo the requirement falsifies at sample 182
%
% Best ==> <0,0.13012>
% Best ==> <0,0.10986>
% Best ==> <0,-0.34173>
% FALSIFIED at sample ,182!

clear;
warning off;
bdclose all;
model_name='BlackBoxHA1';
model=str2func(model_name);
slCharacterEncoding('Shift_JIS');

init_cond = [];
input_range = [0 100;0 100;0 100;0 100;0 100;0 100;0 100;0 100;-5 5];

cp_array = [1 1 1 1 1 1 1 1 1];

 phi = '(!predi1)';
i=1;
 preds(i).str='predi1';
 preds(i).A = [0 0 0 0 0 0 0 0 1];
 preds(i).b = [-8 ]';
 preds(i).loc={[]};


time = 0.1;

opt = staliro_options();
opt.StrlCov_params.multiHAs=1;
opt.optimization_solver='SA_Taliro';
opt.ode_solver='default';
opt.falsification=1;
opt.interpolationtype={'const'};
opt.black_box=1;
opt.optim_params.dispStart=10;
opt.optim_params.dispAdap=10;
opt.optim_params.n_tests=1000;
opt.n_workers=1; 


opt.seed=1477374206;
opt.runs=1;


opt.SampTime=0.01024;
opt.spec_space='Y';
opt.loc_traj='none';
opt.dispinfo=1;
opt.taliro_metric='hybrid';
opt.rob_scale=100;
opt.taliro='dp_taliro';
opt.map2line=0;
opt.hasim_params=[1 0 0 0];

opt.StrlCov_params.chooseBestSample=1;
opt.StrlCov_params.nLocUpdate = 1;
opt.StrlCov_params.locSearch='specific';
opt.StrlCov_params.specificLoc=[1];
opt.StrlCov_params.locationEncoding='independent';
opt.StrlCov_params.numOfMultiHAs=[2];

opt;

disp(' ')
disp('Running S-TaLiRo ')

tic
 [locHis,listOfCheckedLocations ,seenList,unseenList,results, history,falsify] = Structural_Coverage(model,init_cond,input_range,cp_array,phi,preds,time,opt);
toc


