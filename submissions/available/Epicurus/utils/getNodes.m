% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

% GETNODES traverses the decision tree (depth first) and collects the
% conditions ci from the decision tree nodes
% INPUTS
%   T: the decision tree 
%
% OUTPUTS
%   as: a cell array of all ci + information 
%   node index | Parent node index | node size | ci | proportion | Mean


function as=getNodes(T)
    as = cell(T.NumNodes,1);
    for i=1:T.NumNodes
        p= T.Parent(i,:);
        if (p~=0)
            operand1=T.CutPredictor(p,:);
            if strcmp(T.CutType(p,:),'continuous')
                if (rem(i,2)==0)
                    operator='<';
                else
                    operator='>=';
                end
                operand2=T.CutPoint(p,:);
            elseif strcmp(T.CutType(p,:),'categorical')
                operator='=';
                if (rem(i,2)==0)
                    operand2=T.CutCategories(p,1);
                else
                    operand2=T.CutCategories(p,2);
                end
            end
            if iscell(operand2)
                as{i}=strcat(operand1{:},operator,num2str(operand2{:}));
            else
                as{i}=strcat(operand1{:},operator,num2str(operand2));
            end
        else
            as{i}='NaN';
        end    
    end
end