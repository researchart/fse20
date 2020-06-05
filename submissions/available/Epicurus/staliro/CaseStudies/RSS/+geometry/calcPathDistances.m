function [distances] = calcPathDistances(x, y)
% calcPathDistances - calculate the distance (L2-norm) between all adjacent
% points (x,y) of the polyline
%
% Syntax:
%   [distance] = calcPathDistances(x, y)
%   
% Inputs:
%   x - x-coordinates of polyline
%   y - y-coordinates of polyline
%
% Outputs:
%   distances - distance between the ith and (i-1)th point
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

% initialise
num = length(x);
distances = zeros(1,num);

for i=2:num
    % calculate the distance between the current and previous point
    distances(i) = norm( [x(i);y(i)] - [x(i-1);y(i-1)] );
end

end

%------------- END CODE --------------