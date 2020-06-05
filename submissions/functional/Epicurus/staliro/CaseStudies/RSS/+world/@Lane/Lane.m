classdef Lane < handle
    % Lane - class for representing a drivable union of road segments
    % (all longidinally adjacent lanelets assembled to one lane object)
    %
    % Syntax:
    %  object constructor: obj = Lane(varargin)
    %
    % Inputs:
    %   leftBorderVertices - vertices of left border
    %   rightBorderVertices - vertices of right border
    %   lanelets - Lanelet objects wich assemble to the Lane object
    %   speedLimit - official speed limit of the Lanelet
    %   centerVertices - vertices of the center positions of the lane
    %   adjacentLeft - left adjacent lane with driving tag
    %   adjacentRight - right adjacent lane with driving tag
    %
    % Outputs:
    %   obj - generated object
    %
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: none
    %
    % See also: Althoff and Magdici, 2016, Set-Based Prediction of Traffic Participants on
    % Arbitrary Road Networks, III. A. Road Network Representation
    
    % Author:       Markus Koschi
    % Written:      02-November-2016
    % Last update:  02-Dezember-2016
    %
    % Last revision:---
    
    %------------- BEGIN CODE --------------
    
    properties (SetAccess = protected, GetAccess = public)
        id = []; % a unique id
        leftBorder = [];
        %         leftBorder.vertices = []; % vertices of left lane border
        %         leftBorder.distances = []; % distance of each vertice to previous vertice of left border
        %         leftBorder.curvatures = []; % curvature of the left border at each vertice
        rightBorder = [];
        %         rightBorder.vertices = []; % vertices of right lane border
        %         rightBorder.distances = []; % distance of each vertice to previous vertice of right border
        %         rightBorder.curvatures = []; % curvature of the right border of each vertice
        lanelets = world.Lanelet.empty(); % sortet list of lanelets which assemble to the lane object
        speedLimit = inf; % official speed limit of the lane in m/s at each vertice
        center = [];
        %       center.vertices = []; % vertices of the center positions of the lane
        %       center.xi = []; % path length at each center vertice
        shortestPath = []; % shortest possible path through the lane
        %       shortestPath.xi
        %       shortestPath.indexBorder
        %       shortestPath.side
        adjacentLeft = []; % left adjacent lane with driving tag
        %       adjacentLeft.lane = world.Lane.empty();
        %       adjacentLeft.driving = 'same' or 'different'
        adjacentRight = []; % right adjacent lane with driving tag
        %       adjacentRight.lane = world.Lane.empty();
        %       adjacentRight.driving = 'same' or 'different'
        
        %obb = []; % oriented bounding box including the left and right lane border
    end
    
    methods
        % class constructor
        function obj = Lane(leftBorderVertices, rightBorderVertices, ...
                lanelets, speedLimit, centerVertices, adjacentLeft, adjacentRight)
            
            % unique ids
            persistent laneIdCount;
            if isempty(laneIdCount)
                laneIdCount = 0;
            end
            
            if nargin > 0
                % set id
                laneIdCount = laneIdCount + 1;
                obj.id = laneIdCount;
                
                if nargin >= 2
                    % set border vertices
                    obj.leftBorder.vertices = leftBorderVertices;
                    obj.rightBorder.vertices = rightBorderVertices;
                    
                    % calcuate the point-wise distance of the points of the borders
                    % (not the path length distance xi)
                    obj.leftBorder.distances = geometry.calcPathDistances(obj.leftBorder.vertices(1,:), obj.leftBorder.vertices(2,:));
                    obj.rightBorder.distances = geometry.calcPathDistances(obj.rightBorder.vertices(1,:), obj.rightBorder.vertices(2,:));
                    
                    % calculate the signed curvature for each border
                    obj.leftBorder.curvatures = geometry.calcCurvature(obj.leftBorder.vertices(1,:), obj.leftBorder.vertices(2,:));
                    obj.rightBorder.curvatures = geometry.calcCurvature(obj.rightBorder.vertices(1,:), obj.rightBorder.vertices(2,:));
                    
                    % find the shortest path through the lane network (Definition 8)
                    obj.shortestPath = world.findShortestPath(obj.leftBorder, obj.rightBorder);
                end
                
                % set the lanelets which assemble to the lane object
                if nargin >=3 && isa(lanelets, 'world.Lanelet')
                    obj.lanelets = lanelets;
                end
                
                % set the speed limit (an array with a value at each border vertex)
                if nargin >= 4
                    if (length(speedLimit) == size(obj.leftBorder.vertices,2))
                        obj.speedLimit = speedLimit;
                    else
                        obj.speedLimit = speedLimit(1) * ones(1,size(obj.leftBorder.vertices,2));
                    end
                end
                
                % set center vertices
                if nargin >= 5
                    obj.center.vertices = centerVertices;
                    
                    % % calculate path length
                    % obj.center.xi = geometry.calcPathVariable(obj.centerVertices(1,:), obj.centerVertices(2,:));
                end
                
                % set left and right adjacent lanes
                if nargin == 7
                    if ~isempty(adjacentLeft)
                        obj.adjacentLeft = adjacentLeft;
                    end
                    if ~isempty(adjacentRight)
                        obj.adjacentRight = adjacentRight;
                    end
                end
            end
        end
        
        % find handle objects within H
        %Hmatch = findobj(H,property,value,...,property,value)
        
        % methods in seperate files:
        [lanes] = findLaneByPosition(obj, position)
        [lanes] = findLaneByLanelet(obj, lanelet)
        [reachableLanes] = findReachableLanes(varargin)
        
        % visualization methods
        disp(obj)
        plot(obj)
    end
    
    % static methods in seperate files
    methods (Static)
        [lanes] = createLanesFromLanelets(lanelets)
        [laneStruct] = combineLaneletAndSuccessors(laneStruct, currentLanelet, k)
        [lanes] = createFromOSM(LaneMatrix, rowID)
        [lane] = flipLane(lane)

    end
    
end
%------------- END CODE --------------