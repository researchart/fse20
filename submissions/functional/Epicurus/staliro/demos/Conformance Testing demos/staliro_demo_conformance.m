function staliro_demo_conformance(varargin)
% NAME
%
% staliro_demo_conformance - run conformance testing demos
%
% SYNOPSIS
%
%       staliro_demo_conformance(suffix,args)
%       staliro_demo_conformance(suffix)
%
% DESCRIPTION
%
%       Do conformance testing between two systems. Conformance is defined either as
%       (T,J,(tau,eps))-closeness, or as PWC (point-wise conformance).
%
%       Uses two example systems:
%       - Simulink model of a Fuel Controller: Model and Implementation
%       are provided as Simulink mdl, where Model is a simplification of the
%       Implementation.
%       - The navigation benchmark: the 'Implementation' hybrid system is
%       created by varying the differential equations or the guards. The
%       variation covers a range from 'small' to 'large', where admittedly
%       these terms are subjective.
%
%       Inputs
%
%         suffix
%             If results are saved, each .mat's name gets this suffix. Useful in
%             batch runs, to avoid over-writing other runs' results.
%
%         args
%         A struct with the following fields:
%
%             run_only_mdl
%                 If not 0, runs only the simulink examples
%
%             plotit
%                 If non-0, plot the navigation benchmark
%
%             save_results
%                 If non-0, save staliro run-results at outdir/. Useful for
%                 long runs and book-keeping.
%
%             outdir
%                 where to save the results if save_results
%
%             taueps_tau
%                 tau parameter of (tau,eps)-closeness.
%
%             taueps_eps
%                 epsilon parameter of (tau,eps)-closeness
%
%             fcfiller
%                 Optional. Filler value for a hybrid-Timed State Sequence. For a hybrid-TSS,
%                 the trajectory is chopped into fragments, such that each
%                 fragment corresponds to one mode. To make corresponding
%                 fragments of equal length, the 'missing' values are
%                 filled with fcfiller, which should be some arbitrarily
%                 large value.
%                 Note this capacity works only when you can detect mode
%                 (or 'location') changes. For the default systems of this
%                 script, that is not possible.
%                 If fcfiller is not provided, then no mode checks happen, and
%                 the trajectory is treated as a real-TSS
%
%             simtime
%                 duration of each trajectory, or test.
%
%             nb_dichotomy_iter
%                 nb of dichotomy (or binary search) iterations. The dichotomy
%                 interval [low,high] is set to [0, 3*taueps_tau]. Feel free to
%                 change it.
%
%             nb_sa_runs
%                 nb of staliro runs per dichotomy iteration, and when falsifying
%                 PWC.
%
%             nb_sa_tests
%                 nb of tests per run of s-taliro
%
%             For (T,J,(tau,eps))-closeness, the T value is automatically set to
%             simtime - 2*tau.
%
%             All of the above have default values - see code.
%
%
% AUTHOR(S)
%
%     Written by Houssam Abbas - Arizona State University
%
% SEE ALSO - conf_get_formulae, create_combined_parallel_system

%% Unavailability of some systems
disp('')
disp('*********************************************************');
msg = ['Please read:\n'];
msg = [msg, 'The results in submitted Conformance paper use simulink models that we currently can not release publicly.\n'];
msg = [msg, 'Therefore, the current demo uses a simulink model that ships with Matlab: the Automatic Transmission,\n and the Powertrain Controller from CheckMate.\n'];
msg = [msg, 'To use your own, edit the variables ModelSys (which should point to the Model) and ImplementationSys (which should point to the Implementation.\n'];
msg = [msg, 'If you do use your own models, meaningful results depend on the use of meaningful parameters. E.g. the values of tau and epsilon for (tau,epsilon)-closeness checking.\n'];
msg = [msg, '\nThis demo uses a CheckMate Powertrain model. So to run it, you need to have CheckMate installed - you can \ndownload it from http://users.ece.cmu.edu/~krogh/checkmate/\n'];
fprintf(msg);
disp('*********************************************************');
disp('')
pause(4)

currentdir = pwd;
cd('..\..')
currentrootdir = pwd;
cd(currentdir)
if isempty(regexp(currentdir,'demos\\Conformance Testing demos$'))
    error('You must first cd to demos directory and run this from there. It is not enough to add it to the matlabpath.')
end

