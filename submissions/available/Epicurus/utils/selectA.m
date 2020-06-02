% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

% selectA selects assumptions from the intermediate assumptions by keeping only the ones 
% associated to leaves with (fitness 'op' v).
% We define siblings as the leaves that have the same parent node.
%
% INPUT
%   assumptions: cell array of assumptions + information of assumptions
%   operator: will be used as an operator to evaluate and select assumptions
%   v: the desired fitness threshold 
%   exploit: if the assumptions will be exploited for the next test
%   generation exploit=1. otherwise exploit=0
%   pure: the selection of the assumption will be performed only on pure nodes
%
% OUTPUT
%   assumptionToCheckArray : The selected assumptions + information
%   parent_constraints: The parent constraints of the leaves associated with the selected assumptions assumptionArray.
%                       

function [parent_constraints,selectedAssum]=selectA(assumptions,operator,v,exploit,pure)  
    parent_constraints=[];
    selectedAssum=[];
    [parents,~,idx] = unique(cell2mat(assumptions(:,4)),'rows'); % parents: the indexes of the parents
    cnt = histc(idx,unique(idx)); % occurence of each parent
    sib_parents=parents(cnt==2,:); % parents with siblings 
    % siblings cell array contains: 
    % sibling1 fitness | sibling2 fitness | parent node | parent constraints
    siblings = cell(size(sib_parents,1),4);
    for i = 1 : size(sib_parents,1)
        x=assumptions(cell2mat(assumptions(:,4))==sib_parents(i),:);
        siblings{i,1}=x{1,5}; % sibling1 fitness
        siblings{i,2}=x{2,5}; % sibling2 fitness
        siblings{i,3}=sib_parents(i); % parent node
        inter=intersect(strsplit(x{1,1}),strsplit(x{2,1})); % parent constraints : intersection of siblings constraints
        siblings{i,4}=inter(:,~strcmp(inter,'and')); % append parent constraints
    end
    % find the siblings where the fitness has an opposite sign and the fitness is >= v 
    informative_row=find(([siblings{:,1}].*[siblings{:,2}]<=0)&(max([siblings{:,1}],[siblings{:,2}])>=v));
    sib=[max([siblings{informative_row,1};siblings{informative_row,2}]),siblings{informative_row,3}]; 
    positive_sib = reshape(sib,[],2); % [The siblings with positive fitness; the parent constraint]
    row=zeros(1,size(positive_sib,1));
    for ind=1:size(positive_sib,1)
        % Find the positive siblings indexes in assumptions 
        row(1,ind) = max(find( arrayfun(@(RIDX) assumptions{RIDX,4} == positive_sib(ind,2) && assumptions{RIDX,5}==positive_sib(ind,1), 1:size(assumptions,1)) ));
    end 
    selectedRow=eval(['find( arrayfun(@(RIDX) assumptions{RIDX,5}',operator,num2str(v),' , 1:size(assumptions,1)) )']);
    if ~isempty(selectedRow)
        selectedAssum=assumptions(selectedRow,:); % selected assumptions + information
    end
    if pure ==1
        pureRow=find( arrayfun(@(RIDX) selectedAssum{RIDX,6}==1, 1:size(selectedAssum,1)) );
        if ~isempty(pureRow)            
            selectedAssum=selectedAssum(pureRow,:); % pure assumptions + information
        else
            selectedAssum=[];
        end
    end
    
    if ~isempty(row) && (exploit==1)
        parent_constraints=reshape(siblings(informative_row,4),size(positive_sib,1),[]); % (size(row)× branche's number of nodes) string array the parent constraints    
    end
end
