classdef Rectangle < geometry.Shape
    % Rectangle - class for describing rectangles
    %
    % v4 ---------------------- v1
    %    |                    |
    %    |                    |
    %    |        +--->       |  obj.width
    %    |        position    |
    %    |        orientation |
    % v3 ---------------------- v2
    %         obj.length
    %
    % Syntax:
    %   object constructor: obj = Rectangle(width, length, position, orientation)
    %
    % Inputs:
    %   length - length of the obstacle in m
    %   width - width of the obstacle in m
    %   position - position of the rectangle's center
    %   orientation - orientation of the rectangle in radians
    %
    % Outputs:
    %   obj - generated object
    %
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: none
    
    % Author:       Markus Koschi
    % Written:      08-February-2017
    % Last update:
    %
    % Last revision:---
    
    %------------- BEGIN CODE --------------
    
    properties (SetAccess = protected, GetAccess = public)
        length = [];
        width = [];
        position = [];
        orientation = [];
    end
    
    %     properties (SetAccess = protected, GetAccess = public)
    %         radius
    %         vertices
    %     end
    
    methods
        % class constructor
        function obj = Rectangle(length, width, position, orientation)
            if nargin >= 2
                obj.length = length;
                obj.width = width;
            end
            
            if nargin == 4
                if size(position,2) == 2
                    obj.position = position';
                else
                    obj.position = position;
                end
                obj.orientation = orientation;
            end
            
            %             obj.radius = sqrt(width^2/4+height^2/4);
            %
            %             w = obj.height/2;
            %             h = obj.width/2;
            %             vert = [w w -w -w; h -h -h h];
            %             vert = geometry.rot2d(obj.orientation, vert);
            %             vert = [vert(1,:) + obj.position(1); vert(2,:) + obj.position(2)];
            %             obj.vertices = vert;
        end
        
        % visualization methods
        disp(obj)
        plot(varargin)
    end
    
end

%------------- END CODE --------------