%% Parameters and stuff
format long
disp(' ');
if nargin == 2
    suffix                  = varargin{1};
    argv                    = varargin{2};
    % What to run
    run_only_mdl            = argv.run_only_mdl;
    falsification_method    = argv.falsification_method;
    % Presentation
    plotit                  = argv.plotit;
    save_results            = argv.save_results;
    outdir                  = argv.outdir;
    % Properties parameters
    taueps_tau              = argv.taueps_tau;
    taueps_eps              = argv.taueps_eps;
    if isfield(argv,'fcfiller')
        fcfiller            = argv.fcfiller;
    end
    % Run parameters
    simtime                 = argv.simtime;
    nb_dichotomy_iter       = argv.nb_dichotomy_iter;
    nb_sa_runs              = argv.nb_sa_runs;
    nb_sa_tests             = argv.nb_sa_tests;
    
elseif nargin <= 1
    if nargin == 1
        if ischar(varargin{1})
            % Only the suffix is supplied
            suffix = varargin{1};
        else
            error('Incorrect arguments - see Help');
        end
    else
        % No inputs
        suffix = '';
    end
    
    % Set defaults for the parameters.
    falsification_method    = 'direct'; % 'direct' or 'convertToMTL'
    run_only_mdl            = 0;
    
    plotit                  = 0;
    save_results            = 0;
    outdir                  = 'outdir';
    
    % Parameters for FC systems
    % Maxi relative errors between LUT and polynomial outputs (from
    % AbstractFuelControl and AbstractFuelControlNoLUTs) (data collected by
    % running LUTPolyComparison, denominator = poly):
    % 1-Kappa: 0.0547    tau_ww: 0.4091    delay: 0.2591
    fcrelerr                = [0.0547, 0.4091, 0.2591];
    fctau                   = 10e-4;
    
    % Tau should be such that the number of samples in a window of size
    % 2*tau is manageable to dp_taliro: i.e. the resulting signal isn't so
    % huge that dp_taliro will run out of memory while computing its
    % robustness.
    taueps_tau              = 0.1;
    taueps_eps              = max(fcrelerr);
    
    simtime                 = 5;
    nb_dichotomy_iter       = 5;
    nb_sa_runs              = 5;
    nb_sa_tests             = 5;
    
else
    error('Too many input arguments - see Help.')
end

%% Formulae
nbloc = 16;

% This is the sampling period of Model and Implementation trajectories.
% There are three cases:
% 1) if we find that the computed trajectories have the same sampling
% period, and that is equal to the variable below, all is good.
% 2) If they have the same sampling period which differs from the variable,
% an error is raised asking you to set it equal to the computed one.
% If they don't have the same sampling period, the trajectories are
% interpolated to have a period equal to the variable below.
taueps_samplingPeriod = 0.05; %0.0005;
formArgs = struct('plotit', plotit, ...
    'simtime', simtime,  ...
    'Dpwc', 0.5, 'po_t1', 2,...
    'taueps_tau', taueps_tau, 'taueps_eps', taueps_eps, 'sp', taueps_samplingPeriod, ...
    'nbloc', nbloc);
formulae = conf_get_formulae(formArgs);

%% Navigation bmk Model
disp('Building Navigation benchmark and its implementations...')
pause(2)

addpath([currentrootdir,'/benchmarks/NavBenchmark']); 
addpath([currentrootdir,'/benchmarks/AutomaticTransmission']); 
addpath([currentrootdir,'/benchmarks/Powertrain']); 
init.loc = 13;
init.cube = [0.2 0.8; 3.2 3.8; -0.4 0.4; -0.4 0.4];
A = [4 2 3 4; 3 6 5 6; 1 2 3 6; 2 2 1 1];
Av = [-1.2000    0.1000;     0.1000   -1.2000];
Bv = Av;
Model = navbench_hautomaton(plotit,init,A, [], Av, Bv);

% Flow changes
[V D]=eig(Av);
% Provide a range of changes to the matrix (but still keeping system stable)
Dc = {D+0.000001*eye(2), D+0.000002*eye(2), D+0.000003*eye(2), ...
    D+0.0001*eye(2), D+0.0002*eye(2), D+0.0003*eye(2), ...
    D + 0.01*eye(2), D + 0.02*eye(2), D + 0.03*eye(2), ...
    };
for i=1:length(Dc)
    implAv{i} = V*Dc{i}*V';
end
implBv = implAv;
% Guard changes
% Shift horizontal guards
horiz_shift=[0.0003 0.0005 0.0007];
% You can uncomment the array to see an example of vertical
% guard shifts.
verti_shift=[]; %0.0003 0.0005 0.0007];

common_elts = struct('A', A, 'init', init);
variable_elts = struct('horiz_shift', horiz_shift, 'verti_shift', verti_shift);
implargv = struct('common_elts', common_elts, 'variable_elts', variable_elts);

