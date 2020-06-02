% This is a demo presents the application of S-TALIRO on the navigation
% benchmark HSCC 04 paper by Fehnker & Ivancic

% (C) Georgios Fainekos 2010 - Arizona State Univeristy

clear

% Best ==> <0,0.0027048>
% Best ==> <0,-0.0052011>
% FALSIFIED at sample ,75!

 init.loc = 5;
 init.cube = [0.2 0.8; 1.2 1.8; -1.4 1.4; -1.4 1.4];
 A = [4 2 3 4; 3 6 5 6; 1 2 3 6; 2 2 1 1];
op=zeros(1,9);
op(1)=1;
op(3)=0;

disp('init.cube');
disp(init.cube);



model = navbench_hautomaton(op ,init,A);
rectangle('Position',[3.25, 0.25, 0.5, 0.5 ],'FaceColor','r');
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
% disp(' O(p11) = {4} x [3.2,3.8] x [0.2,0.8] x R^2')
Pred(i).str = 'p11';
Pred(i).A = [1 0 0 0; -1 0 0 0; 0 1 0 0; 0 -1 0 0];
Pred(i).b = [3.8; -3.2; 0.8; -0.2];
Pred(i).loc = 10;

i=i+1;
% disp(' O(p12) = {8} x [3.2,3.8] x [1.2,1.8] x R^2')
Pred(i).str = 'p12';
Pred(i).A = [1 0 0 0; -1 0 0 0; 0 1 0 0; 0 -1 0 0];
Pred(i).b = [3.8; -3.2; 1.8; -1.2];
Pred(i).loc = 8;

i=i+1;
% disp(' O(p21) = {10} x {x in R^4 | x_1>=1.1 }')
Pred(i).str = 'p21';
Pred(i).A = [-1 0 0 0];
Pred(i).b = [-1.1];
Pred(i).loc = 10;

i=i+1;
% disp(' O(p22) = {5,6} x {x in R^4 | x_2<=1.05 }')
Pred(i).str = 'p22';
Pred(i).A = [0 1 0 0];
Pred(i).b = [1.05];
Pred(i).loc = [5 6];

i=i+1;
% disp(' O(p23) = {9} x {x in R^4 | x_1<=0.9 }')
Pred(i).str = 'p23';
Pred(i).A = [1 0 0 0];
Pred(i).b = [0.9];
Pred(i).loc = 9;

i = i+1;
% disp(' O(p31) = {10} x {x in R^4 | x_1>=1.05 /\ x_2>=2}')
Pred(i).str = 'p31';
Pred(i).A = [-1 0 0 0; 0 -1 0 0];
Pred(i).b = [-1.05; -2];
Pred(i).loc = 10;

i=i+1;
% disp(' O(p32) = {5} x {x in R^4 | x_1<=1 /\ x_2<=1.95}')
Pred(i).str = 'p32';
Pred(i).A = [1 0 0 0; 0 1 0 0];
Pred(i).b = [1; 1.95];
Pred(i).loc = 5;

i = i+1;
% disp(' O(p41) = {10} x {x in R^4 | x_1>=1.2 /\ x_2>=2}')
Pred(i).str = 'p41';
Pred(i).A = [-1 0 0 0; 0 -1 0 0];
Pred(i).b = [-1.2; -2];
Pred(i).loc = 10;

i = i+1;
% disp(' O(p51) =  {4} x [3.25,3.75] x [0.25,0.75] x R^2')
Pred(i).str = 'redAreaLoc4';
Pred(i).A = [1 0 0 0; -1 0 0 0; 0 1 0 0; 0 -1 0 0];
% Pred(i).b = [3.7; -3.3; 0.7; -0.3];
Pred(i).b = [3.75; -3.25; 0.75; -0.25];
Pred(i).loc = 4;

i = i+1;
% disp(' O(p52) =  {} x [3.25,3.75] x [0.25,0.75] x R^2')
Pred(i).str = 'redArea';
Pred(i).A = [1 0 0 0; -1 0 0 0; 0 1 0 0; 0 -1 0 0];
% Pred(i).b = [3.7; -3.3; 0.7; -0.3];
Pred(i).b = [3.75; -3.25; 0.75; -0.25];
Pred(i).loc = [];

i = i+1;
% disp(' O(p61) =  {3} x [2.25,2.75] x [0.25,0.75] x R^2')
Pred(i).str = 'p61';
Pred(i).A = [1 0 0 0; -1 0 0 0; 0 1 0 0; 0 -1 0 0];
% Pred(i).b = [3.7; -3.3; 0.7; -0.3];
Pred(i).b = [2.75; -2.25; 0.75; -0.25];
Pred(i).loc = 3;

i = i+1;
% disp(' O(p62) =  {} x [2.25,2.75] x [0.25,0.75] x R^2')
Pred(i).str = 'p62';
Pred(i).A = [1 0 0 0; -1 0 0 0; 0 1 0 0; 0 -1 0 0];
% Pred(i).b = [3.7; -3.3; 0.7; -0.3];
Pred(i).b = [2.75; -2.25; 0.75; -0.25];
Pred(i).loc = [];

