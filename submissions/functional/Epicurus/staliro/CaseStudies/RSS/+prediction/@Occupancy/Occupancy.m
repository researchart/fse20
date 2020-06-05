classdef Occupancy < handle
    % Occupancy - class to predict the occupancy of other obstacles
    %
    % Syntax:
    %   object constructor: obj = Occupancy(varargin)
    %
    % Inputs:
    %   obstacle
    %   OR
    %   forLane
    %   timeInterval
    %   vertices
    %
    % Outputs:
    %   obj - generated object
    %
    % Other m-files required: none
    % Subfunctions: computeOccupancyCore, computeOccupancyAlongTrajectory
    % MAT-files required: none
    %
    % See also: Althoff and Magdici, 2016, Set-Based Prediction of Traffic
    % Participants on Arbitrary Road Networks, IV. Occupancy Prediction
    
    % Author:       Markus Koschi
    % Written:      06-September-2016
    % Last update:  27-October-2016
    %               02-November-2016
    %
    % Last revision:---
    
    %------------- BEGIN CODE --------------
    
    properties (SetAccess = protected, GetAccess = public)
        forLane = world.Lane.empty();
        timeInterval = globalPck.TimeInterval.empty();
        vertices = [];
    end
    
    % constant, global occupancy properties
    properties (Constant, GetAccess = public)
        % general
        COMPUTE_OCC_M1 = true;
        COMPUTE_OCC_M2 = true;
        
        % obstacles
        INITIAL_SPEEDING_FACTOR = 0.2;
        
        % lanes
        EXTEND_LANES_BACKWARD = false;
        EXTEND_LANES_FORWARD = false;
    end
    
    methods
        % class constructor
        function obj = Occupancy(varargin)
            if nargin == 1 && isa(varargin{1}, 'world.Obstacle')
                % argin: (obstacle)
                % initialise the occupancy of the obstacle for a zero time
                % interval, i.e. only the obstacle's dimensions
                if ~isempty(varargin{1}.inLane)
                    obj.forLane = varargin{1}.inLane;
                end
                obj.timeInterval = globalPck.TimeInterval(0, 1, 0);
                obj.vertices = obj.M1_accelerationBasedOccupancy(varargin{1}, 0, 1, 0);
            elseif nargin == 3 && isa(varargin{2}, 'globalPck.TimeInterval')
                % argin: (forLane, timeInterval, vertices)
                obj.forLane = varargin{1};
                obj.timeInterval = varargin{2};
                obj.vertices = varargin{3};
            end
        end
        
        % methods in seperate files:
        % occupancy
        [obj] = computeOccupancyCore(obj, obstacle, map, timeInterval)
        [obj] = manageConstraints(obj, obstacle)
        [occM1] = M1_accelerationBasedOccupancy(obj, obstacle, ts, dt, tf)
        [occM2] = M2_laneFollowingOccupancy(obj, obstacle, lane, ts, dt, tf)
        [obj] = computeOccupancyAlongTrajectory(obj, obstacle, map, timeInterval)
        
        % visualization methods
        disp(obj)
        plot(varargin) % argin: obj, timeInterval
    end
    
    methods(Access = ?globalPck.Perception)
        function [] = updateOccupancy(obj, vertices)
            obj.vertices = vertices;
        end
    end
    
    % static methods in seperate files
    methods(Static)
        % reachable lanes
        [reachableLanes] = findAllReachableLanes(lanes, constraint5, obstacleInLane)
        
        % M_1        
        [q] = accelerationOccupancyLocal(vx, a_max, tk, tkplus1, constraint3)
        
        % M_2
        [xi] = closestLongitudinalReach(t, v0, a_max, constraint3)
        [xi] = furthestLongitudinalReach(t, v0, v_s, v_max, a_max)
        [vertices] = inflectionPointSegmentation(iPath_Obstacle, xiObstacle, xiClosest, xiFurthest, shortestPath, leftBorder, rightBorder)
        [bound, iLeftBorder_Bound, iRightBorder_Bound] = constructBound(iPath_Obstacle, xiBound, typeOfBound, xi, shortestPath, leftBorder, rightBorder)
    end
end

%------------- END CODE --------------