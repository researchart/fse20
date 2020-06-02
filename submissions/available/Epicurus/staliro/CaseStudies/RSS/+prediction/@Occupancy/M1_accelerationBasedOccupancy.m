function [occM1] = M1_accelerationBasedOccupancy(obj, obstacle, ts, dt, tf)
% M1_accelerationBasedOccupancy - compute an over-approximation of the
% acceleration-based occupancy
% (occupancy towards the road boundaries with a_max; abstraction M_1)
%
% Syntax:
%   [occM1] = M1_accelerationBasedOccupancy(obj, obstacle, ts, dt, tf)
%
% Inputs:
%   obj - Occupancy object
%   obstacle - Obstacle object (car.a_max, car.velocity, car.orientation,
%           car.position)
%   ts - start time of OccupancyCalculation object
%   dt - time step of OccupancyCalculation object
%   tf - final time of OccupancyCalculation object
%
% Outputs:
%   occM1 - polygon vertices representing the acceleration-based occupancy
%           of the object for each time step from ts until tf; generally
%           non-convex (convention: clockwise-ordered vertices are
%           external contours)
%
% Other m-files required: accelerationOccupancyLocal, addObjectDimensions,
%                         rotateAndTranslateVertices
% Subfunctions: none
% MAT-files required: none
%
% See also: Althoff and Magdici, 2016, Set-Based Prediction of Traffic
% Participants on Arbitrary Road Networks, IV. Occupancy Prediction, A.
% Acceleration-Based Occupancy (Abstraction M_1)
%
% References in this function refer to this paper.

% Author:       Markus Koschi
% Written:      15-September-2016
% Last update:  02-November-2016
%
% Last revision:---

%------------- BEGIN CODE --------------

% compute the occupancy for static and dynamic objects
if (ts == tf) || isa(obstacle,'world.StaticObstacle')
    if isa(obstacle.shape,'geometry.Rectangle')
    % the steady occupancy for no time step or an static obstacle is
    % only the center of the point mass
    q = [0;0];
    
    % vertices p represent the occupancy with vehicle dimensions
    % (Theorem 1)
    p = geometry.addObjectDimensions(q, obstacle.shape.length, obstacle.shape.width);
    
    % rotate and translate the vertices of the occupancy set in local
    % coordinates to the object's reference position and rotation
    vertices = geometry.rotateAndTranslateVertices(p, obstacle.position, obstacle.orientation);
    
    % create a polygon which is a convex hull of the occupancy
    occM1 = vertices;
    
    elseif isa(obstacle.shape,'geometry.Polygon')
        occM1 =  obstacle.shape.vertices;
    else
        error(['Obstacle has unknown shape. ' ...
            'Error in prediction.Occupancy/M1_accelerationBasedOccupancy']);
    end
    
elseif isa(obstacle,'world.DynamicObstacle')    
    % initalize occupancy vertices
    occM1 = cell(1,length(ts:dt:(tf-dt)));
    k = 1;
    
    % compute the occupancy for each time interval
    for t = ts:dt:(tf-dt)
        % calculate the polygon vertices q which represent the convex occupancy
        % in local coordinates without vehicle dimensions:
        % (special position and orientation) (Lemma 1)        
        q = prediction.Occupancy.accelerationOccupancyLocal(obstacle.velocity, obstacle.a_max, t, t+dt);
        
        % vertices p represent the occupancy with vehicle dimensions
        % (Theorem 1)
        p = geometry.addObjectDimensions(q, obstacle.shape.length, obstacle.shape.width);
        
        % rotate and translate the vertices of the occupancy set in local
        % coordinates to the object's reference position and rotation
        vertices = geometry.rotateAndTranslateVertices(p, obstacle.position, obstacle.orientation);
        
        % create a polygon which is a convex hull of the occupancy
        occM1{1,k} = vertices;
        %patch(occM1{1,k}(1,:), occM1{1,k}(2,:), 1, 'FaceColor', 'g', 'FaceAlpha', 0.5)
        k = k + 1;
    end
else
    error(['First input argument is not an instance of the superclass '...
        'Obstacle. Error in prediction.Occupancy/M1_accelerationBasedOccupancy']);
end

end

%------------- END CODE --------------