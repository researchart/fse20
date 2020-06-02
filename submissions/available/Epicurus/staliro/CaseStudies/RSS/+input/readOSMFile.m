function [lanelets, obstacles, egoVehicles, adjacencyGraph] = readOSMFile(filename)
%readXmlFile - reads a xml file which contains lane borders and obstacles
% with their trajectories
% (xml elements: nodes, ways, relations, obstacles)
%
% Syntax:
%   [lanelets, obstacles, egoVehicles, adjacencyGraph] = readXMLFile(filename)
%
% Inputs:
%   filename - full path- and filename to the XML file
%
% Outputs:
%   lanelets - struct of lanelets with lanelet properties
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
%   obstacles - struct of obstacle with obstacle properties
%           .id
%           .trajectory
%                       .id
%                       .nodes (fields id, x, y, orientation, velocity, acceleration, time)
%           .role
%           .type
%   egoVehicles - struct of ego vehicles with obstacle properties (as above)
%   adjacencyGraph - boolean: 1 if adjacent lanelets are specified, 0 if not
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: XML format specification

% Author:       Markus Koschi
% Written:      08-September-2016
% Last update:  08-February-2017 (polygon)
%
% Last revision:---

%------------- BEGIN CODE --------------

% read the XML file
xdoc = xmlread(filename);

% check if lanelets are specified with adjacency graph
osm = xdoc.getElementsByTagName('osm');
if strcmp(osm.item(0).getAttribute('adjacencyGraph'), 'true')
    adjacencyGraph = 1;
else
    adjacencyGraph = 0;
end

% extract all nodes
nodeList = xdoc.getElementsByTagName('node');
nodes(nodeList.getLength()).id = 0;
goalRegionNodesCounter = 1;
for i = 0:(nodeList.getLength()-1)
    % extract the ID of the node
    nodes(i+1).id = str2double(nodeList.item(i).getAttribute('id'));
    
    % extract the position coordinates
    lat = str2double(nodeList.item(i).getAttribute('lat'));
    lon = str2double(nodeList.item(i).getAttribute('lon'));
    
    % convert from lat and lon in degrees to UTM format in meters)
    [nodes(i+1).x, nodes(i+1).y, ~] = geometry.deg2utm(lat', lon');
        
    % extract all tags, which are specified for trajectory nodes
    % (orientation, velocity, acceleration, and time stamp)
    nodeTagList = nodeList.item(i).getElementsByTagName('tag');
    for j = 0:(nodeTagList.getLength()-1);
        if ~isempty(nodeTagList.item(j))
            switch char(nodeTagList.item(j).getAttribute('k'))
                case 'orientation'
                    nodes(i+1).orientation = str2double(nodeTagList.item(j).getAttribute('v'));
                case 'velocity'
                    nodes(i+1).velocity = str2double(nodeTagList.item(j).getAttribute('v'));
                case 'acceleration'
                    nodes(i+1).acceleration = str2double(nodeTagList.item(j).getAttribute('v'));
                case 'time'
                    nodes(i+1).time = str2double(nodeTagList.item(j).getAttribute('v'));
                case 'goalRegionNode'
                    goalRegionNodes(goalRegionNodesCounter) = nodes(i+1);
                    goalRegionNodesCounter = goalRegionNodesCounter+1;
            end
        end
    end
end

% extract all ways
wayList = xdoc.getElementsByTagName('way');
numWays = wayList.getLength();
if(numWays>0)
    ways(numWays).id = 0;
    for i = 0:(wayList.getLength()-1)
        % extract the ID of the way
        ways(i+1).id = str2double(wayList.item(i).getAttribute('id'));
        
        % extract all nodes of the way
        wayNodeList = wayList.item(i).getElementsByTagName('nd');
        for j = 0:(wayNodeList.getLength()-1)
            if ~isempty(wayNodeList.item(j))
                % store the nodes which are part of the way
                index = [nodes.id]' == str2double(wayNodeList.item(j).getAttribute('ref'));
                ways(i+1).nodes(j+1) = nodes(index);
            end
        end
        
        % extract the type of the way (by tag)
        waysTagList = wayList.item(i).getElementsByTagName('tag');
        % (insert for loop here, if way has more tags)
        if ~isempty(waysTagList.item(0)) && strcmp(waysTagList.item(0).getAttribute('k'), 'type')
            ways(i+1).type = char(waysTagList.item(0).getAttribute('v'));
        else
            ways(i+1).type = 'unknown';
        end
    end
