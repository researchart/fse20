classdef Vehicle < world.DynamicObstacle
    % Vehicle - class for describing vehicles
    %
    % Syntax:
    %   object constructor: obj = Vehicle(id, position, orientation,...
    %           width, length, inLane, velocity, acceleration, v_max, a_max,...
    %           time, v_s, power_max)
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
    % Written:      26-October-2016
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
        % velocity = [];
        % acceleration = [];
        % v_max = inf;
        % a_max = inf;
        % time = 0;
        % trajectory = globalPck.Trajectory.emtpy();
        % occupancy = prediction.Occupancy.empty();
        
        v_s = 5; %inf;
        power_max = inf;
    end
    
    methods
        % class constructor
        function obj = Vehicle(id, position, orientation, shape, ...
                inLane, velocity, acceleration, v_max, a_max, time, v_s, power_max)
            % instantiate parent class
            if nargin >= 10
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
            obj = obj@world.DynamicObstacle(super_args{:});
            
            % set vehicle properties
            if nargin >= 11 && ~isempty(v_s)
                obj.v_s = v_s;
            end
            if nargin == 12
                obj.power_max = power_max;
            end
            
            % old code:
            % % add missing parameters to each car
            % for i=1:length(cars);
            %     if isempty(cars(i).a_max)
            %         cars(i).a_max = 5;
            %     end
            %     if isempty(cars(i).v_max)
            %         cars(i).v_max = 50;
            %     end
            %     if isempty(cars(i).v_s)
            %         cars(i).v_s = 30;
            %     end
            % end
        end
        
        % methods in seperate files:
        % set function
        set(obj, propertyName, propertyValue)
        
        % Dynamic class methods
        step(obj)
        update(varargin)
        
        % visualization methods
        disp(obj)
        % plot(varargin) % implemented in superclass Obstacle
    end
end

%------------- END CODE --------------