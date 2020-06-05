function [lane] = findLaneByLanelet(obj, lanelet)
% findLaneByLanelet - search through all obj to find the lane(s) which
% contain(s) the lanelet
%
% Syntax:
%   [lanes] = findLaneByLanelet(obj, lanelet)
%
% Inputs:
%   obj - Lane object(s)
%   lanelet - Lanelet object
%
% Outputs:
%   lane - Lane object(s) which contain(s) the lanelet
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      07-January-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

% initalise empty lane
lane = world.Lane.empty();

% search through all lane objects
for i = 1:numel(obj)
    % check whether the lanelet array of the ith lane contains the lanelet
    if any(find(obj(i).lanelets == lanelet))
        lane(end+1) = obj(i);
    end
end

% note that find cannot search through a property array. thus, this does
% not work: lane = findobj(lanes, 'lanelets', lanelet)

end

%------------- END CODE --------------