else
    ways = [];
end

% extract all relations, i.e. lanelets
relationList = xdoc.getElementsByTagName('relation');
lanelets(relationList.getLength()).id = [];
for i = 0:(relationList.getLength()-1)
    % extract the ID of the way
    lanelets(i+1).id = str2double(relationList.item(i).getAttribute('id'));
    
    % extract all members of the relation
    relationMemberList = relationList.item(i).getElementsByTagName('member');
    for j = 0:(relationMemberList.getLength()-1)
        % find the way which is the left or right border of the lanelet
        index = [ways.id]' == str2double(relationMemberList.item(j).getAttribute('ref'));
        switch char(relationMemberList.item(j).getAttribute('role'))
            case 'left'
                lanelets(i+1).left = ways(index);
            case 'right'
                lanelets(i+1).right = ways(index);
        end
    end
    
    % exctract all tags of the relation
    laneletsTagList = relationList.item(i).getElementsByTagName('tag');
    for j = 0:(laneletsTagList.getLength()-1)
        if ~isempty(laneletsTagList.item(j))
            switch char(laneletsTagList.item(j).getAttribute('k'))
                case 'type'
                    % check if type is lanelet
                    if ~strcmp(laneletsTagList.item(j).getAttribute('v'), 'lanelet')
                        warning('Relation is not of type ''lanelet''.');
                    end
                case 'speedLimit'
                    % store the speed limit
                    lanelets(i+1).speedLimit = str2double(laneletsTagList.item(j).getAttribute('v'));
            end
        end
    end
end

% extract all adjacent lanelets
if adjacencyGraph
    for i = 0:(relationList.getLength()-1)
        % find all lanelets which are predecessor
        predecessorList = relationList.item(i).getElementsByTagName('predecessor');
        for j = 0:(predecessorList.getLength()-1)
            if ~isempty(predecessorList.item(j))
                %index = [lanelets.id]' == str2double(predecessorList.item(j).getAttribute('ref'));
                %lanelets(i+1).predecessor(j+1) = lanelets(index);
                lanelets(i+1).predecessor(j+1).id = str2double(predecessorList.item(j).getAttribute('ref'));
            end
        end
        
        % find all lanelets which are successor
        successorList = relationList.item(i).getElementsByTagName('successor');
        for j = 0:(successorList.getLength()-1)
            if ~isempty(successorList.item(j))
                %index = [lanelets.id]' == str2double(successorList.item(j).getAttribute('ref'));
                %lanelets(i+1).successor(j+1) = lanelets(index).id;
                lanelets(i+1).successor(j+1).id = str2double(successorList.item(j).getAttribute('ref'));
            end
        end
        
        % find all lanelets which are adjacent left
        adjacentLeftList = relationList.item(i).getElementsByTagName('adjacentLeft');
        for j = 0:(adjacentLeftList.getLength()-1)
            if ~isempty(adjacentLeftList.item(j))
                %index = [lanelets.id]' == str2double(adjacentLeftList.item(j).getAttribute('ref'));
                %lanelets(i+1).adjacentLeft(j+1).lanelet = lanelets(index);
                lanelets(i+1).adjacentLeft(j+1).lanelet.id = str2double(adjacentLeftList.item(j).getAttribute('ref'));
                lanelets(i+1).adjacentLeft(j+1).driving = char(adjacentLeftList.item(j).getAttribute('driving'));
            end
        end
        
        % find all lanelets which are adjacent right
        adjacentRightList = relationList.item(i).getElementsByTagName('adjacentRight');
        for j = 0:(adjacentRightList.getLength()-1)
            if ~isempty(adjacentRightList.item(j))
                %index = [lanelets.id]' == str2double(adjacentRightList.item(j).getAttribute('ref'));
                %lanelets(i+1).adjacentRight(j+1).lanelet = lanelets(index);
                lanelets(i+1).adjacentRight(j+1).lanelet.id = str2double(adjacentRightList.item(j).getAttribute('ref'));
                lanelets(i+1).adjacentRight(j+1).driving = char(adjacentRightList.item(j).getAttribute('driving'));
            end
        end
    end
