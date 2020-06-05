function [laneStruct] = combineLaneletAndSuccessors(laneStruct, currentLanelet, k)
% combineLaneletAndSuccessors - builds a struct with lane properties of the
% current lanelet and all longitudinally adjacent lanelets
%
% Syntax:
%   [laneStruct] = combineLaneletAndSuccessors(laneStruct, currentLanelet, k)
%
% Inputs:
%   laneStruct - struct with lane properties
%   currentLanelet - current lanelet in the search along the lane
%   k - index of current row of lane struct
%
% Outputs:
%   laneStruct - struct with lane properties
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      05-Dezember-2016
% Last update:  25-August-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

if ~isempty(currentLanelet)
    
    % check for cyclic adjacencies
    if any(laneStruct(k).lanelets == currentLanelet)
        % cut the cyclic adjacency after one cycle
        % (note that in order to guarantee that no edge through the 
        % adjacency graph is missed, two cycles have to be passed:
        % sum(laneStruct(k).lanelets == currentLanelet) >= 2)
        warning(['The cyclic adjacency of Lanelet ' num2str(currentLanelet.id) ...
            ' has been cut after one cycle.'])
        return
    end
    
    % add the lane properties of the current lanelet to the struct
    laneStruct(k).leftBorderVertices = [laneStruct(k).leftBorderVertices, currentLanelet.leftBorderVertices(:,2:end)];
    laneStruct(k).rightBorderVertices = [laneStruct(k).rightBorderVertices, currentLanelet.rightBorderVertices(:,2:end)];
    laneStruct(k).lanelets(end+1) = currentLanelet;
    % choose the higher speed limit for the connection point
    % (over-approximation)
    laneStruct(k).speedLimit = [laneStruct(k).speedLimit(1:end-1), ...
        max(laneStruct(k).speedLimit(end),currentLanelet.speedLimit), ...
        currentLanelet.speedLimit * ones(1,size(currentLanelet.leftBorderVertices,2)-1)];
    laneStruct(k).centerVertices = [laneStruct(k).centerVertices, currentLanelet.centerVertices(:,2:end)];
    
    % for all successor lanelets, copy this lane in the next rows of the struct
    laneStruct((k+1):(k+numel(currentLanelet.successorLanelets)-1)) = laneStruct(k);
    
    % continue for all succesor lanelets
    for n = 1:numel(currentLanelet.successorLanelets)
        if length(laneStruct(k+n-1).lanelets) > length(laneStruct(k).lanelets) || ...
                ~isequal(laneStruct(k+n-1).lanelets(end), laneStruct(k).lanelets(length(laneStruct(k+n-1).lanelets)))
            % the recursive function combineLaneletAndSuccessors has
            % overwritten the current lanelet (at row k+n-1) due to a road fork
            % hence, create new row o with laneStruct(k).lanelets(1:currentLanelet)
            o = size(laneStruct,2) + 1;
            laneStruct(o).lanelets = laneStruct(k).lanelets(1);
            laneStruct(o).leftBorderVertices = laneStruct(k).lanelets(1).leftBorderVertices;
            laneStruct(o).rightBorderVertices = laneStruct(k).lanelets(1).rightBorderVertices;
            laneStruct(o).speedLimit = laneStruct(k).lanelets(1).speedLimit * ones(1,size(laneStruct(k).lanelets(1).leftBorderVertices,2));
            laneStruct(o).centerVertices = laneStruct(k).lanelets(1).centerVertices;
            p = 2;
            while ~isequal(laneStruct(o).lanelets(end), currentLanelet)
                laneStruct(o).lanelets(end+1) = laneStruct(k).lanelets(p);
                laneStruct(o).leftBorderVertices = [laneStruct(o).leftBorderVertices, laneStruct(k).lanelets(p).leftBorderVertices(:,2:end)];
                laneStruct(o).rightBorderVertices = [laneStruct(o).rightBorderVertices, laneStruct(k).lanelets(p).rightBorderVertices(:,2:end)];
                laneStruct(o).speedLimit = [laneStruct(o).speedLimit(1:end-1), ...
                    max(laneStruct(o).speedLimit(end),laneStruct(k).lanelets(p).speedLimit), ...
                    laneStruct(k).lanelets(p).speedLimit * ones(1,size(laneStruct(k).lanelets(p).leftBorderVertices,2)-1)];
                laneStruct(o).centerVertices = [laneStruct(o).centerVertices, laneStruct(k).lanelets(p).centerVertices(:,2:end)];
                p = p + 1;
            end
            % continue with row o
            laneStruct = world.Lane.combineLaneletAndSuccessors(laneStruct, currentLanelet.successorLanelets(n), o);
        else
            % continue with row k+n-1
            laneStruct = world.Lane.combineLaneletAndSuccessors(laneStruct, currentLanelet.successorLanelets(n), k+n-1);
        end
    end
end

end

%------------- END CODE --------------