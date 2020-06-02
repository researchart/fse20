classdef Triangle < geometry.Shape
    % TRIANGLE - class for describing triangles
    % (vertices in clockwise order)
    %
    %    % v1
    %    |\
    %    | \
    %    |  \
    %    |   \
    %    |    \
    % v3 -------v2
    %
    % Syntax:
    %   object constructor: obj = Triangle(x1, y1, x2, y2, x3, y3)
    %
    % Inputs:
    %   vertices - array of points which define the triangle
    %                vertices = [x ; y], x = vector of x-coordinates of all
    %                points, y = vector of y-coordinates of all points
    %
    % Outputs:
    %   obj - generated object
    %
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: none
    
    % Author:       Vanessa Bui, Markus Koschi
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
        function obj = Triangle(x1, y1, x2, y2, x3, y3)
            if nargin == 6
                obj.vertices = [x1, x2, x3 ; y1, y2, y3];
            end
        end
        
        % visualization methods
        disp(obj)
        plot(varargin)
    end
    
end

%------------- END CODE --------------