end

% extract all rectangles
rectangleList = xdoc.getElementsByTagName('rectangle');
numRectangles = rectangleList.getLength();
if (numRectangles > 0)
    rectangles(numRectangles).id = 0;
    for i = 0:(numRectangles-1)
        % extract the ID of the rectangle
        rectangles(i+1).id = str2double(rectangleList.item(i).getAttribute('id'));
        
        % extract the tags length and width
        rectangleTagList = rectangleList.item(i).getElementsByTagName('tag');
        for j = 0:(rectangleTagList.getLength()-1);
            if ~isempty(rectangleTagList.item(j))
                switch char(rectangleTagList.item(j).getAttribute('k'))
                    case 'length'
                        rectangles(i+1).length = str2double(rectangleTagList.item(j).getAttribute('v'));
                    case 'width'
                        rectangles(i+1).width = str2double(rectangleTagList.item(j).getAttribute('v'));
                end
            end
        end
    end
else
    rectangles = [];
end

% extract all polygons
polygonList = xdoc.getElementsByTagName('polygon');
numPolygons = polygonList.getLength();
if (numPolygons > 0)
    polygons(numPolygons).id = 0;
    for i = 0:(numPolygons-1)
        % extract the ID of the rectangle
        polygons(i+1).id = str2double(polygonList.item(i).getAttribute('id'));
        
        % extract the nodes (vertices) of the polygon
        polygonNodeList = polygonList.item(i).getElementsByTagName('nd');
        for j = 0:(polygonNodeList.getLength()-1);
            if ~isempty(polygonNodeList.item(j))
                index = [nodes.id]' == str2double(polygonNodeList.item(j).getAttribute('ref'));
                polygons(i+1).nodes(j+1) = nodes(index);
            end
        end
    end
else
    polygons = [];
end

% extract all obstacles
obstacleList = xdoc.getElementsByTagName('obstacle');
numObstacles = obstacleList.getLength();
if (numObstacles > 0)
    obstacles(numObstacles).id = 0;
    for i = 0:(numObstacles-1)
        % extract the ID of the obstacle
        obstacles(i+1).id = str2double(obstacleList.item(i).getAttribute('id'));
        
        % extract the shape of the obstacle
        obstacleShapeList = obstacleList.item(i).getElementsByTagName('shape');
        if ~isempty(obstacleShapeList.item(0)) && strcmp(obstacleShapeList.item(0).getAttribute('type'), 'rectangle')
            index = [rectangles.id]' == str2double(obstacleShapeList.item(0).getAttribute('ref'));
            obstacles(i+1).shape = rectangles(index);
        elseif ~isempty(obstacleShapeList.item(0)) && strcmp(obstacleShapeList.item(0).getAttribute('type'), 'polygon')
            index = [polygons.id]' == str2double(obstacleShapeList.item(0).getAttribute('ref'));
            obstacles(i+1).shape = polygons(index);
        else
            warning('Obstacle shape is of unknown type.');
        end
        
        % extract the trajectory of the obstacle
        obstacleTrajectoryList = obstacleList.item(i).getElementsByTagName('trajectory');
        if ~isempty(obstacleTrajectoryList.item(0)) && strcmp(obstacleTrajectoryList.item(0).getAttribute('type'), 'way')
            index = [ways.id]' == str2double(obstacleTrajectoryList.item(0).getAttribute('ref'));
            obstacles(i+1).trajectory = ways(index);
            obstacles(i+1).role = char(obstacleTrajectoryList.item(0).getAttribute('role'));
        elseif ~isempty(obstacleTrajectoryList.item(0)) && strcmp(obstacleTrajectoryList.item(0).getAttribute('type'), 'node')
            index = [nodes.id]' == str2double(obstacleTrajectoryList.item(0).getAttribute('ref'));
            obstacles(i+1).trajectory.id = nodes(index).id;
            obstacles(i+1).trajectory.nodes(1) = nodes(index);
            obstacles(i+1).trajectory.type = 'trajectory';
            obstacles(i+1).role = char(obstacleTrajectoryList.item(0).getAttribute('role'));
        elseif isempty(obstacleTrajectoryList.item(0))
            obstacles(i+1).role = 'static';
        else
            warning('Obstacle trajectory is of unknown type.');
        end
        
        % extract the tags of the obstacle
        obstacleTagList = obstacleList.item(i).getElementsByTagName('tag');
        for j = 0:(obstacleTagList.getLength()-1);
            if ~isempty(obstacleTagList.item(j))
                switch char(obstacleTagList.item(j).getAttribute('k'))
                    case 'type'
                        obstacles(i+1).type = char(obstacleTagList.item(j).getAttribute('v'));
                    case 'aMax'
                        obstacles(i+1).a_max = str2double(obstacleTagList.item(j).getAttribute('v'));
                    case 'vMax'
                        obstacles(i+1).v_max = str2double(obstacleTagList.item(j).getAttribute('v'));
                    case 'vS'
                        obstacles(i+1).v_s = str2double(obstacleTagList.item(j).getAttribute('v'));
                end
            end
        end
        if ~isfield(obstacles(i+1), 'type') || isempty(obstacles(i+1).type)
            obstacles(i+1).type = 'unknown';
        end
    end
