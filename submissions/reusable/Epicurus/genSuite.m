
% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

%   GENSUITE generates the test cases within the inputs ranges and
%   following a given policy. Then, it simulates the model given the inputs
%   and returns the test case 

% INPUTS:
%   - model: the simulink model name. 
%
%   - init_cond : a hyper-rectangle that holds the range of the initial 
%       conditions (or more generally, constant parameters) and it should be a 
%       Matlab n x 2 array, where 
%			n is the size of the vector of initial conditions.
%		In the case of a Simulink model or a Blackbox model:
%			The array can be empty indicating no search over initial conditions 
%			or constant parameters. For Simulink models in particular, an empty 
%			array for initial conditions implies that the initial conditions in
%			the Simulink model will be used. 
%
%       Format: [LowerBound_1 UpperBound_1; ...
%                          ...
%                LowerBound_n UpperBound_n];
%
%       Examples: 
%        % A set of initial conditions for a 3D system
%        init_cond = [3 6; 7 8; 9 12]; 
%        % An empty set in case the initial conditions in the model should be 
%        % used
%        init_cond = [];
%
%       Additional constraints on the initial condition search space can be defined 
%       using the staliro option <a href="matlab: doc staliro_options.search_space_constrained">staliro_options.search_space_constrained</a>. 
%   - phi : The formula to falsify. It should be a string. For the syntax of MTL 
%       formulas type "help dp_taliro" (or see staliro_options.taliro for other
%       supported options depending on the temporal logic robustness toolbox 
%       that you will be using).
%                               
%       Example: 
%           phi = '!<>_[3.5,4.0] b)'
%
%       Note: phi can be empty in case the model is a hybrid automaton 
%       object. In this case, an unsafe set must be provided in the hybrid
%       automaton.
%
%   - preds : contains the mapping of the atomic propositions in the formula to
%       predicates over the state space or the output space of the model. For 
%       help defining predicate mappings type "help dp_taliro" (or see 
%       staliro_options.taliro for other supported options depending on the 
%       temporal logic robustness toolbox that you will be using).
%
%       In case of parameter mining:
%           If staliro is run for specification parameter mining, then set the 
%           staliro option parameterEstimation to 1 (the default value is 0):
%               opt.parameterEstimation = 1;
%           and read the instructions under staliro_options.parameterEstimation 
%           on how to define the mapping of the atomic propositions.	               
% 
%   - input_range: the ranges for the test case generation.
% 
%   - interpolation_type: The methods for interpolation functions
%       * 'pconst' for piecewise constant signals 
%       * 'const' for constant signals (only one control point must be specified)
% 
%  - cp_array : contains the control points that parameterize each input signal. It should be a vector (1 x m array) and its length must be equal 
%       to the number of inputs to the system. Each element in the vector indicates how many control points each signal will have. 
%
%           Specific cases:
% 
%           * If the signals generated using interpolation between the control  
%             points, e.g., piece-wise linear or splines (for more options see 
%             <a href="matlab: doc staliro_options.interpolationtype">staliro_options.interpolationtype</a>): 
% 
%             Initially, the control points are equally distributed over the time duration of the simulation. The time coordinate of the 
%             control points will remain constant unless the option
% 
%                         <a href="matlab: doc staliro_options.varying_cp_times">staliro_options.varying_cp_times</a>
% 
%             is set (see the staliro_options help file for further instructions and restrictions). The time coordinate of the first and last control 
%             points always remains fixed.
% 
%             Example: 
%               cp_array = [1];
%                   indicates 1 control point for only 1 input signal to the model. One control point can only be used with piecewise constant 
%                   signals. If we assume that the total simulation time is 6 time units and the input range is [0 2], then the input signal will 
%                   be:
%                      for all time t in [0,6] u(t) = const with const in [0,2] 						
% 
%               cp_array = [4];
%                   indicates 4 control points for only 1 input signal to the model. If we assume that the total simulation time is 6 time units, 
%                   then the initial distribution of the control points will be:
%                                0   2   4   6
% 
%               cp_array = [10 14];
%                   indicates 10 control points for the 1st input signal and 14 for the second input. 
%
%   - cp: a cell array of the control points names built as input name+the number of control.
%       i.e: {'HDGref1','HDGref2','HDGmode1','HDGmode2'}
%
%   - datasavefile: the name of the file that saves the inputs.
%
%   - categorical: the index of the categorical inputs in input_name. if none write []
%   - count: the iteration counter
%   - assume_opt : epicurus_options . epicurus should be of type "epicurus_options". 
%       If the default options are going to be used, then this input may be
%       omitted. For instructions on how to change epicurus options, 
%       see the epicurus_options help file for each desired property.

