function rectangleNode = exportRectangle(varargin)
% exportRectangle - returns rectangle information as a DOM tree node
%
% Syntax:
%   exportRectangle(doc,rectangle)  %geometry.Rectangle
%   exportRectangle(doc,length,width)
%   exportRectangle(doc,length,width,orientation)
%   exportRectangle(doc,length,width,orientation,xOffset,yOffset)
%
% Inputs:
%   doc - DOM tree 
%   length - length of object
%   width - width of object
%   orientation - orientation of object
%   xOffset - Offset of geometric center point in x-direction
%   yOffset - Offset of geometric center point in y-direction
%
% Outputs:
%   rectangleNode - DOM tree node containing all information about the
%   rectangle
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
    doc = varargin{1};
    if nargin == 2 && isa(varargin{2},'geometry.Rectangle')
        rect = varargin{2};
        length = rect.length;
        width = rect.width;
        orientation = rect.orientation;
        xOffset = rect.position(1);
        yOffset = rect.position(2);
    elseif nargin == 3
        length = varargin{2};
        width = varargin{3};
        orientation = 0;
        xOffset = 0;
        yOffset = 0;
    elseif nargin == 4
        length = varargin{2};
        width = varargin{3};
        orientation = varargin{4};
        xOffset = 0;
        yOffset = 0;
    elseif nargin == 6 
        length = varargin{2};
        width = varargin{3};
        orientation = varargin{4};
        xOffset = varargin{5};
        yOffset = varargin{6};
    else
        error('wrong number of input argument for exportRectangle');
    end
    
    
    rectangleNode = doc.createElement('rectangle');
    
    len = doc.createElement('length');
    len.appendChild(doc.createTextNode(num2str(length)));
    rectangleNode.appendChild(len);
    
    wid = doc.createElement('width');
    wid.appendChild(doc.createTextNode(num2str(width)));
    rectangleNode.appendChild(wid);

    if orientation
        or = doc.createElement('orientation');
        or.appendChild(doc.createTextNode(num2str(orientation)));
        rectangleNode.appendChild(or);
    end
    
    if xOffset && yOffset
        center = doc.createElement('center');
        rectangleNode.appendChild(center);
        
        x = doc.createElement('x');
        x.appendChild(doc.createTextNode(num2str(xOffset)));
        center.appendChild(x);
        
        y = doc.createElement('y');
        y.appendChild(doc.createTextNode(num2str(yOffset)));
        center.appendChild(y);
    end
end


%------------- END CODE ------------------