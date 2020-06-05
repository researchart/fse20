function plot(varargin)
% plot - plots a Map object
%
% Syntax:
%   plot(obj, timeInterval)
%
% Inputs:
%   obj - Map object
%   timeInterval - TimeInterval object
%
% Outputs:
%   none
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

if nargin == 1
    % plot the map for the current time
    obj = varargin{1};
    timeInterval = globalPck.TimeInterval.empty();
    idSet = [];
%elseif nargin == 2
    % plot the map for the time interval
%    obj = varargin{1};
%    timeInterval = varargin{2};
%end
elseif nargin == 2
    % plot the map for the time interval
    obj = varargin{1};
    if (isa(varargin{2},'globalPck.TimeInterval'))
        timeInterval = varargin{2};
    else
        idSet = varargin{2};
    end
elseif nargin == 3
    obj = varargin{1};
    timeInterval = varargin{2};
    idSet = varargin{3};
elseif nargin == 4
    obj = varargin{1};
    timeInterval = varargin{2};
    idSet = varargin{3};
    params = varargin{4};
end

% plot all obstacles of map object (which are set at the current time)
if globalPck.PlotProperties.SHOW_OBSTACLES
    for i = 1:numel(obj.obstacles)
        if (isa(obj.obstacles(i), 'world.StaticObstacle') || ...
                ~isempty(obj.obstacles(i).time) && ...
                (isempty(idSet) || ismember(obj.obstacles(i).id, idSet)))
                %(obj.obstacles(i).id==692 || obj.obstacles(i).id==708 || obj.obstacles(i).id==675)
            %if obj.obstacles(i).id==675
            %    obj.obstacles(i).id;
            %end
            obj.obstacles(i).plot(timeInterval, params);
        end
    end
end

% plot all ego vehicles of map object
if globalPck.PlotProperties.SHOW_EGO_VEHICLE
    obj.egoVehicle(:).plot(timeInterval);
end

% plot all lanes of map object
if globalPck.PlotProperties.SHOW_LANES
    obj.lanes(:).plot();
end
end

%------------- END CODE --------------