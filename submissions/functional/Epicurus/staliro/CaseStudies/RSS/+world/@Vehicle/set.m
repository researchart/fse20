function set(obj, propertyName, propertyValue)
% set - sets a property of a Vehicle object
%
% Syntax:
%   set(obj, propertyName, propertyValue)
%
% Inputs:
%   obj - Vehicle object
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
% Written:      16-Nomvember-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

switch propertyName
    case 'v_s'
        if isa(propertyValue, 'numeric')
            obj.v_s = propertyValue;
        else
            error(['No numeric input argument provided for property %s '...
                '\n\nError in world.Vehicle/set'], propertyName);
        end
    case 'power_max_max'
        if isa(propertyValue, 'numeric')
            obj.power_max = propertyValue;
        else
            error(['No numeric input argument provided for property %s '...
                '\n\nError in world.Vehicle/set'], propertyName);
        end
    otherwise
        % call set method of superclass DynamicObstacle
        set@world.DynamicObstacle(obj, propertyName, propertyValue)
end

%------------- END CODE --------------