% This is a demo presents the application of S-TALIRO on the navigation
% benchmark HSCC 04 paper by Fehnker & Ivancic

% (C) Georgios Fainekos 2010 - Arizona State Univeristy

clear
warning off

 init.loc = 9;
 init.cube = [0.2 0.8; 2.2 2.8; -1 1; -1 1];


 A = [4 2 3 4; 3 6 5 6; 1 2 3 6; 2 2 1 1]; % original map
op=zeros(1,9);
op(1)=1;
op(4)=2;
op(5)=0;

disp('init.cube');
disp(init.cube);



model = navbench_hautomaton(op ,init,A);
   rectangle('Position',[2.25, 0.25, 0.5, 0.5 ],'FaceColor','y');
   str = num2str(3);
   hh = text(2.5,0.5,str);
    set(hh,'FontSize',12)

  
disp(' ')
disp('The initial conditions defined as a hypercube:')
model.init.loc
model.init.cube

disp(' ')
disp('No input signals')
input_range = []
cp_array=[]

disp(' ')
disp('Propositions:')

i=0;

i=i+1;
disp(' O(p64) =  {} x [2.25,2.75] x [0.25,0.75] x R^2')
Pred(i).str = 'p64';
Pred(i).A = [1 0 0 0; -1 0 0 0; 0 1 0 0; 0 -1 0 0];
Pred(i).b = [2.75; -2.25; 0.75; -0.25];
% Pred(i).loc = [];


nform = 0;
nform  = nform+1;
phi{nform} = '!<>p64';



disp(' ')
for j = 1:nform
    disp(['   ',num2str(j),' . phi_',num2str(j),' = ',phi{j}])
end
form_id = 1;

disp(' ')
disp(' Hybrid with distance to guards')
metric_id = 1;%input('Choose a metric to use:');

disp(' ')
disp(' Simulated Annealing with Monte Carlo Sampling')
search_id = 1;%input('Choose a search algorithm:');

disp(' ')
disp('Total Simulation time:')
% if form_id==1
%     time = 25
% else
%     time = 12
% end

time = 10;

disp(' ')
disp('Create an staliro_options object with the default options:')
opt = staliro_options();

disp(' ')
disp('Change options:')
opt.runs = 1;
n_tests=10;
%n_tests=50;
opt.spec_space = 'X';
opt.ode_solver = 'ode15s';
opt.n_workers=1;
opt.map2line = 0;

opt.StrlCov_params.multiHAs=0;
opt.StrlCov_params.nLocUpdate=3;
opt.StrlCov_params.locSearch='random';
% opt.StrlCov_params.specificLoc=[1 2;4 5;3 6;7 8;9 10;11 12;13 14];
opt.StrlCov_params.chooseBestSample=0;
 
if search_id==1
    opt.optimization_solver = 'SA_Taliro';
	opt.optim_params.n_tests = n_tests;
elseif search_id==2
    opt.optimization_solver = 'UR_Taliro';
	opt.optim_params.n_tests = n_tests;
elseif search_id == 3
  opt.optimization_solver = 'CE_Taliro';
else
    error('Search option not supported')
end

if metric_id==1
    opt.taliro_metric = 'none';
elseif metric_id==2
    opt.taliro_metric = 'hybrid_inf';
elseif metric_id==3
    opt.taliro_metric = 'hybrid';
else
    error('Metric option not supported')
end


disp(' ')
disp('Running S-TaLiRo ...')
tic
    [locHis,listOfCheckedLocations ,seenList,unseenList,results,history,falsify]= Structural_Coverage(model,model.init.cube,input_range,cp_array,phi{form_id},Pred,time,opt);

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



