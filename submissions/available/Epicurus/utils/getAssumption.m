% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

% GETASSUMPTION returns the assumption + information
% each row contains all the information about the constraint
% Each row contains the information of one constraint C={c1 ^ c2 ^.. cn} where ci is a condition on one input
% Example of constraint C: ‘(input1 < 1) and (input2>= 10)’
% INPUT
%   decisionTree: the decision tree 
%   as: the nodes information 
% OUTPUT
%   assumption: a cell array of the constraints.
%               C | probability estimate | leaf size | Parent node index | the Mean fitness at the leaf | importantFeature(if exists)

function assumption=getAssumption(decisionTree,as)
    number_leaves=sum(decisionTree.IsBranchNode==0);
    
    assumption = cell(number_leaves,3);
    leaf_indexes= find(decisionTree.IsBranchNode==0);
    for l= 1:number_leaves 
        n=leaf_indexes(l);
        assumption{l,1}=strcat(' (',as{leaf_indexes(l)},') ');
        while (decisionTree.Parent(n,:)>1)      
            assumption{l,1}=strcat(' (',as{decisionTree.Parent(n,:)},') and',assumption{l,1});
            n=decisionTree.Parent(n,:);
        end 
        assumption{l,3}=decisionTree.NodeProbability(leaf_indexes(l),1);
        assumption{l,2}=decisionTree.NodeSize(leaf_indexes(l),:);
        assumption{l,4}=decisionTree.Parent(leaf_indexes(l),1);
        if isa(decisionTree,'RegressionTree')
            assumption{l,5}=decisionTree.NodeMean(leaf_indexes(l),1);
        else
           assumption{l,5}=str2double(decisionTree.NodeClass(leaf_indexes(l),1)); 
           assumption{l,6}=max(decisionTree.ClassProbability(leaf_indexes(l),:));     
        end
     
    end
end