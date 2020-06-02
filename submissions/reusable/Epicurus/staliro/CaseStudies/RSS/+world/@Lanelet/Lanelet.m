classdef Lanelet < handle
    % Lanelet - repesents single piece of a road
    %
    % Syntax:
    %  object constructor: obj = Lanelet(varargin)
    %
    % Inputs:
    %   id - a unique id
    %   leftBorderVertices - vertices of left border
    %   rightBorderVertices - vertices of right border
    %   speedLimit - official speed limit of the Lanelet
    %   predecessorLanelets - previous Lanelet (multiple for a road fork)
    %   successorLanelets - longitudinally adjacent Lanlet (multiple for a road fork)
    %   adjacentLeft - left adjacent lanelet with driving tag
    %   adjacentRight - right adjacent lanelet with driving tag
    %
    % Outputs:
    %   obj - generated object
    %
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: none
    %
    % See also: Bender et al., 2014, Lanelets: Efficient Map Representation
    % for Autonomous Driving
    
    % Author:       Markus Koschi
    % Written:      02-Dezember-2016
    % Last update:  21-August-2017
    %
    % Last revision:---
    
    %------------- BEGIN CODE --------------
    
    properties (SetAccess = protected, GetAccess = public)
        id = []; % a unique id
        leftBorderVertices = []; % vertices of left border
        rightBorderVertices = []; % vertices of right border
        speedLimit = inf; % official speed limit of the Lanelet
        predecessorLanelets  = world.Lanelet.empty();  % previous Lanelet (multiple for a road fork)
        successorLanelets = world.Lanelet.empty(); % longitudinally adjacent Lanlet (multiple for a road fork)
        adjacentLeft = []; % left adjacent lanelet with driving tag
        adjacentRight = []; % right adjacent lanelet with driving tag
        centerVertices = []; % center vertives of a lane
    end
    
    methods
        % class constructor
        function obj = Lanelet(id, leftBorderVertices, rightBorderVertices, ...
                speedLimit, predecessorLanelets, successorLanelets, adjacentLeft, adjacentRight)
            
            if nargin >= 3
                % set id
                if isempty(id)
                    idCount = obj.addId();
                    obj.id = idCount;
                else
                    obj.addId(id);
                    obj.id = id;
                end
                
                % if the vertices of the left border are shared with a laterally
                % adjacent lanelet which has an opposite driving direction,
                % flip the vertices of the left border
                if norm(rightBorderVertices(:,1) - leftBorderVertices(:,1)) > ...
                        (norm(rightBorderVertices(:,1) - leftBorderVertices(:,end)) + 0.1)
                    leftBorderVertices = fliplr(leftBorderVertices);
                end
                
                % set border vertices
                if size(leftBorderVertices,2) == size(rightBorderVertices,2)
                    obj.leftBorderVertices = leftBorderVertices;
                    obj.rightBorderVertices = rightBorderVertices;
                else
                    [obj.leftBorderVertices, obj.rightBorderVertices] = ...
                        obj.alignBorderPoints(leftBorderVertices, rightBorderVertices);
                    % warning(['Lanelet %i had different number of vertices'...
                    %     ' on the left and right bound. We tried to adjust'...
                    %     ' the bounds accordingly.'] , obj.id);
                end
                    
                % set center vertices by calculating them from the border
                % vertices
                obj.createCenterVertices();
            end
            
            % set speed limit
            if nargin >= 4 && ~isempty(speedLimit)
                obj.speedLimit = speedLimit;
            end
            
            % set adjacent lanelets
            if nargin == 8
                if ~isempty(predecessorLanelets)
                    obj.predecessorLanelets = predecessorLanelets;
                end
                if ~isempty(successorLanelets)
                    obj.successorLanelets = successorLanelets;
                end
                if ~isempty(adjacentLeft)
                    obj.adjacentLeft = adjacentLeft;
                end
                if ~isempty(adjacentRight)
                    obj.adjacentRight = adjacentRight;
                end
            end
        end
        
        % set function
        function setId(obj, id)
            obj.id = id;
        end
        
        % methods in seperate files
        [lBorder, rBorder] = alignBorderPoints(obj, leftBorder, rightBorder)
        [pt_out, dist, idx] = closestPointOnLaneBorder(obj, point, rBorder)
        [pt_out, dist, idx] = closestPointOnLaneBorderInTrun(obj, point, rBorder)
        createCenterVertices(obj)
        [obj] = addAdjacentLanelet(obj, typeOfAdjacency, adjacentLanelet)
        [successors] = findAllSuccessorLanelets(obj, successors)
        [lanelets] = findLaneletByPosition(obj, position) 
        
        % visualization methods in seperate files        
        disp(obj)
        plot(obj)
    end
    
    % static methods
    methods(Static)
        function id = addId(init)
            % Creates unique ids
            persistent id_count;
            if nargin==1
                assert(isnumeric(init) && round(init) == init && numel(init) == 1);
                id_count = int32(init);
            end
            if (numel(id_count)==0)
                id_count = 0;
            end
            id_count = id_count + 1;
            id = id_count;
        end
        
        % static methods in seperate files
        % create lanelets from xml/osm data
        lanelets = createLaneletsFromXML(lanelets_XML, refPos, refOrientation)
        lanelets = createLaneletsFromOSM(lanelets_OSM, adjacencyGraph_OSM, refPos, refOrientation)
        
        % create the adjacency graph
        createAdjacencyGraph(lanelets)
    end
end

%------------- END CODE --------------