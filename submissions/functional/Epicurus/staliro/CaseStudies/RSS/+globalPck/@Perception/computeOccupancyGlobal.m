function computeOccupancyGlobal(obj, timeInterval)
% computeOccupancyGlobal - frame for occupancy predicition of all obstacles
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
% Other m-files required: computeOccupancyForObstacle, computeOccupancyCore
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

% compute the occupancy for all obstacles in the map for the time interval
%parfor (parallelize the prediction of each obstacle)
for i = 1:numel(obj.map.obstacles)
    obj.map.obstacles(i).computeOccupancyForObstacle(obj.map, timeInterval)
end

% compute the occupancy of the ego vehicle
if ~isempty(obj.map.egoVehicle)
    obj.map.egoVehicle.computeOccupancyForObstacle(obj.map, timeInterval)
end

end

%------------- END CODE --------------