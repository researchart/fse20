function [lanelets] = createLaneletsFromOSM(lanelets_OSM, adjacencyGraph_OSM, refPos, refOrientation)
% createLaneletsFromSOM - creates all Lanelet objects from the OSM input
%
% Syntax:
%   [lanelets] = createLaneletsFromOSM(lanelets_OSM, adjacencyGraph_OSM, refPos, refOrientation)
%
% Inputs:
%   lanelets_OSM - structure of lanelets
%           .id
%           .left
%           .right
%           .speedLimit
%           .predecessor
%           .successor
%           .adjacentLeft
%                       .lanelet
%                       .driving
%           .adjacentRight
%                       .lanelet
%                       .driving
%   adjacencyGraph_OSM - boolean whether adjacency is provided
%   refPos - translation vector of map should be translated
%   refOrientation - rotation of scenario 
%
% Outputs:
%   lanelets - array of Lanelet objects
%
% Other m-files required: createAdjacencyGraph()
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      02-Dezember-2016
% Last update:  21-August-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

if nargin == 2 
    refPos = [0,0];
    refOrientation = 0;
end

% construct lanelet objects
numLanelets = length(lanelets_OSM);
lanelets(1,numLanelets) = world.Lanelet();
for i = 1:numLanelets
        if isfield(lanelets_OSM(i), 'speedLimit') && ~isempty(lanelets_OSM(i).speedLimit)
            args = {lanelets_OSM(i).id, ...
                geometry.translateAndRotateVertices([lanelets_OSM(i).left.nodes.x; lanelets_OSM(i).left.nodes.y],refPos,refOrientation),...
                geometry.translateAndRotateVertices([lanelets_OSM(i).right.nodes.x; lanelets_OSM(i).right.nodes.y],refPos,refOrientation), ...
                lanelets_OSM(i).speedLimit};
        else
            args = {lanelets_OSM(i).id, ...
                geometry.translateAndRotateVertices([lanelets_OSM(i).left.nodes.x; lanelets_OSM(i).left.nodes.y],refPos,refOrientation), ...
                geometry.translateAndRotateVertices([lanelets_OSM(i).right.nodes.x; lanelets_OSM(i).right.nodes.y],refPos,refOrientation)};
        end
    lanelets(i) = world.Lanelet(args{:});
end

% add adjacent lanelets
if adjacencyGraph_OSM
    for i = 1:numLanelets
        % add predecessors
        if isfield(lanelets_OSM(i), 'predecessor') && ~isempty(lanelets_OSM(i).predecessor)
            for j = 1:length(lanelets_OSM(i).predecessor)
                index = [lanelets.id]' == lanelets_OSM(i).predecessor(j).id;
                lanelets(i).addAdjacentLanelet('predecessor', lanelets(index));
            end
        end
        
        % add successors
        if isfield(lanelets_OSM(i), 'successor') && ~isempty(lanelets_OSM(i).successor)
            for j = 1:length(lanelets_OSM(i).successor)
                index = [lanelets.id]' == lanelets_OSM(i).successor(j).id;
                lanelets(i).addAdjacentLanelet('successor', lanelets(index));
            end
        end
        
        % add adjacent left
        if isfield(lanelets_OSM(i), 'adjacentLeft') && ~isempty(lanelets_OSM(i).adjacentLeft)
            for j = 1:length(lanelets_OSM(i).adjacentLeft)
                index = [lanelets.id]' == lanelets_OSM(i).adjacentLeft(j).lanelet.id;
                lanelets(i).addAdjacentLanelet('adjacentLeft', {lanelets(index), lanelets_OSM(i).adjacentLeft(j).driving});
            end
        end
        
        % add adjacent right
        if isfield(lanelets_OSM(i), 'adjacentRight') && ~isempty(lanelets_OSM(i).adjacentRight)
            for j = 1:length(lanelets_OSM(i).adjacentRight)
                index = [lanelets.id]' == lanelets_OSM(i).adjacentRight(j).lanelet.id;
                lanelets(i).addAdjacentLanelet('adjacentRight', {lanelets(index), lanelets_OSM(i).adjacentRight(j).driving});
            end
        end
    end
elseif numLanelets > 1
    % no adjacency graph exists, so create it
    world.Lanelet.createAdjacencyGraph(lanelets);
end

end

%------------- END CODE --------------