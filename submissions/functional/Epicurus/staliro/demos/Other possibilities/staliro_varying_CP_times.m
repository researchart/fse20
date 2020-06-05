% staliro_varying_CP_times
% 	This script demonstrates how to search using control points with  
%   varying time stamps. Namely, initially, the time stamps of the control 
%   points are randomly or evenly distributed over the simulation time and, 
%   then, the optimizer moves them around to better approximate the 
%   falsifying input signal. We also demonstrate how to set a minimum
%   distance of 3 sec between the time stamps.
%
%   We use the Simulink auto transmission benchmark with two inputs:  
%   throttle and break.
%
% See also: staliro_demo_autotrans_01, staliro_demo_autotrans_03, staliro_demo_constraint_input_signal_space_01        

clear

cd('..')
cd('SystemModelsAndData')
model = 'sldemo_autotrans_mod01_2inp';

% Total Simulation time
totTime = 30;

opt = staliro_options();
opt.runs = 1;

% No initial conditions
init_cond = [];

% Some specification
phi{1} = '!(<>r1 /\ <>(r3 /\ <>r4))';
phi{2} = '!(<>(r1 /\ <>r2) /\ <>(r3 /\ <>r4))';
disp([' 1. (easier) ',phi{1}]) 
disp([' 2. (harder) ',phi{2}]) 
idx_phi = input(' Select a formula : ');

if idx_phi>2 || idx_phi<1
    disp(' Wrong selection. Setting option to 1.')
    idx_phi = 1;
end 


ii = 1;
preds(ii).str = 'r1';
preds(ii).A = [-1 0];
preds(ii).b = -80;

ii = ii+1;
preds(ii).str = 'r2';
preds(ii).A = [1 0];
preds(ii).b = 60;

ii = ii+1;
preds(ii).str = 'r3';
preds(ii).A = [0 -1];
preds(ii).b = -4500;

ii = ii+1;
preds(ii).str = 'r4';
preds(ii).A = [0 1];
preds(ii).b = 3300;

%% Input signal

disp(' ')
disp(' Choose an algorithm for varying the time stamps of control points: ')
disp(' 1. Alg 1: The number of control points for each input signal should be the same. The time stamps for the corresponding control points are synchronized.')
disp(' 2. Alg 2: Each control point (besides the 1st and last) is associated with a variable. The resulting search space is larger than option 1.')
opt.varying_cp_times = input(' Choose 1 or 2: ');

if (opt.varying_cp_times>2 || opt.varying_cp_times<1)
    disp(' Wrong selection. Setting option to 1.')
    opt.varying_cp_times = 1;
end 

input_range = [0 100; 0 100];

if opt.varying_cp_times==1
    cp_array = [4 4];
else
    cp_array = [4 5];
end

if opt.varying_cp_times==1
    
%     % Currently not supported. Code left here for future support.
%    
%     disp(' ')
%     disp(' Add additional constraints: ')
%     disp(' 1. No additional constraints.')
%     disp(' 2. Require that the gas pedal value is always greater than the break pedal.')
%     tmp_addconst = input(' Choose 1 or 2: ');
% 
%     if (tmp_addconst>2 || tmp_addconst<1)
%         disp(' Wrong selection. Setting option to 1.')
%         tmp_addconst = 1;
%     end 
% 
%     if tmp_addconst==2
%         % Adding constraints on the gas and break signals : control points
%         % 1 to 4 for gas and 5 to 8 for break
%         opt.search_space_constrained.constrained = true;
%         opt.search_space_constrained.A_ineq = zeros(4,8);
%         opt.search_space_constrained.A_ineq(1,1) = -1; 
%         opt.search_space_constrained.A_ineq(1,5) = -1; 
%         opt.search_space_constrained.A_ineq(2,2) = -1; 
%         opt.search_space_constrained.A_ineq(2,6) = -1; 
%         opt.search_space_constrained.A_ineq(3,3) = -1; 
%         opt.search_space_constrained.A_ineq(3,7) = -1; 
%         opt.search_space_constrained.A_ineq(4,4) = -1; 
%         opt.search_space_constrained.A_ineq(4,8) = -1; 
%         opt.search_space_constrained.b_ineq = zeros(4,1);
%     end

    opt.optimization_solver = 'SA_Taliro';
    opt.optim_params.n_tests = 500;