i = i+1;
% disp(' O(ploc1) =  {1} x R^4')
Pred(i).str = 'ploc1';
Pred(i).A = [];
Pred(i).b = [];
Pred(i).loc = 1;

i = i+1;
% disp(' O(ploc1Ab) =  {1} x [3.3,3.7] x [0.3,0.7] x R^2')
Pred(i).str = 'ploc1Ab';
Pred(i).A = [1 0 0 0; -1 0 0 0; 0 1 0 0; 0 -1 0 0];
Pred(i).b = [0.7; -0.3; 0.7; -0.3];
Pred(i).loc = 1;

i = i+1;
% disp(' O(ploc1half) =  {1} x  {x in R^4 | x_2<= 0.5 }')
Pred(i).str = 'ploc1half';
Pred(i).A = [0 1 0 0];
Pred(i).b = [0.5];
Pred(i).loc = 1;

i = i+1;
% disp(' O(ploc1half) =  {x in R^4 | x_2<= 0.5 }')
Pred(i).str = 'phalf';
Pred(i).A = [0 1 0 0];
Pred(i).b = [0.5];
Pred(i).loc = [];

i = i+1;
% disp(' O(ploc5) =  {5} x R^4')
Pred(i).str = 'ploc5';
Pred(i).A = [];
Pred(i).b = [];
Pred(i).loc = 5;

i = i+1;
% disp(' O(ploc2) =  {2} x R^4')
Pred(i).str = 'ploc2';
Pred(i).A = [];
Pred(i).b = [];
Pred(i).loc = 2;

i = i+1;
% disp(' O(ploc6) =  {6} x R^4')
Pred(i).str = 'ploc6';
Pred(i).A = [];
Pred(i).b = [];
Pred(i).loc = 6;


nform = 0;
nform  = nform+1;
phi{nform } = '(!p11) U p12';
nform  = nform+1;
phi{nform} = '[](!p21 \/ (p22 R (!p23)))';
nform  = nform+1;
phi{nform} = '[](p31 -> [](!p32))';
nform  = nform+1;
phi{nform} = '[](p41 -> [](!p32))';
nform  = nform+1;
phi{nform} = '!<>redAreaLoc4';
nform  = nform+1;
phi{nform} = '!<>redArea';
nform  = nform+1;
phi{nform} = '!<>(ploc1/\<>redAreaLoc4)';
nform  = nform+1;
phi{nform} = '!<>(ploc1Ab/\<>redAreaLoc4)';
nform  = nform+1;
phi{nform} = '!<>(ploc1half/\<>redAreaLoc4)';
nform  = nform+1;
phi{nform} = '!<>(phalf/\<>redAreaLoc4)';
nform  = nform+1;
phi{nform} = '!<>(ploc5/\<>(ploc1/\<>(ploc2/\<>redAreaLoc4)))';
nform  = nform+1;
phi{nform} = '!<>(ploc6/\<>p51)';
nform  = nform+1;
phi{nform} = '!<>(ploc6/\<>(ploc2/\<>redAreaLoc4))';
nform  = nform+1;
phi{nform} = '!<>(ploc5/\<>(ploc6/\<>redAreaLoc4))';
nform  = nform+1;
phi{nform} = '!<>p62';
nform  = nform+1;
phi{nform} = '!<>(ploc1/\<>p62)';

metric_id = 1;%input('Choose a metric to use:');

search_id = 1 %input('Choose a search algorithm:');

disp(' ')
time = 15;

disp(' ')
disp('Create an staliro_options object with the default options:')
opt = staliro_options();

disp(' ')
opt.runs = 1;
n_tests=100;
opt.spec_space = 'X';
opt.map2line = 0;
opt.n_workers=1;
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

opt;
opt.seed=201083226;
opt.seed;
form_id = 6;

disp(' ')
disp('Running S-TaLiRo ...')
disp(phi{form_id});
tic
 [results, history] = staliro(model,model.init.cube,input_range,cp_array,phi{form_id},Pred,time,opt);

toc

[ hh , locHis ]= hasimulator(model,[model.init.loc 0 results.run(results.optRobIndex).bestSample(:,1)'],12,'ode45',[1 0 0 0]);
plot(hh(:,3),hh(:,4))

opt.seed;

form_id = 7;
opt.taliro_metric = 'hybrid';

disp(' ')
disp('Running S-TaLiRo ...')
disp(phi{form_id});
tic
 [results, history] = staliro(model,model.init.cube,input_range,cp_array,phi{form_id},Pred,time,opt);

toc

[ hh , locHis ]= hasimulator(model,[model.init.loc 0 results.run(results.optRobIndex).bestSample(:,1)'],12,'ode45',[1 0 0 0]);
plot(hh(:,3),hh(:,4),'m')


disp(locHis);

