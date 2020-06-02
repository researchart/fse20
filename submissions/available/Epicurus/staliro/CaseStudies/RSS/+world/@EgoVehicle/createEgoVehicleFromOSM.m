function [egoVehicle] = createEgoVehicleFromOSM(egoVehicle_OSM,lanes,refPos,refOrientation,refTime)
%CREATEOBSTACLESFROMOSM This function creates EgoVehicle objects from
%                       readOSMFile output data
%   Syntax:
%   [egoVehicle] = createEgoVehicleFromOSM(egoVehicle_OSM)
%   Be aware of the flag variable (at line 54)
%
%   Inputs:
%   egoVehicle_OSM - structure of egoVehicle
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
%           .goalRegionNodes
%                   .id
%                   .x
%                   .y
%                   .orientation 
%                   .velocity
%                   .acceleration
%                   .time
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
% Written:      17-April-2017
% Last update:  17-April-2017
%
% Last revision:---


%------------- BEGIN CODE --------------

% shape (default values)
% shape = geometry.Rectangle(4.8, 2.0);

%set flag to 1 if you want to set manually  bigger or smaller boundaries
%for your goalregion @95-101 and a more precise GoalRegionRectangle @92
flag = 1;

% inital state
if isfield(egoVehicle_OSM.trajectory.nodes, 'acceleration') && ...
        isfield(egoVehicle_OSM.trajectory.nodes, 'velocity')
    initialState = {geometry.translateAndRotateVertices([egoVehicle_OSM.trajectory.nodes.x; ...
        egoVehicle_OSM.trajectory.nodes.y],refPos,refOrientation), ...
        egoVehicle_OSM.trajectory.nodes.orientation + refOrientation, ...
        geometry.Rectangle(egoVehicle_OSM.shape.length,egoVehicle_OSM.shape.width),...
        [], egoVehicle_OSM.trajectory.nodes.velocity, ...
        egoVehicle_OSM.trajectory.nodes.acceleration, ...
        [], [], egoVehicle_OSM.trajectory.nodes.time + refTime};
elseif isfield(egoVehicle_OSM.trajectory.nodes, 'acceleration')
    initialState = {geometry.translateAndRotateVertices([egoVehicle_OSM.trajectory.nodes.x; ...
        egoVehicle_OSM.trajectory.nodes.y],refPos,refOrientation), ...
        egoVehicle_OSM.trajectory.nodes.orientation + refOrientation, ...
        geometry.Rectangle(egoVehicle_OSM.shape.length,egoVehicle_OSM.shape.width),...
        [], [], egoVehicle_OSM.trajectory.nodes.acceleration, ...
        [], [], egoVehicle_OSM.trajectory.nodes.time + refTime};
elseif isfield(egoVehicle_OSM.trajectory.nodes, 'velocity')
    initialState = {geometry.translateAndRotateVertices([egoVehicle_OSM.trajectory.nodes.x; ...
        egoVehicle_OSM.trajectory.nodes.y],refPos,refOrientation), ...
        egoVehicle_OSM.trajectory.nodes.orientation + refOrientation, ...
        geometry.Rectangle(egoVehicle_OSM.shape.length,egoVehicle_OSM.shape.width),...
        [], egoVehicle_OSM.trajectory.nodes.velocity, [], ...
        [], [], egoVehicle_OSM.trajectory.nodes.time + refTime};
end


% goal region:
%just for the one case: Id 'NGSIM_US101_0'
% if egoVehicle_OSM.id == -482
%     warning('lane 1 is set as GoalRegion');
%     RectangleGR = lanes(1).lanelets;
if isfield(egoVehicle_OSM, 'goalRegionNodes') && flag==1
    x = mean([egoVehicle_OSM.goalRegionNodes(1).x,egoVehicle_OSM.goalRegionNodes(2).x]);
    y = mean([egoVehicle_OSM.goalRegionNodes(1).y,egoVehicle_OSM.goalRegionNodes(2).y]);
    position = geometry.translateAndRotateVertices([x;y],refPos,refOrientation);
    RectangleGR = globalPck.GoalRegion.createGRRFromPosition(lanes,position,2.8,3);
elseif isfield(egoVehicle_OSM, 'goalRegionNodes')
    x = mean([egoVehicle_OSM.goalRegionNodes(1).x,egoVehicle_OSM.goalRegionNodes(2).x]);
    y = mean([egoVehicle_OSM.goalRegionNodes(1).y,egoVehicle_OSM.goalRegionNodes(2).y]);
    position = geometry.translateAndRotateVertices([x;y],refPos,refOrientation);
    RectangleGR = globalPck.GoalRegion.createGRRFromPosition(lanes,position);
end

%obj = GoalRegion(position, orientation, time, velocity, acceleration)
if isfield(egoVehicle_OSM, 'goalRegionNodes') && flag ==1
    orientation = [egoVehicle_OSM.goalRegionNodes(1).orientation + refOrientation-1,...
        egoVehicle_OSM.goalRegionNodes(2).orientation + refOrientation+1];
    time = [egoVehicle_OSM.goalRegionNodes(1).time + refTime-2,...
        egoVehicle_OSM.goalRegionNodes(2).time + refTime+2];
    velocity = [egoVehicle_OSM.goalRegionNodes(1).velocity-4,...
        egoVehicle_OSM.goalRegionNodes(2).velocity+4];
    acceleration = [egoVehicle_OSM.goalRegionNodes(1).acceleration,...
        egoVehicle_OSM.goalRegionNodes(2).acceleration];
    goalRegion = globalPck.GoalRegion(RectangleGR, ...
        orientation, time, velocity, acceleration);
elseif isfield(egoVehicle_OSM, 'goalRegionNodes')
    orientation = [egoVehicle_OSM.goalRegionNodes(1).orientation + refOrientation,...
        egoVehicle_OSM.goalRegionNodes(2).orientation + refOrientation];
    time = [egoVehicle_OSM.goalRegionNodes(1).time + refTime,...
        egoVehicle_OSM.goalRegionNodes(2).time + refTime];
    velocity = [egoVehicle_OSM.goalRegionNodes(1).velocity,...
        egoVehicle_OSM.goalRegionNodes(2).velocity];
    acceleration = [egoVehicle_OSM.goalRegionNodes(1).acceleration,...
        egoVehicle_OSM.goalRegionNodes(2).acceleration];
    goalRegion = globalPck.GoalRegion(RectangleGR, ...
        orientation, time, velocity, acceleration);
else
    goalRegion = [];
    warning('egoVehicle without goalregion');
end

% ego vehicle
%constructor: obj = EgoVehicle(id, position, orientation, shape, ...
%            inLane, velocity, acceleration, v_max, a_max, time, v_s, power_max, ...
%            goalRegion)
egoVehicle = world.EgoVehicle(egoVehicle_OSM.id, ...
    initialState{:}, [], [], goalRegion);

end

%------------- END CODE --------------