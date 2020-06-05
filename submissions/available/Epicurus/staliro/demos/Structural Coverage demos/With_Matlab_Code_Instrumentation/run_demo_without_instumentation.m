figure
clear
warning off
model = 'hybrid_system';

disp(' ')
disp('Initial conditions')
init_cond = [];

disp(' ')
disp('No input signals:')
input_range = [-1 1; -1 1]
cp_array = [1,1];

disp(' ')
disp('The specification:')


i = 1;
pred(i).str = 'a';
pred(i).A = [1   0
            -1   0
             0   1
             0  -1];
pred(i).b = [-1.4;1.8;-1.4;1.6];

i = i+1;
pred(i).str = 'b';
pred(i).A = [1   0
            -1   0
             0   1
             0  -1];
pred(i).b = [4.1;-3.7;-1.4;1.6];

phi = '[]!( a ) /\ []!(b )';


disp(' ')
disp(' ')
disp('Create an staliro_options object with the default options:')
opt = staliro_options()

opt.optimization_solver = 'SA_Taliro';
opt.optim_params.n_tests = 500;
opt.interpolationtype = {'const'};

time = 2
opt.runs=1;
opt.black_box = 0;
opt.taliro_metric = 'none';
opt.taliro = 'dp_taliro';
opt.seed = 2;

opt

disp(' ')
disp('Running S-TaLiRo ...')
tic
[results, history] = staliro(model,init_cond,input_range,cp_array,phi,pred,time,opt);
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
    [T XT YT ] = SimSimulinkMdl(model,init_cond,input_range,cp_array,results.run(i).bestSample,time,opt);

    plot(YT(:,1),YT(:,2))
end
for i=1:500
    scatter(history.samples(i,1),history.samples(i,2),'.','b');
end

axis equal

