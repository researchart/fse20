classdef StaticObstacle < world.Obstacle
    % Obstacle - class for describing static obstacles
    %
    % Syntax:
    %   object constructor: obj = StaticObstacle(position, orientation, shape, inLane)
    %
    % Inputs:
    %   position - position of the obstacle's center in UTM coordinates
    %   orientation - orientation of the obstacle in radians
    %   shape - obstacle's dimensions (object of class Shape)
    %   inLane - lane, in which the obstacle is located in
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
        % inherited from abstract class Obstacle:
        % id = [];
        % position = [];
        % orientation = [];
        % shape = geometry.Shape.empty();
        % inLane = world.Lane.empty();
        % occupancy = prediction.Occupancy.empty();
        % color = [rand, rand, rand];
    end
    
    methods
        % class constructor
        function obj = StaticObstacle(id, position, orientation, shape, inLane)
            % instantiate parent class
            if nargin == 5
                super_args = {id, position, orientation, shape, inLane};
            elseif nargin == 4
                super_args = {id, position, orientation, shape};
            else
                super_args = {0};
            end
            obj = obj@world.Obstacle(super_args{:});
            
            % set color specific for static obstacles
            if ~isempty(globalPck.PlotProperties.COLOR_OBSTACLES_STATIC)
                obj.color = globalPck.PlotProperties.COLOR_OBSTACLES_STATIC;
            end
        end
        
        % methods in seperate files:
        disp(obj)
        % plot(varargin) % implemented in superclass Obstacle
    end
end
