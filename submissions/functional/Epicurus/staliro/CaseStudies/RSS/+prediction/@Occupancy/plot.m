function plot(varargin)
% plot - plots a Occupancy object
%
% Syntax:
%   plot(obj, timeInterval, color)
%
% Inputs:
%   obj - Occupancy object
%   timeInterval - TimeInterval object
%   color - color of obstacle
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

% select inputs
if nargin == 1
    % plot the occupancy for the current time
    obj = varargin{1};
    timeInterval = globalPck.TimeInterval.empty();
    color = [rand, rand, rand]; %RGB triplet
elseif nargin == 2
    % plot the occupancy for the time interval
    obj = varargin{1};
    timeInterval = varargin{2};
    color = [rand, rand, rand]; %RGB triplet
elseif nargin == 3
    % plot the occupancy for the time interval in the obstacle's color
    obj = varargin{1};
    timeInterval = varargin{2};
    color = varargin{3};
end

% check time interval
if isa(timeInterval, 'globalPck.TimeInterval') && ~isempty(timeInterval) && ...
        globalPck.PlotProperties.SHOW_PREDICTED_OCCUPANCIES
    % a time interval has been provided as input
    [ts, dt, tf] = timeInterval.getTimeInterval();
    numTimeIntervals = length(ts:dt:(tf-dt));
    
    % check if the dt of input is the same as dt of computed occupancy
    if ~isempty(obj(1,1).timeInterval)
        [~, dt_occ, ~] = obj(1,1).timeInterval.getTimeInterval();
        if dt ~= dt_occ
            warning(['The requested time step for plotting %f is different ' ...
                'than the step size of the occupancy %f. Hence, the step size' ...
                ' of the occupancy calculation has been employed for the '...
                'plot. \n\nWarning in prediction.Occupancy/plot'], dt, dt_occ);
        end
    end
    
    % find the occupancy which matches the ts of the input time interval
    for i = 1:size(obj,1)
        for j = 1:size(obj,2)
            if ~isempty(obj(i,j).timeInterval)
                % find the next starting time of the next occupancy
                [ts_occ, ~, ~] = obj(i,j).timeInterval.getTimeInterval();
                
                % check if matching starting time is found or the end is reached
                if abs(ts - ts_occ) <= eps
                    tsIndex = j;
                    break;
                elseif j == size(obj,2)
                    error('The sarting time for plotting %f is larger than the latest occupancy with ts = %f. \n\nError in prediction.Occupancy/plot', ts, ts_occ)
                end
            %else
                %tsIndex = j; % TODO check
            end
        end
        if exist('tsIndex', 'var')
            break;
        end
    end
    
    if ~exist('tsIndex', 'var')
        warning('No Occupancy found which starts at teh give time interval. Warning in prediction.Occupancy/plot')
        return;
    end
    
    % find tfIndex:
    % check for zero time interval
    if numTimeIntervals == 0
        %warning('A zero time interval has been specified for the plot. Warning in prediction.Occupancy/plot')
        tfIndex = tsIndex;
    else
        % check if occupancy has been computed until tf
        if size(obj,2) >= ((tsIndex-1) + numTimeIntervals)
            tfIndex = (tsIndex-1) + numTimeIntervals;
        else
            %warning('The final time for plotting %f is larger than the latest occupancy. \n\nWarning in prediction.Occupancy/plot', tf)
            tfIndex = size(obj,2);
        end
    end
    
else % no time interval was specified for plotting the occupancy
    %warning('No time interval has been specified for the plot. Warning in prediction.Occupancy/plot')
    if length(obj) == 1
        tsIndex = 1;
        tfIndex = 1;
    else
        return;
    end
end

% plot the occupancy:
% for all lanes
for j = 1:size(obj,1)
    
    % for all specified time intervals
    for k = tsIndex:tfIndex %tsIndex:15:tfIndex
        if ~isempty(obj(j,k).vertices)
            %patch(obj(j,k).vertices(1,:), obj(j,k).vertices(2,:), 1, 'FaceColor', color, 'FaceAlpha', globalPck.PlotProperties.FACE_TRANSPARENCY, 'EdgeColor', color)
            
            if globalPck.PlotProperties.FACE_TRANSPARENCY > 0
                fill(obj(j,k).vertices(1,:), obj(j,k).vertices(2,:), color, 'FaceAlpha', globalPck.PlotProperties.FACE_TRANSPARENCY, 'EdgeColor', color);%'k');%
            else
                plot(obj(j,k).vertices(1,:), obj(j,k).vertices(2,:), 'Color', color);
            end
        end
    end
    
%     if k < tfIndex
%         if ~isempty(obj(j,k).vertices)
%             if globalPck.PlotProperties.FACE_TRANSPARENCY > 0
%                 fill(obj(j,tfIndex).vertices(1,:), obj(j,tfIndex).vertices(2,:), color, 'FaceAlpha', globalPck.PlotProperties.FACE_TRANSPARENCY, 'EdgeColor', color);%'k');%
%             else
%                 plot(obj(j,tfIndex).vertices(1,:), obj(j,tfIndex).vertices(2,:), color);
%             end
%         end
%     end
end

end

%------------- END CODE --------------