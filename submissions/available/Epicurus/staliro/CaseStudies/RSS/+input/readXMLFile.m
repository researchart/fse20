function [lanelets, obstacles, egoVehicles, scenarioData] = readXMLFile(filename)
%readXmlFile - reads an xml file (CommonRoad specification)
% which contains lanelets and obstacles
%
% Syntax:
%   [lanelets, obstacles, egoVehicles] = readXMLFile(filename)
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
%                       .id
%                       .driving
%           .adjacentRight
%                       .id
%                       .driving
%   obstacles - struct of obstacle with obstacle properties
%           .id
%           .role
%           .type
%           .shape
%           .trajectory
%                       .state (position, orientation, time, velocity, acceleration)
%
%   egoVehicles - struct of ego vehicles with obstacle properties (as above)
%   scenarioData - struct
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: XML format specification

% Author:       Markus Koschi
% Written:      29-March-2017
% Last update:  25-August-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

% Warning: much code is copied within this function at multiple places
% ToDo: refactor into subfunctions

% read the XML file
xDoc = xmlread(filename);

%% --- CommonRoad Element ---
% check commonRoadVersion
commonRoad = xDoc.getDocumentElement;
if ~strcmp(commonRoad.getAttribute('commonRoadVersion'), '2017a')
    error('Invalid CommonRoad Version. Error in readXMLFile');
end

scenarioData.scenarioID = char(commonRoad.getAttribute('benchmarkID'));
scenarioData.date = char(commonRoad.getAttribute('date'));
scenarioData.timeStepSize = str2double(commonRoad.getAttribute('timeStepSize'));

%% -- Road Network ---
% extract all lanelets
laneletList = xDoc.getElementsByTagName('lanelet');
%lanelets(laneletList.getLength()).id = [];
for i = 0:(laneletList.getLength()-1)
    % id
    if ~strcmp(laneletList.item(i).getAttribute('id'),'')
        lanelets(i+1).id = str2double(laneletList.item(i).getAttribute('id'));
    else
        continue
    end
    
    % left bound
    boundList = laneletList.item(i).getElementsByTagName('leftBound');
    pointList = boundList.item(0).getElementsByTagName('point');
    lanelets(i+1).leftBound = zeros(2,pointList.getLength());
    for j = 0:(pointList.getLength()-1)
        lanelets(i+1).leftBound(1,j+1) = str2double(pointList.item(j).getElementsByTagName('x').item(0).getTextContent);
        lanelets(i+1).leftBound(2,j+1) = str2double(pointList.item(j).getElementsByTagName('y').item(0).getTextContent);
    end
    % ToDo: lineMarking
    
    % right bound
    boundList = laneletList.item(i).getElementsByTagName('rightBound');
    pointList = boundList.item(0).getElementsByTagName('point');
    lanelets(i+1).rightBound = zeros(2,pointList.getLength());
    for j = 0:(pointList.getLength()-1)
        lanelets(i+1).rightBound(1,j+1) = str2double(pointList.item(j).getElementsByTagName('x').item(0).getTextContent);
        lanelets(i+1).rightBound(2,j+1) = str2double(pointList.item(j).getElementsByTagName('y').item(0).getTextContent);
    end
    % ToDo: lineMarking
    
    % predecessor
    predecessorList = laneletList.item(i).getElementsByTagName('predecessor');
    for j = 0:(predecessorList.getLength()-1)
        if ~isempty(predecessorList.item(j))
            lanelets(i+1).predecessor(j+1) = str2double(predecessorList.item(j).getAttribute('ref'));
        end
    end
    
    % successor
    successorList = laneletList.item(i).getElementsByTagName('successor');
    for j = 0:(successorList.getLength()-1)
        if ~isempty(successorList.item(j))
            lanelets(i+1).successor(j+1) = str2double(successorList.item(j).getAttribute('ref'));
        end
    end
    
    % adjacent left
    adjacentLeftList = laneletList.item(i).getElementsByTagName('adjacentLeft');
    if ~isempty(adjacentLeftList.item(0))
        lanelets(i+1).adjacentLeft.id = str2double(adjacentLeftList.item(0).getAttribute('ref'));
        if ~isempty(adjacentLeftList.item(0).getAttribute('drivingDir')) && ...
                ~strcmp('',char(adjacentLeftList.item(0).getAttribute('drivingDir')))
            lanelets(i+1).adjacentLeft.drivingDir = char(adjacentLeftList.item(0).getAttribute('drivingDir'));
        else
            error(['No driving direction specified for left adjacent '...
                'lanelet of lanelet %i.'], lanelets(i+1).id);
        end
    end
    
    % adjacent right
    adjacentRightList = laneletList.item(i).getElementsByTagName('adjacentRight');
    if ~isempty(adjacentRightList.item(0))
        lanelets(i+1).adjacentRight.id = str2double(adjacentRightList.item(0).getAttribute('ref'));
        if ~isempty(adjacentRightList.item(0).getAttribute('drivingDir')) && ...
                ~strcmp('',char(adjacentRightList.item(0).getAttribute('drivingDir')))
            lanelets(i+1).adjacentRight.drivingDir = char(adjacentRightList.item(0).getAttribute('drivingDir'));
        else
            error(['No driving direction specified for right adjacent '...
                'lanelet of lanelet %i.'], lanelets(i+1).id);
        end
    end
    
    % speed limit
    speedLimitList = laneletList.item(i).getElementsByTagName('speedLimit');
    if ~isempty(speedLimitList.item(0))
        lanelets(i+1).speedLimit = str2double(speedLimitList.item(0).getTextContent);
    end
