function [obstacles_dynamic, vehicles, obstacles_static] = createObstaclesFromOSM(obstacles_OSM, lanes,refPos,refOrientation,refTime)
%CREATEOBSTACLESFROMOSM This function creates Obstacles objects from
%                       readOSMFile output data
%   Syntax:
%   [obstacles, obstacles_dynamic, vehicles, obstacles_static] = createObstaclesFromOSM(obstacles_OSM,lanes)
%
%   Inputs:
%   obstacles_OSM - structure of obstacles
%           .id
%           .shape
%               .id
%               .length
%               .width
%           .trajectory
%               .id
%               .nodes
%                   .id
%                   .x
%                   .y
%                   .orientation
%                   .velocity
%                   .acceleration
%                   .time
%               .type
%           .role
%           .type
%   lanelets - structure of Lanelet Objects
%           .id
%           .leftBorderVertices
%           .rightBorderVertices
%           .speedLimit
%           .predecessorLanelets
%           .successorLanelets
%           .successorLanelets
%           .adjacentLeft
%           .adjacentRight
%           .centerVertices
%
%
%   Outputs:
%       obstacles_dynamic - array of dynamic obstacle objects
%       vehicles - array of vehicle objects
%       obstacles_static - array of static obstacle objects
%
%
%           -without initial position(except of static obstacles).
%           -findLaneletByPosition muss noch implementiert werden.
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Author:       Lukas Braunstorfer
% Written:      25-Dezember-2016
% Last update:  08-February-2017 (polygon and rectangle)
%
% Last revision:---



%------------- BEGIN CODE --------------

% %initialize outputs
numObstacles = length(obstacles_OSM);
obstacles_dynamic = world.DynamicObstacle.empty();
vehicles = world.Vehicle.empty();
obstacles_static = world.StaticObstacle.empty();

%create counters for counting the outputdimensions.
vehicle_count = 1;
obstacle_dynamic_count = 1;
obstacle_static_count = 1;

if ~ismember(nargin,[2,4,5])
    warning('not adequat input');
end


