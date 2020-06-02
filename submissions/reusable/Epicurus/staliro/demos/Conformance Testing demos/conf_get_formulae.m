function formulae = conf_get_formulae(varargin)
% 
% NAME
% 
%     conf_get_formulae - obtain several conformance MTL formulae
% 
% SYNOPSIS
% 
%     formulae = staliro_demo_conformance(args)
%     formulae = staliro_demo_conformance()
%     
% DESCRIPTION
% 
%     Returns a Map containing a number of conformance-related MTL formulae in the usual
%     format: preds, str (or param)
%     
%   Inputs
%     
%     simtime, plotit, bc_dm, bttd_tau, taueps_tau, taueps_eps, sp
%           See staliro_demo_conformance help for these parameters
%         
%     nbloc
%           The number of locations in hybrid automaton for guard-seeking formula
%
%     Dpwc
%           In PWC, if locations are different they must be the same again
%           after D units of time.
%
%     po_t1
%           in parametrized PWC, Dpwc is a parameter, and its range is [0, po_t1]
%         
%         
%   Outputs
%     
%     formuale
%           a containers.Map object, with key = name of formula, and value = struct with fields 
%           'phi' and 'preds'. struct.phi is the string formula expression, and struct.preds
%           is the usual preds struct.
%           Currently supported formulae: pwc (Point-Wise Conformance),
%           pwc_p (parametrized pwc) and taueps_closeness ((tau, eps)-closeness)
%         
% 
% EXAMPLES
% 
%         formulae = conf_get_formulae;
%         fTauEps = formuale('taueps');
%         results = staliro(Model,Model.init.cube,input_range,cp_array, fTauEps.phi , fTauEps.preds, simtime, opt);
%         
%         
% AUTHOR(S)
% 
%        Written by Houssam Abbas - Arizona State University 
% 
% See also - staliro_demo_conformance
        
        
% Parameters and stuff

if nargin == 0
    simtime = 20;    
    nbloc = 16;
    taueps_tau = 0.0001;
    taueps_eps = 0.21;
    sp = taueps_tau/2;   
    Dpwc = 0.5;
    po_t1 = 2;
elseif nargin == 1
    argv = varargin{1};
    simtime = argv.simtime;
    taueps_tau = argv.taueps_tau;
    taueps_eps = argv.taueps_eps;
    Dpwc = argv.Dpwc;
    sp = argv.sp;
    nbloc = argv.nbloc;
    po_t1 = argv.po_t1;
end
effT1 = simtime - Dpwc;
effT2 = simtime - po_t1;

% Because different formulae use different simulator output, we use
% different preds structs for them.

% phi_pwc works on one-dimensional signals, which are the
% magnitude of the difference between trajectories' locations. 
% phi_pwc_p is a parametrized version of phi_pwc.
ii = 1;
preds(ii).str='same_locations_1';
preds(ii).A = 1;
preds(ii).b = 0.5;
preds(ii).loc = 1:nbloc;

ii =ii+1;
preds(ii).str='same_locations_2';
preds(ii).A = -1;
preds(ii).b = 0.5;
preds(ii).loc = 1:nbloc;

ii = ii+1;
preds(ii).par='t1';
preds(ii).value = 2;
preds(ii).range = [0 po_t1];

phi_pwc     = ['[]_[0,',num2str(effT1),'](!(same_locations_1 /\ same_locations_2) -> <>_[0,', num2str(Dpwc),'](same_locations_1 /\ same_locations_2))'];
phi_pwc_p   = ['!([]_[0,',num2str(effT2),'](!(same_locations_1 /\ same_locations_2) -> <>_[0,t1](same_locations_1 /\ same_locations_2)))'];


% (tau, epsilon)-closeness
% sp = sampling period, fixed
% The signal to which these predicates apply is the following:
% y = ||x1(t)-x2(t)|| is the difference between current samples
% m_q = ||x1(t+q*sp)-x2(t)|| is the difference between shifted model sample
% and current implementation sample
% i_q = ||x2(t+q*sp)-x1(t)|| is the difference between shifted
% implementation sample and current model sample
% m_q and i_q are 'auxiliary' signals needed for testing.
% x = [y m_(-tau/sp) ... m_(tau/sp) i_(-tau/sp) ... i_(-tau/sp)]
% Always (y(t) <= eps or m_(-tau/sp)(t) <= eps or ... or m_(tau/sp)(t) < eps)
% AND
% Always (y(t) <= eps or i_(-tau/sp)(t) <= eps or ... or i_(tau/sp)(t) < eps)
tau     = taueps_tau;
strInt = ['[',num2str(tau),',',num2str(simtime - 2*tau),']'];
nbSamples = ceil(tau/sp);
% Nb signals = 1 for y + 2*nbSamples in the past (one for shifting model and one for shiting implementation)
%                      + 2*nbSamples in the future (one for model and one for implementation)
m =    1 +       2*(nbSamples)       +      2*(nbSamples);
tepreds(1).str  = 'y_lt_eps';
tepreds(1).A    = [1 zeros(1,m-1)];
tepreds(1).b    = taueps_eps;
tepreds(1).loc  = 1:nbloc;
for ii=2:m
    tepreds(ii).str = ['aux',num2str(ii),'_lt_eps'];
    tepreds(ii).A   = [zeros(1,ii-1), 1, zeros(1,m-ii)];
    tepreds(ii).b   = taueps_eps;
    tepreds(ii).loc = 1:nbloc;
end
phi_taueps_closeness = ['[]_',strInt,'(y_lt_eps '];
for ii=2:2*nbSamples+1
    phi_taueps_closeness = [phi_taueps_closeness, ' \/ ', tepreds(ii).str ]; %#ok<*AGROW>
end
phi_taueps_closeness = [phi_taueps_closeness, ') /\ []_',strInt,'(y_lt_eps '];

for ii=2*nbSamples+2:m
    phi_taueps_closeness = [phi_taueps_closeness, ' \/ ', tepreds(ii).str ];
end
phi_taueps_closeness = [phi_taueps_closeness, ')'];
ii = ii+1;
tepreds(ii).par = 'epsilon';
tepreds(ii).value = taueps_eps/10; % where to start the search
tepreds(ii).range = [0 taueps_eps];

keys = {'pwc', 'pwc_p', 'taueps_closeness'};
values = {
    struct('phi', phi_pwc, 'preds', preds),
    struct('phi', phi_pwc_p, 'preds', preds),
    struct('phi', phi_taueps_closeness, 'preds', tepreds),
    };
formulae = containers.Map(keys, values);