end


%% -- Static and Dynamic Obstacles ---
% extract all obstacles
obstaclesList = xDoc.getElementsByTagName('obstacle');
if ~isempty(obstaclesList.item(0))
    obstacles(obstaclesList.getLength()).id = [];
    for i = 0:(obstaclesList.getLength()-1)
        % id
        obstacles(i+1).id = str2double(obstaclesList.item(i).getAttribute('id'));
        
        % role
        roleList = obstaclesList.item(i).getElementsByTagName('role');
        obstacles(i+1).role = char(roleList.item(0).getTextContent);
        
        % type
        typeList = obstaclesList.item(i).getElementsByTagName('type');
        obstacles(i+1).type = char(typeList.item(0).getTextContent);
        
        % shape
        shapeList = obstaclesList.item(i).getElementsByTagName('shape');
        if ~isempty(shapeList.item(0))
            rectangleList = shapeList.item(0).getElementsByTagName('rectangle');
            for j = 0:(rectangleList.getLength()-1)
                obstacles(i+1).shape.rectangles(j+1).length = str2double(rectangleList.item(j).getElementsByTagName('length').item(0).getTextContent);
                obstacles(i+1).shape.rectangles(j+1).width = str2double(rectangleList.item(j).getElementsByTagName('width').item(0).getTextContent);
                if ~isempty(rectangleList.item(j).getElementsByTagName('x').item(0))
                    obstacles(i+1).shape.rectangles(j+1).x = str2double(rectangleList.item(j).getElementsByTagName('x').item(0).getTextContent);
                    obstacles(i+1).shape.rectangles(j+1).y = str2double(rectangleList.item(j).getElementsByTagName('y').item(0).getTextContent);
                end
                if ~isempty(rectangleList.item(j).getElementsByTagName('orientation').item(0))
                    obstacles(i+1).shape.rectangles(j+1).orientation = str2double(rectangleList.item(j).getElementsByTagName('orientation').item(0).getTextContent);
                end
            end
            % ToDo: circles and polygons
        end
        
        % trajectory
        trajectoryList = obstaclesList.item(i).getElementsByTagName('trajectory');
        if ~isempty(trajectoryList.item(0))
            stateList = trajectoryList.item(0).getElementsByTagName('state');
            
            for j = 0:(stateList.getLength()-1)
                % position
                positionList = stateList.item(j).getElementsByTagName('position');
                pointList = positionList.item(0).getElementsByTagName('point');
                if ~isempty(pointList.item(0))
                    obstacles(i+1).trajectory.states(j+1).x = str2double(pointList.item(0).getElementsByTagName('x').item(0).getTextContent);
                    obstacles(i+1).trajectory.states(j+1).y = str2double(pointList.item(0).getElementsByTagName('y').item(0).getTextContent);
                end
                % ToDo: rectangle, circle, polygon, lanelet
                
                % orientation
                orientationList = stateList.item(j).getElementsByTagName('orientation');
                if ~isempty(orientationList.item(0).getElementsByTagName('exact').item(0))
                    obstacles(i+1).trajectory.states(j+1).orientation = str2double(orientationList.item(0).getElementsByTagName('exact').item(0).getTextContent);
                    %ToDo: interval
                end
                
                % time
                timeList = stateList.item(j).getElementsByTagName('time');
                if ~isempty(timeList.item(0).getElementsByTagName('exact').item(0))
                    obstacles(i+1).trajectory.states(j+1).time = str2double(timeList.item(0).getElementsByTagName('exact').item(0).getTextContent);
                    %ToDo: interval
                end
                
                % velocity
                velocityList = stateList.item(j).getElementsByTagName('velocity');
                if ~isempty(velocityList.item(0))
                    obstacles(i+1).trajectory.states(j+1).velocity = str2double(velocityList.item(0).getElementsByTagName('exact').item(0).getTextContent);
                    %ToDo: interval
                end
                
                % acceleration
                accelerationList = stateList.item(j).getElementsByTagName('acceleration');
                if ~isempty(accelerationList.item(0))
                    obstacles(i+1).trajectory.states(j+1).acceleration = str2double(accelerationList.item(0).getElementsByTagName('exact').item(0).getTextContent);
                    %ToDo: interval
                end
            end
        end
        
        %ToDo: occupancySet
        %ToDo: probabilityDistribution
        
        %         node = stateList.getFirstChild;
        %         while ~isempty(node)
        %             if strcmpi(node.getNodeName, 'position')
        %                 positionNode = node.item(0).getChildNodes;
        %                 %
        %
        %                 while ~isempty(positionNode)
        %                     if strcmpi(positionNode.getNodeName, 'point')
        %                         x = str2double(positionNode.item(0).getElementsByTagName('x').item(0).getTextContent);
        %                     else
        %                         positionNode = positionNode.getNextSibling;
        %                     end
        %                 end
        %
        %             else
        %                 node = node.getNextSibling;
        %             end
        %         end
        
    end
