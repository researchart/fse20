function update(varargin)
% update - updates all dynamic properties of a Map object
%
% Syntax:
%   update(obj, t)
%
% Inputs:
%   obj - Map object
%   t - current time of the object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      27-January-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

if nargin == 2
    obj = varargin{1};
    t = varargin{2};
    
    % update all dynamic obstacles
    for i = 1:numel(obj.obstacles)
        if isa(obj.obstacles(i), 'world.DynamicObstacle')
            obj.obstacles(i).update(t, obj);
        end
    end
    
    % update ego vehicle
    for i = 1:numel(obj.egoVehicle)
        obj.egoVehicle(i).update(t, obj);
    end
    
    % update map time
    obj.time = t;
end
end

%------------- END CODE --------------