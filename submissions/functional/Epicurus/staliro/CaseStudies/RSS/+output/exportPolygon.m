function [polygonNode] = exportPolygon (doc,pointList)
% exportPolygon - returns polygon information as a DOM tree node
%
% Syntax:
%   exportPolygon(doc,pointList)
%
% Inputs:
%   doc - DOM tree 
%   pointList - array containing all coordinates of points 
%               first row: x-values
%               second row: y-values
%
% Outputs:
%   polygonNode - DOM tree node containing all points of the polygon
%
% Other m-files required: exportPoint.m

% Author:       Lukas Willinger
% Written:      5 April 2017
% Last update:
%
% Last revision:---
%
%------------- BEGIN CODE --------------
    % create polygon node 
    polygonNode = doc.createElement('polygon');
    % append all points to the polygon node
    for i = 1:size(pointList,2)
        polygonNode.appendChild(output.exportPoint(doc,pointList(1,i),pointList(2,i)));
    end
end
%------------- END CODE ------------------