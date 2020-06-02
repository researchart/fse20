function [obstacles] = createObstaclesFromXML(obstacles_XML, refPos, refOrientation, refTime)
%CREATEOBSTACLESFROMXML This function creates Obstacles objects from
%                       readXMLFile output data
%   Syntax:
%   [obstacles] = createObstaclesFromXML(obstacles_XML,lanes)
%
%   Inputs:
%   obstacles_XML - structure of obstacles
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
%       obstacles_dynamic - array of dynamic obstacle objects
%       vehicles - array of vehicle objects
%       obstacles_static - array of static obstacle objects
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

global timestepSize
numObstacles = length(obstacles_XML);
obstacles(numObstacles) = world.Obstacle();

for i=1:numObstacles
    % role
    switch obstacles_XML(i).role
        case 'static'
            % static obstacle
            obstacles(i) = world.StaticObstacle( ...
                obstacles_XML(i).id, ...
                geometry.translateAndRotateVertices([obstacles_XML(i).shape.rectangles.x; ...
                obstacles_XML(i).shape.rectangles.y],refPos,refOrientation), ...
                obstacles_XML(i).shape.rectangles.orientation + refOrientation, ...
                geometry.Rectangle(obstacles_XML(i).shape.rectangles.length, ...
                obstacles_XML(i).shape.rectangles.width));
        case 'dynamic'
            % dynamic obstacles with trajectory (known behavior)
            if isfield(obstacles_XML(i), 'trajectory') && ~isempty(obstacles_XML(i).trajectory)
                
                % shape object
                shape = geometry.Rectangle(obstacles_XML(i).shape.rectangles.length, ...
                            obstacles_XML(i).shape.rectangles.width);
                
                % timeInterval object
                ts = obstacles_XML(i).trajectory.states(1).time + refTime;
                dt = timestepSize; %obstacles_XML(i).trajectory.states(2).time - obstacles_XML(i).trajectory.states(1).time;
                tf = obstacles_XML(i).trajectory.states(end).time + refTime;
                timeInterval = globalPck.TimeInterval(ts, dt, tf);
                
                % optional velocity
                if isfield(obstacles_XML(i).trajectory.states, 'velocity') && ~isempty(obstacles_XML(i).trajectory.states(1).velocity)
                    velocity = [obstacles_XML(i).trajectory.states.velocity];
                else
                    velocity = [];
                end
                
                % optional acceleration
                if isfield(obstacles_XML(i).trajectory.states, 'acceleration') && ~isempty(obstacles_XML(i).trajectory.states(1).acceleration)
                    acceleration = [obstacles_XML(i).trajectory.states.acceleration];
                else
                    acceleration = [];
                end
                
                % trajectory object
                trajectory = globalPck.Trajectory(timeInterval, ...
                    geometry.translateAndRotateVertices([[obstacles_XML(i).trajectory.states.x]; ...
                    [obstacles_XML(i).trajectory.states.y]],refPos,refOrientation), ...
                    [obstacles_XML(i).trajectory.states(:).orientation] + refOrientation, ...
                    velocity, acceleration);
                
                % type
                switch obstacles_XML(i).type
                    case {'car','truck','bus'}
                        % vehicle object
                        obstacles(i) = world.Vehicle( ...
                            obstacles_XML(i).id, [], [], shape);
                        obstacles(i).setTrajectory(trajectory);                        
                    case {'bicycle','pedestrian','priorityVehicle'}
                        error('Obstacle of type %s not supported.', obstacles_XML(i).type);                        
                    case {'unknown'}
                        % dynamicObstacle object
                        obstacles(i) = world.DynamicObstacle(...
                            obstacles_XML(i).id, [], [], shape);
                        obstacles(i).setTrajectory(trajectory);
                    otherwise
                        error('Obstacle of type %s not supported.', obstacles_XML(i).type);
                end
            end
    end
end

end

%------------- END CODE --------------