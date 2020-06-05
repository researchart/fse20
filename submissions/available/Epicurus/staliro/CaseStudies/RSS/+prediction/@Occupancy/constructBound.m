function [bound, iLeftBorder_Bound, iRightBorder_Bound] = constructBound(iPath_Obstacle, xiBound, typeOfBound, xi, shortestPath, leftBorder, rightBorder)
%constructBound - construct the bound of the inflection point segmentation
% along the shortest path, such that the reachable xiBound is enclosed
%
% Syntax:
%   [bound, iLeftBorder_Bound, iRightBorder_Bound] = constructBound(iPath_Obstacle, xiBound, typeOfBound, xi, shortestPath, leftBorder, rightBorder)
%
% Inputs:
%   iPath_Obstacle - index in shortest path of the vertice which is closest to the obstacle
%   xiBound - closest or furthest longitudinal reachability of the obstacle
%   typeOfBound - string: 'front' (closest) or 'final' (furthest)
%   shortestPath - shortest path through the lane
%   leftBorder - left border of the lane
%   rightBorder - right border of the lane
%
% Outputs:
%   bound - point coordinates of the bound (such that a occupancy polygon
%           with clockwise-ordered vertices can be constructed)
%   iLeftBorder_Bound - index of the left lane border at which the
%                       segmentation starts or ends, respectively
%   iRightBorder_Bound - index of the right lane border at which the
%                       segmentation starts or ends, respectively
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: Althoff and Magdici, 2016, Set-Based Prediction of Traffic
% Participants on Arbitrary Road Networks, IV. Occupancy Prediction, B.
% Lane-Following Occupancy (Abstraction M_2), Definition 8
% (Inflection-point segmentation)
%
% References in this function refer to this paper.

% Author:       Markus Koschi
% Written:      23-November-2016
% Last update:  03-August-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

% construct the bound of the occupancy, such that xiBound is enclosed
% (over-approximation):
% (note that xiBound might be negative if backward driving is allowed)
if xiBound >= xi(iPath_Obstacle)
    % follow the shortest path forwards until just before xiClosest is reached
    for j = iPath_Obstacle:(length(xi)-1)
        if xi(j+1) > xiBound
            % the bound is between the vertex j and the next vertex (j+1)
            break;
        end
        % else step forward to vertice (j+1)
    end
else % (xiBound - xiObstacle) < 0
    % check if iPath_Obstacle is not at the beginning of the bound
    if iPath_Obstacle > 1
        % follow the shortest path backwards until xiBound is passed
        for j = (iPath_Obstacle-1):-1:1
            if xi(j) < xiBound
                % the bound is between vertex j and previous vertex (j+1),
                % which is closer to the obstacle
                break;
            end
            % else step back to vertex (j-1)
        end
    else % iPath_Obstacle == 1
        j = 1;
    end
end

% the bound is between the vertices j and (j+1):
% set indexes on inner bound
iPath_Bound_j = j;
iInnerBound_Bound_j = shortestPath.indexBorder(iPath_Bound_j);

% assign the inner bound at vertice j
if shortestPath.side(iPath_Bound_j) %i.e. left
    innerBound = leftBorder;
    outerBound = rightBorder;
else %i.e. right
    innerBound = rightBorder;
    outerBound = leftBorder;
end

% find the next (non-identical) vertex on the inner bound
iInnerBound_Bound_jplus1 = geometry.getNextIndex(innerBound.vertices, iInnerBound_Bound_j, 'forward', innerBound.distances);

% distance on inner bound between vertex j and xiBound
distanceBound = xiBound - xi(iPath_Bound_j);

% calculate the coordinates of xiBound on the inner bound
% (vector equation: pointInnerBound = vertex(Bound_j) + lamda * vector)
vectorInnerBound = innerBound.vertices(:,iInnerBound_Bound_jplus1) - innerBound.vertices(:,iInnerBound_Bound_j);
if norm(vectorInnerBound) ~= 0
    lamdaInnerBound = distanceBound / norm(vectorInnerBound);
else
    lamdaInnerBound = 0;
end
pXiBound = innerBound.vertices(:,iInnerBound_Bound_j) + lamdaInnerBound * vectorInnerBound;

% construct tangent at pXiBound
t = innerBound.vertices(:,iInnerBound_Bound_jplus1) - innerBound.vertices(:,iInnerBound_Bound_j);

% construct normal vector to tangent at pXiBound
n = [-t(2); t(1)];

% find vertex on outer bound, such that mu_j is the first
% vertice in front of n in driving direction
for iOuterBound_Bound_jplus1 = iInnerBound_Bound_j:size(outerBound.vertices,2)
    mu_j = outerBound.vertices(:,iOuterBound_Bound_jplus1);
    % due to the specific orientation of n, mu_j is always on
    % the right of n to be in front in driving direction
    if ~geometry.isLeft(pXiBound, pXiBound + n, mu_j)
        break;
    end
end
iOuterBound_Bound_j =  geometry.getNextIndex(outerBound.vertices, iOuterBound_Bound_jplus1, 'backward', outerBound.distances);

