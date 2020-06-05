function exportCircle (varargin)
% exportCircle - returns cicle information as a DOM tree node
%
% Syntax:
%   exportCircle(doc,radius,xOffset,yOffset)
%
% Inputs:
%   doc - DOM tree 
%   radius - radius of circle
%   xOffset - Offset of geometric center point in x-direction
%   yOffset - Offset of geometric center point in y-direction
%
% Outputs:
%   circleNode - DOM tree node containing all information about the
%   circle
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Lukas Willinger
% Written:      5 April 2017
% Last update:
%
% Last revision:---
%
%------------- BEGIN CODE --------------
    if nargin == 2 && isa(varargin{2},'geometry.Circle')
        radius = varargin{2}.radius;
        % ToDo
        % implement circle
        warning ('Circle export is not implemented, due to missing class implementation');
    elseif nargin == 2
        doc = varargin{1};
        radius = varargin{2};
        xOffset = 0;
        yOffset = 0;
    elseif nargin == 4
        doc = varargin{1};
        radius = varargin{2};
        xOffset = varargin{3};
        yOffset = varargin{4};
    else
        error('wrong number of input arguments for circle');
    end
    
    circleNode = doc.createElement('circle');
    rad = doc.createElement('radius');
    rad.appendChild(doc.createTextNode(num2str(radius)));
    
    if xOffset && yOffset
        center = doc.createElement('center');
        circleNode.appendChild(center);
        
        x = doc.createElement('x');
        x.appendChild(doc.createTextNode(num2str(xOffset)));
        center.appendChild(x);
        
        y = doc.createElement('y');
        y.appendChild(doc.createTextNode(num2str(yOffset)));
        center.appendChild(y);
    end
    doc.getDocumentElement.appendChild(circleNode);
end 


%------------- END CODE ---------------