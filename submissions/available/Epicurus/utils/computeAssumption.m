% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

% COMPUTEASSUMPTION computes the informative assumptions by generating a
%regression tree 
% INPUTS
%   X: the values of the inputs in a test suite
%   Y: the values of the fitness associated with each test case in the test
%   suite 
%   inputnames: a string array of the input control points names. 
%               it serves as the parameter predictors names during the decision tree building 
% 
%   categorical: an array of the categorical inputs indexes
%               it serves as the parameter predictors names during the decision tree building 
%   count: the iteration counter
%   opt : epicurus_options . epicurus should be of type "epicurus_options". 
%       If the default options are going to be used, then this input may be
%       omitted. For instructions on how to change epicurus options, 
%       see the epicurus_options help file for each desired property.

function [feature,informativeA] = computeAssumption(X, Y,inputnames,categorical,count,assume_opt)
    selectedV=[];
    selectedminus=[];
    selectedplus=[];
    minLeafSize = round(size(Y,1)/10);
    selectedplus=[];
    selectedminus=[];
    regressionTree =  fitrtree(X,Y,...
                    'minleaf',minLeafSize,...
                     'PredictorNames',inputnames,...
                     'CategoricalPredictors',categorical);
    if (regressionTree.NumNodes<=1)
        regressionTree =  fitrtree(X,Y,...
                     'minleaf',minLeafSize,...
                     'PredictorNames',inputnames,...
                     'CategoricalPredictors',categorical);
    end
    
    r_as=getNodes(regressionTree); % as: a cell array of all ci
    disp('r_as:');
    disp(r_as);
    interInformativeAssum=getAssumption(regressionTree,r_as);
    disp('interInformativeAssum:')
    disp(interInformativeAssum);
    disp('assume_opt.desiredFitness-assume_opt.exploit:');
    disp(assume_opt.desiredFitness);
    disp(assume_opt.exploit);
    [~,informativeAplus]=selectA(interInformativeAssum,'>',assume_opt.desiredFitness,assume_opt.exploit,0);
    plusRow=find( arrayfun(@(RIDX) informativeAplus{RIDX,5}==min([informativeAplus{:,5}]) , 1:size(informativeAplus,1)) );
    if ~isempty(plusRow)
        selectedplus=informativeAplus(plusRow,:); % selected assumptions + information
    end
    [~,informative]=selectA(interInformativeAssum,'==',assume_opt.desiredFitness,assume_opt.exploit,0);
    vRow=find( arrayfun(@(RIDX) informative{RIDX,5}==min([informative{:,5}]) , 1:size(informative,1)) );
    if ~isempty(vRow)
        selectedV=informative(vRow,:); % selected assumptions + information
    end
    [~,informativeAminus]=selectA(interInformativeAssum,'<',assume_opt.desiredFitness,assume_opt.exploit,0);
    minusRow=find( arrayfun(@(RIDX) informativeAminus{RIDX,5}==max([informativeAminus{:,5}]) , 1:size(informativeAminus,1)) );
    if ~isempty(minusRow)
        selectedminus=informativeAminus(minusRow,:); % selected assumptions + information
    end
    informativeA=[selectedminus;selectedV;selectedplus];
    % use regression to retrieve the important feature
    feature=getImportantF(regressionTree,count, assume_opt);
     

end

