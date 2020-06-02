% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

% TRANSLATE1CONTROLPOINT translates one control points constraint into a readable statement by QVtrace 
% INPUTS
%   lowkinterval: the lower bound of the time interval
%   upkinterval: the upper bound of the time interval 
%   input: the constraint input
%   c: the control point constraint value
% OUTPUT
%   qctformula: a formula readable by QVtrace

function qctformula=tanslate1controlpoint(lowkinterval,upkinterval,input,c)
        % search for the operators 
         % note that the DT can only contain < or >=
        s=[contains(c,'<'),contains(c,'>='),contains(c,'=')&& ~contains(c,'>')];
        [~,col]=find(s>0); %1: < , 2: >= 
        switch col
            case 2
                v=extractBetween(c,">=",")");
                qctformula=strjoin(['all_k(k>=',num2str(lowkinterval),' and k<=',num2str(upkinterval),' impl (',strcat(input,'{k}'),'>=',v,'))']);
            case 1
                v=extractBetween(c,"<",")");
                qctformula=strjoin(['all_k(k>=',num2str(lowkinterval),' and k<=',num2str(upkinterval),' impl (',strcat(input,'{k}'),'<',v,'))']);
            case 3
                v=extractBetween(c,"=",")");
                if strcmp(v,'0')
                    op='not';
                else
                    op='';
                end
                qctformula=strjoin(['all_k(k>=',num2str(lowkinterval),' and k<=',num2str(upkinterval),' impl (',op,strcat(input,'{k}'),'))']);

        end
end
