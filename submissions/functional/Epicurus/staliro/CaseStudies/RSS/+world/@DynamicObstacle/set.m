function set(obj, propertyName, propertyValue)
% set - sets a property of a DynamicObstacle object
%
% Syntax:
%   set(obj, propertyName, propertyValue)
%
% Inputs:
%   obj - DynamicObstacle object
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
    %added by Mohammad Hekmatnejad
    case 'position'
        if isa(propertyValue, 'numeric')
            obj.position = propertyValue;
        else
            error(['No numeric input argument provided for property %s '...
                '\n\nError in world.DynamicObstacle/set'], propertyName);
        end    
    %added by Mohammad Hekmatnejad
    case 'orientation'
        if isa(propertyValue, 'numeric')
            obj.orientation = propertyValue;
        else
            error(['No numeric input argument provided for property %s '...
                '\n\nError in world.DynamicObstacle/set'], propertyName);
        end    
    %added by Mohammad Hekmatnejad
    case 'time'
        if isa(propertyValue, 'numeric')
            obj.time = propertyValue;
        else
            error(['No numeric input argument provided for property %s '...
                '\n\nError in world.DynamicObstacle/set'], propertyName);
        end    
    case 'v_max'
        if isa(propertyValue, 'numeric')
            obj.v_max = propertyValue;
        else
            error(['No numeric input argument provided for property %s '...
                '\n\nError in world.DynamicObstacle/set'], propertyName);
        end
    case 'a_max'
        if isa(propertyValue, 'numeric')
            obj.a_max = propertyValue;
        else
            error(['No numeric input argument provided for property %s '...
                '\n\nError in world.DynamicObstacle/set'], propertyName);
        end
    case 'speedingFactor'
        if isa(propertyValue, 'numeric')
            obj.speedingFactor = propertyValue;
        else
            error(['No numeric input argument provided for property %s '...
                '\n\nError in world.DynamicObstacle/set'], propertyName);
        end
    case 'constraint3'
        if isa(propertyValue, 'logical') || propertyValue == 0 || propertyValue == 1
            obj.constraint3 = propertyValue;
        else
            error(['No logical input argument provided for property %s '...
                '\n\nError in world.DynamicObstacle/set'], propertyName);
        end
    case 'constraint5'
        if isa(propertyValue, 'logical') || propertyValue == 0 || propertyValue == 1
            obj.constraint5 = propertyValue;
        else
            error(['No logical input argument provided for property %s '...
                '\n\nError in world.DynamicObstacle/set'], propertyName);
        end
    otherwise
        error(['Input argument %s is not a property of the class  '...
            'DynamicObstacle. Error in world.DynamicObstacle/set'], propertyName);
end

%------------- END CODE --------------