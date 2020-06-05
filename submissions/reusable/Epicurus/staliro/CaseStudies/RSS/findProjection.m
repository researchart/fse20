% function findProjecttion - Returns the project point of a Point on a
% Line. Projection point is the intersection of the Line with its
% perpendicular line passing through the Point.
% 
% USAGE  
%        [prep_x,prep_y] = findProjection(LineEnd1,LineEnd2,Point)
% 
% INPUTS:
%
%        LineEnd1 - The X/Y coordinates of the first end point of the Line.
%        
%        LineEnd2 - The X/Y coordinates of the second end point of the Line.
%
%        Point - The X/Y coordinates of the Point whose the projection on
%        the Line with two end points (LineEnd1, LineEnd2) will be computed.
%
% OUTPUTS:
%
%        prep_x,prep_y - The X/Y coordinates of the projection point.
%

function [prep_x,prep_y] = findProjection(LineEnd1,LineEnd2,Point)
    x1=LineEnd1(1);
    y1=LineEnd1(2);
    x2=LineEnd2(1);
    y2=LineEnd2(2);
    x0=Point(1);
    y0=Point(2);
    kk = ((y2-y1) * (x0-x1) - (x2-x1) * (y0-y1)) / ((y2-y1)^2 + (x2-x1)^2);
    prep_x = x0 - kk * (y2-y1);
    prep_y = y0 + kk * (x2-x1);
end
%WARNING: this can return NaN