implinfo = struct('common_elts', common_elts, 'variable_elts', variable_elts, 'get_info','nb_implementations' );
nb_impls = conf_get_next_implementation(implinfo, implAv, implBv);


%% Options for s-taliro falsification
display('Direct falsification of conformance notions')
opt = staliro_options();
opt.runs = nb_sa_runs;
opt.spec_space = 'X';
opt.optimization = 'min';
opt.map2line = 0;
opt.falsification =1;
opt.taliro = 'dp_taliro';
opt.dp_t_taliro_direction = 'both';
opt.hasim_params = [1 0 0 0 1];
opt.parameterEstimation = 0;
opt.dispinfo = 0;
opt.optimization_solver = 'SA_Taliro';
opt.optim_params.n_tests = nb_sa_tests;
opt.interpolationtype = {'pchip'};
opt.black_box = 1;
global staliro_opt;
staliro_opt = opt;

input_range = [0 50];
nbControlPnts = 1;   % If interpolationtype is other than 'const', you can increase this beyond 1. Larger implies a richer class of input signals.

if nbControlPnts == 1
    staliro_opt.interpolationtype = {'const'};
end

%% Create parallel model
disp('--------------------------------------------------------------')
disp('Trying to falsify (tau,epsilon)')

% ModelSys = 'AbstractFuelControlNoLUTs';
% ImplementationSys = 'AbstractFuelControl';
ModelSys = 'sldemo_autotrans_mod01';
ImplementationSys = staliro_blackbox(@BlackBoxPowertrain03);
if ischar(ModelSys) && 4 ~= exist(ModelSys)
    ss= sprintf(['The ModelSys ', ModelSys, ' seems meant to be a simulink model but it is not on the matlabpath. Please verify.']);
    error(['The ModelSys ', ModelSys, ' seems meant to be a simulink model but it is not on the matlabpath. Please verify.']);
end
if  ischar(ImplementationSys) && 4~= exist(ImplementationSys) && 2~= exist(ImplementationSys) %#ok<EXIST>
    error(['The ImplementationSys ', ImplementationSys, ' seems meant to be a simulink model but it is not on the matlabpath. Please verify.']);
end
disp(['Using Model = ', ModelSys, ' and Implementation = @BlackBoxPowertrain03']);

% Other simulator output can be used, adjust tau and eps accordingly.
if exist('fcfiller','var')
    comsys = create_combined_parallel_system(struct('model', ModelSys, 'implementation', ImplementationSys, 'simulator_output', 'relative_error', 'tau', taueps_tau,'sp', taueps_samplingPeriod, 'filler', fcfiller));
else
    comsys = create_combined_parallel_system(struct('model', ModelSys, 'implementation', ImplementationSys, 'simulator_output', 'relative_error', 'tau', taueps_tau,'sp', taueps_samplingPeriod));
end


