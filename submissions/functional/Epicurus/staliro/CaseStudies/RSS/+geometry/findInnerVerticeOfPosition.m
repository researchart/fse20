function [iPath_min, iBorder_min] = findInnerVerticeOfPosition(position, shortestPath, leftBorderVertices, rightBorderVertices)
% findVerticeOfPosition - find the vertice of the inner bound which has the
% minimal distance to the object's position
%
% Syntax:
%   [iPath, iBorder] = findVerticeOfPosition(position, shortestPath, leftBorderVertices, rightBorder)
%
% Inputs:
%   position - coordinates of the object
%   shortestPath - shortest path through the lane (note that its size, i.e.
%                  number of vertices, might be greater than the lane borders)
%           .xi - path variable (path length along the shortest path)
%           .indexBorder - for each path variable the corresponding 
%           index of the vertice of inner bound
%           .side - side of the current inner bound (1: left; 0: right)
%   leftBorderVertices - left border vertices of the lane
%   rightBorderVertices - right border vertices of the lane
%
% Outputs:
%   iPath - in shortest path, index of the closest vertex
%   iBorder - in border array, index of the closest vertex
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ---

% Author:       Markus Koschi
% Written:      18-Oktober-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

% initialize distance array
distance = 99*ones(1,length(shortestPath.side));

% calculate distance between the inner bound and the object position for
% all vertices (to find the global minima)
for iPath = 1:length(shortestPath.side)
    iBorder = shortestPath.indexBorder(iPath);
    if shortestPath.side(iPath) %i.e. left
        distance(iPath) = norm(leftBorderVertices(:,iBorder) - position);
    else %i.e. right
        distance(iPath) = norm(rightBorderVertices(:,iBorder) - position);
    end
end

% find the inner vertice of the minimal distance (in respect to the shortest
% path indexes)
[minDistance, iPath_min] = min(distance);

% check for plausibility
if (minDistance >= 99)
    warning(['The object is not close enough to the lane. (Its position' ...
    ' is more than 99 m away from the nearest lane vertex.'])
    %error('Object position is not close enough to lane. Error in geometry.findVerticeOfPosition')
end

% the innner vertice of the minimal distance in respect to the border indexes
iBorder_min = shortestPath.indexBorder(iPath_min);

end

%------------- END CODE --------------