else
    obstacles = [];
end

%% -- Ego Vehicles ---
egoVehiclesList = xDoc.getElementsByTagName('planningProblem');
if ~isempty(egoVehiclesList.item(0))
    egoVehicles(egoVehiclesList.getLength()).id = [];
    for i = 0:(egoVehiclesList.getLength()-1)
        % id
        egoVehicles(i+1).id = str2double(egoVehiclesList.item(i).getAttribute('id'));
        
        % initial state
        initialStateList = egoVehiclesList.item(i).getElementsByTagName('initialState');
        
        % position
        positionList = initialStateList.item(0).getElementsByTagName('position');
        % point
        pointList = positionList.item(0).getElementsByTagName('point');
        if ~isempty(pointList.item(0))
            egoVehicles(i+1).initialState.position.point.x = str2double(pointList.item(0).getElementsByTagName('x').item(0).getTextContent);
            egoVehicles(i+1).initialState.position.point.y = str2double(pointList.item(0).getElementsByTagName('y').item(0).getTextContent);
        end
        % ToDo: rectangle, circle, polygon, lanelet
        
        % orientation
        orientationList = initialStateList.item(0).getElementsByTagName('orientation');
        if ~isempty(orientationList.item(0).getElementsByTagName('exact').item(0))
            egoVehicles(i+1).initialState.orientation = str2double(orientationList.item(0).getElementsByTagName('exact').item(0).getTextContent);
            %ToDo: interval
        end
        
        % time
        timeList = initialStateList.item(0).getElementsByTagName('time');
        if ~isempty(timeList.item(0).getElementsByTagName('exact').item(0))
            egoVehicles(i+1).initialState.time = str2double(timeList.item(0).getElementsByTagName('exact').item(0).getTextContent);
            %ToDo: interval
        end
        
        % velocity
        velocityList = initialStateList.item(0).getElementsByTagName('velocity');
        if ~isempty(velocityList.item(0))
            egoVehicles(i+1).initialState.velocity = str2double(velocityList.item(0).getElementsByTagName('exact').item(0).getTextContent);
            %ToDo: interval
        end
        
        % acceleration
        accelerationList = initialStateList.item(0).getElementsByTagName('acceleration');
        if ~isempty(accelerationList.item(0))
            egoVehicles(i+1).initialState.acceleration = str2double(accelerationList.item(0).getElementsByTagName('exact').item(0).getTextContent);
            %ToDo: interval
        end
        
        % goal region
        goalRegionList = egoVehiclesList.item(i).getElementsByTagName('goalRegion');
        stateList = goalRegionList.item(0).getElementsByTagName('state');
        for j = 0:(stateList.getLength()-1)
            % position
            positionList = stateList.item(j).getElementsByTagName('position');
            % point
            pointList = positionList.item(0).getElementsByTagName('point');
            if ~isempty(pointList.item(0))
                egoVehicles(i+1).goalRegion(j+1).position.point.x = str2double(pointList.item(0).getElementsByTagName('x').item(0).getTextContent);
                egoVehicles(i+1).goalRegion(j+1).position.point.y = str2double(pointList.item(0).getElementsByTagName('y').item(0).getTextContent);
            end
            % rectangle
            rectangleList = positionList.item(0).getElementsByTagName('rectangle');
            if ~isempty(rectangleList.item(0))
                egoVehicles(i+1).goalRegion(j+1).position.rectangles.length = str2double(rectangleList.item(0).getElementsByTagName('length').item(0).getTextContent);
                egoVehicles(i+1).goalRegion(j+1).position.rectangles.width = str2double(rectangleList.item(0).getElementsByTagName('width').item(0).getTextContent);
                if ~isempty(rectangleList.item(j).getElementsByTagName('x').item(0))
                    egoVehicles(i+1).goalRegion(j+1).position.rectangles.x = str2double(rectangleList.item(0).getElementsByTagName('x').item(0).getTextContent);
                    egoVehicles(i+1).goalRegion(j+1).position.rectangles.y = str2double(rectangleList.item(0).getElementsByTagName('y').item(0).getTextContent);
                end
                if ~isempty(rectangleList.item(j).getElementsByTagName('orientation').item(0))
                    egoVehicles(i+1).goalRegion(j+1).position.rectangles.orientation = str2double(rectangleList.item(0).getElementsByTagName('orientation').item(0).getTextContent);
                end
            end
            % lanelet
            laneletList = positionList.item(0).getElementsByTagName('lanelet');
            if ~isempty(laneletList.item(0))
                egoVehicles(i+1).goalRegion(j+1).position.laneletId = str2double(laneletList.item(0).getAttribute('ref'));
            end
            % ToDo: circle, polygon
            
            % orientation
            orientationList = stateList.item(j).getElementsByTagName('orientation');
            if ~isempty(orientationList.item(0).getElementsByTagName('exact').item(0))
                egoVehicles(i+1).goalRegion(j+1).orientation = str2double(orientationList.item(0).getElementsByTagName('exact').item(0).getTextContent);
            elseif ~isempty(orientationList.item(0).getElementsByTagName('intervalStart').item(0))
                egoVehicles(i+1).goalRegion(j+1).orientation(1) = str2double(orientationList.item(0).getElementsByTagName('intervalStart').item(0).getTextContent);
                egoVehicles(i+1).goalRegion(j+1).orientation(2) = str2double(orientationList.item(0).getElementsByTagName('intervalEnd').item(0).getTextContent);
            elseif ~isempty(orientationList.item(1).getElementsByTagName('intervalStart').item(0))
                egoVehicles(i+1).goalRegion(j+1).orientation(1) = str2double(orientationList.item(1).getElementsByTagName('intervalStart').item(0).getTextContent);
                egoVehicles(i+1).goalRegion(j+1).orientation(2) = str2double(orientationList.item(1).getElementsByTagName('intervalEnd').item(0).getTextContent);
            end
            
            % time
            timeList = stateList.item(j).getElementsByTagName('time');
            if ~isempty(timeList.item(0).getElementsByTagName('exact').item(0))
                egoVehicles(i+1).goalRegion(j+1).time = str2double(timeList.item(0).getElementsByTagName('exact').item(0).getTextContent);
            elseif ~isempty(timeList.item(0).getElementsByTagName('intervalStart').item(0))
                egoVehicles(i+1).goalRegion(j+1).time(1) = str2double(timeList.item(0).getElementsByTagName('intervalStart').item(0).getTextContent);
                egoVehicles(i+1).goalRegion(j+1).time(2) = str2double(timeList.item(0).getElementsByTagName('intervalEnd').item(0).getTextContent);
            end
            
            % velocity
            velocityList = stateList.item(j).getElementsByTagName('velocity');
            if ~isempty(velocityList.item(0))
                if ~isempty(velocityList.item(0).getElementsByTagName('exact').item(0))
                    egoVehicles(i+1).goalRegion(j+1).velocity = str2double(velocityList.item(0).getElementsByTagName('exact').item(0).getTextContent);
                elseif ~isempty(velocityList.item(0).getElementsByTagName('intervalStart').item(0))
                    egoVehicles(i+1).goalRegion(j+1).velocity(1) = str2double(velocityList.item(0).getElementsByTagName('intervalStart').item(0).getTextContent);
                    egoVehicles(i+1).goalRegion(j+1).velocity(2) = str2double(velocityList.item(0).getElementsByTagName('intervalEnd').item(0).getTextContent);
                end
            end
            
            % acceleration
            accelerationList = stateList.item(j).getElementsByTagName('acceleration');
            if ~isempty(accelerationList.item(0))
                if ~isempty(accelerationList.item(0).getElementsByTagName('exact').item(0))
                    egoVehicles(i+1).goalRegion(j+1).acceleration = str2double(accelerationList.item(0).getElementsByTagName('exact').item(0).getTextContent);
                elseif ~isempty(accelerationList.item(0).getElementsByTagName('intervalStart').item(0))
                    egoVehicles(i+1).goalRegion(j+1).acceleration(1) = str2double(accelerationList.item(0).getElementsByTagName('intervalStart').item(0).getTextContent);
                    egoVehicles(i+1).goalRegion(j+1).acceleration(2) = str2double(accelerationList.item(0).getElementsByTagName('intervalEnd').item(0).getTextContent);
                end
            end
        end
    end
else
    egoVehicles = [];
end

end

%------------- END CODE --------------