classdef epicurus_options < staliro_options
% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 
% Class definition for the Epicurus options
%
% opt = epicurus_options;
%
% The above function call sets the default values for the class properties. 
% For a detailed description of each property open the <a href="matlab: doc epicurus_options">epicurus_options help file</a>.
%
% To change the default values to user-specified values use the default
% object already created to specify the properties.
%
% E.g.: to change the number of assume iterations to 100, type
% opt.assumeIterations = 100;
     properties
        % the maximum number of iterations 
        assumeIterations= 30;
        % The number of Epicurus runs
        assumeRuns=1;
        % Enabling writing internal assumptions of each iteration 
        writeInternalAssumptions=1;
        % the number of test cases per iteration
        testSuiteSize=30;
        % The number of test cases in the first iteration
        iteration1Size=30;
        % the number of control points 
        nbrControlPoints=1;
        % the test case generation policy. choose one from : 'UR','ART','IFBT_UR','IFBT_ART'
        policy='UR';
        % the desired fitness value
        desiredFitness=0;
        epsilon=10; % the fitness tolerence value in IFBT policy
        exploit=0;
        first=1;
        % Qvtrace check enabling
        qvtraceenabled=true;
     end
        methods
          function obj = set.assumeIterations(obj,assumeIterations)
            obj.assumeIterations=assumeIterations;
          end
          function obj = set.qvtraceenabled(obj,qvtraceenabled)
            obj.qvtraceenabled=qvtraceenabled;
          end
          function obj = set.writeInternalAssumptions(obj,writeInternalAssumptions)
            obj.writeInternalAssumptions=writeInternalAssumptions;
          end        
          function obj = set.nbrControlPoints(obj,nbrControlPoints)
            obj.nbrControlPoints=nbrControlPoints;
          end
          function obj = set.policy(obj,policy)
            obj.policy=policy;
          end
          function obj = set.desiredFitness(obj,desiredFitness)
            obj.desiredFitness=desiredFitness;
          end
          function obj = set.epsilon(obj,epsilon)
            obj.epsilon=epsilon;
          end
          function obj = set.exploit(obj,exploit)
            obj.exploit=exploit;
          end
          function obj = set.iteration1Size(obj,iteration1Size)
            obj.iteration1Size=iteration1Size;
          end
          function obj = set.testSuiteSize(obj,testSuiteSize)
            obj.testSuiteSize=testSuiteSize;
          end
          function obj = set.first(obj,first)
            obj.first=first;
          end
        end
end
