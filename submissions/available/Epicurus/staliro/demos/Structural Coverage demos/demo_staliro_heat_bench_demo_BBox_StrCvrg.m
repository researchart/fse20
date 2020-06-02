% S-Taliro script

clear 

warning off;

model = @BlackBoxHeat;
load heat30;
time = 1;%24;
cp_array = [1];
input_range = [1 2];
X0 = [17*ones(10,1) 18*ones(10,1)];
zero10x10=zeros(10);
i=1;
phi = '[]p';
preds(i).str = 'p';
 preds(i).A = [-eye(10)];
  preds(i).b = -[14.50; 14.50; 13.50; 14.00; 13.00; 14.00; 14.00; 13.00; 13.50; 14.00];

opt = staliro_options();
opt.runs = 1;
opt.black_box=1;
opt.n_workers=1;
opt.optim_params.n_tests=20;
opt.taliro_metric='none';
opt.optimization_solver='SA_Taliro';
opt.ode_solver='default';
opt.falsification=1;
opt.interpolationtype={'const'};

opt.StrlCov_params.multiHAs=1;
opt.StrlCov_params.nLocUpdate = 3;
opt.StrlCov_params.chooseBestSample=0;
opt.StrlCov_params.locationEncoding='combinatorial';
opt.StrlCov_params.numOfMultiHAs=[2 2 2 2 2 2 2 2 2 2];

% opt.StrlCov_params.locSearch='specific';
% opt.StrlCov_params.specificLoc=[1 1 1 1 1 1 1 2 1 1 ;1 1 1 2 1 1 1 1 2 2];
% opt.StrlCov_params.specificLoc={[1] [1] [1 2] [1] [1] [1] [2] [1] [1] [1 2]; ...
%                                      1 [] 1 1 [1 2] 1 1 1 1 1 ; ...
%                                  1 1 1 1 2 1 [] 1 2 2; ...
%                                  [] [] [] [] [] [] [] [] [] [];
%                                  1 1 1 1 1 1 1 2 1 1 ;1 1 1 2 1 1 1 1 2 2};
% opt.StrlCov_params.specificLoc={[] [] [] [] [] [] [] [] [] [];[] [] [] [] [] [] [] [] [] [] ;[] [] [] [] [] [] [] [] [] []};
 

% opt.sa_params.apply_local_descent = 1;
[locHis,listOfCheckedLocations ,seenList,unseenList,results,history,falsify] = Structural_Coverage(model,X0,input_range,cp_array,phi,preds,time,opt);

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