%% Settings for direct maximization of eps(tau) using anneal
loss = @(p) -epsForThisTau(p); % anneal() minimizes
p0 = [];
for ii=1:size(input_range,1)
    r0 = input_range(ii,1) + rand(nbControlPnts,1)*(input_range(ii,2)-input_range(ii,1));
    p0 = [p0, r0'];
end
anneal_opts = anneal();
anneal_opts.MaxIterations = 100;

%% Falsify (tau,eps)
%============= Perspective 1: falsify (tau,epsilon) with designer-provided parameters ===========================
fprintf('\n\nPerspective 1: Given values for tau and epsilon from the designer, try to find trajectories that are further apart \n than what is sepcified\n');
disp(['tau = ',num2str(taueps_tau), ', epsilon = ', num2str(taueps_eps),'.'])
pause(3)

%------------- 1.1 Maximization of eps for a given tau
S = formulae('taueps_closeness');
results_te_pers1 = falsify_taueps(falsification_method, p0, S, taueps_eps);
if save_results
    save([outdir, '/results_te_pers1', suffix, '.mat'], 'results_te_pers1');
end

if (results_te_pers1.rob <= 0)
    disp('Falsified')
else
    disp('Not falsified - conformant with probability approaching 1.');
end

% ============ Perspective 2: find tightest (=smallest) epsilon for which (tau,epsilon)-closeness is satisfied ===================
% For a fixed tau, (tau,epsilon) robustness is non-decreasing in
% epsilon, so do a dichotomy search.
fprintf('\n\nPerspective 2: find a smallest (tau,epsilon) pair such that the two systems are conformant.\n');
fprintf('This does search on epsilon only, given a tau value. Can be modified to do it the other way around.\n');
pause(4)
eta     = taueps_eps;  % the running epsilon
prevEta = 2*taueps_eps;
high = 3*taueps_eps;   % search in [low, high]
low = 0;
lastPosRob = [];
lastNegRob = [];

% First, verify that high indeed has positive rob - otherwise quit and ask
% user for a better starting value. This is typically faster than doing
% dichotomoy to find the initial high, though that can also be used.
formArgs.taueps_eps = high;
formEta = conf_get_formulae(formArgs);
SEta = formEta('taueps_closeness');

results_dichotomy = falsify_taueps(falsification_method, p0, SEta, high);
rob = results_dichotomy.rob;

if rob < 0
    msg = ['Robustness of high =  ', num2str(eta), ' is ', num2str(rob),'<0: re-start with a higher taueps_eps, to guarantee a positive starting robustness.'];
    error(msg);
elseif rob > 0
    lastPosRob = rob;
    signPrevRob = 1;
else
    msg = ['Found threshold epsilon = ',num2str(high),', rob = ',num2str(rob), ' from first dichotomy attempt! Quick, go play the lottery!'];
    disp(msg);
    return;
end

% Actual dichotomy
i = 0;
fval = high;
formArgs.taueps_eps = eta;
formEta = conf_get_formulae(formArgs);
SEta = formEta('taueps_closeness');
results_dichotomy = falsify_taueps(falsification_method, p0, SEta, eta);
rob = results_dichotomy.rob;
fval = results_dichotomy.fval;
signRob = sign(rob);
disp(['[',falsification_method,'] Dichotomy i=  ',num2str(i), ', eta = ', num2str(eta), ', rob = ', num2str(rob), ', high=',num2str(high), ', low=',num2str(low), ', fval = ', num2str(fval)])
% Always save last negative robustness, as this presents falsification
% witnesses.
if (rob < 0)
    save('lastNegRob.mat','results_dichotomy','lastPosRob','lastNegRob','high','low','eta','i')
end
% 100*eps is a small enough change to stop search
while i <= nb_dichotomy_iter && abs(prevEta - eta) > 100*eps
    i = i+1;
    % if rob remained positive or it went neg -> pos
    if signRob == 1 && signPrevRob == 1 || signPrevRob == -1 && signRob == 1
        high = eta;
    % rob remained negative or it went pos -> neg
    elseif signRob == -1 && signPrevRob == -1 || signPrevRob == 1 && signRob == -1
        low = eta;
    end
    prevEta = eta;
    eta = (high+low)/2;
    formArgs.taueps_eps = eta;
    formEta = conf_get_formulae(formArgs);
    SEta = formEta('taueps_closeness');
    results_dichotomy = falsify_taueps(falsification_method, p0, SEta, eta);
    rob = results_dichotomy.rob;
    fval = results_dichotomy.fval;
    p0 = results_dichotomy.psol; % for next iteration, use the current maximizer as starting point
    disp(['[',falsification_method,'] Dichotomy i=  ',num2str(i), '/',num2str(nb_dichotomy_iter), ', eta = ', num2str(eta), ', rob = ', num2str(rob), ', high=',num2str(high), ', low=',num2str(low), ', fval = ', num2str(fval)])
    if (rob < 0)
        save('lastNegRob.mat','results_dichotomy','lastPosRob','lastNegRob','high','low','eta','i')
    end
    signPrevRob = signRob;
    signRob = sign(rob);
    if signRob == -1
        lastNegRob = rob;
    else
        lastPosRob = rob;
    end
end
if isempty(lastNegRob)
    disp(['Dichotomy: could not find an epsilon such that (',num2str(taueps_tau),',epsilon)-closeness is false in ', num2str(i),' iterations.']);
elseif isempty(lastPosRob)
    disp(['Dichotomy: could not find an epsilon such that (',num2str(taueps_tau),',epsilon)-closeness is true in ', num2str(i),' iterations.']);
else
    disp(['Dichotomy: found a threshold epsilon = ', num2str(eta), ' in ', num2str(i),' iterations: (', num2str(taueps_tau),',',num2str(eta),')-closeness is false.' ]);
    disp(['Robustness interval around 0: [', num2str(lastNegRob),', ', num2str(lastPosRob), '], epsilon interval = [', num2str(low),', ', num2str(high), '].']);
    
end


% Used for iterating over Implementations
global nb_implementation_iterator_calls;
nb_implementation_iterator_calls = 0; %#ok<NASGU> % set to 0 to start new iteration

if ~run_only_mdl
    %% Demonstrate application-dependent PWC notion using Navbench (and several implementations of that)
    disp('')
    disp('--------------------------------------------------------------')
    disp('Falsifying Point-Wise Conformance (PWC) on Navigation benchmark');
    disp('PWC expresses that if the mode sequences of the two systems are different at some point, they will be equal after a maximum delay D.')
    disp('It is an example of an application-dependent conformance notion which is weaker than (tau,epsilon)-closeness.')
    pause(5)
    disp('For this task, we use temporal robustness. Note that temporal robustness can acquire infinite values.')
    disp('Also note that the simulator might output messages about guard crossings. These are normal.')
    pause(5);
    disp('We will compare the Model with several Implementations, obtained by varying dynamics and guard conditions.')
    pause(4);
    simtime = 20 %#ok<NOPRT>
    input_range = [];
    cp_array = [];
    opt.taliro = 'dp_t_taliro';
    results_direct = cell(1, nb_impls);
    nb_implementation_iterator_calls = 0;
    [s, Implementation] = conf_get_next_implementation(implargv, implAv, implBv);
    while s
        disp('')
        disp('Next implementation using SA_Taliro ')
        
        % If using other notions of conformance can add them here and save
        % them all in a results_direct cell.
        ixphi = 0;
        
        ixphi = ixphi+1;
        combined_system_locdiff = create_combined_parallel_system(struct('model', Model, 'implementation', Implementation, 'simulator_output', 'location_difference'));
        S = formulae('pwc');
        [results, ~] = staliro(combined_system_locdiff,combined_system_locdiff.init.cube,input_range,cp_array, S.phi, S.preds,simtime,opt);
        results_direct{ixphi, nb_implementation_iterator_calls} = results;
        
        [s, Implementation] = conf_get_next_implementation(implargv, implAv, implBv);
    end
    if save_results
        save([outdir, '/results_direct', suffix, '.mat'], 'results_direct');
    end
end

rmpath([currentrootdir,'/benchmarks/NavBenchmark']); 
rmpath([currentrootdir,'/benchmarks/AutomaticTransmission']); 
rmpath([currentrootdir,'/benchmarks/Powertrain']); 


    function value = epsForThisTau(p)
        % Given a decision variable value p (representing an initial
        % condition and the vector of control knots), generate Model and
        % Implementation trajectories and compute the corresponding epsilon
        % (for the given tau)
        % tau doesn't appear as an input argument because it's already been
        % incorporated in the definition of the composite system:
        % simulating the latter produces a trajectory with the right amount
        % of shifted differences.
        dimU = size(input_range, 1);
        dimX = length(p) - dimU;
        XPoint = p(1:dimX);
        UPoint = p(dimX+1:end);
        [hs, rc] = systemsimulator(comsys, XPoint, UPoint, simtime, input_range, nbControlPnts);
        % eps_Model(tau) = max_{t \in T} min_{s:|s-t|<tau} ||yM(t)- yI(s)||
        % The first column in ST contains instantaneous (non-shifted)
        % differences. This is part of both windows
        % The first half of the remaining columns contains the differences
        % between Impl traj and shifted Model trajs
        % The second half of the remaining columns contains the differences
        % between Model traj and shifted Impl trajs
        s = hs.STraj;
        shm = 0.5*(size(s,2)-1);
        assert(shm == floor(shm),'incorrect nb of shifted trajectory differences');
        epsModel = max(min(s(:,1:1+shm),[],2));
        epsImpl = max(min(s(:,[1,2+shm:size(s,2)]),[],2));
        value = max(epsModel, epsImpl);
    end

    function results = falsify_taueps(falsification_method, p0, S, epsToBeat)
        % Falsify (tau,epsToBeat) using one of two ways:
        % 'direct': simply maximize eps(tau) for the given tau. If the
        % found max > epsToBeat, then we know (tau,epsToBeat) does not hold
        % for these systems, and rob = -1 (only sign matters). We use
        % function anneal, with starting point p0, to maximize.
        % 'convert': convert (tau,eps) to an actual MTL formula S and
        % falsify that with S-Taliro.
        if strcmp(falsification_method, 'direct')
            [psol, fval] = anneal(loss,p0,anneal_opts);
            fval = -fval; % since we minimized the negative of the objective
            % If the largest found eps is less than the specified eps, then systems do satisfy
            % (tau,high) (with a good probability)
            % This artificial robustness only gives a useful sign (and not a value):
            % 1 if epsToBeat > fval, so max found eps is less than the
            % value we're testing for => (tau,eps) satisfied
            rob = sign(epsToBeat - fval); 
            results = struct('psol', psol);
        else
            results = staliro(comsys,[], input_range, nbControlPnts, S.phi, S.preds,simtime,opt);            
            fval = nan;
        end
        results.rob = rob;
        results.fval = fval;
    end

end



