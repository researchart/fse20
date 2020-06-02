% This demo presents the Gradient Descent based local search combination 
% with Simulated Annealing and Uniform Random Sampling on a steamCondenser
% controlled using a Recurrent Neural Network.
%
% The algorithm is illustrated in Shakiba Yaghoubi, Georgios Fainekos. "
% Gray-box Adversarial Testing for Control Systems with Machine Learning 
% Components", Hybrid Systems: Computation and Control (HSCC) 2019

% (C) Shakiba Yaghoubi 2019 - Arizona State Univeristy

clear;
close;
warning('off','all')

% Simulation time & Requirements (run " help staliro" for more information)
SP.t0 = 0;
SP.tf = 35;
SP.pred(1).str = 'p1';  
SP.pred(1).A =  1;
SP.pred(1).b =  87.5;  
SP.pred(2).str = 'p2';  
SP.pred(2).A =  -1;
SP.pred(2).b =  -87;
SP.phi = '[]_[30,35] (p1/\p2)'; % Make sure you specify the output mapping and its derivative if the requirement is not on the states
model = @GDBlackbox;            % Black box model that calls Simulink through staliro
nbstarts = 1;                   % # of Runs
nbiter = 200;                   % Max # of simulations
cp_array = 12;
input_range = [3.99 ,4.01];     % Input bounds
max_T = 100;


opt = staliro_options(); %(See staliro_options help file)
opt.interpolationtype = {'pconst'};
opt.runs = nbstarts;
opt.black_box = 1;
opt.seed = 1;
opt.varying_cp_times = 1;

disp(' ')
disp('The reqirement is: []_[30,35] (87<= y <=87.5)')
disp(' ')
disp(' 1. Simulated Annealing combined with Gradinet Descent')
disp(' 2. Uniform Random Sampling combined with Gradinet Descent')
disp(' 3. Pure Simulated Annealing')
disp(' 4. Pure Uniform Random Sampling')
search_id = input('Choose a search algorithm: ');


if search_id == 1
    opt.optim_params.apply_GD = 1;
    opt.optim_params.GD_params.no_suc_TH = 2;
    opt.optim_params.n_tests = nbiter;
    opt.optim_params.GD_params.model = 'steamcondense_RNN_22';
    [results, history] = staliro(model,[],input_range,cp_array,SP.phi,SP.pred,SP.tf,opt);
    disp('Applied SA+GD method:') 
    disp(['# of falsifications: ',num2str(sum([results.run.falsified].')),'/', num2str(nbstarts)])
    disp(['Avg min robustness: ',num2str(mean([results.run.bestCost].'))])
    disp(['Avg Execution time: ', num2str(mean([results.run.time].'))])
    disp(['Avg # of simulations: ', num2str(mean([results.run.nTests].'))])
    
elseif search_id == 2
    opt.optimization_solver = 'UR_Taliro';
    opt.optim_params.apply_GD = 1;
    opt.optim_params.GD_params.no_dec_TH = 3;
    opt.optim_params.n_tests = nbiter;
    opt.optim_params.GD_params.model = 'steamcondense_RNN_22';
    [results, history] = staliro(model,[],input_range,cp_array,SP.phi,SP.pred,SP.tf,opt);
    disp('Applied UR+GD method:') 
    disp(['# of falsifications: ',num2str(sum([results.run.falsified].')),'/', num2str(nbstarts)])
    disp(['Avg min robustness: ',num2str(mean([results.run.bestCost].'))])
    disp(['Avg Execution time: ', num2str(mean([results.run.time].'))])
    disp(['Avg # of simulations: ', num2str(mean([results.run.nTests].'))])
    
elseif search_id == 3
    opt.optim_params.n_tests = nbiter;
    opt.optim_params.GD_params.model = 'steamcondense_RNN_22';
    [results, history] = staliro(model,[],input_range,cp_array,SP.phi,SP.pred,SP.tf,opt);
    disp('Applied Pure SA method:') 
    disp(['# of falsifications: ',num2str(sum([results.run.falsified].')),'/', num2str(nbstarts)])
    disp(['Avg min robustness: ',num2str(mean([results.run.bestCost].'))])
    disp(['Avg Execution time: ', num2str(mean([results.run.time].'))])
    disp(['Avg # of simulations: ', num2str(mean([results.run.nTests].'))])
    
elseif search_id ==4
    opt.optimization_solver = 'UR_Taliro';
    opt.optim_params.n_tests = nbiter;
    opt.optim_params.GD_params.model = 'steamcondense_RNN_22';
    [results, history] = staliro(model,[],input_range,cp_array,SP.phi,SP.pred,SP.tf,opt);
    disp('Applied Pure UR method:') 
    disp(['# of falsifications: ',num2str(sum([results.run.falsified].')),'/', num2str(nbstarts)])
    disp(['Avg min robustness: ',num2str(mean([results.run.bestCost].'))])
    disp(['Avg Execution time: ', num2str(mean([results.run.time].'))])
    disp(['Avg # of simulations: ', num2str(mean([results.run.nTests].'))])
    
else
    error('Search option not supported')
end
try
    [T, XT, YT] = feval(model,[],SP.tf,results.run.bestSample(1:end/2),results.run.bestSample(1+end/2:end)); 
    figure
    subplot(2,1,1)
    plot(T, YT)
    hold on
    plot(30:35, SP.pred(1).b*ones(length(30:35)),'red')
    plot(30:35, -SP.pred(2).b*ones(length(30:35)),'red')
    title('Falsifying trajectory')
    subplot(2,1,2)
    plot(results.run.bestSample(1:end/2),results.run.bestSample(1+end/2:end))
    title('Falsifying input')
catch
    TU = (0:opt.SampTime:SP.tf);
    U = ComputeInputSignals(TU, results.run.bestSample, opt.interpolationtype, cp_array, input_range, SP.tf, opt.varying_cp_times)';
    [T, XT, YT] = feval(model,[],SP.tf,TU,U); 
    figure
    subplot(2,1,1)
    plot(T, YT)
    hold on
    plot(30:35, SP.pred(1).b*ones(length(30:35)),'red')
    plot(30:35, -SP.pred(2).b*ones(length(30:35)),'red')
    title('Least robust trajectory found')
    subplot(2,1,2)
    plot(TU,U)
    title('Best input found')
end
save_system
close_system