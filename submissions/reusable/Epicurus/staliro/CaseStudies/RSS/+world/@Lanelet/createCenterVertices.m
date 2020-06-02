function createCenterVertices(obj)
% createCenterVertices - creates center vertices for the lanelet object
% (by arithmetic mean)
%
% Syntax:
%   createCenterVertices(obj)
%
% Inputs:
%   obj - Lanelet object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      05-Dezember-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

% initialise
numVertices = length(obj.leftBorderVertices);
obj.centerVertices = zeros(2,numVertices);

assert(numVertices==length(obj.rightBorderVertices));
for i = 1:numVertices
    % calculate a center vertex as the arithmetic mean between the opposite
    % vertex on the left and right border
    % (calculate x and y values seperately in order to minimize error)
    obj.centerVertices(1,i) = 0.5 * (obj.leftBorderVertices(1,i) + obj.rightBorderVertices(1,i));
    obj.centerVertices(2,i) = 0.5 * (obj.leftBorderVertices(2,i) + obj.rightBorderVertices(2,i));
end

end

%------------- END CODE --------------