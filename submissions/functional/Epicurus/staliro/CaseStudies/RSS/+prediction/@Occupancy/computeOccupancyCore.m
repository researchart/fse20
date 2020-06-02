function [obj] = computeOccupancyCore(obj, obstacle, map, timeInterval)
% computeOccupancyCore - predicts the occupancy of the obstacle on the
% given map for the given time interval
%
% Syntax:
%   [occ] = computeOccupancyCore(obj, obstacle, map, timeInterval)
%
% Inputs:
%   obj - Occupancy object (property of obstacle)
%   obstacle - Obstacle object
%   map - Map object holding all lanes
%   timeInterval - Timeinterval object specifying the prediction horizon
%
% Outputs:
%   obj - Occupancy object: predicted over-approximated occupancy of the
%           obstacle for the time interval represented by the vertices of a
%           polygon for all possible lanes
%
% Other m-files required: polybool (Mapping Toolbox), findLane, getLaneNetwork
% Subfunctions: M1_accelerationBasedOccupancy, M2_laneFollowingOccupancy
% MAT-files required: none
%
% See also: Althoff and Magdici, 2016, Set-Based Prediction of Traffic
% Participants on Arbitrary Road Networks, IV. Occupancy Prediction

% Author:       Markus Koschi
% Written:      06-September-2016
% Last update:  18-May-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

% check if mapping toolbox is available, which is required for polybool
if ~license('test','Map_Toolbox')
    error(['No license found for the Mapping Toolbox. Error in '...
        'prediction.Occupancy/computeOccupancy'])
end

% constraint management
obj.manageConstraints(obstacle);

% get the time interval properties
if isa(timeInterval, 'globalPck.TimeInterval')
    [ts, dt, tf] = timeInterval.getTimeInterval();
    numTimeIntervals = length(ts:dt:(tf-dt));
else
    error(['Fourth input argument is not an instance of the class '...
        'TimeInterval. Error in prediction.Occupancy/computeOccupancyCore']);
end

% M_1: compute the acceleration-based occupancy for each time interval
% (maximum possible occupancy with maximum longitudinally and laterally
% acceleration, i.e. "occupancy towards the road boundaries")
if obj.COMPUTE_OCC_M1
    verticesM1 = obj.M1_accelerationBasedOccupancy(obstacle, ts, dt, tf);
else
    % initialise empty cell
    verticesM1 = cell(1,length(ts:dt:(tf-dt)));
end

if isa(obstacle, 'world.StaticObstacle')
    % occM1 represents the steady occupancy of the static obstacle including its dimensions
    obj.forLane = obstacle.inLane;
    obj.timeInterval = timeInterval;
    obj.vertices = verticesM1;
