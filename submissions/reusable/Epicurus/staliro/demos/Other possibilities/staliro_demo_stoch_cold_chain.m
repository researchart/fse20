% NAME
% 
%     staliro_demo_stoch_cold_chain - run falsification for the chain Linear Stochastic Hybird Automaton (LSHA)
% 
% SYNOPSIS
% 
%     staliro_demo_stoch_cold_chain
%     
% DESCRIPTION
% 
%     Run falsification for the chain Linear Stochastic Hybird Automaton (LSHA).
%     Uses stochChain.mat in this folder.          
%     This contains code to generate the landscape of the objective (given a spec).
%     Also can obtain the objective values at the burn-out samples (if any).
%     This being a script, all data is left in the workspace. See struct results.         
%        
% AUTHOR(S)
% 
%        Written by Houssam Abbas and Georgios Fainekos - Arizona State University 
%        The data in stochChain.mat has been obtained by running the LSHA code of Dr. Agung Julius - Rensselaer Polytechnic Institute.
%        
% 
% See also - stoch_chain_simulator 
    
clear

load 'stochChainLandscape.mat';

cd('..')
cd('..')
cd('benchmarks')
cd('stochasticChain')
load('stochChain.mat') 
g1 = stochChain.G1(1,1); % G1 is diagonal
model = @(x0,T,dum1,dum2) stoch_chain_simulator(x0,T,stochChain.A1, g1, stochChain.N);

init_cond = [0.5 5; 0.5 5];
input_range = [];
cp_array = [];


%% Safety specification
ii = 0;
phiSafety = '!(<>r1)' ;
ii = ii + 1;
preds(ii).str='r1';
preds(ii).A = -1;
preds(ii).b = -5.5;
preds(ii).loc = 1:20;
phi = phiSafety;

%% Run parameters
T = 40;                  %  simulation time
% SA parameters
ep = 0.25;
delta = 0.2;  
sigma = 0.75; 
R = norm(init_cond(:,2)-init_cond(:,1)); 
L = norm(stochChain.M); 
n=size(init_cond,1);
J = ceil(  ((1+ep+delta)/ep)*(log(sigma/(1-sigma)) + n*log(L*R/ep) + 2*log((1+delta)/delta))  ); % [Lecchini-Visintini Eq.(8)]
% A value for J which should be sufficient to accurately compute the
% objective function value. Only used when creating the landscape of the
% objective. Feel free to increase.
Jmean = 2*J;

% Normalization constant for the target density (U+delta)^J
a = ((1+delta)^(J+1) - delta^(J+1))/(J+1); 
% Measure of set of initial conditions
meas = (init_cond(1,2)-init_cond(1,1))*(init_cond(2,2)-init_cond(2,1));
m = ceil(a*meas*(1+delta)^J); % [Lecchini-Visintini Thm. 6]
K1 = log(0.15)/log(1-1/m);    % [Lecchini-Visintini Eq.(10)] with ||.|| <= 0.15
% Because the bounds are conservative (especially for a uniform proposal
% density), we are going to use a maximum of 500, because life is short,
% and running 10,000 simulations is not always an option.
% Again, adjust to your liking.
K = max(200,min(K1,500));


opt = staliro_options();
opt.runs = 1;
opt.spec_space = 'Y';
opt.black_box = 1;
opt.map2line = 0;
opt.n_workers = 1;
opt.optimization_solver = 'SA_Cold_Stoch';
opt.optim_params.n_tests = K;
opt.optim_params.J_bound = J;
opt.optim_params.delta = delta;
opt.optim_params.nBurnOutSamples = 10;
opt.optim_params.proposalMethod = 'uniform';

disp('Precision parameters:')
disp(['epsilon = ',num2str(ep), ', delta = ', num2str(delta), ', sigma = ',num2str(sigma)])
disp('Resulting run parameters:')
disp(['Nb tests (optimization + burn-out) = ', num2str(opt.optim_params.n_tests + opt.optim_params.nBurnOutSamples)])
disp(['Number of extractions J = ', num2str(opt.optim_params.J_bound)])
disp(['Test duration T = ', num2str(T)])
disp(['Nb of staliro runs = ',num2str(opt.runs)])


