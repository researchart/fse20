% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

% TRANSLATE2CONTROLPOINTS translates two consecutive control points constraints into a readable statment by QVtrace 
% INPUTS
%   lowkinterval: the lower bound of the time interval
%   upkinterval: the upper bound of the time interval 
%   midkeinterval: the time value that cuts the time interval in two parts 
%   input: the constraint input
%   c1: first control point constraint value
%   c2: second control point constraint value 
% OUTPUT
%   qctformula: a formula readable by QVtrace

function qctformula=tanslate2controlpoints(lowkinterval,upkinterval,midkeinterval,input,c1,c2)
    
    if contains(c1,'=')&& ~contains(c1,'>')&& contains(c2,'=')&& ~contains(c2,'>')
        v1=extractBetween(c1,"=",")");
        v2=extractBetween(c2,"=",")");
        if strcmp(v1,'0')
            op1='not';
        else
            op1='';
        end
        if strcmp(v2,'0')
            op2='not';
        else
            op2='';
        end
        qctformula=strjoin(['(all_k(k>=',num2str(lowkinterval),' and k<=',num2str(midkeinterval),' impl (',op1,strcat(input,'{k}'),'))) and all_k(k>=',num2str(midkeinterval),' and k<=',num2str(upkinterval),' impl (',op2,strcat(input,'{k}'),')))']);
    else    
        % search for the operators
        % note that the DT can only contain < or >=
        s=[contains(c1,'<'),contains(c1,'>=');contains(c2,'<'),contains(c2,'>=')];
        
        intervalsize=upkinterval-lowkinterval;
        switch mat2str(s)
             % >= >=
             case '[false true;false true]'
                v1=str2double(extractBetween(c1,">=",")"));
                v2=str2double(extractBetween(c2,">=",")"));
                m=(v2-v1)/intervalsize; 
                y=[num2str(m),'*','(k-',num2str(lowkinterval),') +',num2str(v1)];
                qctformula=strjoin(['all_k(k>=',num2str(lowkinterval),' and k<=',num2str(upkinterval),' impl (',strcat(input,'{k}'),'>=',y,'))']);
            % < < 
            case '[true false;true false]'
                v1=str2double(extractBetween(c1,"<",")"));
                v2=str2double(extractBetween(c2,"<",")"));
                m=(v2-v1)/intervalsize; 
                y=[num2str(m),'*','(k-',num2str(lowkinterval),') +',num2str(v1)];
                qctformula=strjoin(['all_k(k>=',num2str(lowkinterval),' and k<=',num2str(upkinterval),' impl (',strcat(input,'{k}'),'<',y,'))']);
            % >= <
            case '[false true;true false]'
                    v1=str2double(extractBetween(c1,">=",")"));
                    v2=str2double(extractBetween(c2,"<",")"));
                    m=(v2-v1)/intervalsize; 
                    if m>0
                        disp('here')
                    end
                    y=[num2str(m),'*','(k-',num2str(lowkinterval),') +',num2str(v1)];
                    qctformula=strjoin(['(all_k(k>=',num2str(lowkinterval),' and k<=',num2str(midkeinterval),' impl (',strcat(input,'{k}'),'>=',y,'-0.001))) and (all_k(k>=',num2str(midkeinterval),' and k<=',num2str(upkinterval),' impl (',strcat(input,'{k}'),'<',y,'+0.001)))']);
            % < >=
            case '[true false;false true]'
                v1=str2double(extractBetween(c1,"<",")"));
                v2=str2double(extractBetween(c2,">=",")"));
                m=(v2-v1)/intervalsize; 
                y=[num2str(m),'*','(k-',num2str(lowkinterval),') +',num2str(v1)];
                qctformula=strjoin(['(all_k(k>=',num2str(lowkinterval),' and k<=',num2str(midkeinterval),' impl (',strcat(input,'{k}'),'<',y,'+0.001))) and (all_k(k>=',num2str(midkeinterval),' and k<=',num2str(upkinterval),' impl (',strcat(input,'{k}'),'>=',y,'-0.001)))']);
        end
    end
end
