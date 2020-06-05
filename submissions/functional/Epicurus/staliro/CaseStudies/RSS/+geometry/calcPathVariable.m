function [xi] = calcPathVariable(x, y)
% calcPathVariable - calculate the accumulated, piecewise linear
% distance for all points (x,y), i.e. transformation of 2-D function (x,y)
% in 1-D path variable function (greek letter xi)
%
% Syntax: 
%   [xi] = calcPathVariable(x, y)
%   
% Inputs:
%   x - x-coordinates of curve points
%   y - y-coordinates of curve points
%
% Outputs:
%   xi - path variable (path length)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ---

% Author:       Markus Koschi
% Written:      11-Oktober-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

% initialise
num = length(x);
xi = zeros(1,num);

for i=2:num
    % sum up the distance between the points
    xi(i) = xi(i-1) + norm( [x(i);y(i)] - [x(i-1);y(i-1)] );
end

end

%------------- END CODE --------------