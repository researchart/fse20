function [obj] = addAdjacentLanelet(obj, typeOfAdjacency, adjacentLanelet)
% addAdjacentLanelet - adds the input lanelet as an adjacent property to the object,
% i.e. either longitudinally (predecessor or successor) or laterally
% adjacent (left or right)
% (A lanelet can have only one left and one right adjacent lanelet by
% definition.)
%
% Syntax:
%   [obj] = addAdjacentLanelet(obj, adjacentLanelet, typeOfAdjacency)
%
% Inputs:
%   obj - Lanelet object
%   typeOfAdjacency - string
%   adjacentLanelet - Lanelet which is adjacent to the object
%                   if left/right adjecent, with driving tag
%
% Outputs:
%   obj - Lanelet object
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
    case 'predecessor'
        if isa(adjacentLanelet, 'world.Lanelet')
            obj.predecessorLanelets(end+1) = adjacentLanelet;
        end
    case 'successor'
        if isa(adjacentLanelet, 'world.Lanelet')
            obj.successorLanelets(end+1) = adjacentLanelet;
        end
    case 'adjacentLeft'
        if isa(adjacentLanelet{1}, 'world.Lanelet')
            obj.adjacentLeft.lanelet = adjacentLanelet{1};
            obj.adjacentLeft.driving = adjacentLanelet{2};
        end
    case 'adjacentRight'
        if isa(adjacentLanelet{1}, 'world.Lanelet')
            obj.adjacentRight.lanelet = adjacentLanelet{1};
            obj.adjacentRight.driving = adjacentLanelet{2};
        end        
end

end

%------------- END CODE --------------