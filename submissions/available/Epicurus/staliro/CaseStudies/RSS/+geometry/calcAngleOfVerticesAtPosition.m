function [angle] = calcAngleOfVerticesAtPosition(position, vertices)
% calcAngleOfVerticesAtPosition - calculates the angle (orientation) of
% the line segment of the vertices which has the minimal distance to the
% given position.
% The angle is measured in the closed interval [-pi, pi] relative to the
% global x-axis (counter-clockwise is positive).
%
% Syntax:
%   [angle] = calcAngleOfVerticesAtPosition(position, vertices)
%
% Inputs:
%   position - coordinates of the object
%   vertices - polyline
%
% Outputs:
%   angle - orientation of the closest line segment
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ---

% Author:       Markus Koschi
% Written:      18-May-2017
% Last update:  23-August-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

% find closest vertex
[indexClosestVertex, ~] = geometry.findClosestVertexOfPosition(position, vertices);

if indexClosestVertex == length(vertices)
    indexClosestVertex = indexClosestVertex - 1;
end

%ToDo: use flag_segment of calcProjectedDistance
angle = atan2(vertices(2,indexClosestVertex+1) - vertices(2,indexClosestVertex), ...
    vertices(1,indexClosestVertex+1) - vertices(1,indexClosestVertex));

end

%------------- END CODE --------------