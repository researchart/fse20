function pointNode = exportPoint(doc,xValue,yValue)
% exportPoint - returns point information as a DOM tree node
%
% Syntax:
%   exportPoint(doc,xValue,yValue)
%
% Inputs:
%   doc - DOM tree 
%   xValue - x-Value of the point
%   yValue - y-Value of the point
%
% Outputs:
%   pointNode - DOM tree node containing x and y coordinate Values of the
%   point
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
    % create point node
    pointNode = doc.createElement('point');    
    % create x and y node and append coordinate values
    x = doc.createElement('x');
    x.appendChild(doc.createTextNode(num2str(xValue)));
    pointNode.appendChild(x);

    y = doc.createElement('y');
    y.appendChild(doc.createTextNode(num2str(yValue)));
    pointNode.appendChild(y);
    
end
