function plot(varargin)
% plot - plots a Triangle object
%
% Syntax:
%   plot(obj, color)
%
% Inputs:
%   obj - Triangle object
%   color - color to plot
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

if nargin == 1
    obj = varargin{1};
    color = [rand, rand, rand];
elseif nargin >= 2
    obj = varargin{1};
    color = varargin{2};
end

fill(obj.vertices(1,:), obj.vertices(2,:), color, 'FaceAlpha', 0.1, 'EdgeColor', 'k');

end

%------------- END CODE --------------