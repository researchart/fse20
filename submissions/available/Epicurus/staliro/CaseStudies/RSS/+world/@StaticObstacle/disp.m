function disp(obj)
% display - displays a StaticObstacle object
%
% Syntax:
%   display(obj)
%
% Inputs:
%   obj - StaticObstacle object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      26-Oktober-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

disp('-----------------------------------');

% display parent object
disp('parent object:');
disp@world.Obstacle(obj);

% display type
disp('type: StaticObstacle');

disp('-----------------------------------');

end

%------------- END CODE --------------
