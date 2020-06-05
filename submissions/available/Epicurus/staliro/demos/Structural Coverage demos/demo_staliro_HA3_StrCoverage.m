% In this demo the requirement falsifies at sample 150
%
% Best ==> <0,4.0213>
% Best ==> <0,-1.8176>
% FALSIFIED at sample ,150!

clear;
warning off;
bdclose all;
model_name='BlackBoxHA3';
model=str2func(model_name);
slCharacterEncoding('Shift_JIS');

init_cond = [];
input_range = [0 100;0 100;0 100;0 100;0 100;0 100;0 100;0 100;-5 5];

cp_array = [1 1 1 1 1 1 1 1 1];

 phi = '(!(<>_[0,0.1](predi1/\predi2/\predi3)))';


i=1;
 preds(i).str='predi1';
 preds(i).A = [0 0 0 0 0 0 0 0 0 1 0 0];
 preds(i).b = [-8 ]';
 preds(i).loc={[] [] []};


 i=2;
 preds(i).str='predi2';
 preds(i).A = [0 0 0 0 0 0 0 0 0 0 1 0];
 preds(i).b = [-100]';
 preds(i).loc={[] [] []};

 i=3;
 preds(i).str='predi3';
 preds(i).A = [0 0 0 0 0 0 0 0 0 0 0 1];
 preds(i).b = [-20]'; 
 preds(i).loc={[] [] []};
 

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

opt.seed=41009338; 
opt.runs=1;


opt.SampTime=0.01024;
opt.spec_space='Y';
opt.loc_traj='none';
opt.dispinfo=1;
% opt.taliro_metric='none';
opt.taliro_metric='hybrid';
opt.rob_scale=100;
opt.taliro='dp_taliro';
opt.map2line=0;
opt.hasim_params=[1 0 0 0];

opt.StrlCov_params.chooseBestSample=1;
opt.StrlCov_params.nLocUpdate = 1;
opt.StrlCov_params.locSearch='specific';
opt.StrlCov_params.specificLoc=[1 1 1];
opt.StrlCov_params.locationEncoding='independent';
opt.StrlCov_params.numOfMultiHAs=[2 2 2];

opt;

disp(' ')
disp('Running S-TaLiRo ')

tic
 [locHis,listOfCheckedLocations ,seenList,unseenList,results, history,falsify] = Structural_Coverage(model,init_cond,input_range,cp_array,phi,preds,time,opt);
toc


