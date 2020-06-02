% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

% REFINECONSTR takes a constraint and the number of control points and
% returns the refined constraint
% Example: an input in where in1 and in2 are two control points of in.
% the contraint = 'in1<2 and in1<3 and in2>2' 
% the refined constraint = 'in1<3 and in2>2'

function refined_constr=refineConstr(constr,n_cp)

    refined_constr=[]; 
    lt={};
    gt={};
    xinf='';
    xsup='';
    constrSplitted=strsplit(constr);
    clause_array=constrSplitted(:,~strcmp(constrSplitted,'and'));
    ind=1;
    %% simplifying the < clauses
    for c= 1 : size(clause_array,2)
        if ~isempty(find(strfind(clause_array{c},'<')))
            lt{ind,1}=clause_array{c}(strfind(clause_array{c},'(')+1:strfind(clause_array{c},'<')-1);
            lt{ind,2}=repmat('<',size(find(strfind(clause_array{c},'<')),2),1);
            lt{ind,3}=clause_array{c}(strfind(clause_array{c},'<')+1:strfind(clause_array{c},')')-1);
            ind=ind+1;
        end
    end
    if ~isempty(lt)
        % inputsup:(2*1 string array) list of constrained inputs with an upper range 
        % upper: (2×1 string array) the upper range for each input in inputsup 2×1 string array
        [inputsup,~,~] = unique(lt(:,1),'rows');
        upper=zeros(1,size(inputsup,1));
        xsup={};
        for i = 1 : size(inputsup,1)
            rows=find( arrayfun(@(RIDX) strcmp(lt{RIDX,1}, inputsup(i)), 1:size(lt,1)));
            valuesup= zeros(1,size(rows,2));
            for j=1:size(rows,2)
                valuesup(j)=str2double(lt{rows(j),3});  
            end
            upper(i)=min(valuesup);
            % translate the number of control points 
            if (n_cp==1)
                inS=inputsup{i}(1:end-1);
            else
                inS=inputsup{i};
            end
            xsup{i}=strcat('(',inS,'<',num2str(upper(i)),')');
        end
    end
    
    ind=1;
    
    %% simplifying the >= clauses
    for c= 1 : size(clause_array,2)
        if ~isempty(find(strfind(clause_array{c},'>=')))
            gt{ind,1}=clause_array{c}(strfind(clause_array{c},'(')+1:strfind(clause_array{c},'>=')-1);
            gt{ind,2}=repmat('>=',size(find(strfind(clause_array{c},'>=')),2),1);
            gt{ind,3}=clause_array{c}(strfind(clause_array{c},'>=')+2:strfind(clause_array{c},')')-1);
            ind=ind+1;
        end
    end
    if ~isempty(gt)
        % inputsup:(2*1 string array) list of constrained inputs with an upper range 
        % upper: (2×1 string array) the upper range for each input in inputsup 2×1 string array
        [inputinf,~,idxsup] = unique(gt(:,1),'rows');
        lower=zeros(1,size(inputinf,1));
        xinf={};
        for i = 1 : size(inputinf,1)
            rows=find( arrayfun(@(RIDX) strcmp(gt{RIDX,1}, inputinf(i)), 1:size(gt,1)));
            valuesup= zeros(1,size(rows,2));
            for j=1:size(rows,2)
                valuesup(j)=str2double(gt{rows(j),3});  
            end
            lower(i)=max(valuesup);
            % translate the number of control points 
            if (n_cp==1)
                inS=inputinf{i}(1:end-1);
            else
                inS=inputinf{i};
            end
            xinf{i}=strcat('(',inS,'>=',num2str(lower(i)),')');
        end
    end
    
    %% Boolean inputs
     for c= 1 : size(clause_array,2)
       if ~isempty(find(strfind(clause_array{c},'='))) && (isempty(find(strfind(clause_array{c},'<'))) && isempty(find(strfind(clause_array{c},'>'))))
           refined_constr=constr;
       end
     end
    %% creating the final constraint
    if ~isempty(xinf) && ~isempty(xsup)
        refined_constr=strcat(' ', strjoin(xinf,' and '),' and ',strjoin(xsup,' and '));
    elseif  ~isempty(xinf)
        refined_constr=strjoin(xinf,' and ');
    elseif ~isempty(xsup)
        refined_constr=strjoin(xsup,' and ');
    end
        
end