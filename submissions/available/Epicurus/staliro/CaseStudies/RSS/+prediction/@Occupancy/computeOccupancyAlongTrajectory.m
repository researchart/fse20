function [obj] = computeOccupancyAlongTrajectory(obj, obstacle, map, timeInterval)
% computeOccupancyAlongTrajectory -
%
% Syntax:
%   [occ] = computeOccupancyAlongTrajectory(obj, obstacle, map, timeInterval)
%
% Inputs:
%   obj - Occupancy object (property of obstacle)
%   obstacle - Obstacle object
%   map - Map object holding all lanes
%   timeInterval - Timeinterval object specifying the prediction horizon
%
% Outputs:
%   obj - Occupancy object:
%
% Other m-files required:
% Subfunctions:
% MAT-files required: none

% Author:       Markus Koschi
% Written:      23-February-2017
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

% get the time interval properties
if isa(timeInterval, 'globalPck.TimeInterval')
    [ts, dt, tf] = timeInterval.getTimeInterval();
    numTimeIntervals = length(ts:dt:(tf-dt));
else
    error(['Fourth input argument is not an instance of the class '...
        'TimeInterval. Error in prediction.Occupancy/computeOccupancyCore']);
end

l = 1;
%for t = ts:dt:(tf-dt)
for k = 1:numTimeIntervals
    % get the positions of the trajectory in the time interval from
    % current time onwards
    if ~isempty(obstacle.trajectory)
        [idx_start, idx_end] = obstacle.trajectory.timeInterval.getIndex(ts + dt*(k-1) + obstacle.time, ts + dt*k + obstacle.time);
        if idx_end > size(obstacle.trajectory.position,2)
            positions = obstacle.trajectory.position(:,idx_start:end);
        else
            positions = obstacle.trajectory.position(:,idx_start:idx_end);
        end
        
        if ~isempty(positions)
            % compute the occupancy due to the vehicle's dimension and orientation
            dimensions = geometry.addObjectDimensions([0;0], obstacle.shape.length, obstacle.shape.width);
            occupancyPoints = zeros(2,4*size(positions,2));
            for i = 1:size(positions,2)
                occupancyPoints(:,i*4-3:i*4) = geometry.rotateAndTranslateVertices(dimensions, positions(:,i), obstacle.trajectory.orientation(idx_start));
            end
            % compute convex hull
            occupancyHull = occupancyPoints(:,convhull(occupancyPoints'));
            
            % arrange the points of the hull in clockwise ordering
            [px, py] = poly2cw(occupancyHull(1,:), occupancyHull(2,:));
            occupancyVertices = [px; py];
            
            %plot(occupancyPoints(1,:), occupancyPoints(2,:), 'b');
            %plot(occupancyHull(1,:), occupancyHull(2,:), 'g');
            %plot(occupancyVertices(1,:), occupancyVertices(2,:), 'r');
            
            % check forLane row
            forLane = map.lanes.findLaneByPosition(positions);
            if k > 1 && ~isequal(forLane, obj(l,k-1).forLane)
                %l = forLane == obj(:,1).forLane;
                l = l + 1;
            end
            
            % set the occupancy object properties
            obj(l,k).forLane = forLane;
            obj(l,k).timeInterval = globalPck.TimeInterval(ts + dt*(k-1), dt, ts + dt*k);
            obj(l,k).vertices = occupancyVertices;
            
        else
            % set empty occupancy object
            %obj(l,k) = prediction.Occupancy.emtpy();
        end
        
    end
end

end

%------------- END CODE --------------
