% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

% getRange changes the previous ranges by getting the new ranges from one parents constraint
% INPUT
%   pConstr: 1 constraint C = {c1, c2,...,cn}, each ci is a condition on one input control point
%   input_names: the inputs names
%   candidate: previous input ranges
% OUTPUT
%   constrRange: new input ranges

function constrRange=getRange(Constr,input_names,candidate)
    constrRange=candidate;
    PieceConstrSplited=strsplit(Constr);
    PieceConstr=PieceConstrSplited(:,~strcmp(PieceConstrSplited,'and'));
   
        
%         perc=2+0.1*it_num;
        if ~isempty(find(contains(PieceConstr,'>=')))
            gt{:,1}=extractBetween(PieceConstr(find(contains(PieceConstr,'>='))),"(",">=")';
            gt{:,2}=repmat('>=',size(find(contains(PieceConstr,">=")),2),1);
            gt{:,3}=extractBetween(PieceConstr(find(contains(PieceConstr,'>='))),">=",")")';
            % inputinf: (2*1 string array) list of constrained inputs with a lower range 
            % Lower: (2×1 string array) the lower range for each input in inputinf 
            [inputinf,~,idxinf] = unique((gt{:,1}),'rows'); 
            lower=zeros(1,size(inputinf,1));

            for i = 1 : size(inputinf,1)
                rows=find( arrayfun(@(RIDX) strcmp(gt{1}{RIDX},inputinf{i}), 1:size(gt{1},1)) );
                valueinf= zeros(1,size(rows,2));
                for j=1:size(rows,2)
                    valueinf(j)=str2double(gt{3}{rows(j)});  
                end
                lower(i)=max(valueinf);
                % find the index of the constrained input in input_names
                % use the index to change the ranges in candidate lower bound
                input_name_index=find( arrayfun(@(RIDX) strcmp(input_names{1,RIDX},inputinf{i}), 1:size(input_names,2)) );
%                 if (lower(i)-lower(i)/perc)>constrRange(input_name_index,1)
%                     
%                     lower(i)= lower(i)-lower(i)/perc;
%                     constrRange(input_name_index,1)=round(lower(i), 3, 'significant');
% 
%                 end
                if lower(i)>constrRange(input_name_index,1)
                    constrRange(input_name_index,1)=lower(i);
                end
            end
        end
        if ~isempty(find(contains(PieceConstr,'<')))
            lt{:,1}=extractBetween(PieceConstr(find(contains(PieceConstr,'<'))),"(","<")';
            lt{:,2}=repmat('<',size(find(contains(PieceConstr,"<")),2),1);
            lt{:,3}=extractBetween(PieceConstr(find(contains(PieceConstr,'<'))),"<",")")';

            % inputsup:(2*1 string array) list of constrained inputs with an upper range 
            % upper: (2×1 string array) the upper range for each input in inputsup 2×1 string array
            [inputsup,~,idxsup] = unique((lt{:,1}),'rows');
            upper=zeros(1,size(inputsup,1));
            for i = 1 : size(inputsup,1)
                rows=find( arrayfun(@(RIDX) strcmp(lt{1}{RIDX},inputsup{i}), 1:size(lt{1},1) ));
                valuesup= zeros(1,size(rows,2));
                for j=1:size(rows,2)
                    valuesup(j)=str2double(lt{3}{rows(j)});  
                end
                upper(i)=min(valuesup);
                % find the index of the constrained input in input_names
                % use the index to change the ranges in candidate upper bound
                input_name_index=find( arrayfun(@(RIDX) strcmp(input_names{1,RIDX},inputsup{i}), 1:size(input_names,2)) );
%                 if upper(i)+upper(i)/perc<=constrRange(input_name_index,2)
%                     upper(i)= upper(i)+upper(i)/perc;
%                     constrRange(input_name_index,2)=round(upper(i), 3, 'significant');
% 
%                 end
                if upper(i)<=constrRange(input_name_index,2)
                    constrRange(input_name_index,2)=upper(i);
                end
            end

        end
end
