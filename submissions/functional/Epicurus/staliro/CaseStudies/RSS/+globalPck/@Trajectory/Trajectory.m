classdef Trajectory < handle
    % Trajectory - class to describe the configuration of an dynamic
    % obstacle over time
    %
    % Syntax:
    %   obj = Trajectory(timeInterval, position, velocity, acceleration, inLane)
    %
    % Inputs: (all row vectors with the same length)
    %   position - position of the obstacle's center in UTM coordinates [x;y]
    %   orientation - orientation of the obstacle in radians
    %   velocity - velocity of the obstacle in m/s
    %   acceleration - acceleration of the obstacle in m/s^2 
    %
    % Outputs:
    %   obj - generated object
    %
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: none
    
    % Author:       Markus Koschi
    % Written:      15-November-2016
    % Last update:  16-August-2017
    %
    % Last revision:---
    
    %------------- BEGIN CODE --------------
    
    properties (SetAccess = protected, GetAccess = public)
        timeInterval = globalPck.TimeInterval.empty();
        position = [];
        orientation = [];
        velocity = [];
        acceleration = [];
        %inLane = world.Lane.empty();
    end
    
    methods
         % class constructor
        function obj = Trajectory(timeInterval, position, orientation, ...
                                  velocity, acceleration)
            if nargin >= 3
                obj.timeInterval = timeInterval;
                obj.position = position;
                obj.orientation = wrapToPi(orientation);
            end
            if nargin >= 4
                obj.velocity = velocity;
            end
            if nargin == 5
                obj.acceleration = acceleration;
            end
        end
        
        % get methods
        function position = getPosition(obj, t)
            try
                position = obj.position(:,obj.timeInterval.getIndex(t));
            catch
                position = [];
            end
        end
        
        function orientation = getOrientation(obj, t)
            try
                orientation = obj.orientation(:,obj.timeInterval.getIndex(t));
            catch
                orientation = [];
            end
        end
        
        function velocity = getVelocity(obj, t)
            try
                velocity = obj.velocity(:,obj.timeInterval.getIndex(t));
            catch
                velocity = [];
            end
        end
        
        function acceleration = getAcceleration(obj, t)
            try
                acceleration = obj.acceleration(:,obj.timeInterval.getIndex(t));
            catch
                acceleration = [];
            end
        end   
        
        % set methods
        function setOrientation(obj, orientation)            
            if numel(obj.orientation) == numel(orientation)
                obj.orientation = orientation;
            else
                warning('number of orientation points does not fit');
            end
            
        end
        
        % methods in seperate files:
        % set trajectory
        setTrajectory(obj, t, x, y, theta, v, a)
        
        % create trajectory along center vertices with constant speed
        defineTrajectory(obj, obstacle, timeInterval, inLane_idx)
        
        % visualization methods
        disp(obj)
        plot(varargin) % argin: obj, timeInterval
    end
end

%------------- END CODE --------------