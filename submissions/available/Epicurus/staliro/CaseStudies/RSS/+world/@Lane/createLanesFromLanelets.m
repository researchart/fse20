function [lanes] = createLanesFromLanelets(lanelets)
% createLanesFromLanelets - creates lanes from lanelets, i.e. stringing
% all longitudinally adjacent lanelets together
%
% Syntax:
%   [lanes] = createLanesFromLanelets(lanelets)
%
% Inputs:
%   lanelets - array of Lanelet objects
%
% Outputs:
%   lanes - array of Lane objects
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

% find the lanelets which have no predecessor, i.e. the begin of a lane
firstLanelets = findobj(lanelets, 'predecessorLanelets', world.Lanelet.empty());

% build a struct with lane properties of all longitudinally adjacent
% lanelets
%laneStruct(numel(firstLanelets)).leftBorderVertices = [];
for i = 1:numel(firstLanelets)
    
    % the size of laneStruct might have changed after the recursive function
    % combineLaneletAndSuccessors(). hence, set the new variable m to write
    % into the next empty row of the struct
    if i ~= 1
        m = size(laneStruct,2) + 1;
    else
        m = i;
    end
    
    % set the lanelet properties of the ith first lanelet into the struct
    laneStruct(m).leftBorderVertices = firstLanelets(i).leftBorderVertices;
    laneStruct(m).rightBorderVertices = firstLanelets(i).rightBorderVertices;
    laneStruct(m).lanelets = firstLanelets(i);
    laneStruct(m).speedLimit = firstLanelets(i).speedLimit * ones(1,size(firstLanelets(i).leftBorderVertices,2));
    laneStruct(m).centerVertices = firstLanelets(i).centerVertices;
    
    % copy the first properties in the next field of the laneStruct, if
    % there is a road fork
    laneStruct((m+1):(m+numel(firstLanelets(i).successorLanelets)-1)) = laneStruct(m);
    
    % recursively string current lanelet and all successors together
    for k = 1:numel(firstLanelets(i).successorLanelets)
        if length(laneStruct(m+k-1).lanelets) > length(laneStruct(m).lanelets) || ...
                ~isequal(laneStruct(m+k-1).lanelets(end), laneStruct(m).lanelets(length(laneStruct(m+k-1).lanelets)))
            % the recursive function combineLaneletAndSuccessors has
            % overwritten the current lanelet (at row m+k-1) due to a road fork
            % hence, create new row o with laneStruct(m).lanelets(1:firstLanelets(i))
            o = size(laneStruct,2) + 1;
            laneStruct(o).lanelets = laneStruct(m).lanelets(1);
            laneStruct(o).leftBorderVertices = laneStruct(m).lanelets(1).leftBorderVertices;
            laneStruct(o).rightBorderVertices = laneStruct(m).lanelets(1).rightBorderVertices;
            laneStruct(o).speedLimit = laneStruct(m).lanelets(1).speedLimit * ones(1,size(laneStruct(m).lanelets(1).leftBorderVertices,2));
            laneStruct(o).centerVertices = laneStruct(m).lanelets(1).centerVertices;
            
            % continue with row o
            laneStruct = world.Lane.combineLaneletAndSuccessors(laneStruct, firstLanelets(i).successorLanelets(k), o);
        else
            % continue with row m+k-1
            laneStruct = world.Lane.combineLaneletAndSuccessors(laneStruct, firstLanelets(i).successorLanelets(k), m+k-1);
        end
    end
end

% construct lane objects
numLanes = length(laneStruct);
lanes(numLanes) = world.Lane();
for i = 1:numLanes
    lanes(i) = world.Lane(laneStruct(i).leftBorderVertices, laneStruct(i).rightBorderVertices, ...
        laneStruct(i).lanelets , laneStruct(i).speedLimit, laneStruct(i).centerVertices);
end

% add left and right adjacent lane for all lanes
% (if all lanelets are adjacent with the same lane, the lane is adjacent
% to the lane)
for i = 1:numLanes
    % adjacentLeft
    if ~isempty(lanes(i).lanelets(1).adjacentLeft)
        % find the left lane
        leftLane = lanes.findLaneByLanelet(lanes(i).lanelets(1).adjacentLeft.lanelet);
        for j = 1:numel(leftLane)
            % check whether all lanelets of this ith lane have only left adjacent
            % lanelets which belong to the left lane
            flag_left = true;
            for k = 2:numel(lanes(i).lanelets)
                % check whether the lanelet has a left adjecent lanelet
                if isempty(lanes(i).lanelets(k).adjacentLeft)
                    flag_left = false;
                    break
                else
                    % check whether the adjacent lanelet of the jth lanelet
                    % belongs to the left lane
                    if ~ismember(leftLane(j), lanes.findLaneByLanelet(lanes(i).lanelets(k).adjacentLeft.lanelet))
                        flag_left = false;
                        break
                    end
                end
            end
            
            if flag_left
                % add leftLane to lane(i)
                lanes(i).addAdjacentLane('adjacentLeft', leftLane(j), lanes(i).lanelets(1).adjacentLeft.driving);
                break;
            end
        end
    end
    
    % adjacentRight
    if ~isempty(lanes(i).lanelets(1).adjacentRight)
        % find the right lane
        rightLane = lanes.findLaneByLanelet(lanes(i).lanelets(1).adjacentRight.lanelet);
        
        % check whether all lanelets of this ith lane have only right adjacent
        % lanelets which belong to the right lane
        for j = 1:numel(rightLane)
            flag_right = true;
            for k = 2:numel(lanes(i).lanelets)
                % check whether the lanelet has a right adjecent lanelet
                if isempty(lanes(i).lanelets(k).adjacentRight)
                    flag_right = false;
                    break
                else
                    % check whether the adjacent lanelet of the jth lanelet
                    % belongs to the left lane
                    if ~ismember(rightLane(j), lanes.findLaneByLanelet(lanes(i).lanelets(k).adjacentRight.lanelet))
                        flag_right = false;
                        break
                    end
                end
            end
            
            if flag_right
                % add rightLane to lane(i)
                lanes(i).addAdjacentLane('adjacentRight', rightLane(j), lanes(i).lanelets(1).adjacentRight.driving);
                break
            end
        end
    end
end

end

%------------- END CODE --------------