else
    obstacles = [];
end

% extract all ego vehicles
egoVehicleList = xdoc.getElementsByTagName('egoVehicle');
numEgoVehicles = egoVehicleList.getLength();
if (numEgoVehicles > 0)
    egoVehicles(numEgoVehicles).id = 0;
    for i = 0:(numEgoVehicles-1)
        % extract the ID of the obstacle
        egoVehicles(i+1).id = str2double(egoVehicleList.item(i).getAttribute('id'));
        
        % extract the shape of the ego vehicle
        egoVehicleShapeList = egoVehicleList.item(i).getElementsByTagName('shape');
        if ~isempty(egoVehicleShapeList.item(0)) && strcmp(egoVehicleShapeList.item(0).getAttribute('type'), 'rectangle')
            index = [rectangles.id]' == str2double(egoVehicleShapeList.item(0).getAttribute('ref'));
            egoVehicles(i+1).shape = rectangles(index);
        else
            warning('Ego Vehicle shape is not of type rectangle.');
        end
        
        % extract the trajectory of the ego vehicle
        egoVehicleTrajectoryList = egoVehicleList.item(i).getElementsByTagName('trajectory');
        if ~isempty(egoVehicleTrajectoryList.item(0)) && strcmp(egoVehicleTrajectoryList.item(0).getAttribute('type'), 'way')
            index = [ways.id]' == str2double(egoVehicleTrajectoryList.item(0).getAttribute('ref'));
            egoVehicles(i+1).trajectory = ways(index);
            egoVehicles(i+1).role = char(egoVehicleTrajectoryList.item(0).getAttribute('role'));
        elseif ~isempty(egoVehicleTrajectoryList.item(0)) && strcmp(egoVehicleTrajectoryList.item(0).getAttribute('type'), 'node')
            index = [nodes.id]' == str2double(egoVehicleTrajectoryList.item(0).getAttribute('ref'));
            egoVehicles(i+1).trajectory.id = nodes(index).id;
            egoVehicles(i+1).trajectory.nodes(1) = nodes(index);
            egoVehicles(i+1).trajectory.type = 'trajectory';
            egoVehicles(i+1).role = char(egoVehicleTrajectoryList.item(0).getAttribute('role'));
        else
            warning('Ego Vehicle trajectory is not of type way.');
        end
        
        % extract the type of the ego vehicle (by tag)
        egoVehicleTagList = egoVehicleList.item(i).getElementsByTagName('tag');
        % (insert for loop here, if ego vehicle has more tags)
        if ~isempty(egoVehicleTagList.item(0)) && strcmp(egoVehicleTagList.item(0).getAttribute('k'), 'type')
            egoVehicles(i+1).type = char(egoVehicleTagList.item(0).getAttribute('v'));
        else
            egoVehicles(i+1).type = 'unknown';
        end
        
        %adding egoVehicleNodes
        %Problem: In case of several egoVehicles, goalRegionNodes are not
        %precisely assigned to each egoVehicle
        if exist('goalRegionNodes','var')
            egoVehicles(i+1).goalRegionNodes(1) = goalRegionNodes((i+1)*2-1);
            egoVehicles(i+1).goalRegionNodes(2) = goalRegionNodes((i+1)*2);
        end
    end
else
    egoVehicles = [];
end

end

%------------- END CODE --------------