elseif opt.varying_cp_times==2
    
    opt.varying_cp_times_coeff = 0.1; % minimum distance between time stamps 0.1*totTime = 3 sec
    
    disp(' ')
    disp(' Add additional constraints: ')
    disp(' 1. No additional constraints.')
    disp(' 2. Require that the break pedal is non-decreasing function (it increases).')
    tmp_addconst = input(' Choose 1 or 2: ');

    if (tmp_addconst>2 || tmp_addconst<1)
        disp(' Wrong selection. Setting option to 1.')
        tmp_addconst = 1;
    end 

    if tmp_addconst==2
        % Adding constraints on the break signal : control points 5 to 9
        opt.search_space_constrained.constrained = true;
        opt.search_space_constrained.A_ineq = zeros(4,9);
        opt.search_space_constrained.A_ineq(1,5) = 1; 
        opt.search_space_constrained.A_ineq(1,6) = -1; 
        opt.search_space_constrained.A_ineq(2,6) = 1; 
        opt.search_space_constrained.A_ineq(2,7) = -1; 
        opt.search_space_constrained.A_ineq(3,7) = 1; 
        opt.search_space_constrained.A_ineq(3,8) = -1; 
        opt.search_space_constrained.A_ineq(4,8) = 1; 
        opt.search_space_constrained.A_ineq(4,9) = -1; 
        opt.search_space_constrained.b_ineq = zeros(4,1);
    end

    disp(' ')
    disp (' Select a solver to use ')
    disp (' 1. Simulated Annealing Method. ')
    disp (' 2. Genetic Algorithm using @mutationadaptfeasible (GA Matlab toolbox required - Note: it may fail to falsify).')
    disp (' 3. Genetic Algorithm using @mutationuniform (GA Matlab toolbox required - Note: it may fail to satisfy the linear constraints).')
    disp (' ')
    tmp_solv = input (' Choose 1, 2, or 3: ');
    
    if (tmp_solv>3 || tmp_solv<1)
        disp(' Wrong selection. Setting option to 1.')
        tmp_solv = 1;
    end 
    if (tmp_solv == 2)
        opt.optimization_solver = 'GA_Taliro';
        opt.optim_params.ga_options = gaoptimset(opt.optim_params.ga_options,'PopulationSize',20,'Generations',25);
    elseif (tmp_solv == 3)
        opt.optimization_solver = 'GA_Taliro';
        opt.optim_params.ga_options = gaoptimset(opt.optim_params.ga_options,'PopulationSize',20,'Generations',25,'MutationFcn',{@mutationuniform,0.2});
    else
        opt.optimization_solver = 'SA_Taliro';
        opt.optim_params.n_tests = 500;
    end

end

% Each input signal should be a piecewise linear function
opt.interpolationtype = {'linear'};

%% Running S-TaLiRo

disp(' ')
disp('Running S-TaLiRo ...')
results = staliro(model,init_cond,input_range,cp_array,phi{idx_phi},preds,totTime,opt);

results.run(results.optRobIndex).bestRob

disp(' ')
disp('Plotting the results of the 1st run ...')
disp(' ')

figure
bestSamp = results.run(results.optRobIndex).bestSample(:,1);
[T1,XT1,YT1,IT1] = SimSimulinkMdl(model,init_cond,input_range,cp_array,bestSamp,totTime,opt);
subplot(4,1,1)
hold on
plot(IT1(:,1),IT1(:,2))
if opt.varying_cp_times==1
    plot(bestSamp(9:12),bestSamp(1:4),'*r')
else
    plot([0 bestSamp([10 11])' totTime],bestSamp(1:4),'*r')
end
title('Throttle')
grid on
subplot(4,1,2)
hold on
plot(IT1(:,1),IT1(:,3))
if opt.varying_cp_times==1
    plot(bestSamp(9:12),bestSamp(5:8),'*r')
else
    plot([0 bestSamp(12:14)' totTime],bestSamp(5:9),'*r')
end
title('Break')
grid on
subplot(4,1,3)
plot(T1,YT1(:,2))
hold on 
plot([0 30],[4500 4500],'r');
title('RPM')
subplot(4,1,4)
plot(T1,YT1(:,1))
hold on 
plot([0 30],[80 80],'r');
title('Speed')

cd('..')
cd('Other possibilities')


