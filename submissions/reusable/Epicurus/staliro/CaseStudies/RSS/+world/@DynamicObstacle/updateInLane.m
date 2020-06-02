function inLane = updateInLane(obj, lanes)
% updateInLane - finds all lanes in which the obstacle is positioned in and
% whose orientation is similar to the obstacle (to prevent returning lanes
% which are crossed, e.g. at an intersection)
%
% Syntax:
%   inLane = updateInLane(obj, lanes)
%
% Inputs:
%   obj - DynamicObstacle object
%   lanes - Lane objects of the map
%
% Outputs:
%   inLane - lane(s) in which the obstacle is driving in
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      23-May-2017
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

inLane = world.Lane.empty();

lanesAtObjPosition = lanes.findLaneByPosition(obj.position);
for i = 1:numel(lanesAtObjPosition)
    laneOrientation = geometry.calcAngleOfVerticesAtPosition(...
        obj.position, lanesAtObjPosition(i).center.vertices);
    
    % assume that a traffic participant is only in a lane, if its
    % orientation differs less than +- pi/5 from the lane orientation
    if abs(angdiff(laneOrientation,obj.orientation)) < pi/5 || ...
            abs(angdiff(laneOrientation,obj.orientation)) > 4*pi/5
        inLane(end+1) = lanesAtObjPosition(i);
    end
end

end

%------------- END CODE --------------