elseif isa(obstacle, 'world.Vehicle')
    % check if map is provided
    if isa(map, 'world.Map')
        
        % find all Lane objects of the map which can be reached by the
        % obstacle according to the adjacency graph and contraint5
        % (only if ~constraint 5, the occupancy will be computed for all lanes)
        if ~isempty(obstacle.inLane)
            reachableLanes = prediction.Occupancy.findAllReachableLanes(map.lanes, obstacle.constraint5, obstacle.inLane);
            %reachableLanes = map.lanes;
        else
            % obstacle is not in a lane. thus, we can only consider occM1
            for k = 1:numTimeIntervals
                obj(1,k).timeInterval = globalPck.TimeInterval(ts + dt*(k-1), dt, ts + dt*k);
                obj(1,k).vertices = [verticesM1{1,k}(1,:); verticesM1{1,k}(2,:)];
            end
            return
        end
        
        % initialise the new occupancy matrix
        occupancy(numel(reachableLanes),numTimeIntervals) = prediction.Occupancy();
        
        % compute occupancy for all reachable lanes
        for i = 1:numel(reachableLanes) %parfor
            
            reachableLanes_i = reachableLanes(i);
            
            % flip the current lane if driving direction is opposite
            % (compare vehicle oriantation to lane orientation):
            % calculate horizontal angle of the closest center vertices
            laneOrientation = geometry.calcAngleOfVerticesAtPosition(...
                obstacle.position, reachableLanes_i.center.vertices);
            
            % flip lane if difference of orientation is larger than pi/2
            if abs(angdiff(laneOrientation,obstacle.orientation)) > pi/2
                warning(['Lane %i has been flipped for obstacle' ...
                    ' %i.'], reachableLanes_i.id, obstacle.id);
                reachableLanes_i = world.Lane.flipLane(reachableLanes_i);
            end
            
            % M_2: compute the lane-following occupancy in the current lane
            % for each time interval (already cut with lane borders)
            % (maximum possible occupancy with maximum longitudinally
            % acceleration and deceleration along the shortest path through
            % the lane)
            if obj.COMPUTE_OCC_M2
                verticesM2 = obj.M2_laneFollowingOccupancy(obstacle, reachableLanes_i, ts, dt, tf);
            else
                % initialise empty cell
                verticesM2 = cell(1,length(ts:dt:(tf-dt)));
            end
            
            % intersect the occupancy M1 and M2 for each time interval
            % using the function polybool of the MATLAB mapping toolbox
            % [x,y] = polybool(flag,x1,y1,x2,y2) %flag: 'intersection' 'union' 'subtraction' 'exclusiveor'
            % (Numerical problems can occur when the polygons have a large offset
            % from the origin.)
            for k = 1:numTimeIntervals
                if obj.COMPUTE_OCC_M1 && obj.COMPUTE_OCC_M2 && ...
                        ~isempty(verticesM1{1,k}) && ~isempty(verticesM2{1,k})
                    % intersect the occupancy M_1 and M_2
                    [verticesOcc_x, verticesOcc_y] = polybool('intersection', verticesM1{1,k}(1,:), verticesM1{1,k}(2,:), verticesM2{1,k}(1,:), verticesM2{1,k}(2,:));
                elseif obj.COMPUTE_OCC_M1 && ~isempty(verticesM1{1,k})
                    % intersect the occupancy M_1 with the lane border
                    border = [reachableLanes(i).leftBorder.vertices, fliplr(reachableLanes(i).rightBorder.vertices)];
                    [verticesOcc_x, verticesOcc_y] = polybool('intersection', verticesM1{1,k}(1,:), verticesM1{1,k}(2,:), border(1,:), border(2,:));
                    if isempty(verticesM2{1,k})
                        warning(['For obstacle %i, occupancy M2 is empty' ...
                            ' at time step %i.'], obstacle.id, k);
                    end
                elseif obj.COMPUTE_OCC_M2 && ~isempty(verticesM2{1,k})
                    % occupancy M_2 is the complete occupancy
                    verticesOcc_x = verticesM2{1,k}(1,:);
                    verticesOcc_y = verticesM2{1,k}(2,:);
                else
                    % the occupancy is empty
                    verticesOcc_x = [];
                    verticesOcc_y = [];
                end
                
                % DEBUG: plot
                %patch(verticesM1{1,k}(1,:), verticesM1{1,k}(2,:), 1, 'FaceColor', 'g', 'FaceAlpha', 0.1)
                %patch(verticesM2{1,k}(1,:), verticesM2{1,k}(2,:), 1, 'FaceColor', 'b', 'FaceAlpha', 0.1)
                %patch(verticesOcc_x, verticesOcc_y, 1, 'FaceColor', 'b', 'FaceAlpha', 0.5)
                
                % set the occupancy object properties
                occupancy(i,k).forLane = reachableLanes(i);
                occupancy(i,k).timeInterval = globalPck.TimeInterval(ts + dt*(k-1), dt, ts + dt*k);
                occupancy(i,k).vertices = [verticesOcc_x; verticesOcc_y];
            end % for k numTimeIntervals
            
            % DEBUG: plot
            %hold on
            %fill(verticesM2{1,2}(1,:), verticesM2{1,2}(2,:), 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'b');
            %plot(verticesM2{1,2}(1,:), verticesM2{1,2}(2,:), 'b');
            
        end % for i reachableLanes
        %fill(verticesM1{1,2}(1,:), verticesM1{1,2}(2,:), 'g', 'FaceAlpha', 0.2, 'EdgeColor', 'g');
        %plot(verticesM1{1,2}(1,:), verticesM1{1,2}(2,:), 'g');
        
        % the computed occupancy is the new occupancy of the obstacle
        obj = occupancy;
    else
        error(['Third input argument is not an instance of the class '...
            'Map. Error in prediction.Occupancy/computeOccupancyCore']);
    end % if map
else
    warning(['Obstacle %i is not static nor of type vehicle. Occupancy ' ...
        'cannot be predicted.'], obstacle.id);
end % if obstacle

end

%------------- END CODE --------------