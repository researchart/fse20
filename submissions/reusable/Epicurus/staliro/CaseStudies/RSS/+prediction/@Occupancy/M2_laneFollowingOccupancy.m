function [occM2] = M2_laneFollowingOccupancy(obj, obstacle, lane, ts, dt, tf)
% M2_laneFollowingOccupancy - compute the lane-following occupancy for each
% time step, taking into account only the full acceleration and full deceleration
% (shortest path through a lane; abstraction M_2)
%
% Syntax:
%   [occM2] = M2_laneFollowingOccupancy(obj, obstacle, lane, ts, dt, tf)
%
% Inputs:
%   obj - Occupancy object
%   obstacle - Obstacle object
%   network - current lane
%   ts - start time of the prediction horizon
%   dt - time step of the prediction horizon
%   tf - final time of the prediction horizon
%
% Outputs:
%   occM2 - polygon vertices representing the lane-following occupancy of
%           the obstacle in the lane for each time step from ts until tf;
%           generally non-convex (convention: clockwise-ordered vertices are
%           external contours)
%
% Other m-files required: findVerticeOfPosition, calcProjectedDistance,
% Subfunctions: closestLongitudinalReach, furthestLongitudinalReach,
%   inflectionPointSegmentation
% MAT-files required: none
%
% See also: Althoff and Magdici, 2016, Set-Based Prediction of Traffic
% Participants on Arbitrary Road Networks, IV. Occupancy Prediction, B.
% Lane-Following Occupancy (Abstraction M_2)
%
% References in this function refer to this paper.

% Author:       Markus Koschi
% Written:      14-Oktober-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

% initalize occupancy vertices
occM2 = cell(1,length(ts:dt:(tf-dt)));
k = 1;

v_max_M2 = min(obstacle.v_max, max(lane(1).speedLimit) * (1 + obstacle.speedingFactor));
%TODO: Diana add lane.criticalVelocityProfile

% find the index of the lane vertice of the inner bound which has the minimal
% distance to the obstacle's postion, which must not be in the current lane
% -> starting coordinates of the inflection point segmentation
[iPath, iBorder] = geometry.findInnerVerticeOfPosition(obstacle.position, lane.shortestPath, lane.leftBorder.vertices, lane.rightBorder.vertices);

% assign the inner bound at this vertice
if lane.shortestPath.side(iPath) %i.e. left
    innerBound = lane.leftBorder;
else %i.e. right
    innerBound = lane.rightBorder;
end

% calculate the distance between the vertice iBorder and the perpendicular
% projection of the obstacle's coordinates onto the inner bound, i.e. the
% path variable xi at the vertice iBorder (xi = 0 at objPosition)
% (instead of constructing the initial inner lane bound which is
% perdendicular to hStart)
% xiObstacle is positive, if projection is behind in driving direction
% xiObstacle is negative, if projection is in front in driving direction
[xiObstacle, ~] = geometry.calcProjectedDistance(iBorder, innerBound, obstacle.position);

% % DEBUG: plot
% figure()
% plot(lane.leftBorder.vertices(1,:), lane.leftBorder.vertices(2,:), 'k-')
% hold on
% axis equal
% plot(lane.rightBorder.vertices(1,:), lane.rightBorder.vertices(2,:), 'k-')
% plot(obstacle.position(1), obstacle.position(2), 'c*')
% plot(innerBound.vertices(1,iBorder), innerBound.vertices(2,iBorder), 'ko')
% plot(innerBound.vertices(1,iBorder-1), innerBound.vertices(2,iBorder-1), 'ko')
% obstaclesCoordinatesRear = [obstacle.position(1) - obstacle.length*cos(obstacle.orientation)/2; ...
%  obstacle.position(2) - obstacle.length*sin(obstacle.orientation)/2];
% plot(obstaclesCoordinatesRear(1), obstaclesCoordinatesRear(2), 'co')

% compute the occupancy M2 for each time interval
for t = ts:dt:(tf-dt)
    % xi is the path variable (equation (7))
    
    % compute the closest longitudinal reach, i.e. xi of hStart (Definition 7)
    % (xi might be negative if backward driving is allowed)
    xiClosest_t = prediction.Occupancy.closestLongitudinalReach(t, obstacle.velocity, obstacle.a_max, obstacle.constraint3);
    xiClosest_tdt = prediction.Occupancy.closestLongitudinalReach(t+dt, obstacle.velocity, obstacle.a_max, obstacle.constraint3);
    xiClosest = min(xiClosest_t, xiClosest_tdt);
    
    % compute the furthest longitudinal reach, i.e. xi of hfinal (Definition 7)
    xiFurthest = prediction.Occupancy.furthestLongitudinalReach(t+dt, obstacle.velocity, obstacle.v_s, v_max_M2, obstacle.a_max);
    
    % compute the polygon vertices of the occupancy when following the
    % shortest path through the current lane starting at xiClosest and
    % ending at xiFurthest with subtracted and added half of the obstacle's
    % length, respectively
    occM2{1,k} = prediction.Occupancy.inflectionPointSegmentation(...
        iPath, xiObstacle, (xiClosest - 1/2 * obstacle.shape.length), (xiFurthest + 1/2 * obstacle.shape.length),...
        lane.shortestPath, lane.leftBorder, lane.rightBorder);
    %patch(occM2{1,k}(1,:), occM2{1,k}(2,:), 1, 'FaceColor', 'b', 'FaceAlpha', 0.1)
    k = k + 1;
end

end

%------------- END CODE --------------