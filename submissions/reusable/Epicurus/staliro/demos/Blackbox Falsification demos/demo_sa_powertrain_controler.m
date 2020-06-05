% This script demonstrates how to use:
%   * SA_Taliro for falsification of formula 27 in paper [1]
%   * Customized Pulse input for staliro explained in paper [2]
%
% To run this demo you must have tbxmanager installed
%   Matlab toolbox manager is available at (http://www.tbxmanager.com/).
%   Using tbxmanager, the following packages should be installed:
%   cddmex, fourier, glpkmex, hysdel, lcp, mpt, mptdoc, sedumi, yalmip
%
%
% The model is described in detail in the benchmark paper:
% [1] Xiaoqing Jin, Jyotirmoy V. Deshmukh, James Kapinski, Koichi Ueda, 
%     Ken Butts, Powertrain Control Verification Benchmark HSCC 2014
%
%
% The input is described in detail in the benchmark paper:
% [2] Adel Dokhanchi, Shakiba Yaghoubi, Bardh Hoxha and Georgios Fainekos
%     ARCH-COMP17 Category Report: Preliminary Results on the Falsification 
%     Benchmarks, ARCH workshop CPSWeek 2017
%
%
% (C) Shakiba Yaghoubi - 2018 - Arizona State University 
% (C) Adel Dokhanchi - 2018 - Arizona State University 
% (C) Georgios Fainekos - 2018 - Arizona State University 

clear;
warning('off','all');
cd('..')
cd('SystemModelsAndData');

model = @BlackBoxAbstractFuelControl;
% total simulation time
simTime = 50 ; 
% time to start measurement, mainly used to ignore 
measureTime = 1;  
% number of control points, here we use onstant engine speed


fault_time = 100; 
% setting time
eta = 1;
% parameter h used for event definition
h = 0.05;
% parameter related to the period of the pulse signal
zeta_min = 5;
%
C = 0.05;
Cr = 0.1;
Cl = 0.1;
Ut = 0.008;
low=8.8;
high=40;
taus = 10 + eta;

% default settings
spec_num = 1; %specification measurement
fuel_inj_tol = 1.0; 
MAF_sensor_tol = 1.0;
AF_sensor_tol = 1.0;
initial_cond = [];

opt = staliro_options();
opt.black_box = 1;
opt.SampTime = 0.05;
opt.falsification=1;
outer_runs = 1;
opt.runs=1;


%---------------------------------------------------------------------    
i=0;

i = i+1;
preds(i).str = 'low'; % for the pedal input signal
preds(i).A =  [0 0 1] ;
preds(i).b =  low ;
i = i+1;

preds(i).str = 'high'; % for the pedal input signal
preds(i).A =  [0 0 -1] ;
preds(i).b =  -high ;
i = i+1;
% rise event is represented as low/\<>_(0,h)high
% fall event is represented as high/\<>_(0,h)low
preds(i).str = 'norm'; % mode < 0.5 (normal mode = 0)
preds(i).A =  [0 1 0] ;  
preds(i).b =  0.5 ;
i = i+1;
preds(i).str = 'pwr'; % mode >0.5 (power mode = 1)
preds(i).A =  [0 -1 0] ;
preds(i).b =  -0.5 ;
i = i+1;
preds(i).str = 'utr'; % u<=Ut
preds(i).A =  [1 0 0] ;
preds(i).b =  Ut ;
i = i+1;
preds(i).str = 'utl'; % u>=-Ut
preds(i).A =  [-1 0 0] ;
preds(i).b =  Ut ;
i = i+1;

phi =['[]_(' num2str(taus) ', inf)(((low/\<>_(0,' ...
            num2str(h) ')high) \/ (high/\<>_(0,' num2str(h) ')low))' ...
           '-> []_[' num2str(eta) ', ' num2str(zeta_min) '](utr /\ utl))'];
        
        
cp_array = []; 
pulse='mid_high' ;% 'mid_low'  for -_- first fall, then rise
                  % 'mid_high' for _-_ first rise, then fall
opt.optimization_solver = 'SA_Taliro'; 
opt.optim_params.dispStart= 0.9;
opt.optim_params.dispAdap = 2;        
% Parameterization:
% x1 : the value of the signal1,
% x2, x4, x6: the values of signal 2, and
% x3, x5: times of steps.
opt.interpolationtype = {'const', @PulseInputSignal};
input_range = {[900  1100]; [0 61.1; 0 simTime; 0 61.1; 0 simTime; 0 61.1]}; 

% Input signal

opt.search_space_constrained.constrained=true;
if strcmp(pulse,'mid_high')
        % t2>t1+5: x5-x3>5 
        A = [0 0 1 0 -1 0];
        b = -5;
        %t1>tau_s : x3>tau_s
        A = [A; [0 0 -1 0 0 0]];
        b = [b; -taus];
        %  x2 < low
        A = [A; [0 1 0 0 0 0]];
        b = [b; low];
        % x4 > high
        A = [A; [0 0 0 -1 0 0]];
        b = [b; -high];
        %  x6 < low
        A = [A; [0 0 0 0 0 1]];
        b = [b; low];
else
        % t2>t1+5: x5-x3>5
        A = [0 0 1 0 -1 0];
        b = -5;
        %  x2 > high
        A = [A; [0 -1 0 0 0 0]];
        b = [b; -high];
        % x4 < low
        A = [A; [0 0 0 1 0 0]];
        b = [b; low];
        %  x6 > high
        A = [A; [0 0 0 0 0 -1]];
        b = [b; -high];
end
opt.search_space_constrained.A_ineq= A;
opt.search_space_constrained.b_ineq= b;

opt.optim_params.n_tests = 20; % number of tests
[results,history] = staliro(model,initial_cond,input_range,cp_array,phi,preds,simTime,opt);

results.run(results.optRobIndex).bestRob

cd('..')
cd('Blackbox Falsification demos')