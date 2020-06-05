function [x_cen,y_cen] = calcPolygonCentroid(x,y)
% calcPolygonCentroid - Summary of this function goes here
%
% Syntax:
%   [x_cen,y_cen] = calcPolygonCentroid(x,y);
%
% Inputs:
%   x,y : x and y are coulmn vector for polygon
%
% Outputs:
%   x_cen,y_cen : centroid of polygon
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Rajat Koner
% Written:      30 Jan 2017
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------
% check if inputs are same size
if ~isequal( size(x), size(y) ),
  error( 'X and Y must be the same size');
end

% temporarily shift data to mean of vertices for improved accuracy
xm = mean(x);
ym = mean(y);
x = x - xm;
y = y - ym;

% summations for CCW boundary
xp = x( [2:end 1] );
yp = y( [2:end 1] );
a = x.*yp - xp.*y;

A = sum( a ) /2;
xc = sum( (x+xp).*a  ) /6/A;
yc = sum( (y+yp).*a  ) /6/A;

% replace mean of vertices
x_cen = xc + xm;
y_cen = yc + ym; 

end
