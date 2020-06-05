function [lanelets] = findLaneletByPosition(obj, position)
% findLaneByPosition - find the lanelet by the ostacle's position
%
% Syntax:
%   lanes = findLaneByPosition(obj, position)
%
% Inputs:
%   obj - Lanelet object(s)
%   position - position (e.g. of an obstacle)
%
% Outputs:
%   lanelets - Lanelet object(s)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      23-December-2016
% Last update:  06-September-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

lanelets = world.Lanelet.empty();

for i = 1:numel(obj)
    % call inpolygon to check whether the position is in or on lanelet(i)
    xv = [obj(i).leftBorderVertices(1,:), fliplr(obj(i).rightBorderVertices(1,:)), obj(i).leftBorderVertices(1,1)];
    yv = [obj(i).leftBorderVertices(2,:), fliplr(obj(i).rightBorderVertices(2,:)), obj(i).leftBorderVertices(2,1)];
    [in, on] = inpolygon(position(1,:), position(2,:), xv, yv);
    if in || on
        lanelets(end+1) = obj(i);
    end
end

end

%------------- END CODE --------------