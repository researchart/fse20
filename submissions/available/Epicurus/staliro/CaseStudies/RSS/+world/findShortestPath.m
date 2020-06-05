function [shortestPath] = findShortestPath(leftBorder, rightBorder)
% findShortestPath - find the shortest possible path through the lane (network)
% by always following the inner bound (i.e. corresponding path, Definition 8)
%
% Syntax:
%   [shortestPath] = findShortestPath(leftBorder, rightBorder)
%
% Inputs:
%   leftBorder - left border of the lane
%   rightBorder - right border of the lane
%
% Outputs:
%   shortestPath - shortest path through the lane according to Definition 8
%                 (note that its size, i.e. the number of vertices, might 
%                  be greater than of the lane borders)
%           .xi - path variable (path length along the shortest path)
%           .indexBorder - for each path variable the corresponding 
%           index of the vertice of inner bound
%           .side - side of the current inner bound (1: left; 0: right)
%
% Other m-files required: followBound
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
% Written:      14-Oktober-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

% start at the first vertice of the lane borders
iFirst = 1;

% 1) find inner lane bound
if (sign(leftBorder.curvatures(iFirst)) > 0) % (Definition 8)
    % left bound is the inner lane bound
    innerBound = leftBorder;
    innerBound.side = 1; % flag for left
    outerBound = rightBorder;
    outerBound.side = 0; % flag for right
else
    % right bound is the inner lane bound
    innerBound = rightBorder;
    innerBound.side = 0; % flag for right
    outerBound = leftBorder;
    outerBound.side = 1; % flag for left
end

% shortest path starts at the first vertice of the inner bound
shortestPath.xi(iFirst) = 0;
shortestPath.indexBorder(iFirst) = iFirst;
shortestPath.side(iFirst) = innerBound.side;
shortestPath.curvature(iFirst) = innerBound.curvatures(iFirst);

% 2) recursively follow all inner bounds
shortestPath = world.followBound(iFirst, shortestPath, innerBound, outerBound);

% 3) recompute curvature
%ToDo

% % debug:
% figure()
% hold on
% for i = 1:length(shortestPath.side)
%     if shortestPath.side(i)
%         % left
%         plot(leftBorder.vertices(1,shortestPath.indexBorder(i)), ...
%             leftBorder.vertices(2,shortestPath.indexBorder(i)), 'r*');
%     else
%         % right
%         plot(rightBorder.vertices(1,shortestPath.indexBorder(i)), ...
%             rightBorder.vertices(2,shortestPath.indexBorder(i)), 'g*');
%     end
% end
end

%------------- END CODE --------------