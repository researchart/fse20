function [lanelets] = createLaneletsFromXML(lanelets_XML, refPos, refOrientation)
% createLaneletsFromXML - creates all Lanelet objects from the XML input
%
% Syntax:
%   [lanelets] = createLaneletsFromXML(lanelets_XML, adjacencyGraph_XML)
%
% Inputs:
%   lanelets_XML - structure of lanelets
%           .id
%           .left
%           .right
%           .speedLimit
%           .predecessor
%           .successor
%           .adjacentLeft
%                       .id
%                       .drivingDir
%           .adjacentRight
%                       .id
%                       .drivingDir
%
% Outputs:
%   lanelets - array of Lanelet objects
%
% Other m-files required: createAdjacencyGraph()
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      02-Dezember-2016
% Last update:  25-August-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

if nargin == 1
    refPos = [0,0];
    refOrientation = 0;
end

% construct lanelet objects
numLanelets = length(lanelets_XML);
lanelets(1,numLanelets) = world.Lanelet();
for i = 1:numLanelets
    if isempty(lanelets_XML(i).id) || isempty(lanelets_XML(i).leftBound) ...
            || isempty(lanelets_XML(i).rightBound)
        warning('A lanelet was not created due to missing input arguments.')
        continue;
    end
    
    leftBound = geometry.translateAndRotateVertices(lanelets_XML(i).leftBound,refPos,refOrientation);
    rightBound = geometry.translateAndRotateVertices(lanelets_XML(i).rightBound,refPos,refOrientation);
    if isfield(lanelets_XML(i), 'speedLimit') && ~isempty(lanelets_XML(i).speedLimit)
        args = {lanelets_XML(i).id, lanelets_XML(i).leftBound, ...
            lanelets_XML(i).rightBound, lanelets_XML(i).speedLimit};
    else
        args = {lanelets_XML(i).id, leftBound, rightBound};
    end
    % create lanelet object
    lanelets(i) = world.Lanelet(args{:});
end

% add adjacent lanelets
for i = 1:numLanelets
    if isempty(lanelets_XML(i).id) || isempty(lanelets_XML(i).leftBound) ...
            || isempty(lanelets_XML(i).rightBound)
        continue;
    end
    
    % add predecessors
    if isfield(lanelets_XML(i), 'predecessor') && ~isempty(lanelets_XML(i).predecessor)
        for j = 1:length(lanelets_XML(i).predecessor)
            index = [lanelets.id]' == lanelets_XML(i).predecessor(j);
            lanelets(i).addAdjacentLanelet('predecessor', lanelets(index));
        end
    end
    
    % add successors
    if isfield(lanelets_XML(i), 'successor') && ~isempty(lanelets_XML(i).successor)
        for j = 1:length(lanelets_XML(i).successor)
            index = [lanelets.id]' == lanelets_XML(i).successor(j);
            lanelets(i).addAdjacentLanelet('successor', lanelets(index));
        end
    end
    
    % add adjacent left
    if isfield(lanelets_XML(i), 'adjacentLeft') && ~isempty(lanelets_XML(i).adjacentLeft)
        index = [lanelets.id]' == lanelets_XML(i).adjacentLeft.id;
        lanelets(i).addAdjacentLanelet('adjacentLeft', {lanelets(index), lanelets_XML(i).adjacentLeft.drivingDir});
    end
    
    % add adjacent right
    if isfield(lanelets_XML(i), 'adjacentRight') && ~isempty(lanelets_XML(i).adjacentRight)
        index = [lanelets.id]' == lanelets_XML(i).adjacentRight.id;
        lanelets(i).addAdjacentLanelet('adjacentRight', {lanelets(index), lanelets_XML(i).adjacentRight.drivingDir});
    end
end

end

%------------- END CODE --------------