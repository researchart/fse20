function [shapeNode] = exportShape (varargin)
% exportShape - returns shape information as a DOM tree node
%
% Syntax:
%   exportShape(varargin)
%   exportShape(doc,shapeList)
%   exportShape(doc,shapeList,orientation,xCenter,yCenter)
%
% Inputs:
%   doc - DOM tree 
%   shapeList - array containing all shapes 
%   xCenter - X-coordinate of center if not equal 0 
%   yCenter - Y-coordinate of center if not equal 0
%
% Outputs:
%   shapeNode - DOM tree node containing all information about the
%   shape
%   
%
% Other m-files required: exportRectangle.m, exportCircle.m,
%                           exportPolygon.m


% Author:       Lukas Willinger
% Written:      10 April 2017
% Last update:
%
% Last revision:---
%
%------------- BEGIN CODE --------------       

    doc = varargin {1};
    shapeList = varargin{2};

    switch nargin
        case 2 % Center is at (0,0)
            orientation = 0;
            xCenter = 0;
            yCenter = 0;
        case 5 % Specified center location
            orientation = varargin{3};
            xCenter = varargin{4};
            yCenter = varargin{5};
        otherwise
            error('wrong input parameters for exportShape');
    end
    
    % create shape node
    shapeNode = doc.createElement('shape');
    
    % create node for each shape in shape list 
    for i = 1:numel(shapeList)
        % switch between different shapes
        if isa(shapeList(i),'geometry.Rectangle')
            shapeNode.appendChild(output.exportRectangle(doc,shapeList(i).length,...
                shapeList(i).width,orientation,xCenter,yCenter));
        elseif isa(shapeList(i),'geometry.Circle')
            shapeNode.appendChild(output.exportCircle(doc,shapeList(i).radius,xCenter,yCenter));
        elseif isa(shapeList(i),'geometry.Polygon')
            shapeNode.appendChild(output.exportPolygon(doc,shapeList(i).vertices));
        else
            error('Shape not supported for export.');
        end    
    end
end