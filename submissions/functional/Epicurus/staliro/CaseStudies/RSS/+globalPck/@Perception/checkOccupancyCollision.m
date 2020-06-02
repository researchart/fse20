function [collision_flag, collision_time, collision_obstacle] = checkOccupancyCollision(obj)
% checkOccupancyCollision -
%
% Syntax:
%
%
% Inputs:
%
%
% Outputs:
%
%
% Other m-files required:
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      23-February-2017
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

% Warning: brute force collision check

% (we assume the time step size of the occupancies are the same of all obstacles)
collision_flag = false;
collision_time = 0;
collision_obstacle = world.Obstacle.empty();

% check if the occupancy of the ego vehicle intersects with any obstacle's
% occupancy during the same time interval:

% for all numTimeIntervals (of ego vehicle occupancy)
for k = 1:size(obj.map.egoVehicle.occupancy_trajectory,2)
    
    % for all lanes with occupancy of ego vehicle
    for l_ego = 1:size(obj.map.egoVehicle.occupancy_trajectory,1)
        if ~isempty(obj.map.egoVehicle.occupancy_trajectory(l_ego,k).vertices)
            
            % for all obstacle
            for i = 1:numel(obj.map.obstacles)
                
                % for all lanes with occupancy of obstacle (l_obstacle) equal to l_ego
                for l_obstacle = 1:size(obj.map.obstacles(i).occupancy,1)
                    if isequal(obj.map.obstacles(i).occupancy(l_obstacle,k).forLane, ...
                            obj.map.egoVehicle.occupancy_trajectory(l_ego,k).forLane)
                        if ~isempty(obj.map.egoVehicle.occupancy_trajectory(l_ego,k).vertices) && ...
                                ~isempty(obj.map.obstacles(i).occupancy(l_obstacle,k).vertices)
                            
                            % check if intersection is empty
                            [x, y] = polybool('intersection', obj.map.egoVehicle.occupancy_trajectory(l_ego,k).vertices(1,:), obj.map.egoVehicle.occupancy_trajectory(l_ego,k).vertices(2,:), ...
                                obj.map.obstacles(i).occupancy(l_obstacle,k).vertices(1,:), obj.map.obstacles(i).occupancy(l_obstacle,k).vertices(2,:));
                            if ~isempty(x) && ~isempty(y)
                                % collision of occupancies
                                collision_flag = true;
                                collision_time = obj.map.egoVehicle.occupancy_trajectory(l_ego,k).timeInterval.ts + obj.map.egoVehicle.time;
                                collision_obstacle = obj.map.obstacles(i);
                                return;
                            end
                        end
                    end
                end
                
            end
            
        end
    end
    
end

end

%------------- END CODE --------------