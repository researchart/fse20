% Demonstration of using the S-Taliro BlackBox option to search over 
% parameter ranges

% (C) G. Fainekos
% Created: 2013.09.19
% Last major update: 2013.09.19

% Note the BlackBox interface must not be changed
function [T, XT, YT, LT,  clg, grd] = BlackBoxHeat1(X0,simT,TU,U)


LT = [];

get=[16;17;17;16;15;16;17;16;16;17];
rows=eye(10);
neg_rows=-eye(10);

clg=cell(1,10);
grd=cell(1,10);

for i=1:10
    clg{i} = {2;1};
% c(i).adj{1}=[2];
% c(i).adj{2}=[1];
% 2 -> 1 : x_i>get_i
    guards = [];
    guards(2,1).A=neg_rows(i,:);
    guards(2,1).b=[-1*get(i)];
% 1 -> 2 : x_i<=get_i
    guards(1,2).A=rows(i,:);
    guards(1,2).b=[get(i)];
    grd{i} = guards;

end



model = 'BBox_Heat_01';

% Change the parameter values in the model
% set_param([model,'/Constant'],'Value',num2str(X0(1)));
% set_param([model,'/Gain'],'Gain',num2str(X0(2)));
simopt = simget('BBox_Heat_01');
simopt = simset(simopt,'SaveFormat','Array'); % Replace input outputs with structures
% Run the model 
 [T, XT, YT] = sim(model,[0 simT],simopt,[TU U]);
 
   LT = YT(:,[11:20]);%  YT(:,[11 13 15]) = [];
%  disp(LT);
  YT(:,[11:20]) = [];%  LT = YT(:,[11]); %  disp(LT);
%  disp(YT);


 

end
