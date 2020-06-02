function plot( varargin )
% plot - plots a Trajectory
%
% Syntax:
%   plot(obj, timeInterval)
%
% Inputs:
%   obj - Trajectory object
%   timeInterval - TimeInterval object
%   color - Color to plot trajectory
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Manzinger Stefanie
% Written:      29-November-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

if nargin == 1
    % plot whole trajectory
    obj = varargin{1};
    timeInterval = obj.timeInterval;
    color = [rand, rand, rand];
    start = 1;
elseif nargin == 2
    % plot trajectory for given time interval
    obj = varargin{1};
    timeInterval = varargin{2};
    color = [rand, rand, rand];
    start = 1;
elseif nargin == 3
    % plot trajectory for the time interval in the obstacle's color
    obj = varargin{1};
    timeInterval = varargin{2};
    start = 1;
    if ~isscalar(varargin{3}) || ischar(varargin{3})
        color = varargin{3};
    else
        color = [rand, rand, rand];
        if isscalar(varargin{3})%added by Mohammad
            tmpIdx = find(obj.position(1,:)>=varargin{3});
            if isempty(tmpIdx)==0
                start = tmpIdx(1);
            else
                start = length(obj.position);
            end
        end
    end
elseif nargin == 4
    % plot trajectory for the time interval in the obstacle's color
    obj = varargin{1};
    timeInterval = varargin{2};
    color = varargin{3};
    start = 1;
    if isscalar(varargin{4})%added by Mohammad
        tmpIdx = find(obj.position(1,:)>=varargin{4});
        if isempty(tmpIdx)==0
            start = tmpIdx(1);
        else
            start = length(obj.position);
        end
    end
end

if(isempty(timeInterval))
    timeInterval = obj.timeInterval;
end

[idx_start, idx_end] = obj.timeInterval.getIndex(timeInterval.ts, timeInterval.tf);
if idx_start < start
    idx_start = start;
end
if idx_start >= 1 && idx_end <= size(obj.position,2)
    plot(obj.position(1,idx_start:idx_end), obj.position(2,idx_start:idx_end), 'Color', color)
elseif idx_start >= 1 && idx_start <= size(obj.position,2)
    plot(obj.position(1,idx_start:end), obj.position(2,idx_start:end), 'Color', color)
    %plot(obj.position(1,:), obj.position(2,:), 'Color', color)
end

%------------- END CODE --------------