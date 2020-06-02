function plot(varargin)
% plot - plots a Rectangle object
%
% Syntax:
%   plot(varargin)
%
% Inputs:
%   obj - Rectangle object
%   color - color to plot
%   position - coordinates of rectangle's center
%   orientation - orientation of the rectangle
%
% Outputs:
%   none
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

if nargin == 1 && ~isempty(varargin{1}.position) && ~isempty(varargin{1}.orientation)
    obj = varargin{1};
    color = [rand, rand, rand];
    position = obj.position;
    orientation = obj.orientation;
elseif nargin == 2 && ~isempty(varargin{1}.position) && ~isempty(varargin{1}.orientation)
    obj = varargin{1};
    color = varargin{2};
    position = obj.position;
    orientation = obj.orientation;  
elseif nargin == 4
    obj = varargin{1};
    color = varargin{2};
    position = varargin{3};
    orientation = varargin{4};    
else
    return;
end

vertices = geometry.rotateAndTranslateVertices(geometry.addObjectDimensions([0;0], obj.length, obj.width), position, orientation);
fill(vertices(1,:), vertices(2,:), color, 'FaceAlpha', 1, 'EdgeColor', 'k');

end

%------------- END CODE --------------