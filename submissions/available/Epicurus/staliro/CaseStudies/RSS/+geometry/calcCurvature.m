function [curvature] = calcCurvature(x, y)
% calcCurvature - calculate the well-known signed curvature of the polyline
%
% Syntax:
%   [curvature] = calcCurvature(x, y)
%
% Inputs:
%   x - x-coordinates of the polyline
%   y - y-coordinates of the polyline
%
% Outputs:
%   curvature - curvature of the given polyline
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ---

% Author:       Markus Koschi
% Written:      05-Oktober-2016
% Last update:  16-May-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

% calculate the gradients
dx = gradient(x);
ddx = gradient(dx);
dy = gradient(y);
ddy = gradient(dy);

% calculate the signed curvature
if all(dx ~= 0) && all(dy ~= 0)
    curvature = (dx .* ddy - ddx .* dy) ./ ((dx.^2 + dy.^2).^(3/2));
else
    % set curvature to 0 instead of to NaN (when division by 0)
    curvature = zeros(1,length(x));
    isNum = and((dx ~= 0),(dy ~= 0));
    curvature(isNum) = (dx(isNum) .* ddy(isNum) - ddx(isNum) .* dy(isNum)) ./ ((dx(isNum).^2 + dy(isNum).^2).^(3/2));
end

% % smoothing
% isSmall = abs(curvature) < 10e-04;
% curvature(isSmall) = 0;

end

%------------- END CODE --------------