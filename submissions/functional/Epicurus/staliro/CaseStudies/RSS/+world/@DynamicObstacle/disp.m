function disp(obj)
% display - displays a DynamicObstacle object
%
% Syntax:
%   display(obj)
%
% Inputs:
%   obj - DynamicObstacle object
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

% display parent object
disp('parent object:');
disp@world.Obstacle(obj);

% display type and properties
disp('type: DynamicObstacle');
disp(['time: ',num2str(obj.time)]);

disp('-----------------------------------');

end

%------------- END CODE --------------
