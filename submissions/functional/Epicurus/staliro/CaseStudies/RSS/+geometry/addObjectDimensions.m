function [p] = addObjectDimensions(q, length, width)
% addObjectDimensions - add the dimensions of the object (length and width)
% to the polygon vertices q in the object's coordinate frame (x: length,
% y: width) (convention: clockwise-ordered vertices are external contours)
%
% Syntax:
%	[p] = addObjectDimensions(q, length, width)
%
% Inputs:
%   q - 2D row of vertices q1, ..., qn (polygon)
%   length - length of the object (including measurement uncertainties)
%   width - width of the object (including measurement uncertainties)
%
% Outputs:
%   p - 2D row of vertices p1, ..., pn (polygon)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: Althoff and Magdici, 2016, Set-Based Prediction of Traffic
% Participants on Arbitrary Road Networks, IV. Occupancy Prediction, A.
% Acceleration-Based Occupancy (Abstraction M_1)
%
% References in this function refer to this paper.

% Author:       Markus Koschi
% Written:      13-September-2016
% Last update:  31-October-2016 (arbitrary q)
%
% Last revision:---

%------------- BEGIN CODE --------------

if isempty(length) || isempty(width)
    error('Empty input variables. Error in geometry.addObjectDimensions')
end

% check for special cases
if size(q,2) == 1 % exactly one vertice
    % add the dimension around the point q
    p1 = q + [-0.5 * length; 0.5 * width];
    p2 = q + [0.5 * length; 0.5 * width];
    p3 = q + [0.5 * length; -0.5 * width];
    p4 = q + [-0.5 * length; -0.5 * width];
    p = [p1, p2, p3, p4];
    
elseif size(q,2) == 6 % exactly six vertices
    % add the dimensions to all six vertices q (Theorem 1)
    p1 = q(:,1) + [-0.5 * length; 0.5 * width];
    p2 = q(:,2) + [-0.5 * length; 0.5 * width];
    p3 = q(:,3) + [0.5 * length; 0.5 * width];
    p4 = q(:,4) + [0.5 * length; -0.5 * width];
    p5 = q(:,5) + [-0.5 * length; -0.5 * width];
    p6 = q(:,6) + [-0.5 * length; -0.5 * width];
    p = [p1, p2, p3, p4, p5, p6];
    
elseif size(q,1) == 2 % arbitrary polygon
    % add the dimensions to all vertices q:
    % (left up, right up, left down, right down)
    p_LU(1,:) = q(1,:) - 0.5 * length;
    p_LU(2,:) = q(2,:) + 0.5 * width;
    
    p_RU(1,:) = q(1,:) + 0.5 * length;
    p_RU(2,:) = q(2,:) + 0.5 * width;
    
    p_LD(1,:) = q(1,:) - 0.5 * length;
    p_LD(2,:) = q(2,:) - 0.5 * width;
    
    p_RD(1,:) = q(1,:) + 0.5 * length;
    p_RD(2,:) = q(2,:) - 0.5 * width;
    
    p_all = [p_LU, p_RU, p_LD, p_RD];
    
    % find the convex hull
    p_convex = p_all(:,convhull(p_all'));
    
    % arrange the vertices in clockwise ordering
    [px, py] = poly2cw(p_convex(1,:), p_convex(2,:));
    p = [px; py];
else
    error('Input vector is not a 2D row of vertices. Error in geometry.addObjectDimensions')
end

%------------- END CODE --------------