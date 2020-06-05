% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

%   genAssum learns assumptions from all the previously generated test cases.
%   it takes the data, builds a classification tree then extracts the conditions on the nodes 
%   from each branch of the tree to build the assumptions and returns the assumptions.
%
% INPUTS
%   tv: the newly generated test cases
%
%   Oldt: the prviously generated test cases. tv and Oldt will be merged and used for assumption generation
%
%   inputnames: a string array of the input control points names. 
%               it serves as the parameter predictors names during the decision tree building 
% 
%   categorical: an array of the categorical inputs indexes
%               it serves as the parameter predictors names during the decision tree building 
%
%   - assume_options : epicurus_options . epicurus should be of type "epicurus_options". 
%       If the default options are going to be used, then this input may be
%       omitted. For instructions on how to change epicurus options, 
%       see the epicurus_options help file for each desired property.
% OUTPUTS
%   assumptionArray: a cell array that contains the selected assumptions + information:
%                       C | probability estimate | leaf size | Parent node index | the Mean fitness at the leaf | importantFeature(if exists)
%                       Each row contains the information of one constraint C={c1 ^ c2 ^.. cn} where ci is a condition on one input
%                       Example of constraint C: ‘(input1 < 1) and (input2>= 10)’
%
%   parent_constraints: The parent constraints of the leaves associated with the selected assumptions assumptionArray.
%                       It can serve as a parameter in the function getRanges (genSuite) to get the next candidate input ranges
%                       on which the next test generation will be based. 
%
%   interAssum: a cell array of the intemediate assumptions generated + information
%               It serves as history

function [assumptionArray,parent_constraints,interAssum] = genAssum(tv,Olt,inputnames,categorical,assume_options)
    
    assume_opt=assume_options();
    data = [Olt;tv]; 
    X=data(:,1:end-1);     % X contains the input predictors
    if ~isempty(categorical) % if the categorical is set , make sure the inputs are booleans 
        X(:,categorical)=double(X>=0.5);
    end
    Y1=data(:,end);       % Y contains the fitness values
    Y(:,1)=double(Y1(:,1)>=assume_opt.desiredFitness);

    classificationTree =  fitctree(X,Y,...
                     'PredictorNames',inputnames,...
                     'CategoricalPredictors',categorical,...
                     'ClassNames',[0,1]);
    as=getNodes(classificationTree); % as: a cell array of all ci
    interAssum=getAssumption(classificationTree,as);
    % Select assumptions associated with fitness>0
    if classificationTree.NumNodes==1
        assumptionArray=[];
        parent_constraints=[];
    else
        [parent_constraints,assumptionArray]= selectA(interAssum,'>',assume_opt.desiredFitness,assume_opt.exploit,1);
    end
end