classdef EgoVehicle < world.Vehicle
    % EgoVehicle - class for describing ego vehicles
    %
    % Syntax:
    %   object constructor: obj = EgoVehicle(id, position, orientation, width, ...
    %           length, inLanelet, velocity, v_max, a_max, time, inLanelet, v_s, power_max, ...
    %           goalRegion)
    %
    % Inputs:
    %   id - unique id of the obstacle
    %   position - position of the obstacle's center in UTM coordinates
    %   orientation - orientation of the obstacle in radians
    %   width - width of the obstacle in m
    %   length - length of the obstacle in m
    %   inLanelet - lanelet, in which the obstacle is located in
    %   velocity - scalar velocity of the obstacle in m/s
    %   acceleration - scalar acceleration of the obstacle in m/s^2
    %   v_max - maximum velocity of the obstacle in m/s
    %   a_max - maximum absolute acceleration of the obstacle in m/s^2
    %   time - current time of the obstacle
    %   v_s - switching velocity in m/s (modeling limited engine power)
    %   power_max - maximmum power for accelerating (currently unused)
    %
    % Outputs:
    %   obj - generated object
    %
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: none
    
    % Author:       Markus Koschi
    % Written:      20-January-2017
    % Last update:  06-April-2017
    %
    % Last revision:---
    
    %------------- BEGIN CODE --------------
    
    properties (SetAccess = {?world.Obstacle}, GetAccess = public)
        % inherited from parent classes:
        % id = [];
        % position = [];
        % orientation = [];
        % width = [];
        % length = [];
        % velocity = [];
        % acceleration = [];
        % v_max = inf;
        % a_max = inf;
        % time = 0;
        % inLanelet = world.Lanelet.empty();
        % trajectory = globalPck.Trajectory.emtpy();
        % occupancy = prediction.Occupancy.empty();
        % v_s = inf;
        % power_max = inf;
        
        occupancy_trajectory = prediction.Occupancy.empty();
        goalRegion = globalPck.GoalRegion.empty();
    end
    
    methods
        % class constructor
        function obj = EgoVehicle(id, position, orientation, shape, ...
                inLane, velocity, acceleration, v_max, a_max, time, v_s, power_max, ...
                goalRegion)
            % instantiate parent class
            if nargin >= 12
                super_args = {id, position, orientation, shape, inLane, velocity, acceleration, v_max, a_max, time, v_s, power_max};
            elseif nargin >= 10
                super_args = {id, position, orientation, shape, inLane, velocity, acceleration, v_max, a_max, time};
            elseif nargin >= 9
                super_args = {id, position, orientation, shape, inLane, velocity, acceleration, v_max, a_max};
            elseif nargin >= 7
                super_args = {id, position, orientation, shape, inLane, velocity, acceleration};
            elseif nargin >= 5
                super_args = {id, position, orientation, shape, inLane};
            elseif nargin >= 4
                super_args = {id, position, orientation, shape};
            elseif nargin >= 3
                super_args = {id, position, orientation};
            else
                super_args = {};
            end
            obj = obj@world.Vehicle(super_args{:});
            
            obj.color = globalPck.PlotProperties.COLOR_EGO_VEHICLE;
            
            % set ego vehicle properties (goal region)
            if nargin == 13 && isa(goalRegion, 'globalPck.GoalRegion')
                obj.goalRegion = goalRegion;
            end
        end
        
        % set goal region
        function setGoalRegion(obj, goalRegion)
            if isa(goalRegion, 'globalPck.GoalRegion')
                obj.goalRegion = goalRegion;
            end
        end
        
        % methods in seperate files:
        
        %set(obj, propertyName, propertyValue)  % implemented in superclass Vehicle
        %setTrajectory(obj, trajectory)  % implemented in superclass Vehicle
        
        % Dynamic class methods        
        %step(obj) % implemented in superclass DynamicObstacle
        %update(varargin) % implemented in superclass DynamicObstacle
        
        % visualization methods
        disp(obj)
        plot(varargin)     
    end
    
    methods (Static)
        % static methods in seperate files
        [egoVehicle] = createEgoVehicleFromXML(egoVehicle_XML,lanelets, refPos, refOrientation, refTime) 
        [egoVehicle] = createEgoVehicleFromOSM(egoVehicle_OSM, lanes, refPos, refOrientation, refTime)
    end 
end

%------------- END CODE --------------