function disp(obj)
% display - displays a Vehicle object
%
% Syntax:
%   display(obj)
%
% Inputs:
%   obj - Vehicle object
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
disp@world.DynamicObstacle(obj);

% display type and properties
disp('type: Vehicle');
disp(['velocity: ',num2str(obj.velocity)]);
disp(['v_s: ',num2str(obj.v_s)]);
disp(['v_max: ',num2str(obj.v_max)]);
disp(['a_max: ',num2str(obj.a_max)]);
disp(['power_max: ',num2str(obj.power_max)]);

disp('-----------------------------------');

end

%------------- END CODE --------------
