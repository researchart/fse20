clear;
warning off;
model_name='demo_file';

init_cond = [];
input_range = [0 100;-5 5;0 0.5;0 100;0 4;0 100];

cp_array = [1 1 1 1 1 1];

 phi = '(!(<>_[0,0.1](predi1/\predi2/\predi3)))';


i=1;
 preds(i).str='predi1';
 preds(i).A = [1 0 0 0 ];
 preds(i).b = [-8 ]';
 

 i=2;
 preds(i).str='predi2';
 preds(i).A = [0 1 0 0 ];
 preds(i).b = [-100]';
 

 i=3;
 preds(i).str='predi3';
 preds(i).A = [0 0 1 1 ];
 preds(i).b = [-20]'; 
 
 

time = 0.1;

opt = staliro_options();
opt.optimization_solver='SA_Taliro';
opt.ode_solver='default';
opt.falsification=1;
opt.interpolationtype={'const'};
opt.optim_params.dispStart=10;
opt.optim_params.dispAdap=10;
opt.optim_params.n_tests=100;
opt.n_workers=1; 

opt.runs=1;


opt.SampTime=0.01024;
opt.spec_space='Y';
opt.loc_traj='none';
opt.dispinfo=1;
opt.rob_scale=100;
opt.taliro='dp_taliro';
opt.map2line=0;
opt.hasim_params=[1 0 0 0];

opt.StrlCov_params.chooseBestSample=0;
opt.StrlCov_params.nLocUpdate = 10;
opt.StrlCov_params.locSearch='random';
opt.StrlCov_params.locationEncoding='combinatorial';

% Set the s-taliro to instument the model 
opt.StrlCov_params.instumentModel=1;

opt;

disp(' ')
disp('Running S-TaLiRo ')

tic
 [locHis,listOfCheckedLocations ,seenList,unseenList,results, history,falsify] = Structural_Coverage(model_name,init_cond,input_range,cp_array,phi,preds,time,opt);
toc

disp('Coverage information');
disp('List of all visited locations:');
disp(locHis);
disp('List of location predicates that are tested:');
disp(listOfCheckedLocations);
disp('List of location predicates that are visited:');
disp(seenList);
if(isempty(seenList))
    disp('List is empty');
end
disp('List of location predicates that are not visited:');
disp(unseenList);
if(isempty(unseenList))
    disp('List is empty');
end

