classdef Polygon < geometry.Shape
    % Polygon - class for describing polygons
    %
    % v1--v2---v3---v4
    % |              |
    % vN+2           v5
    % |              |
    % vN+1--vN-...--v6
    %
    % Syntax:
    %   object constructor: obj = Polygon(width, length, position, orientation)
    %
    % Inputs:
    %   vertices - array of points which define the polygon
    %                vertices = [x ; y], x = vector of x-coordinates of all
    %                points, y = vector of y-coordinates of all points
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
        vertices = [];
    end
    
    methods
        % class constructor
        function obj = Polygon(vertices)
            if size(vertices,2) == 2 && size(vertices,1) ~= 2
                obj.vertices = vertices';
            else
                obj.vertices = vertices;
            end
            %order vertices in clockwise order
            if ~ispolycw(obj.vertices(1,:),obj.vertices(2,:))
                obj.vertices(1,:) = fliplr(obj.vertices(1,:));
                obj.vertices(2,:) = fliplr(obj.vertices(2,:));
                %obj.vertices = poly2cw(obj.vertices(1,:),obj.vertices(2,:));
            end
        end
        
        % visualization methods
        disp(obj)
        plot(varargin)
    end
    
end

%------------- END CODE --------------