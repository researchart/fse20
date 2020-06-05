% This is a demo for the Vacuity Aware Falsification presented in CASE 2017
%
% We present the Navigation benchmark with various specifications
%
% (C) Adel Dokhanchi, 2017, Arizona State University

clear;
warning('off','all');

%% Display and user feedback
disp(' ')
disp('This is the Navigation benchmark problem for the Vacuity Aware')
disp('Falsification presented in the CASE 2017 paper.')
disp(' ')
disp('Press any key to continue')

opt = staliro_options();
simTime = 12;

%% specifications


i=0;

i = i+1;
Pred(i).str = 'p1';
Pred(i).A = [-1 0 0 0; 0 -1 0 0];
Pred(i).b = [-1.65; -3.65];
Pred(i).loc = 14;

i=i+1;
Pred(i).str = 'p2';
Pred(i).A = [1 0 0 0; 0 1 0 0];
Pred(i).b = [0.75; 1.8];
Pred(i).loc = 5;

i = i+1;
Pred(i).str = 'p3';
Pred(i).A = [-1 0 0 0; 0 -1 0 0];
Pred(i).b = [-1.2; -2.25];
Pred(i).loc = 10;


nform = 0;
nform  = nform+1;
phi_nat{nform} = 'Always within the simulation time if a set p2 is visited, then from that point on a set p3 should not be visited.';
phi{nform} = ['[]_[0,', num2str(simTime), '](p2 -> [](!p3))'];
nform  = nform+1;
phi_nat{nform} = 'Always within the simulation time if a set p3 is visited, then from that point on a set p2 should not be visited.';
phi{nform} = ['[]_[0,', num2str(simTime), '](p3 -> [](!p2))']; 
nform  = nform+1;
phi_nat{nform} = 'Always within the simulation time if a set p2 is visited, then from that point on a set p1 should not be visited.';
phi{nform} = ['[]_[0,', num2str(simTime), '](p2 -> [](!p1))']; 

disp('The set of specifications for the Navigation benchmark model:')
for j = 1:nform
    disp(['   ',num2str(j),'. NAT: ',phi_nat{j}])
    disp(['      MTL: ',phi{j}])
    disp(' ')
end
disp([' O(',Pred(1).str,') = Location {',num2str(Pred(1).loc),'} x {x in R^4 | x_1>=',num2str(-Pred(1).b(1)),' /\ x_2>=',num2str(-Pred(1).b(2)),'}']);
disp([' O(',Pred(2).str,') = Location {',num2str(Pred(2).loc),'} x {x in R^4 | x_1<=',num2str(Pred(2).b(1)),' /\ x_2<=',num2str(Pred(2).b(2)),'}']);
disp([' O(',Pred(3).str,') = Location {',num2str(Pred(3).loc),'} x {x in R^4 | x_1>=',num2str(-Pred(3).b(1)),' /\ x_2>=',num2str(-Pred(3).b(2)),'}']);

form_id_1 = input('Choose a specification to falsify:');
disp(' ')

if form_id_1~=1 && form_id_1~=2  && form_id_1~=3
    error('Select only 1, or 2');
end 

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
    opt.optim_params.n_tests = 200;
elseif search_id==2
    opt.optimization_solver='UR_Taliro';
    opt.optim_params.n_tests = 200;
elseif search_id==3 
    opt.optimization_solver='CE_Taliro';
    opt.optim_params.n_tests = 500;
else
    error('Select only 1, 2 or 3');    
end

%% Model 
init.loc = 13;
init.cube = [0.2 0.8; 3.2 3.8; -0.4 0.4; -0.4 0.4];
A = [4 2 3 4; 3 6 5 6; 1 2 3 6; 2 2 1 1];
id_fig = figure;
model = navbench_hautom_inputs([1 0 id_fig.Number 2 1 0 0 0 0],init,A);

% input signals
u_val = 0.5;
input_range = [-u_val,u_val; -u_val,u_val];
cp_array = [5,5];


%% Falsification parameters

outer_runs = 100;
rectangle('Position',[-Pred(1).b(1), -Pred(1).b(2), ceil(-Pred(1).b(1))+Pred(1).b(1), ceil(-Pred(1).b(2))+Pred(1).b(2)],'FaceColor','y');
rectangle('Position',[0, 1, Pred(2).b(1), Pred(2).b(2)-1],'FaceColor','y');
rectangle('Position',[-Pred(3).b(1), -Pred(3).b(2), ceil(-Pred(3).b(1))+Pred(3).b(1), ceil(-Pred(3).b(2))+Pred(3).b(2)],'FaceColor','y');



opt.spec_space = 'X';
opt.map2line = 0;
opt.taliro_metric = 'hybrid';

opt.runs = 1;
opt.vacuity_param.number_of_runs = 10;

[pref,suff,n_fals]=VAF(model, model.init.cube, input_range, cp_array, phi{form_id_1}, Pred, simTime, opt);
disp(' ')
disp('**************************************************************')
disp([' Number of falsifications : ',num2str(n_fals),'/',num2str(opt.vacuity_param.number_of_runs)])
disp('**************************************************************')
disp(' ')


cd('..')
cd('VAF demos')
