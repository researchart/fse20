% This is a demo for using S-TALIRO with the quadrotor model of the
% robotics toolbox v9.10 developed by Peter Corke. Note that the Robotics Toolbox
% needs to be installed for this demo to work.

% (C) Bardh Hoxha, 2013, Arizona State University.

clear

cd('..')
cd('SystemModelsAndData')

% rng(3000) % Incompatible with the rand generator in MPT?

disp(' ')
disp(' For this demo to run, you must have installed the Robotics Toolbox and ')
disp(' the Multi-Parametric Toolbox (MPT).')
disp(' If not, please visit: http://www.petercorke.com/Robotics_Toolbox.html and')
disp(' http://control.ee.ethz.ch/~mpt/.')
disp(' ')
disp(' Press any key to continue ...')
disp(' ')
pause 

% <<<<<<< .mine
% sl_quadrotor
% ||||||| .r40
% mdl_quadcopter
% =======
% >>>>>>> .r52

model = 'sl_quadrotor_inp';

disp(' ')
disp('The constraints on the initial conditions defined as a hypercube:')
init_cond = []

disp(' ')
disp('The constraints on the input signal defined as a range:')
input_range = [-4 4;-4 4]
disp(' ')
disp('The number of control points for the input signal:')
cp_array = [5;5]

disp(' Total simulation time: ')
time = 5

disp(' ')
disp('The specification:')

phi{1} = '!(<>(r1 /\ r2 /\ r3 /\ r4) /\ []!(a1 /\ a2 /\ a3 /\ a4))';
phi{2} = '!(<>[](r1 /\ r2 /\ r3 /\ r4) /\ []_[4,5]!(a1 /\ a2 /\ a3 /\ a4))';

disp([' 1. ',phi{1}])
disp([' 2. ',phi{2}])
i_phi = input(' Choose specification : ');

%VISIT--------

ii = 1;
preds(ii).str = 'r1';
preds(ii).A = [1 0];
preds(ii).b =  4;

ii = ii+1;
preds(ii).str = 'r2';
preds(ii).A = [-1 0];
preds(ii).b =  -2;

ii = ii+1;
preds(ii).str = 'r3';
preds(ii).A = [0 1];
preds(ii).b =  1;

ii = ii+1;
preds(ii).str = 'r4';
preds(ii).A = [0 -1];
preds(ii).b =  1;

%Bad Region-------------------------------------------------------

ii = ii+1;
preds(ii).str = 'a1';
preds(ii).A = [1 0];
preds(ii).b =  1;

ii = ii+1;
preds(ii).str = 'a2';
preds(ii).A = [-1 0];
preds(ii).b =  0;

ii = ii+1;
preds(ii).str = 'a3';
preds(ii).A = [0 1];
preds(ii).b =  1;

ii = ii+1;
preds(ii).str='a4';
preds(ii).A = [0 -1];
preds(ii).b =  1;

% -------------------------------------------------------

figure(1)
clf
k = 1;
A_tmp = [preds(k).A;preds(k+1).A;preds(k+2).A;preds(k+3).A];
b_tmp = [preds(k).b;preds(k+1).b;preds(k+2).b;preds(k+3).b];
plot(polytope(A_tmp,b_tmp),'y')
hold on 
k = 5;
A_tmp = [preds(k).A;preds(k+1).A;preds(k+2).A;preds(k+3).A];
b_tmp = [preds(k).b;preds(k+1).b;preds(k+2).b;preds(k+3).b];
plot(polytope(A_tmp,b_tmp),'r')
axis([-4 4 -4 4])

% -------------------------------------------------------

opt = staliro_options();
opt.optimization_solver = 'SA_Taliro';
opt.runs = 1;
opt.optim_params.n_tests = 100;
opt.falsification = 0;
opt.interpolationtype={'pchip'};
opt

disp(' ')
disp('Running S-TaLiRo with chosen solver ...')
tic
results = staliro(model,init_cond,input_range,cp_array,phi{i_phi},preds,time,opt);
runtime=toc;

runtime

results.run(results.optRobIndex).bestRob

model_plot = 'sl_quadrotor_inp_plot';

[T1,XT1,YT1,IT1] = SimSimulinkMdl(model_plot,init_cond,input_range,cp_array,results.run(results.optRobIndex).bestSample(:,1),time,opt);

plot(YT1(:,1),YT1(:,2))

if i_phi==2
    jj = find(T1>=4);
    plot(YT1(jj,1),YT1(jj,2),'*')
end

cd('..')
cd('Other possibilities')


