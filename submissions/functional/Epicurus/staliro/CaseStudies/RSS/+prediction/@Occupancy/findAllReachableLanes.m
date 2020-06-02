function [reachableLanes] = findAllReachableLanes(lanes, constraint5, obstacleInLane)
% findAllReachableLanes - find all Lane objects of the map which can be
% reached by the obstacle according to the adjacency graph and contraint5
%
% Syntax:
%   [reachableLanes] = findAllReachableLanes(lanes, constraint5, obstacleInLane)
%
% Inputs:
%   lanes - all Lane Objects of the map
%   constraint5 - boolean of the obstacle
%   obstacleInLane - Lane object(s) in which the obstacle is located in
%
% Outputs:
%   reachableLanes - Lane objects which can be reached of the obstacle
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: Althoff and Magdici, 2016, Set-Based Prediction of Traffic
% Participants on Arbitrary Road Networks, IV. Occupancy Prediction

% Author:       Markus Koschi
% Written:      13-January-2017
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

%reachableByLanes = lanes.findReachableLanes(constraint5, obstacleInLane);
reachableByLanelets = lanes.findReachableLanes(constraint5, obstacleInLane.lanelets);

% return and remove double entries
% (the current obstacle's lane is reachable, but 
% do not add lanes which are obstacle's lane(s))
%reachableLanes = [obstacleInLane, reachableByLanes(~ismember(reachableByLanes, obstacleInLane)), reachableByLanelets(~ismember(reachableByLanelets, reachableByLanes))];
reachableLanes = [obstacleInLane, reachableByLanelets(~ismember(reachableByLanelets, obstacleInLane))];

end

%------------- END CODE --------------