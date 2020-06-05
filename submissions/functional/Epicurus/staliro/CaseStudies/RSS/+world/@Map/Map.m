classdef Map < globalPck.Dynamic
    % Map - class for holding all objects in the environment of the ego vehicle
    %
    % Syntax:
    %  object constructor: obj = Map(varargin)
    %
    % Inputs:
    %   varargin
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
    % Last update:  16-August-2017
    %
    % Last revision:---
    
    %------------- BEGIN CODE --------------
    
    properties (SetAccess = protected, GetAccess = public)
        % inherited from abstract class Dynamic:
        % time = 0;
        
        scenarioID = [];
        timeStepSize = [];
        
        lanes = world.Lane.empty();
        obstacles = world.Obstacle.empty();
        egoVehicle = world.EgoVehicle.empty();
        
        lanelets = world.Lanelet.empty(); % only needed to save scenario back in an xml file
    end
    
    methods
        % class constructor
        function obj = Map(varargin)
            format long;
            global timestepSize
            
            if nargin >= 1 && (isa(varargin{1}, 'world.Lane') || isa(varargin{1}, 'world.Lanelet'))
                % set lanes
                if isa(varargin{1}, 'world.Lanelet')
                    obj.lanelets = varargin{1};
                    obj.lanes = world.Lane.createLanesFromLanelets(varargin{1});
                else %if isa(varargin{1}, 'world.Lane')
                    obj.lanes = varargin{1};
                end
                
                % set obstacles
                if nargin >= 2 && isa(varargin{2}, 'world.Obstacle')
                    obj.obstacles = varargin{2};
                end
                
                % set ego vehicle
                if nargin == 3 && isa(varargin{3}, 'world.EgoVehicle')
                    obj.egoVehicle = varargin{3};
                end
                
                % map is given as file:
            elseif nargin == 1 && ischar(varargin{1})
                % check for type of file
                % [pathstr, name, ext] = fileparts(filename)
                [~, name, ext] = fileparts(varargin{1});
                
                % flag whether the map will be translated and rotated such
                % that the ego vehicle is in the origin (also time)
                transformEgoToOrigin = false;
                
                % --- OSM file ---
                if strcmp(ext,'.osm')
                    % read osm file
                    [lanelets_OSM, obstacles_OSM, egoVehicle_OSM, adjacencyGraph_OSM] = input.readOSMFile(varargin{1});
                    
                    % set transformation parameter
                    if ~isempty(egoVehicle_OSM) && transformEgoToOrigin
                        refPos = [-egoVehicle_OSM(1).trajectory.nodes(1).x, -egoVehicle_OSM(1).trajectory.nodes(1).y];
                        refOrientation = -egoVehicle_OSM(1).trajectory.nodes(1).orientation; %0;
                        refTime = -egoVehicle_OSM(1).trajectory.nodes(1).time;
                    else
                        refPos = [0,0];
                        refOrientation = 0;
                        refTime = 0;
                    end
                    
                    % create lanelet objects
                    obj.lanelets = world.Lanelet.createLaneletsFromOSM(lanelets_OSM, adjacencyGraph_OSM, refPos, refOrientation);
                    
                    % create lanes from lanelets
                    try
                        obj.lanes = world.Lane.createLanesFromLanelets(obj.lanelets);
                    catch
                        warning(['Lanes could not be created from lanelets'...
                            ' using the adjacency graph. Thus, for each '...
                            'lanelet, one lane has been created.']);
                        % create a lane for each lanelet (and do not use
                        % the adjacency graph)
                        numLanes = length(obj.lanelets);
                        for i = 1:numLanes
                            obj.lanes(i) = world.Lane(obj.lanelets(i).leftBorderVertices, obj.lanelets(i).rightBorderVertices, ...
                                obj.lanelets(i) , obj.lanelets(i).speedLimit, obj.lanelets(i).centerVertices);
                        end
                    end
                    
                    % create obstacles
                    [obstacles_dynamic, vehicles, obstacles_static] = ...
                        world.Obstacle.createObstaclesFromOSM(obstacles_OSM, obj.lanes, refPos, refOrientation, refTime);
                    obj.addObstacle([obstacles_dynamic, vehicles, obstacles_static]);
                    
                    % create ego vehicle
                    for i=1:numel(egoVehicle_OSM)
                        egoVehicle = world.EgoVehicle.createEgoVehicleFromOSM(egoVehicle_OSM(i), obj.lanes, refPos, refOrientation, refTime);
                        if ~isempty(egoVehicle)
                            obj.egoVehicle(i) = egoVehicle;
                        end
                    end
                    
                    % extract scenario meta data
                    obj.scenarioID = name;
                    
                    % find time step size
                    if ~isempty(obj.obstacles) && ~isempty(obj.obstacles(1))
                        obj.timeStepSize = obj.obstacles(1).trajectory.timeInterval.dt;
                    else
                        obj.timeStepSize = 0.1; % default value
                    end
                    
                    % --- XML file ---
                elseif strcmp(ext,'.xml')
                    % read xml file (CommonRoad Specification)
                    [lanelets_XML, obstacles_XML, egoVehicle_XML, scenarioData] = input.readXMLFile(varargin{1});
                    
                    % set transformation parameter
                    if ~isempty(egoVehicle_XML) && transformEgoToOrigin
                        refPos = [-egoVehicle_XML(1).initialState.position.point.x, -egoVehicle_XML(1).initialState.position.point.y];
                        refOrientation = -egoVehicle_XML(1).initialState.orientation;
                        refTime = -egoVehicle_XML(1).initialState.time;
                    else
                        refPos = [0,0];
                        refOrientation = 0;
                        refTime = 0;
                    end
                    
                    % extract scenario meta data
                    obj.scenarioID = scenarioData.scenarioID;
                    obj.timeStepSize = scenarioData.timeStepSize;
                    timestepSize = scenarioData.timeStepSize;
                    
                    % create lanelet objects
                    obj.lanelets = world.Lanelet.createLaneletsFromXML(lanelets_XML, refPos, refOrientation);
                    
                    % create lanes from lanelets
                    try
                        obj.lanes = world.Lane.createLanesFromLanelets(obj.lanelets);
                    catch
                        warning(['Lanes could not be created from lanelets'...
                            ' using the adjacency graph. Thus, for each '...
                            'lanelet, one lane has been created.']);
                        % create a lane for each lanelet (and do not use
                        % the adjacency graph)
                        numLanes = length(obj.lanelets);
                        for i = 1:numLanes
                            obj.lanes(i) = world.Lane(obj.lanelets(i).leftBorderVertices, obj.lanelets(i).rightBorderVertices, ...
                                obj.lanelets(i) , obj.lanelets(i).speedLimit, obj.lanelets(i).centerVertices);
                        end
                    end
                    
                    % create obstacles
                    if ~isempty(obstacles_XML)
                        obj.obstacles = world.Obstacle.createObstaclesFromXML(obstacles_XML, refPos, refOrientation, refTime);
                    end
                    
                    % create ego vehicle
                    if ~isempty(egoVehicle_XML)
                        obj.egoVehicle = world.EgoVehicle.createEgoVehicleFromXML(egoVehicle_XML,obj.lanelets, refPos, refOrientation, refTime);
                    end
                    
                else
                    error('Invalid input file. Error in world.Map');
                end
                
                % % DEBUG: (hard coded obstacles)
                % % obj = Vehicle(id, position, orientation, shape, inLane, velocity, acceleration, v_max, a_max, time, v_s, power_max)
                % % a = perception.map.lanes(3).leftBorder.vertices(:,1+1)- perception.map.lanes(3).leftBorder.vertices(:,1); b = [1;0]; orientation = acos(a'*b/(norm(a)*norm(b)))
                shape = geometry.Rectangle(4.8, 2.0);
                if strcmp(name,'Intersection_Leopold_Hohenzollern_adj_v3') %|| strcmp(name,'Intersection_Leopold_Hohenzollern_v3')
                    obj.addObstacle(world.Vehicle(1, obj.lanes(1).center.vertices(:,4), -1.841, shape, obj.lanes(1), 50/3.6, 1, 50, 8, 0, 15, 0)); %40/3.6
                    obj.addObstacle(world.Vehicle(2, obj.lanes(5).center.vertices(:,7), 1.300, shape, obj.lanes(5), 50/3.6, 1, 50, 8, 0, 15, 0));
                    obj.addObstacle(world.Vehicle(3, obj.lanes(12).center.vertices(:,4), -0.2685, shape, [obj.lanes(12), obj.lanes(13)], 50/3.6, 1, 50, 8, 0, 15, 0)); %30/3.6
                    %obj.egoVehicle = world.EgoVehicle(10, obj.lanes(8).center.vertices(:,6), -0.2685+pi, shape, obj.lanes(8), 40/3.6, 0, 50, 8, 0, 15, 0);
                elseif strcmp(name,'Intersection_Leopold_Hohenzollern_v3')
                    obj.addObstacle(world.Vehicle(1, obj.lanes(3).center.vertices(:,7), -1.841, shape, obj.lanes(3), 50/3.6, 1, 50, 8, 0, 15, 0));
                    obj.addObstacle(world.Vehicle(2, obj.lanes(1).center.vertices(:,16), pi-0.2685, shape, obj.lanes(1), 50/3.6, 1, 50, 8, 0, 15, 0));
                    obj.addObstacle(world.Vehicle(3, obj.lanes(5).center.vertices(:,9), 1.300, shape, obj.lanes(5), 50/3.6, 1, 50, 8, 0, 15, 0));
                    obj.addObstacle(world.Vehicle(4, obj.lanes(5).center.vertices(:,2), 1.300, shape, obj.lanes(5), 50/3.6, 1, 50, 8, 0, 15, 0));
                    obj.addObstacle(world.Vehicle(5, obj.lanes(6).center.vertices(:,15), 1.300, shape, obj.lanes(6), 50/3.6, 1, 50, 8, 0, 15, 0));
                    obj.addObstacle(world.Vehicle(6, obj.lanes(7).center.vertices(:,12), -0.2685, shape, obj.lanes(7), 50/3.6, 1, 50, 8, 0, 15, 0));
                elseif strcmp(name,'Intersection_Leopold_Hohenzollern_v1')
                    obj.addObstacle(world.Vehicle(1, obj.lanes(1).center.vertices(:,4), -1.841, shape, obj.lanes(1), 50/3.6, 1, 50, 8, 0, 15, 0));
                    %                     obj.addObstacle(world.Vehicle(2, obj.lanes(1).center.vertices(:,7), -1.841, shape, obj.lanes(1), 50/3.6, 1, 50, 8, 0, 15, 0));
                    %                     obj.addObstacle(world.Vehicle(3, obj.lanes(2).center.vertices(:,5), -1.841, shape, obj.lanes(2), 50/3.6, 1, 50, 8, 0, 15, 0));
                    %                     obj.addObstacle(world.Vehicle(4, obj.lanes(2).center.vertices(:,12), -1.841, shape, obj.lanes(2), 50/3.6, 1, 50, 8, 0, 15, 0));
                    %                     obj.addObstacle(world.Vehicle(5, obj.lanes(2).center.vertices(:,17), -1.841, shape, obj.lanes(2), 50/3.6, 1, 50, 8, 0, 15, 0));
                    %                     obj.addObstacle(world.Vehicle(6, obj.lanes(1).center.vertices(:,15), pi-0.2685, shape, obj.lanes(1), 50/3.6, 1, 50, 8, 0, 15, 0));
                elseif strcmp(name,'Example_straight_2lanes')
                    obj.addObstacle(world.Vehicle(1, obj.lanes(1).center.vertices(:,3) - [13;0], 0, shape, obj.lanes(1), 60/3.6, 0, 50, 8, 0, 5, 0));
                    obj.addObstacle(world.Vehicle(2, obj.lanes(2).center.vertices(:,13), 0, shape, obj.lanes(1), 40/3.6, 0, 50, 8, 0, 5, 0));
                    %obj.addObstacle(world.Vehicle(3, obj.lanes(1).center.vertices(:,6), 0.0332, shape, obj.lanes(1), 50/3.6, 0, 50, 8, 0, 15, 0)); %40/3.6
                    %obj.addObstacle(world.Vehicle(4, obj.lanes(2).center.vertices(:,8), pi+0.0332, shape, obj.lanes(2), 50/3.6, 0, 50, 8, 0, 15, 0));
                elseif strcmp(name,'Example_straight_2lanes_extended_PNR')
                    % SPOT example:
                    %obj.addObstacle(world.Vehicle(1, obj.lanes(1).center.vertices(:,7), 0, shape, obj.lanes(1), 40/3.6, 0, 50, 8, 0, 5, 0));
                    %obj.egoVehicle = world.EgoVehicle(2, obj.lanes(1).center.vertices(:,3) - [20-0.962710174499080;0], 0, shape, obj.lanes(1), 60/3.6, 0, 50, 8, 0, 5, 0);
                    %obj.addObstacle(world.Vehicle(3, obj.lanes(2).center.vertices(:,22), pi, shape, obj.lanes(2), 60/3.6, 0, 50, 8, 0, 5, 0));
                    
                    % PNR paper:
                    obj.addObstacle(world.Vehicle(1, obj.lanes(1).center.vertices(:,3), 0, shape, obj.lanes(1), 40/3.6, 0, 50, 8, 0, 5, 0));
                    obj.obstacles(1).set('v_max',40/3.6) % assumption of preceding vehicle
                    obj.egoVehicle = world.EgoVehicle(2, obj.lanes(1).center.vertices(:,3) - [20-0.962710174499080;0], 0, shape, obj.lanes(1), 60/3.6, 0, 50, 8, 0, 5, 0);
                    obj.addObstacle(world.Vehicle(3, obj.lanes(2).center.vertices(:,15), pi, shape, obj.lanes(2), 60/3.6, 0, 50, 8, 0, 5, 0));
                    %obj.addObstacle(world.Vehicle(4, obj.lanes(2).center.vertices(:,22), pi, shape, obj.lanes(2), 60/3.6, 0, 50, 8, 0, 5, 0));
                elseif strcmp(name,'Intersection_Leopold_Hohenzollern_adj_v3_PNR')
                    obj.addObstacle(world.Vehicle(1, obj.lanes(11).center.vertices(:,5), pi/2, shape, obj.lanes(11), 50/3.6, 0, 50, 8, 0, 5, 0));
                    obj.egoVehicle = world.EgoVehicle(2, obj.lanes(3).center.vertices(:,7), 0, shape, obj.lanes(3), 50/3.6, 0, 50, 8, 0, 5, 0);
                elseif strcmp(name,'3_lanes_A9_Freimann_1_direction')
                    obj.addObstacle(world.Vehicle(1, obj.lanes(1).center.vertices(:,5), 1.265, shape, obj.lanes(1), 30, 0, 50, 5, 0, 30, 0));
                    obj.addObstacle(world.Vehicle(2, obj.lanes(3).center.vertices(:,7), 1.265, shape, obj.lanes(1), 30, 0, 50, 5, 0, 30, 0));
                end
                
                % create trajectory for obstacles (along center line)
                %for i = 1:numel(obj.obstacles)
                %    obj.obstacles(i).trajectory.defineTrajectory(perception.map.obstacles(i), timeInterval_trajectory);
                %end
                
                
                % load overtaking trajectory
                %load('scenarios/chrstian/Example_straight_2lanes_trajectory_overtaking_60kmh-2.mat');
                %load('scenarios/chrstian/Example_straight_2lanes_trajectory_overtaking_70kmh-2.mat');
                %perception.map.egoVehicle.trajectory.setTrajectory(t_o, x_o, y_o, theta_o, v_o, a_lon_o);
            end
            
            % find time of scenario
            if ~isempty(obj.egoVehicle) && ~isempty(obj.egoVehicle(1).trajectory)
                time = obj.egoVehicle(1).trajectory.timeInterval.ts;
            elseif ~isempty(obj.egoVehicle) && ~isempty(obj.egoVehicle(1).time)
                time = obj.egoVehicle(1).time;
            elseif ~isempty(obj.obstacles) && ...
                    isa(obj.obstacles(1), 'world.DynamicObstacle') && ...
                    ~isempty(obj.obstacles(1).trajectory)
                time = obj.obstacles(1).trajectory.timeInterval.ts;
            else
                time = 0;
            end
            
            % set time
            obj.time = time;
            
            % update map to its time
            obj.update(obj.time);
        end
        
        
        % function to add obstacle(s) as a map property
        function addObstacle(obj, obstacle)
            if isa(obstacle, 'world.Obstacle')
                for i = 1:numel(obstacle)
                    obj.obstacles(end+1) = obstacle(i);
                end
            else
                error(['Input argument is not an instance of the class '...
                    'Obstacle. Error in world.Map/addObstacle']);
            end
        end
        
        
        % set functions
        function setLanelets(obj, lanelets)
            obj.lanes = world.Lane.createLanesFromLanelets(lanelets);
            obj.lanelets = lanelets;
        end
        
        function setScenarioID(obj, ID)
            if ischar(ID)
                obj.scenarioID = ID;
            end
        end
        
        function setTimeStepSize(obj, dt)
            if isnumeric(dt)
                obj.timeStepSize = dt;
            end
        end
        
        
        % methods in seperate files:        
        createBorderObstacles(obj,lambda)
        
        % Dynamic class methods
        step(obj)
        update(varargin)
        
        % visualization methods
        disp(obj)
        plot(varargin) % argin: obj, timeInterval
        plotDynamic(varargin)
    end
end

%------------- END CODE --------------