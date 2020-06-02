function [vertices] = translateAndRotateVertices(vertices, refPosition, refOrientation)
% rotateAndTranslateVertices - translate and rotate the vertices from
% the reference position and orientation to the special relative coordinates
% (transfer global coordinates to local coordinates)
%
% Syntax:
%   [vertices] = translateAndRotateVertices(vertices, refPosition, refOrientation)
%
% Inputs:
%   vertices - 2D row of vertices 
%   refPosition - reference position
%   refOrientation - reference orientation
%
% Outputs:
%   vertices - vertices in local position and orientation
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ---

% Author:       Lukas Willinger
% Written:      18-April 2017
% Last update:  
%
% Last revision:---

%------------- BEGIN CODE --------------

% translate
vertices(1,:) = vertices(1,:) + refPosition(1);
vertices(2,:) = vertices(2,:) + refPosition(2);

% rotate
cosinus = cos(refOrientation);
sinus = sin(refOrientation);
vertices = [cosinus * vertices(1,:) - sinus * vertices(2,:); ...
    sinus * vertices(1,:) + cosinus * vertices(2,:)];

end
%------------- END CODE --------------