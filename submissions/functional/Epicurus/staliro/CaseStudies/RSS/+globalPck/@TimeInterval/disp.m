function disp(obj)
% display - displays a TimeInterval object
%
% Syntax:
%   display(obj)
%
% Inputs:
%   obj - TimeInterval object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      27-Oktober-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

disp('-----------------------------------');

% display type and properties
disp('type: TimeInterval');
disp(['ts: ',num2str(obj.ts)]);
disp(['dt: ',num2str(obj.dt)]);
disp(['tf: ',num2str(obj.tf)]);

disp('-----------------------------------');

end

%------------- END CODE --------------