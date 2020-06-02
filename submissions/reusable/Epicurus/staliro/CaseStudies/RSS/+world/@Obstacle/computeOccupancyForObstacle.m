function computeOccupancyForObstacle(obj, map, timeInterval)
% computeOccupancyForObstacle - frame for occupancy predicition of all obstacles
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
% Other m-files required: computeOccupancyCore
% Subfunctions: none
% MAT-files required: none
%
% See also: Althoff and Magdici, 2016, Set-Based Prediction of Traffic
% Participants on Arbitrary Road Networks, IV. Occupancy Prediction

% Author:       Markus Koschi
% Written:      28-October-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

% set inLaneId if isempty(obj.inLaneId) or update inLaneId
% TODO

% initialise occupancy
obj.occupancy = prediction.Occupancy();

% compute the occupancy
%tic
if ~isempty(obj.position)
    obj.occupancy = obj.occupancy.computeOccupancyCore(obj, map, timeInterval);
end

%fprintf('Computation time for the occupancy of obstacle %d: %f seconds.\n', obj.id, toc)

if isa(obj, 'world.EgoVehicle')
    % compute the occupancy of the ego vehicle to verify its trajectory
    % (not over-approximated prediction; but the set of its occupancy along its
    % trajectory)
    obj.occupancy_trajectory = prediction.Occupancy();
    obj.occupancy_trajectory = obj.occupancy_trajectory.computeOccupancyAlongTrajectory(obj, map, timeInterval);
end

end

%------------- END CODE --------------