% calculate projection of pXiBound on outer bound
% (pXiOuterBound = pXiBound + alpha*n, where alpha is found by intersection
% with outer bound)
[alpha, ~] = geometry.calcVectorIntersectionPoint(pXiBound, n, ...
    outerBound.vertices(:,iOuterBound_Bound_j), outerBound.vertices(:,iOuterBound_Bound_jplus1) - outerBound.vertices(:,iOuterBound_Bound_j));
pXiOuterBound = pXiBound + alpha * n;

% save the the points of the bound and the index of the lane border at
% which the occupancy will start or end
switch typeOfBound
    case 'front'
        % the front bound is from the right to the left border at pBound
        % and continues at index (j+1) on the border
        if shortestPath.side(iPath_Bound_j) %i.e. left
            bound = [pXiOuterBound, pXiBound];
            iLeftBorder_Bound = iInnerBound_Bound_jplus1;
            iRightBorder_Bound = iOuterBound_Bound_jplus1;
        else %i.e. right
            bound = [pXiBound, pXiOuterBound];
            iLeftBorder_Bound = iOuterBound_Bound_jplus1;
            iRightBorder_Bound = iInnerBound_Bound_jplus1;
        end
    case 'final'
        % the final bound is from the left to the right border at pBound
        % and runs until index j on the border
        if shortestPath.side(iPath_Bound_j) %i.e. left
            bound = [pXiBound, pXiOuterBound];
            iLeftBorder_Bound = iInnerBound_Bound_j;
            iRightBorder_Bound = iOuterBound_Bound_j;
        else %i.e. right
            bound = [pXiOuterBound, pXiBound];
            iLeftBorder_Bound = iOuterBound_Bound_j;
            iRightBorder_Bound = iInnerBound_Bound_j;
        end
end

% DEGUB:
% check the actual xi of the bound, whether the bound over-approximates the
% reach xiBound
iInnerBound_Bound_j = shortestPath.indexBorder(iPath_Bound_j);
if shortestPath.side(iPath_Bound_j) %i.e. left
    pBoundLeft = pXiBound;
    pBoundRight = pXiOuterBound;
else %i.e. right
    pBoundLeft = pXiOuterBound;
    pBoundRight = pXiBound;
end
if sign(distanceBound) == 1
    xiBoundLeft = norm(pBoundLeft - leftBorder.vertices(:,iInnerBound_Bound_j)) + xi(iPath_Bound_j);
    xiBoundRight = norm(pBoundRight - rightBorder.vertices(:,iInnerBound_Bound_j)) + xi(iPath_Bound_j);
else % sign(distanceFrontBound) == -1
    xiBoundLeft = - norm(pBoundLeft - leftBorder.vertices(:,iInnerBound_Bound_j)) + xi(iPath_Bound_j);
    xiBoundRight = - norm(pBoundRight - rightBorder.vertices(:,iInnerBound_Bound_j)) + xi(iPath_Bound_j);
end
switch typeOfBound
    case 'front'
        % the computed front bound must not be further away than the
        % closest reach
        if (xiBoundLeft - xiBound) > 10e-9 && (xiBoundRight - xiBound) > 10e-9
            warning('Front bound is further away than xiClosest, i.e. no over-approximation.')
        end
    case 'final'
        % the computed final bound must not be closer than the furthest
        % reach
        if (xiBoundLeft - xiBound) < -10e-9  && (xiBoundRight - xiBound) < -10e-9
            warning('Final bound is closer than xiFurthest, i.e. no over-approximation.')
        end
end

% % DEBUG: plot
% lamda = 0:0.05:2;
% if shortestPath.side(iPath_Bound_j) %i.e. left
%     plot(leftBorder.vertices(1,iInnerBound_Bound_j), leftBorder.vertices(2,iInnerBound_Bound_j), 'rx')
%     plot(leftBorder.vertices(1,iInnerBound_Bound_jplus1), leftBorder.vertices(2,iInnerBound_Bound_jplus1), 'rx')
%     plot(rightBorder.vertices(1,iOuterBound_Bound_j), rightBorder.vertices(2,iOuterBound_Bound_j), 'rx')
%     plot(rightBorder.vertices(1,iOuterBound_Bound_jplus1), rightBorder.vertices(2,iOuterBound_Bound_jplus1), 'r*')
% else %i.e. right
%     plot(leftBorder.vertices(1,iOuterBound_Bound_j), leftBorder.vertices(2,iOuterBound_Bound_j), 'rx')
%     plot(leftBorder.vertices(1,iOuterBound_Bound_jplus1), leftBorder.vertices(2,iOuterBound_Bound_jplus1), 'rx')
%     plot(rightBorder.vertices(1,iInnerBound_Bound_j), rightBorder.vertices(2,iInnerBound_Bound_j), 'rx')
%     plot(rightBorder.vertices(1,iInnerBound_Bound_jplus1), rightBorder.vertices(2,iInnerBound_Bound_jplus1), 'r*')
% end
% plot(pXiBound(1), pXiBound(2), 'bs')
% plot(pXiOuterBound(1), pXiOuterBound(2), 'bd')
% plot(bound(1,:), bound(2,:), 'r-')
% plot(pXiBound(1) + lamda*n(1), pXiBound(2) + lamda*n(2), 'g.')

end

%------------- END CODE --------------