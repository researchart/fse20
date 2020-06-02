function [lanes] = findLaneByPosition(obj, position)
% findLaneByPosition - finds the lane(s) which contain the given position
%
% Syntax:
%   lanes = findLaneByPosition(obj, position)
%
% Inputs:
%   obj - Lane object(s)
%   position - position (e.g. of an obstacle)
%
% Outputs:
%   lanes - Lane object(s)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      23-December-2016
% Last update:  25-August-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

lanes = world.Lane.empty();

for i = 1:numel(obj)
    % call inpolygon to check whether the position is in or on lane(i)
    xv = [obj(i).leftBorder.vertices(1,:), fliplr(obj(i).rightBorder.vertices(1,:)), obj(i).leftBorder.vertices(1,1)];
    yv = [obj(i).leftBorder.vertices(2,:), fliplr(obj(i).rightBorder.vertices(2,:)), obj(i).leftBorder.vertices(2,1)];
    [in, on] = inpolygon(position(1,:), position(2,:), xv, yv);
    if in || on
        lanes(end+1) = obj(i);
    end
end

end

%------------- END CODE --------------