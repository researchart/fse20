function plot(varargin)
% plot - plots a Obstacle object
%
% Syntax:
%   plot(obj, timeInterval)
%
% Inputs:
%   obj - Obstacle object
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
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

if nargin == 1
    % plot the obstacle for the current time
    obj = varargin{1};
    timeInterval = globalPck.TimeInterval.empty();
elseif nargin == 2
    % plot the obstacle for the time interval
    obj = varargin{1};
    timeInterval = varargin{2};
elseif nargin == 3
    % plot the obstacle for the time interval
    obj = varargin{1};
    timeInterval = varargin{2};
    params = varargin{3};
end

hold on

for i = 1:numel(obj)   
    % plot obstacle's occupancy
    if globalPck.PlotProperties.SHOW_PREDICTED_OCCUPANCIES && ~isempty(obj(i).occupancy) && ...
            ~isempty(obj(i).occupancy(1,1).timeInterval) && ...
            (~isa(obj(i), 'world.EgoVehicle') || globalPck.PlotProperties.SHOW_PREDICTED_OCCUPANCIES_EGO)
        obj(i).occupancy.plot(timeInterval, obj(i).color);
    end
    if isa(obj(i), 'world.EgoVehicle') && ~isempty(obj(i).occupancy_trajectory) && ...
            ~isempty(obj(i).occupancy_trajectory(1,1).timeInterval) && ...
            globalPck.PlotProperties.SHOW_TRAJECTORY_OCCUPANCIES_EGO
        obj(i).occupancy_trajectory.plot(timeInterval, globalPck.PlotProperties.COLOR_TRAJECTORY_OCCUPANCIES_EGO);
    end
    
    % plot obstacle's dimensions
    if ~isempty(obj(i).shape) && isa(obj(i).shape, 'geometry.Shape')
        obj(i).shape.plot(obj(i).color, obj(i).position, obj(i).orientation);
    end
    
    % plot obstacle's trajectory
    if isa(obj(i), 'world.DynamicObstacle') && (globalPck.PlotProperties.SHOW_TRAJECTORIES || ...
             (isa(obj(i), 'world.EgoVehicle') && globalPck.PlotProperties.SHOW_TRAJECTORIES_EGO)) && ...
              ~isempty(obj(i).trajectory)
          if isempty(obj(i).inLane)==0
            obj(i).trajectory.plot(timeInterval, obj(i).color, obj(i).inLane(1).center.vertices(1,1));
          else
              %TEST added by Mohammad
            %obj(i).trajectory.plot(timeInterval, obj(i).color, -16);
            obj(i).trajectory.plot(timeInterval, obj(i).color);
          end
    end
    
    % plot obstacle's center
    if globalPck.PlotProperties.SHOW_OBSTACLES_CENTER
        plot(obj(i).position(1), obj(i).position(2), 'Color', 'k', 'Marker', 'x', 'MarkerSize', 3);
    end
    
    % print description
    if globalPck.PlotProperties.SHOW_OBJECT_NAMES && ~isempty(obj(i).position)
        if isa(obj(i), 'world.EgoVehicle')
            string = sprintf('ego %d', obj(i).id);
        else
            string = sprintf('obs %d', obj(i).id);
        end
        text(obj(i).position(1)+1, obj(i).position(2), 0, string,'FontSize',8);
        %text(obj(i).position(1), obj(i).position(2), 0, ['\leftarrow ', string]);
    end
end

end

%------------- END CODE --------------