function [obj] = addAdjacentLane(obj, typeOfAdjacency, adjacentLane, driving)
% addAdjacentLane - adds the input lane as an adjacent property to the object,
% i.e. laterally adjacent (left or right)
% (A lane can have only one left and one right adjacent lane by definition.)
%
% Syntax:
%   [obj] = addAdjacentLane(obj, adjacentLane, typeOfAdjacency)
%
% Inputs:
%   obj - Lane object
%   typeOfAdjacency - string (adjacentLeft or adjacentRight)
%   adjacentLane - Lane which is adjacent to the object
%   driving - with driving tag
%
% Outputs:
%   obj - Lane object
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      02-Dezember-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

switch typeOfAdjacency
    case 'adjacentLeft'
        if isa(adjacentLane, 'world.Lane')
            obj.adjacentLeft.lane = adjacentLane;
            if ischar(driving)
                obj.adjacentLeft.driving = driving;
            end
        end
    case 'adjacentRight'
        if isa(adjacentLane, 'world.Lane')
            obj.adjacentRight.lane = adjacentLane;
            if ischar(driving)
                obj.adjacentRight.driving = driving;
            end
        end
end

end

%------------- END CODE --------------