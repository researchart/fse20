function [indexOfVertex, distanceToVertex] = findClosestVertexOfPosition(position, vertices)
% findClosestVertexOfPosition - finds the vertex of the given polyline which
% has the minimal distance to the given position
%
% Syntax:
%   [indexVertex] = findClosestVertexOfPosition(position, vertices)
%
% Inputs:
%   position - coordinates of the object
%   vertices - polyline
%
% Outputs:
%   indexOfVertex - index of closest vertex
%   distanceToVertex - euclidean distance from position to closest vertex
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ---

% Author:       Markus Koschi
% Written:      18-May-2017
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

distance = zeros(1,size(vertices,2));
for i = 1:size(vertices,2)
    distance(i) = norm(vertices(:,i) - position);
end

[distanceToVertex, indexOfVertex] = min(distance);

%knnsearch

end

%------------- END CODE --------------