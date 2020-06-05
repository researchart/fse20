function [ goalRegionRectangle ] = createGRRFromPosition( lanes, position, width, ratio, inLane_idx )
%createGRRFromPosition - This function creates a rectangle as position for
%       goalregion with width as percentage from lane width. Ratio as ratio
%       between width and length of rectangle: >1 length bigger than
%       width, <1 length smaller than width
%   Syntax:
%   [ goalRegionRectangle ] = createGRRFromPosition( position, width, ratio )
%
%   Inputs:
%       position (2x1 array)
%       width (0-1 scalar)
%       ratio (scalar)
%
%   Outputs:
%       goalRegionRectangle - rectangle object
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Author:       Lukas Braunstorfer
% Written:      20-April-2017
% Last update:  16-August-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

if nargin<2 || nargin>5
    error('wrong number of input arguments');
elseif nargin == 2
    width = 0.5;
    ratio = 1.3;
elseif nargin == 3
    ratio = 1.3;
end

inLane = lanes.findLaneByPosition(position);
numClosestVertice = dsearchn(inLane(inLane_idx).center.vertices',position');
closestVertice = [inLane(inLane_idx).center.vertices(1,numClosestVertice);...
    inLane(inLane_idx).center.vertices(2,numClosestVertice)];

if numClosestVertice>length(inLane(inLane_idx).center.vertices)
    nextVertice = [inLane(inLane_idx).center.vertices(1,numClosestVertice-1);...
        inLane(inLane_idx).center.vertices(2,numClosestVertice-1)];
    orientation = atan2(closestVertice(2)-nextVertice(2),closestVertice(1)-nextVertice(1));
else
    nextVertice = [inLane(inLane_idx).center.vertices(1,numClosestVertice+1);...
        inLane(inLane_idx).center.vertices(2,numClosestVertice+1)];
    orientation = atan2(nextVertice(2)-closestVertice(2),nextVertice(1)-closestVertice(1));
end

laneWidth = 2*(sqrt((closestVertice(1)-inLane(inLane_idx).leftBorder.vertices(1,numClosestVertice))^2+...
    (closestVertice(2)-inLane(inLane_idx).leftBorder.vertices(2,numClosestVertice))^2));

widthRec = width*laneWidth;
lengthRec = ratio*width*laneWidth;

%goalRegionRectangle = geometry.Rectangle(lengthRec,widthRec,closestVertice,orientation);
goalRegionRectangle = geometry.Rectangle(lengthRec,widthRec,position,orientation);

end

