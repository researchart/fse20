function disp(obj)
% display - displays a EgoVehicle object
%
% Syntax:
%   display(obj)
%
% Inputs:
%   obj - EgoVehicle object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      20-January-2017
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

disp('-----------------------------------');

% display parent object
if(~isempty(obj))
    disp('parent object:');
    disp@world.Vehicle(obj);
    
    % display type and properties
    disp('type: EgoVehicle');
    
    for i = 1:numel(obj.goalRegion)
        obj.goalRegion(i).disp();
    end
end

disp('-----------------------------------');

end

%------------- END CODE --------------
