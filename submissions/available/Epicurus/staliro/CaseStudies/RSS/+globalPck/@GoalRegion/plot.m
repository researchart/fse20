function plot(obj)
% plot - plots a GoalRegion object
%
% Syntax:
%   plot(varargin)
%
% Inputs:
%   obj - GoalRegion object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      18-April-2017
% Last update:  16-August-2018
%
% Last revision:---

%------------- BEGIN CODE --------------

for i = 1:numel(obj)
    % plot the position of the goal region
    if globalPck.PlotProperties.SHOW_GOALREGION && ~isa(obj(i).position, 'world.Lanelet')
        obj(i).position.plot(globalPck.PlotProperties.COLOR_EGO_VEHICLE);
    end
    
    % print description
    if globalPck.PlotProperties.SHOW_OBJECT_NAMES && ~isempty(obj(i).position)
        if ~isa(obj(i).position, 'world.Lanelet') && ...
                (~isa(obj(i).position, 'geometry.Shape') || isa(obj(i).position, 'geometry.Rectangle'))
            pos = obj(i).position.position;
            
            string = sprintf('goal Region');
            text(pos(1), pos(2), 0, string);
            %text(pos(1), pos(2), 0, ['\leftarrow ', string]);
        end
    end
end

end

%------------- END CODE --------------