for i=1:numObstacles
    switch obstacles_OSM(i).role % differentiating between dynamic and static
        
        case 'dynamic'
            
            if(length(obstacles_OSM(i).trajectory.nodes)==1) % in Case of single node as trajectory
                timeinterval = globalPck.TimeInterval(obstacles_OSM(i).trajectory.nodes(1).time + refTime, 0, obstacles_OSM(i).trajectory.nodes(1).time + refTime);
                position = geometry.translateAndRotateVertices([obstacles_OSM(i).trajectory.nodes(1).x;obstacles_OSM(i).trajectory.nodes(1).y],refPos,refOrientation);
                orientation = obstacles_OSM(i).trajectory.nodes(1).orientation + refOrientation;
                velocity = obstacles_OSM(i).trajectory.nodes.velocity;
                acceleration = obstacles_OSM(i).trajectory.nodes.acceleration;
                trajectory = globalPck.Trajectory(timeinterval,position,orientation,velocity,acceleration);
                
                
            else
                %setting up TimeInterval for trajectory
                numberTimeSteps = length(obstacles_OSM(i).trajectory.nodes);
                ts = obstacles_OSM(i).trajectory.nodes(1).time + refTime;
                dt = obstacles_OSM(i).trajectory.nodes(2).time - obstacles_OSM(i).trajectory.nodes(1).time;
                tf = obstacles_OSM(i).trajectory.nodes(numberTimeSteps).time + refTime;
                
                timeinterval = globalPck.TimeInterval(ts, dt, tf);
                
                %setting up Trajectory
                
                position = geometry.translateAndRotateVertices([[obstacles_OSM(i).trajectory.nodes.x];[obstacles_OSM(i).trajectory.nodes.y]],refPos,refOrientation);
                orientation  = [obstacles_OSM(i).trajectory.nodes.orientation] + refOrientation;
                velocity = [obstacles_OSM(i).trajectory.nodes.velocity];
                acceleration = [obstacles_OSM(i).trajectory.nodes.acceleration];
                
                
                trajectory  = globalPck.Trajectory(timeinterval,position,orientation,velocity,acceleration);
            end
            
            
            switch obstacles_OSM(i).type %differentiating between vehicles and other dynamic obstacles
                %new vehicle, add here more vehicle types if needed
                case {'passengerCar','truck'}
                    if isfield(obstacles_OSM(i), 'v_s')
                        args = {obstacles_OSM(i).id,[],[],...
                            geometry.Rectangle(obstacles_OSM(i).shape.length, obstacles_OSM(i).shape.width), ...
                            lanes.findLaneByPosition(position(:,1)), ...
                            [], [], obstacles_OSM(i).v_max, obstacles_OSM(i).a_max, ...
                            [], obstacles_OSM(i).v_s};
                    else
                        args = {obstacles_OSM(i).id,[],[],...
                            geometry.Rectangle(obstacles_OSM(i).shape.length, obstacles_OSM(i).shape.width), ...
                            lanes.findLaneByPosition(position(:,1))};
                    end
                    vehicles(vehicle_count) = world.Vehicle(args{:});
                    vehicles(vehicle_count).setTrajectory(trajectory);
                    
                    vehicle_count=vehicle_count+1;
                    
                    
                    %new dynamic obstacle
                otherwise
                    args = {obstacles_OSM(i).id,[],[],...
                        geometry.Rectangle(obstacles_OSM(i).shape.length, obstacles_OSM(i).shape.width), ...
                        lanes.findLaneByPosition(position(:,1))};
                    obstacles_dynamic(obstacle_dynamic_count) = world.DynamicObstacle(args{:});
                    obstacles_dynamic(obstacle_dynamic_count).setTrajectory(trajectory);
                    
                    obstacle_dynamic_count=obstacle_dynamic_count+1;
            end
            
            
        case 'static'
            %new static obstacle
            
            if isfield(obstacles_OSM(i), 'trajectory')
                if isempty(obstacles_OSM(i).trajectory)
                    % static obstacle without trajectory
                    position = geometry.translateAndRotateVertices([obstacles_OSM(i).shape.nodes(1).x;obstacles_OSM(i).shape.nodes(1).y],refPos,refOrientation);
                    orientation = refOrientation;
                    shape = geometry.Polygon(geometry.translateAndRotateVertices([obstacles_OSM(i).shape.nodes.x;obstacles_OSM(i).shape.nodes.y],refPos,refOrientation));
                    inLane = world.Lane.empty();
                    
                    %                 args = {obstacles_OSM(i).id,[obstacles_OSM(i).shape.nodes(1).x;obstacles_OSM(i).shape.nodes(1).y],...
                    %                     0, geometry.Polygon([[obstacles_OSM(i).shape.nodes.x];[obstacles_OSM(i).shape.nodes.y]])};
                elseif (length(obstacles_OSM(i).trajectory.nodes)==1)
                    % static obstacle with one node as trajectory
                    position = geometry.translateAndRotateVertices([obstacles_OSM(i).trajectory.nodes(1).x;obstacles_OSM(i).trajectory.nodes(1).y],refPos,refOrientation);
                    orientation = obstacles_OSM(i).trajectory.nodes(1).orientation + refOrientation;
                    shape = geometry.Rectangle(obstacles_OSM(i).shape.length, obstacles_OSM(i).shape.width);
                    inLane = lanes.findLaneByPosition([obstacles_OSM(i).trajectory.nodes(1).x;obstacles_OSM(i).trajectory.nodes(1).y]);
                    
                    %                 args = {obstacles_OSM(i).id,[obstacles_OSM(i).trajectory.nodes(1).x;obstacles_OSM(i).trajectory.nodes(1).y],...
                    %                     obstacles_OSM(i).trajectory.nodes(1).orientation,...
                    %                     geometry.Rectangle(obstacles_OSM(i).shape.length, obstacles_OSM(i).shape.width), ...
                    %                     lanes.findLaneByPosition([obstacles_OSM(i).trajectory.nodes(1).x;obstacles_OSM(i).trajectory.nodes(1).y])};
                elseif (length(fields(obstacles_OSM(i).trajectory))==3)
                    % static obstacle with multiple nodes as trajectory
                    warning('Static Obstacle with more than one position. Just the first is used.');
                    position = geometry.translateAndRotateVertices([obstacles_OSM(i).trajectory.nodes(1).x;obstacles_OSM(i).trajectory.nodes(1).y],refPos,refOrientation);
                    orientation = obstacles_OSM(i).trajectory.nodes(1).orientation + refOrientation;
                    shape = geometry.Rectangle(obstacles_OSM(i).shape.length, obstacles_OSM(i).shape.width);
                    inLane = lanes.findLaneByPosition([obstacles_OSM(i).trajectory.nodes(1).x;obstacles_OSM(i).trajectory.nodes(1).y]);
                    
                    %                 args = {obstacles_OSM(i).id,[obstacles_OSM(i).trajectory.nodes(1).x;obstacles_OSM(i).trajectory.nodes(1).y],...
                    %                     obstacles_OSM(i).trajectory.orientation,...
                    %                     geometry.Rectangle(obstacles_OSM(i).shape.length, obstacles_OSM(i).shape.width), ...
                    %                     lanes.findLaneByPosition([obstacles_OSM(i).trajectory.nodes(1).x;obstacles_OSM(i).trajectory.nodes(1).y])};
                end
                args = {obstacles_OSM(i).id, position, orientation, shape, inLane};
                obstacles_static(obstacle_static_count) = world.StaticObstacle(args{:});
                obstacle_static_count=obstacle_static_count+1;
            else
                warning('Couldnt detect which type of trajectory');
            end
            
        otherwise
            warning('Couldnt detect whether static or dynamic');
            
    end
    
end





%------------- END CODE --------------