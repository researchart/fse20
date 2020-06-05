classdef GoalRegion
    % GoalRegion - class for defining the goal region of the ego vehicle
    %
    % Syntax:
    %  object constructor: obj = GoalRegion(varargin)
    %
    % Inputs:
    %   position
    %   orientation
    %   time
    %   velocity
    %   acceleration
    %
    % Outputs:
    %   obj - generated object
    %
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: none
    
    % Author:       Markus Koschi
    % Written:      06-April-2017
    % Last update:
    %
    % Last revision:---
    
    %------------- BEGIN CODE --------------
    properties
        position = []; % can be point, shape (rectangle/circle/polygon), or lanelet
        orientation = [];
        time = [];
        velocity = [];
        acceleration = [];
    end
    
    methods
        % class constructor
        function obj = GoalRegion(position, orientation, time, velocity, acceleration)
            if nargin >= 3
                obj.position = position;
                obj.orientation = orientation;
                obj.time = time;
            end
            
            if nargin >= 4
                obj.velocity = velocity;
            end
            
            if nargin >= 5
                obj.acceleration = acceleration;
            end
        end
                
        % visualization methods in seperate files
        disp(obj)
        plot(obj)
    end
    
    methods (Static)
        [goalRegionRectangle] = createGRRFromPosition(lanes, position, width, ratio, inlane_idx)
    end
    
end

%------------- END CODE --------------
