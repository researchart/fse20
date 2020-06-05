function defineTrajectory(obj, obstacle, timeInterval, inLane_idx)
% defineTrajectory - creates a trajectory with constant velocity along the
% path of the center vertices of the lane obstacle.inLane(inLane_idx)
%
%   Syntax:
%       defineTrajectory(obj, obstacle, timeInterval, inLane_idx)
%
%   Inputs:
%       obj - Trajectory object
%       obstacle - obstacle (or ego vehicle) for which the trajecotry is
%                  created
%       timeInterval - time interval of the intended trajectory
%       inLane_idx - index of the inLane property of the obstacle to
%                        specify in which lane the trajectory shall be defined
%
%   Outputs:
%       none (trajectory is saved in the trajectory object)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Mona Beikirch, Markus Koschi
% Written:      20-March-2017
% Last update:  16-August-2017
%
% Last revision:---

%------------- BEIN CODE --------------

% get the time interval properties
[ts, dt, tf] = timeInterval.getTimeInterval();
numTimeIntervals = length(ts:dt:(tf-dt));

% get start position of obstacle
distance = 99 * ones(1,length(obstacle.inLane(inLane_idx).center.vertices));
for j = 1:length(obstacle.inLane(inLane_idx).center.vertices)
    distance(j) = norm(obstacle.inLane(inLane_idx).center.vertices(:,j) - obstacle.position);
end
[startDistance,startPos] = min(distance);

% properties of trajectory
positionArray = obstacle.position;
orientationArray = obstacle.orientation;
velocityArray = obstacle.velocity;
accelerationArray = obstacle.acceleration;
inLaneArray = obstacle.inLane(inLane_idx);

% trajectory with constant speed, i.e. constant distance traveled in each
% time interval
travelDistance = obstacle.velocity * dt;

% distances along center line
centerLineDistances = geometry.calcPathDistances(obstacle.inLane(inLane_idx).center.vertices(1,:), obstacle.inLane(inLane_idx).center.vertices(2,:));

% compute trajectory points, i.e. start position and end position for each
% time interval
if norm(obstacle.inLane(inLane_idx).center.vertices(:,startPos+1) - obstacle.position) > centerLineDistances(startPos+1)
    distance = startDistance;
else
    distance = -startDistance; % obstacle is infront of startPos
end
position = startPos;
for i = 1:numTimeIntervals
    while (distance < travelDistance && position < length(centerLineDistances)) % travel along center line
        distance = distance + centerLineDistances(position+1);
        position = position + 1;
    end
    
    if position >= length(centerLineDistances)
        warning('Trajectory to long! (Obstacle id = %i)', obstacle.id);
        break;
    end
    
    % compute the exact position between two center line points with
    % theorem of intersection lines
    if position < 1
        position = 1;
    end
    x_1 = obstacle.inLane(inLane_idx).center.vertices(1,position-1);
    x_2 = obstacle.inLane(inLane_idx).center.vertices(1,position);
    y_1 = obstacle.inLane(inLane_idx).center.vertices(2,position-1);
    y_2 = obstacle.inLane(inLane_idx).center.vertices(2,position);
    
    orientation_obst = atan2(y_2-y_1,x_2-x_1);
    
    d = centerLineDistances(position);
    d_i = travelDistance - (distance - centerLineDistances(position));
    
    delta_x = d_i/d * (x_2-x_1);
    delta_y = d_i/d * (y_2-y_1);
    
    trajectoryPointX = x_1 + delta_x;
    trajectoryPointY = y_1 + delta_y;
    
    % fill trajectory properties
    next_position = [trajectoryPointX; trajectoryPointY];
    positionArray = [positionArray, next_position];
    orientationArray(end+1) = orientation_obst;
    velocityArray(end+1) = obstacle.velocity;
    accelerationArray(end+1) = obstacle.acceleration;
    inLaneArray(end+1) = obstacle.inLane(inLane_idx);
    
    % set initial distance for next time interval which may be different
    % from 0
    distance = d - d_i;
end

obj.timeInterval = timeInterval;
%obj.time = ts;
obj.position = positionArray;
obj.orientation = orientationArray;
obj.velocity = velocityArray;
obj.acceleration = accelerationArray;
%obj.inLane = inLaneArray;

end

%------------- END CODE --------------