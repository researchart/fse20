classdef DynamicObstacle < world.Obstacle & globalPck.Dynamic
    % DynamicObstacle - class for describing dynamic obstacles
    %
    % Syntax:
    %   object constructor: obj = DynamicObstacle(id, position, orientation, ...
    %            shape, inLane, velocity, acceleration, v_max, a_max, time)
    %
    % Inputs:
    %   id - unique id of the obstacle
    %   position - position of the obstacle's center in UTM coordinates
    %   orientation - orientation of the obstacle in radians
    %   shape - obstacle's dimensions (object of class Shape)
    %   inLane - lane, in which the obstacle is located in
    %   velocity - scalar velocity of the obstacle in m/s
    %   acceleration - scalar acceleration of the obstacle in m/s^2
    %   v_max - maximum velocity of the obstacle in m/s
    %   a_max - maximum absolute acceleration of the obstacle in m/s^2
    %   time - current time of the obstacle
    %
    % Outputs:
    %   obj - generated object
    %
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: none
    
    % Author:       Markus Koschi
    % Written:      27-October-2016
    % Last update:  06-April-2017
    %
    % Last revision:---
    
    %------------- BEGIN CODE --------------
    
    properties (SetAccess = protected, GetAccess = public)
        % inherited from parent classes:
        % id = [];
        % position = [];
        % orientation = [];
        % shape = geometry.Shape.empty();
        % inLane = world.Lane.empty();
        % time = 0;
        % occupancy = prediction.Occupancy.empty();
        
        velocity = [];
        acceleration = [];
        v_max = 83.3333; % = 300km/h
        a_max = 8; %inf;
        trajectory = globalPck.Trajectory.empty();
        
        % constraints for occupancy prediction:
        % parameter, how many percent above the speed limit the obstacle's
        % speed can get
        speedingFactor = prediction.Occupancy.INITIAL_SPEEDING_FACTOR;
        % constraint C3: backward driving is not allowed by default, i.e.
        % constraint3 is true
        constraint3 = true;
        % constraint C5: changing and crossing lanes is forbidden unless
        % allowed by traffic regulations. if traffic participant is
        % following the rules, constraint5 is true
        constraint5 = true; %WARNING: false might not work yet
    end
    
    methods
        % class constructor
        function obj = DynamicObstacle(id, position, orientation, ...
                shape, inLane, velocity, acceleration, v_max, a_max, time)
            
            % set current position and orientation
            if nargin >= 2 && ~isempty(position) && ~isempty(orientation)
                position_static = position(1:2,1);
                orientation_static = orientation(1);
            else
                position_static = [];
                orientation_static = [];
            end
            
            % instantiate parent class
            if nargin >= 5
                super_args = {id, position_static, orientation_static, shape, inLane};
            elseif nargin >= 4
                super_args = {id, position_static, orientation_static, shape};
            else
                super_args = {};
            end
            obj = obj@world.Obstacle(super_args{:});
            
            % set current velocity and acceleration
            if nargin >= 6 && ~isempty(velocity)
                obj.velocity = velocity(1);
            end
            if nargin >= 7 && ~isempty(acceleration)
                obj.acceleration = acceleration(1);
            end
            
            % set maximal velocity and acceleration of obstacle
            if nargin >= 8 && ~isempty(v_max)
                obj.v_max = v_max;
            end
            if nargin >= 9 && ~isempty(a_max)
                obj.a_max = a_max;
            end
            
            if nargin >= 10 && ~isempty(time)
                obj.time = time;
            end
            
            % (trajectory is set with method setTrajectory)
        end
        
        % methods in seperate files:
        % set methods
        set(obj, propertyName, propertyValue)
        setTrajectory(obj, trajectory)
        
        % Dynamic class methods
        step(obj)
        update(varargin)
        
        inLane = updateInLane(obj, lanes)
        
        % visualization methods
        disp(obj)
        % plot(varargin) % implemented in superclass Obstacle
    end
end
