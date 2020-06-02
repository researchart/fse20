
% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

% ISACCURATE translates the assumption learned into qct language. If the QVtrace check is enabled, it checks on QVtrace if the qct formula is valid.
% 
% INPUT
%   - Assumptions: a cell array of assumptions. the assumption contains the set of constraints {C1,C2,...Cn} associated with the different leaves
%   - qctfilename: the file name of the qct file
%   - input_names: the input names. 
%   - opt : epicurus_options . epicurus should be of type "epicurus_options". 
%       If the default options are going to be used, then this input may be
%       omitted. For instructions on how to change epicurus options, 
%       see the epicurus_options help file for each desired property.
%   - simTime: the simulation time
%   - kmax: the simulation time translated into QVtrace time.
% OUTPUT
%   valid: if the QVtrace check returns Valid as result, valid=true else valid=false
%   assumption: the qct assumption

function [valid, assumption]=modelCheck(Assumptions,qctfilename,input_names,opt,simTime,kmax)    
    valid=0;
    assumToCheck=Assumptions(:,1);
    refined={};
    count=0;
    for as = 1:size(assumToCheck,1)
        x=refineConstr(assumToCheck{as},opt.nbrControlPoints);
        if ~isempty(x)
            count=count+1;
            if contains(x,'and')
                refined{count}=strcat('(',x,')');
            else
                refined{count}=x;
            end
            if (opt.nbrControlPoints>1)
                mult_control_point_clause=Constr2QCT(refined(count),input_names,kmax,opt);
                refined{count}=strcat('(',mult_control_point_clause,')');
            end
        end
    end
        
    if ~isempty(refined) 
        if size(refined,2)>1
            assumption=strcat('assume (',strjoin(refined(~cellfun('isempty',refined)),{' or '}),');');
            if iscell(assumption)
                assumption=assumption{:};
            end
        else
            assumption=strcat('assume ',refined(~cellfun('isempty',refined)),';');
            if iscell(assumption)
                assumption=assumption{:};
            end
        end
        
        if opt.qvtraceenabled
            scriptPath=fullfile(fileparts(which('qvtrace.py')),'qvtrace.py');
            originalqctPath=fullfile(fileparts(which([qctfilename,'original.qct'])),[qctfilename,'original.qct']);
            kmax=(simTime/opt.SampTime);
            qctPath=fullfile(fileparts(which([qctfilename,'.qct'])),[qctfilename,'.qct']);
            delete(qctPath);
            copyfile(originalqctPath,regexprep(originalqctPath,'original',''));
            qctPath=fullfile(fileparts(which([qctfilename,'.qct'])),[qctfilename,'.qct']);            
            writeQCT(assumption,qctPath,kmax);
            copyfile(qctPath,'./qct.qct');
            turn='QvCheck';
            turnfile=fopen('./turn.txt', 'w'); 
            fprintf(turnfile,'QvCheck'); 
            fclose(turnfile);
            timetic=tic;
            disp('Waiting that QVtrace finishes the analysis');
            while(~strcmp(turn,'Matlab'))
                pause(1)
                turnfile=fopen('turn.txt', 'r'); 
                turn=fgetl(turnfile); 
                fclose(turnfile);
            end
            qvtraceTime=toc(timetic);
            disp(['qvtrace time: ',num2str(qvtraceTime)]);
            disp('QVtrace ended');
            msgfid=fopen('message.txt', 'r'); 
            message = textscan(msgfid,'%s','delimiter','\n');
            fclose(msgfid);
            noV=strfind(message{1},': No violations are possible');
            v=strfind(message{1},': Violations are possible');
            if ~isempty(find(~cellfun(@isempty,noV)))
                valid=1;
            elseif  ~isempty(find(~cellfun(@isempty,v)))
                valid=0;
            else
                valid=2;
            end         
            delete message.txt;
        end
    else
        assumption='';
        valid=0;
    end
end