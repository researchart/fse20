function [egoVehicle] = createEgoVehicleFromXML(egoVehicle_XML,lanelets, refPos, refOrientation, refTime)
%CREATEOBSTACLESFROMXML This function creates EgoVehicle objects from
%                       readXMLFile output data
%   Syntax:
%   [egoVehicle] = createEgoVehicleFromXML(egoVehicle_XML)
%
%   Inputs:
%   egoVehicle_XML - structure of egoVehicle
%           .id
%           .role
%           .type
%           .shape
%               .rectangles
%           .trajectory
%               .states
%                   .position
%                   .orientation
%                   .time
%                   .velocity
%                   .acceleration
%
%
%   Outputs:
%       egoVehicle - EgoVehicle object
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Author:       Markus Koschi, Lukas Braunstorfer
% Written:      25-Dezember-2016
% Last update:  30-March-2017
%
% Last revision:---



%------------- BEGIN CODE --------------

% shape (default values)
shape = geometry.Rectangle(4.8, 2.0);

global timestepSize;
numEgoVehicles = length(egoVehicle_XML);
egoVehicle(numEgoVehicles) = world.EgoVehicle();

for k = 1:numEgoVehicles
    % inital state
    if isfield(egoVehicle_XML(k).initialState, 'acceleration') && ...
            isfield(egoVehicle_XML(k).initialState, 'velocity')
        initialState = {geometry.translateAndRotateVertices([egoVehicle_XML(k).initialState.position.point.x; ...
            egoVehicle_XML(k).initialState.position.point.y],refPos,refOrientation), ...
            egoVehicle_XML(k).initialState.orientation + refOrientation, ...
            shape, [], egoVehicle_XML(k).initialState.velocity, ...
            egoVehicle_XML(k).initialState.acceleration, ...
            [], [], egoVehicle_XML(k).initialState.time + refTime};
    elseif isfield(egoVehicle_XML(k).initialState, 'acceleration')
        initialState = {geometry.translateAndRotateVertices([egoVehicle_XML(k).initialState.position.point.x; ...
            egoVehicle_XML(k).initialState.position.point.y],refPos,refOrientation), ...
            egoVehicle_XML(k).initialState.orientation + refOrientation, ...
            shape, [], [], ...
            egoVehicle_XML(k).initialState.acceleration, ...
            [], [], egoVehicle_XML(k).initialState.time + refTime};
    elseif isfield(egoVehicle_XML(k).initialState, 'velocity')
        initialState = {geometry.translateAndRotateVertices([egoVehicle_XML(k).initialState.position.point.x; ...
            egoVehicle_XML(k).initialState.position.point.y],refPos,refOrientation), ...
            egoVehicle_XML(k).initialState.orientation + refOrientation, ...
            shape, [], egoVehicle_XML(k).initialState.velocity, ...
            [], ...
            [], [], egoVehicle_XML(k).initialState.time + refTime};
    end
    
    % goal region
    % position
    if isfield(egoVehicle_XML(k).goalRegion,'position')
        if isfield(egoVehicle_XML(k).goalRegion.position, 'rectangles')
            position = geometry.Rectangle(egoVehicle_XML(k).goalRegion.position.rectangles.length, ...
                egoVehicle_XML(k).goalRegion.position.rectangles.width, ...
                geometry.translateAndRotateVertices([egoVehicle_XML(k).goalRegion.position.rectangles.x; ...
                egoVehicle_XML(k).goalRegion.position.rectangles.y],refPos,refOrientation), ...
                egoVehicle_XML(k).goalRegion.position.rectangles.orientation + refOrientation);
        elseif isfield(egoVehicle_XML(k).goalRegion.position, 'laneletId')
            [a,b] = size(lanelets);
            for i=1:a
                for j=1:b
                    if lanelets(i,j).id == egoVehicle_XML(k).goalRegion.position.laneletId
                        position = lanelets(i,j);
                    end
                end
            end
        end
        
        %obj = GoalRegion(position, orientation, time, velocity, acceleration)
        if exist('position','var')
            if isfield(egoVehicle_XML(k).goalRegion,'velocity') && ...
                    isfield(egoVehicle_XML(k).goalRegion,'acceleration')
                goalRegion = globalPck.GoalRegion(position, ...
                    egoVehicle_XML(k).goalRegion.orientation + refOrientation, ...
                    egoVehicle_XML(k).goalRegion.time + refTime, ...
                    egoVehicle_XML(k).goalRegion.velocity, ...
                    egoVehicle_XML(k).goalRegion.acceleration);
            elseif isfield(egoVehicle_XML(k).goalRegion,'velocity')
                goalRegion = globalPck.GoalRegion(position, ...
                    egoVehicle_XML(k).goalRegion.orientation + refOrientation, ...
                    egoVehicle_XML(k).goalRegion.time + refTime, ...
                    egoVehicle_XML(k).goalRegion.velocity);
            elseif isfield(egoVehicle_XML(k).goalRegion,'acceleration')
                goalRegion = globalPck.GoalRegion(position, ...
                    egoVehicle_XML(k).goalRegion.orientation + refOrientation, ...
                    egoVehicle_XML(k).goalRegion.time + refTime, ...
                    egoVehicle_XML(k).goalRegion.acceleration);
            else
                goalRegion = globalPck.GoalRegion(position, ...
                    egoVehicle_XML(k).goalRegion.orientation + refOrientation, ...
                    egoVehicle_XML(k).goalRegion.time + refTime);
            end
        end
    else
        warning('No goal region could be created for ego vehicle %i.', ...
            egoVehicle_XML(k).id);
        goalRegion = globalPck.GoalRegion.empty;
    end
    
    % ego vehicle
    % constructor: obj = EgoVehicle(id, position, orientation, shape, ...
    %            inLane, velocity, acceleration, v_max, a_max, time, v_s, power_max, ...
    %            goalRegion)
    egoVehicle(k) = world.EgoVehicle(egoVehicle_XML(k).id, ...
        initialState{:}, [], [], goalRegion);
    
    % trajectory for ego vehicle
    % constructor: obj = Trajectory(timeInterval, position, orientation, ...
    %                              velocity, acceleration)
    timeInterval = globalPck.TimeInterval(egoVehicle_XML(k).initialState.time + refTime,...
        timestepSize,egoVehicle_XML(k).initialState.time + refTime);
    if isnan(egoVehicle_XML(k).initialState.velocity)
        velocity = [];
    else
        velocity = egoVehicle_XML(k).initialState.velocity;
    end
    if ~isfield(egoVehicle_XML(k).initialState,'acceleration') || ...
            isempty(egoVehicle_XML(k).initialState.acceleration) || ...
            isnan(egoVehicle_XML(k).initialState.acceleration)
        acceleration = [];
    else
        acceleration = egoVehicle_XML(k).initialState.acceleration;
    end
    trajectory = globalPck.Trajectory(timeInterval, ...
        geometry.translateAndRotateVertices([egoVehicle_XML(k).initialState.position.point.x;egoVehicle_XML(k).initialState.position.point.y], ...
        refPos,refOrientation), ...
        (egoVehicle_XML(k).initialState.orientation + refOrientation), ...
        velocity, acceleration);
    egoVehicle(k).setTrajectory(trajectory);
end
end

%------------- END CODE --------------