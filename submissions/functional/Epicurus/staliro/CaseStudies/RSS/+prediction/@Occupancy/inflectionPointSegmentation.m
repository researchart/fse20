function [vertices] = inflectionPointSegmentation(iPath_Obstacle, xiObstacle, xiClosest, xiFurthest, shortestPath, leftBorder, rightBorder)
%inflectionPointSegmentation - compute the segmentation through the lane
% along the shortest path for one time step
%
% Syntax:
%   [vertices] = inflectionPointSegmentation(iPath_Obstacle, xiObstacle, xiClosest, xiFurthest, shortestPath, leftBorder, rightBorder)
%
% Inputs:
%   iPath_Obstacle - index in shortest path of the vertice which is closest to the obstacle
%   xiObstacle - distance between above vertex and obstacle's position along the
%           shortest path
%           (xiObstacle can be positive (projected position is behind iPath_Obstacle)
%           or negative (projected position is in front of iPath_Obstacle))
%   xiClosest - closest longitudinal reach of the obstacle
%   xiFurthest - furthest longitudinal reach of the obstacle
%   shortestPath - shortest path through the lane
%   leftBorder - left border of the lane
%   rightBorder - right border of the lane
%
% Outputs:
%   vertices - polygon vertices of the segmentation (clockwise)
%             (convention: clockwise-ordered vertices are external contours)
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
% Written:      11-Oktober-2016
% Last update:  22-November-2016
%
% Last revision:---

%------------- BEGIN CODE --------------

% initalise vertices array
vertices = [];

% transform the path variable according to the obstacle's position, i.e.
% such that xi is zero at the obstacle's position
xi = shortestPath.xi - shortestPath.xi(iPath_Obstacle) + xiObstacle;

% compute the front and final bound, but make sure xiClosest and xiFurthest
% are within the current lane:
% (if they are not and EXTEND_LANES, the front and last bound will be
% constructed by extending the lane border as a straight line, else
% the occupancy will start at the beginning or end at the end of the lane,
% repsectively)

% front bound
if xiClosest < xi(1)
    % closest longitudinal reach is behind the lane
    %warning(['Lane is not long enough in backward driving direction to'...
    %    ' represent the whole occupancy until the closest reach.'])
    if prediction.Occupancy.EXTEND_LANES_BACKWARD
        [frontBound, iLeftBorder_frontBound, iRightBorder_frontBound] = ...
            prediction.Occupancy.constructBound(iPath_Obstacle, xiClosest, 'front', xi, shortestPath, leftBorder, rightBorder);
    else
        frontBound = [];
        iLeftBorder_frontBound = 1;
        iRightBorder_frontBound = 1;
    end
elseif xiClosest > xi(end)
    % closest longitudinal reach is ahead of the lane
    %warning(['Lane is not long enough in forward driving direction to'...
    %    ' represent the whole occupancy until closest reach.'])
    if prediction.Occupancy.EXTEND_LANES_FORWARD
        [frontBound, iLeftBorder_frontBound, iRightBorder_frontBound] = ...
            prediction.Occupancy.constructBound(iPath_Obstacle, xiClosest, 'front', xi, shortestPath, leftBorder, rightBorder);
    else
        % both bounds are ahead of the lane but will be cut, i.e.
        % the occupancy is empty
        %warning(['RETURN: Lane was not long enough in forward driving'...
        %' direction.'])
        return
    end
else
    % regular computation of the front bound
    [frontBound, iLeftBorder_frontBound, iRightBorder_frontBound] = ...
        prediction.Occupancy.constructBound(iPath_Obstacle, xiClosest, 'front', xi, shortestPath, leftBorder, rightBorder);
end

% final bound
if xiFurthest < xi(1)
    % furthest longitudinal reach is behind the lane
    %warning(['Lane is not long enough in backward driving direction to'...
    %    ' represent the whole occupancy until the furthest reach.'])
    if prediction.Occupancy.EXTEND_LANES_BACKWARD
        [finalBound, iLeftBorder_finalBound, iRightBorder_finalBound] = prediction.Occupancy.constructBound(iPath_Obstacle, xiFurthest, 'final', xi, shortestPath, leftBorder, rightBorder);
    else
        % both bounds are behind the lane but will be cut, i.e.
        % the occupancy is empty
        %warning(['RETURN: Lane was not long enough in backward driving'...
        %' direction.'])
        return
    end
elseif xiFurthest > xi(end)
    % furthest longitudinal reach is ahead of the lane
    %warning(['Lane is not long enough in forward driving direction to'...
    %    ' represent the whole occupancy until furthest reach.'])
    if prediction.Occupancy.EXTEND_LANES_FORWARD
        [finalBound, iLeftBorder_finalBound, iRightBorder_finalBound] = prediction.Occupancy.constructBound(iPath_Obstacle, xiFurthest, 'final', xi, shortestPath, leftBorder, rightBorder);
    else
        finalBound = [];
        iLeftBorder_finalBound = size(leftBorder.vertices,2);
        iRightBorder_finalBound = iLeftBorder_finalBound;
    end
else
    % regular computation of the final bound
    [finalBound, iLeftBorder_finalBound, iRightBorder_finalBound] = prediction.Occupancy.constructBound(iPath_Obstacle, xiFurthest, 'final', xi, shortestPath, leftBorder, rightBorder);
end

% extract the left and right lane border vertices which enclose the shortest path
verticesLeft = leftBorder.vertices(:,iLeftBorder_frontBound:iLeftBorder_finalBound);
verticesRight = fliplr(rightBorder.vertices(:,iRightBorder_frontBound:iRightBorder_finalBound));

% save the vertices array of the computed occupancy (clockwise-ordered)
vertices = [frontBound, verticesLeft, finalBound, verticesRight];

% % % DEBUG: plot
% % %plot(rightBorder.vertices(1,iBorder_frontBound-1), rightBorder.vertices(2,iBorder_frontBound-1), 'rx')
% % plot(rightBorder.vertices(1,iBorder_frontBound), rightBorder.vertices(2,iBorder_frontBound), 'r*')
% % %plot(leftBorder.vertices(1,iBorder_frontBound-1), leftBorder.vertices(2,iBorder_frontBound-1), 'rx')
% % plot(leftBorder.vertices(1,iBorder_frontBound), leftBorder.vertices(2,iBorder_frontBound), 'r*')
% % if ~isempty(frontBound)
% %     plot(frontBound(1,:), frontBound(2,:), 'r-')
% % end
% % plot(rightBorder.vertices(1,iBorder_finalBound), rightBorder.vertices(2,iBorder_finalBound), 'bx')
% % %plot(rightBorder.vertices(1,iBorder_finalBound+1), rightBorder.vertices(2,iBorder_finalBound+1), 'b*')
% % plot(leftBorder.vertices(1,iBorder_finalBound), leftBorder.vertices(2,iBorder_finalBound), 'bx')
% % %plot(leftBorder.vertices(1,iBorder_finalBound+1), leftBorder.vertices(2,iBorder_finalBound+1), 'b*')
% % if ~isempty(finalBound)
% %     plot(finalBound(1,:), finalBound(2,:), 'b-')
% % end
% % patch(vertices(1,:), vertices(2,:), 1, 'FaceColor', 'g', 'FaceAlpha', 0.1, 'EdgeAlpha', 0)

end

%------------- END CODE --------------