% OUTPUT
%   tv: a vector equal in rows length to iteration size: each row represents a test case and contains the values of the inputs
%       control points generated + the outcome of the simulation of the test case.
%       cp1 | cp2 | cp3 | .. | Fitness

function tv=genSuite(model,init_cond, phi, preds, sim_time,Oldt,input_range,interpolation_type,cp_array,cp,datasavefile,categorical,count,assume_opt)
    curPath=fileparts(which('GenSuite.m')); 
    addpath(genpath(curPath));
    cpf=repmat('%.3f,',1,size(cp,2));
%     cp{end+1}='label';
    controlPointNames=cp(1:end);
%% Set the policy    
%   policy: provides guided sampling given the size of the sample. It takes one of the three strings
%        * 'URopt': perform random sampling in the state and input spaces
%           by following a uniform distribution 
%        * 'ARopt': Perform adaptive random sampling in input spaces that maximizes the distance among the generated test cases given the
%           previously generated test cases.
%
%        During random and adaptive random sampling, the optimization mode and the optimization method are set: 
%        isfalsification: If this option is set to true (1), then S-Taliro performs falsification. That is, it stops executing when a trajectory of
%        negative robustness value is detected. If this option is set to false (0), then S-Taliro performs minimization. That is, even if a falsifying trajectory is found,
%        S-Taliro continues the search for the worst possible behavior.
%
%        * 'IFBT_UR': generates test cases by focusing mainly on the important features that have the highest impact on the fitness
%           values given the previously generated test cases and the previously generated assumptions, in areas of the input domain that are more informative for the ML. The test case generationapplies is performed using UR
%
%        * 'IFBT_ART': generates test cases by focusing mainly on the important features that have the highest impact on the fitness
%           values given the previously generated test cases and the
%           previously generated assumptions, in areas of the input domain
%           that are more informative for the ML. The test case generationapplies is performed using ART
%
    switch assume_opt.policy
        case 'UR'
            isfalsification=0;      
            optimization_solver = 'UR_Taliro'; 
        case 'ART'
            isfalsification=0;        
            optimization_solver = 'AR_Taliro';
        case 'IFBT_ART'
            isfalsification=0;   
            optimization_solver = 'IFBT_ART';
        case 'IFBT_UR'
            isfalsification=0;   
            optimization_solver = 'IFBT_UR';
        otherwise    % uniform random by default
            isfalsification=0;   
            optimization_solver = 'UR_Taliro';
    end

    assume_opt.optimization_solver = optimization_solver;  
    interpolation    = cell(size(cp_array,2), 1);
    interpolation(:) = {interpolation_type};
    assume_opt.interpolationtype = interpolation;
    assume_opt.falsification=isfalsification;
    % Setting the first iteration size (we recommend a minimum value as 30 test cases)
    if (assume_opt.first==1)
        assume_opt.optim_params.n_tests=assume_opt.iteration1Size;
    else
        assume_opt.optim_params.n_tests=assume_opt.testSuiteSize;
    end
    assume_opt.runs=1;
    disp(['Setting S-Taliro with ',optimization_solver]);
    disp('Running S-Taliro');
    tv=[];
    [results, history, assume_opt]=staliro(model,init_cond, input_range, cp_array,  phi, preds, sim_time, assume_opt, Oldt,controlPointNames,categorical,count);
    samples= vertcat(history.samples);
    robustness=vertcat(history.rob);
    dataset=[samples robustness];
    tv=dataset;   
    data = [Oldt;tv];
    fid = fopen([datasavefile,'.csv'],'a');
    dataC=data;    
    dataC(:,end)=double(dataC(:,end)>=0);
    fprintf(fid, strcat(cpf(1:end),'%.3f\n'),data');
    fclose(fid);
    fid1=fopen([datasavefile,'C.csv'],'a');
    fprintf(fid1, strcat(cpf(1:end),'%.3f\n'),dataC');
    fclose(fid1);
    delete '*.slxc';
end
