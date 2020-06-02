function [vertices] = rotateAndTranslateVertices(vertices, refPosition, refOrientation)
% rotateAndTranslateVertices - rotate and translate the vertices from
% the special relative coordinates to the reference position and orientation 
% (transfer local coordinates to global coordinates)
%
% Syntax:
%   [vertices] = rotateAndTranslateVertices(vertices, refPosition, refOrientation)
%
% Inputs:
%   vertices - 2D row of vertices representing a polygon in special 
%               relative position and orientation
%   refPosition - reference position of the object
%   refOrientation - reference orientation of the object
%
% Outputs:
%   vertices - polygon in reference position and orientation
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ---

% Author:       Markus Koschi
% Written:      15-September-2016
% Last update:  14-October-2016
%
% Last revision:---

%------------- BEGIN CODE --------------

% rotate
cosinus = cos(refOrientation);
sinus = sin(refOrientation);
vertices = [cosinus * vertices(1,:) - sinus * vertices(2,:); ...
    sinus * vertices(1,:) + cosinus * vertices(2,:)];

% translate
vertices(1,:) = vertices(1,:) + refPosition(1);
vertices(2,:) = vertices(2,:) + refPosition(2);

end

%------------- END CODE --------------