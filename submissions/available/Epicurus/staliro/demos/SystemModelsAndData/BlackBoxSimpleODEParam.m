% Demonstration of using the S-Taliro BlackBox option to search over 
% parameter ranges

% (C) G. Fainekos
% Created: 2013.09.19
% Last major update: 2013.09.19

% Note the BlackBox interface must not be changed
function [T, XT, YT, LT, CLG, Guards] = BlackBoxSimpleODEParam(X0,simT,~,~)

LT = [];
CLG = [];
Guards = [];

model = 'SimpleODE';

load_system(model);

% Change the parameter values in the model
set_param([model,'/Constant'],'Value',num2str(X0(1)));
set_param([model,'/Gain'],'Gain',num2str(X0(2)));

% Run the model
[T, XT, YT] = sim(model,[0 simT]);

close_system(model,0);

end
