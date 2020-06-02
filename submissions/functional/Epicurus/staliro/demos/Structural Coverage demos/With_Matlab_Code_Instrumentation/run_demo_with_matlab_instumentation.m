figure
clear all
close all
warning off
model_name = ifThenElseModel2BBox('hybrid_system','hybrid');
model=str2func(model_name);

disp(' ')
disp('Initial conditions')
init_cond = [];

disp(' ')
disp('No input signals:')
input_range = [-1 1; -1 1]
% input_range = [0.5, 0.95; 0.5, 0.95]
cp_array = [1,1];

disp(' ')
disp('The specification:')

i = 1;
pred(i).str = 'a';
pred(i).A = [1   0 0 0 0 0 0 0 0 0 0 0 ;
            -1   0 0 0 0 0 0 0 0 0 0 0 ;
             0   1 0 0 0 0 0 0 0 0 0 0 ;
             0  -1 0 0 0 0 0 0 0 0 0 0 ];
pred(i).b = [-1.4;1.8;-1.4;1.6];
pred(i).loc=[];

i = i+1;
pred(i).str = 'b';
pred(i).A = [1   0 0 0 0 0 0 0 0 0 0 0 ;
            -1   0 0 0 0 0 0 0 0 0 0 0 ;
             0   1 0 0 0 0 0 0 0 0 0 0 ;
             0  -1 0 0 0 0 0 0 0 0 0 0 ];
pred(i).b = [4.1;-3.7;-1.4;1.6];
pred(i).loc=[];

i = i+1;
pred(i).str = 'loc_pred';
pred(i).A = [];
pred(i).b = [];
pred(i).loc=[2,4];


phi = '[]!( a ) /\ []!(b )';

phi_loc = ['(' , phi , ')' , '\/!<> loc_pred'];


% X0=zeros(1,5);
% assignin('base','X0',X0);

disp(' ')
disp(' ')
disp('Create an staliro_options object with the default options:')
opt = staliro_options()
opt.StrlCov_params.multiHAs=0;
opt.ode_solver='default';
opt.falsification=1;
opt.map2line=0;

opt.optimization_solver = 'SA_Taliro';
opt.optim_params.n_tests = 500;
opt.interpolationtype = {'const'};
opt.n_workers=1; 
opt.black_box = 1;
opt.taliro_metric = 'hybrid';
opt.taliro = 'dp_taliro';
opt.runs=1;
opt.seed=216942605;   
opt
time = 2

disp(' ')
disp('Running S-TaLiRo ...')
tic
[results, history] = staliro(model,init_cond,input_range,cp_array,phi_loc,pred,time,opt);
toc

results.run(results.optRobIndex).bestRob;
results.run(results.optRobIndex).time;
results.run(results.optRobIndex).nTests;

plot(polytope(ProdTop2Polytope(input_range)),'g')
hold on
Yellow= [0.85, 0.95; 0.85, 0.95];
plot(polytope(ProdTop2Polytope(Yellow)),'y')
Red1=[-1.6, -1.4;-1.6, -1.4]
Red2=[3.7, 4.1;-1.6, -1.4]
plot(polytope(ProdTop2Polytope(Red1)))
plot(polytope(ProdTop2Polytope(Red2)))

for i=1:opt.runs
    [T XT YT LT ] = SimBlackBoxMdl(model,init_cond,input_range,cp_array,results.run(i).bestSample,time,opt);
    plot(YT(:,1),YT(:,2))

end
axis equal

