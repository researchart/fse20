function plot(varargin)
% plot - plots a EgoVehicle object
%
% Syntax:
%   plot(obj, timeInterval)
%
% Inputs:
%   obj - EgoVehicle object
%   timeInterval - TimeInterval object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      18-April-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

if nargin == 1
    % plot the egoVehicle for the current time
    obj = varargin{1};
    timeInterval = globalPck.TimeInterval.empty();
elseif nargin == 2
    % plot the egoVehicle for the time interval
    obj = varargin{1};
    timeInterval = varargin{2};
end

hold on

for i = 1:numel(obj)
    
    % plot the goal region
    for j = 1:numel(obj(i).goalRegion)
        obj(i).goalRegion(j).plot;
    end
    
    % call the plot method of superclass Obstacle
    if ~isempty(timeInterval)
        plot@world.Obstacle(obj(i), timeInterval)
    else
        plot@world.Obstacle(obj(i))
    end
end

end

%------------- END CODE --------------