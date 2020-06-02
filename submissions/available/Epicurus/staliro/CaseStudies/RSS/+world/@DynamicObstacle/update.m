function update(varargin)
% update - updates the properties of a DynamicObstacle object by the values
% of the trajectory at the specified time
%
% Syntax:
%   update(obj, t, map)
%
% Inputs:
%   obj - DynamicObstacle object
%   t - current time of the object
%   map - Map object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Stefanie Manzinger, Markus Koschi
% Written:      29-Nomvember-2016
% Last update:  23-May-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

if nargin == 3
    obj = varargin{1};
    t = varargin{2};
    map = varargin{3};
end

% check if t is in the time interval of the object
if ~isempty(obj.trajectory)
    if obj.trajectory.timeInterval.getIndex(t) > 0 && ...
            obj.trajectory.timeInterval.getIndex(t) <= size(obj.trajectory.position,2)
        % store values from previous time step
        position_previous = obj.position;
        inLane_previous = obj.inLane;
        
        % update all properties
        obj.position = obj.trajectory.getPosition(t);
        obj.orientation = obj.trajectory.getOrientation(t);
        obj.velocity = obj.trajectory.getVelocity(t);
        obj.acceleration = obj.trajectory.getAcceleration(t);
        obj.time = t;
        obj.inLane = obj.updateInLane(map.lanes);
        
        % manage constraint 5 (lane crossing)
        if ~isempty(inLane_previous) && ~isempty(obj.inLane) && ...
                ~isempty(position_previous)
            laneOrientation_previous = geometry.calcAngleOfVerticesAtPosition(...
                position_previous, inLane_previous(1).center.vertices);
            laneOrientation_new = geometry.calcAngleOfVerticesAtPosition(...
                obj.position, obj.inLane(1).center.vertices);
            
            if abs(angdiff(laneOrientation_previous,laneOrientation_new)) > pi/2
                warning(['Obstacle %d has moved from lane %i to lane %i, ' ...
                    'which has an opposite driving direction. Constraint 5 '...
                    'is set to false.'], obj.id, inLane_previous(1).id, ...
                    obj.inLane(1).id);
                obj.set('constraint5', false);
            end
        end
    else
        % erase all properties
        obj.position = [];
        obj.orientation = [];
        obj.velocity = [];
        obj.acceleration = [];
        obj.time = [];
        obj.inLane = world.Lane.empty();
    end
elseif ~isempty(obj.position)
    % update objects which have no trajectory (e.g. ego vehicle)
    obj.time = t;
    obj.inLane = obj.updateInLane(map.lanes);
end
end

%------------- END CODE --------------