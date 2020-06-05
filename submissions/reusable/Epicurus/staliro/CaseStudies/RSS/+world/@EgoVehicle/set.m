function set(obj, propertyName, propertyValue)
% set - sets a property of a EgoVehicle object
%
% Syntax:
%   set(obj, propertyName, propertyValue)
%
% Inputs:
%   obj - EgoVehicle object
%   propertyName - name of property to be set
%   propertyValue - value of property to be set
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      06-April-2017
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

switch propertyName
    case 'goalRegion'
        if isa(propertyValue,'globalPck.GoalRegion')
            obj.goalRegion = propertyValue;
        else
            error(['No input argument of class GoalRegion provided for '...
                'property %s \n\nError in world.EgoVehicle/set'], propertyName);
        end
    otherwise
        % call set method of superclass Vehicle
        set@world.Vehicle(obj, propertyName, propertyValue)
end

%------------- END CODE --------------