%% Optimize
opt.save_intermediate_results = 1;
opt.optim_params.logAdjParameter = 0.5*(globalmax - globalmin);
[results, history] = staliro(model,init_cond,input_range,cp_array,phi,preds,T,opt);
results.run(results.optRobIndex)
[T,XT,YT] = model(results.run(results.optRobIndex).bestSample,T);
plot(T,YT); 
hold on;
plot(T,5*ones(1,length(T)),'r');
legend('y(t)','y = 5')
xlabel('t');
title('Least robust trajectory')

%% Get robustness values of samples obtained in burn-out
% % ----------------------------------------------------------------------
% % Uncomment this code if you wish to obtain the values of the objective at
% % the burn-out points (if any)
% % ----------------------------------------------------------------------
% if opt.optim_params.nBurnOutSamples > 0
%     smax = opt.optim_params.squash(globalmax);
%     smin = opt.optim_params.squash(globalmin);
%     successRate = zeros(1,opt.runs);
%     for r=1:opt.runs
%         borob = zeros(1, opt.optim_params.nBurnOutSamples);
%         for i=opt.optim_params.n_tests+1:size(history(r).samples,1)
%             x0 = history(r).samples(i,:)';
%             disp(['Run ', num2str(r), ', burn-out pnt ',num2str(i)])
%             % Simulate J extractions
%             rj=zeros(1,Jmean);
%             for t=1:Jmean
%                 [hs,rc] = systemsimulator(model,x0,[],T,[],0);
%                 temp = dp_taliro(phi,preds,[hs.YT, hs.LT],hs.T);
%                 rj(t) = opt.optim_params.squash(temp);
%             end
%             borob(i) = mean(rj);
%         end
%         levelset = find(borob >= smax - 2*ep*(smax-smin)); % Theta^*(2epsilon)
%         successRate(r) = length(levelset)/opt.optim_params.nBurnOutSamples
%         
%     end
%     successRate
% end

%% Grid
% % ----------------------------------------------------------------------
% % uncomment this code if you wish to generate the landscape of the
% % expected robustness function. This can take a very long time to run as it
% % samples the search space, depending on the parameters you set.
% % ----------------------------------------------------------------------
% d = 0.1;  % difference between grid points when creating landscape
% global staliro_opt;
% staliro_opt = opt;
% Xd = init_cond(1,1):d:init_cond(1,2);
% Yd = init_cond(2,1):d:init_cond(2,2);
% rob = zeros(length(Xd), length(Yd));
% 
% i=0;
% for x=Xd
%     i=i+1;
%     j=0;
%     for y=Yd
%         j=j+1;
%         x0 = [x;y];
%         % Simulate Jmean extractions
%         rj=zeros(1,Jmean);
%         disp(['Grid pnt (',num2str(i),',',num2str(j),')'])
%         tic
%         for t=1:Jmean
%             t
%             [hs,rc] = systemsimulator(model,x0,[],T,[],0);
%             rj(t) = dp_taliro(phi,preds,[hs.YT, hs.LT],hs.T)
%         end
%         toc
%         rob(i,j) = mean(rj);
%     end
% end
% surf(Xd,Yd,rob);
% maxr = max(max(rob)); minr = min(min(rob));
% opt.optim_params.logAdjParameter = 0.5*(maxr-minr);
% scaledrob = opt.optim_params.squash(rob);
% globalmin = min(min(scaledrob))
% globalmax = max(max(scaledrob))
% save('stochChainLandscape.mat', 'Xd','Yd','rob','T','d', 'Jmean', 'globalmin', 'globalmax');

%------------------------------------------------------

cd('..')
cd('..')
cd('demos')
cd('Other possibilities')

