% staliro_demo_red
%    This function demonstrates the use of a descent algorithm in the
%    falsification of hybrid systems. In particular, the algorithm
%    computes the robustness tube for a given trajectory of the hybrid
%    automaton, and, then, it attempts to decrease the robustness wihtin
%    the computed robustness tube.
%
%    This demos also requires the following toolboxes to be installed:
%    * CVX
%    * Ellipsoidal toolbox

function [results, history, runstats] = staliro_demo_red(optimization_solver, apply_descent, modelID, max_nbse, n_tests, simtime, dims_to_fix, ellMinAlgo, n_runs)
% INPUTS
% - nSamples: nb of samples selected
% - optimization_solver: 
% - apply_descent: 
%   if 1, descend from proposed sample using SQP
%   if 2, descend using Uniform Random
%   if 3, descend using Simulated Annealing
%   if 0, don't descend.
% - modelID : select benchmark
% - M : nb of samples for generating histogram
% - max_nbse : stop search if nbse (nb of system evaluations = nb trajectories) exceeds max_nbse. 0 means inf.
%   This is max_nbse over EVERYTHING done in this run: MC, SQP, whatever.
% - n_tests: nb init points for MS_Taliro, or samples for SA_Taliro
% - simtime : trajectory duration
% - dims_to_fix : dimensions in state vector and values to which to fix
% them so they're not varied by the search algos. dims_to_fix(i,1) is the
% dimension (between 1 and n), and dims_to_fix(i,2) is the value at which
% to fix it. Set to an empty array if you don't want any dimensions fixed.

global plotit; 
global RUNSTATS; % initialized in optimization_solver

cd('..')
cd('SystemModelsAndData')

format long
warning('off','YALMIP:strict') ;
warning('off','MATLAB:ezplotfeval:NotVectorized');
cvx_precision('high');

if nargin == 0
    optimization_solver = 'MS_Taliro';
    apply_descent = 1;
    modelID = 'nav0';
    max_nbse = 100;
    simtime = 12;
    dims_to_fix = [];
    ellMinAlgo = 'UR';
    n_runs = 1;
    n_tests = 2;
elseif nargin ~= 9
    error('Wrong nb args - You must either provide all args or none at all.');
end

opt = staliro_options;
opt.optimization_solver = optimization_solver;
opt.spec_space = 'X';
opt.runs = n_runs;
opt.n_workers = 1;
opt.dispinfo = 1;
opt.plot = 0;

if strcmp(optimization_solver,'SA_Taliro')
    opt.optim_params.apply_local_descent = apply_descent;
    opt.optim_params.ld_params.red_hard_limit_on_ellipsoid_nbse = 0;
elseif strcmp(optimization_solver,'MS_Taliro')
    opt.optim_params.apply_local_descent = apply_descent;
    opt.optim_params.ld_params.red_hard_limit_on_ellipsoid_nbse = 1;
end
if apply_descent 
    opt.optim_params.n_tests = n_tests;
else
    opt.optim_params.n_tests = max_nbse;    
end
opt.optim_params.ld_params.red_nb_ellipsoids = 5;
opt.optim_params.ld_params.red_descent_in_ellipsoid_algo = ellMinAlgo;
opt.optim_params.ld_params.max_nbse = max_nbse;
opt.optim_params.ld_params.local_minimization_algo = 'RED';

plotit = opt.plot;

[ms,me,ti,mstr,tstr,tn,sstr]=regexp(modelID, 'air(\d+)_(\d+)');
[ms2,me2,ti2,mstr2,tstr2,tn2,sstr2]=regexp(modelID, 'fosc(\d+)');
if ~isempty(tstr)
    c=tstr{1};    
    nplanes = str2double(c{1}); nwaypnts = str2double(c{2});
    HA = bmkAircraft(nplanes, nwaypnts);
elseif ~isempty(tstr2)
    c=tstr2{1};
    HA = bmkFilteredOscillator(str2double(c{1}));
else
    switch modelID
        case 'nav0'
            HA = bmkNavigation0('circle', 1);            
            
        case 'nav2'
            HA = bmkNavigation2;
            
        case 'nav1'
            HA = bmkNavigation1;
           
        otherwise
            error('System not currently supported');
    end
end
init_cond=HA.init.cube;        
if ~isempty(dims_to_fix)       
    ixfix = dims_to_fix(:,1);
    nfix=size(ixfix,1);
    % make sure the fix-to values are within init_cond
    assert(sum(dims_to_fix(:,2)<=init_cond(ixfix,2))==nfix && sum(dims_to_fix(:,2)>=init_cond(ixfix,1))==nfix, 'Fix-to values not within init_cond');
    init_cond(ixfix,1) = dims_to_fix(:,2);
    init_cond(ixfix,2) = dims_to_fix(:,2);
end

phi = ['[]_[0,',num2str(simtime), '](r)'];
preds(1).A=[1 0 0 0;
    0 -1 0 0];
preds(1).b = [3.2;
    -0.8];
preds(1).str='r';


disp(['Benchmark ', modelID, ' using ', num2str(opt.optim_params.n_tests) ' ', optimization_solver,' tests, max_nbse = ', num2str(max_nbse), ', simtime =',num2str(simtime),'.']);
[results,history] = staliro(HA, init_cond, [], [], '', preds, simtime, opt);
runstats = RUNSTATS;

if opt.plot
    [hs, rc] = systemsimulator(HA, results.run(1).bestSample, [], simtime,[],0);
    hold on;
    plot(hs.XT(:,1),hs.XT(:,2)); title('Least robust traj found');
end

% Collect results
minrob = results.run(results.optRobIndex).bestRob;
avgrob = mean([results.run(:).bestRob]);
maxrob = max([results.run(:).bestRob]);
minnbse = min(RUNSTATS.nb_function_evals_per_run);
avgnbse = mean(RUNSTATS.nb_function_evals_per_run);
maxnbse = max(RUNSTATS.nb_function_evals_per_run);
nfalsi  = length(find([results.run(:).bestRob] <= 0));
disp(['Min rob=',num2str(minrob)])
disp(['Avg rob=',num2str(avgrob)])
disp(['Max rob=',num2str(maxrob)])
disp(['Min nbse=',num2str(minnbse)])
disp(['Avg nbse=',num2str(avgnbse)])
disp(['Max nbse=',num2str(maxnbse)])
disp(['Nb decsent acceptances=',num2str(RUNSTATS.nb_descent_acceptances_per_run)])
disp(['Nfalsi=',num2str(nfalsi)])

cd('..')
cd('Other possibilities')

end

