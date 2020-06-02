function [res] = isLeft(linesStart, linesEnd, points)
% isLeft - returns boolean array whether the points are on the left of the
% lines (function accepts single/multiple points and single/multiple lines)
%
% Syntax:
%   [res] = isLeft(linesStart, linesEnd, points)
%
% Inputs: (in column vectors)
%   linesStart - start point of lines (p0)
%   linesEnd - end point of lines (p1)
%   points - points to determine their position in respect to the line (p2)
%
% Outputs:
%   res - row vector: true if point is on the left, 
%                       false if it is right or on the line
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ---

% Author:       Markus Koschi
% Written:      12-Oktober-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

% isLeft if (x1 - x0)*(y2 - y0) - (x2 - x0)*(y1 - y0) > 0
res = (linesEnd(1,:) - linesStart(1,:)) .* (points(2,:) - linesStart(2,:)) > ...
    (points(1,:) - linesStart(1,:)) .* (linesEnd(2,:) - linesStart(2,:));

end

%------------- END CODE --------------