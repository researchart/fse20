function [triangleNode] = exportTriangle (doc,obj)
% exportTriangle - returns triangle information as a DOM tree node
%
% Syntax:
%   exportTriangle(doc,pointList)
%
% Inputs:
%   doc - DOM tree 
%   pointList - array containing all coordinates of points 
%               first row: x-values
%               second row: y-values
%
% Outputs:
%   triangleNode - DOM tree node containing all points of the triangle
%
% Other m-files required: exportPoint.m
% Subfunctions: none
% MAT-files required: none

% Author:       Lukas Willinger
% Written:      5 April 2017
% Last update:
%
% Last revision:---
%
%------------- BEGIN CODE --------------
    % create triangle node 
    triangleNode = doc.createElement('triangle');
    
    if isa(obj,'geometry.Triangle')
        pointList = obj.vertices;
    elseif isfloat(obj)
        pointList = obj;
    end
    % append all points to the triangle node
    for i = 1:numel(pointList)
        triangleNode.appendChild(output.exportPoint(doc,pointList(1,i),pointList(2,i)));
    end 
end