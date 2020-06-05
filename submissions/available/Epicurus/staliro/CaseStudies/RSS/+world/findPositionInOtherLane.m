function [newPos] = findPositionInOtherLane(trajectory, laneWidth, pos, laneNetwork_i)
% findPositionInOtherLane - 
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
% Other m-files required: %TODO
% Subfunctions: none
% MAT-files required: none
%
% See also: ---

% Author:       
% Written:      
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

traj = laneNetwork_i.net(1).trajectory; % the trajectory of the center line

for i=2:length(traj)-2
    [p1, p2] = OccupancyCalculation.ComputePerpendicular(traj(:,i-1), traj(:,i), traj(:,i+1), laneWidth/2);
    [q1, q2] = OccupancyCalculation.ComputePerpendicular(traj(:,i), traj(:,i+1), traj(:,i+2), laneWidth/2);
    p = [p1 p2 q1 q2];
    p = p(:,convhull(p'));
    if (inpolygon(pos(1,:), pos(2,:), p(1,:), p(2,:)))
        prev = traj(:,i);
        next = traj(:,i+1);
        break
    end
end
[p1, p2] = OccupancyCalculation.ComputePerpendicular(prev,pos,next, 3*laneWidth);
[X,Y]=curveintersect(trajectory(1,:), trajectory(2,:), [p1(1,:) p2(1,:)], [p1(2,:) p2(2,:)]);
newPos = [X;Y];
end

%------------- END CODE --------------