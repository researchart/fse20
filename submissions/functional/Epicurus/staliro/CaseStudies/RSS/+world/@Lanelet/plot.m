function plot(obj)
% plot - plots a Lanelet object (or multiple Lanelet objects)
%
% Syntax:
%   plot(obj)
%
% Inputs:
%   obj - Lanelet object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      07-Dezember-2016
% Last update:  24-August-2107
%
% Last revision:---

%------------- BEGIN CODE --------------

for i = 1:numel(obj)
    % plot vertices of left and right border
    plot(obj(i).leftBorderVertices(1,:), obj(i).leftBorderVertices(2,:),'k-');
    hold on
    plot(obj(i).rightBorderVertices(1,:), obj(i).rightBorderVertices(2,:),'k-');
    
    % plot front and end bound of the lane
    plot([obj(i).leftBorderVertices(1,1), obj(i).rightBorderVertices(1,1)], ...
        [obj(i).leftBorderVertices(2,1), obj(i).rightBorderVertices(2,1)],'k-');
    plot([obj(i).leftBorderVertices(1,end), obj(i).rightBorderVertices(1,end)], ...
        [obj(i).leftBorderVertices(2,end), obj(i).rightBorderVertices(2,end)],'k-');
    
    % plot center vertices
    if globalPck.PlotProperties.SHOW_LANE_CENTER_VERTICES && ~isempty(obj(i).centerVertices)
        plot(obj(i).centerVertices(1,:), obj(i).centerVertices(2,:),'k:');
    end
    
    % print description
    if globalPck.PlotProperties.SHOW_LANE_NAMES
        string = sprintf('lanelet %d', obj(i).id);
        middle = round(size(obj(i).centerVertices,2) / 2);
        text(obj(i).centerVertices(1, middle), obj(i).centerVertices(2, middle), 0, ['\leftarrow ', string]);
        %text(obj(i).obb.position(1), obj(i).obb.position(2), 0, string);
    end
    
    % plot all vertices (with their index)
    if globalPck.PlotProperties.SHOW_LANE_BORDER_VERTICES
        plot(obj(i).leftBorderVertices(1,:), obj(i).leftBorderVertices(2,:),'k.');
        plot(obj(i).rightBorderVertices(1,:), obj(i).rightBorderVertices(2,:),'k.');
        if globalPck.PlotProperties.SHOW_LANE_BORDER_VERTICES_NUMBERS
            for j = 1:length(obj(i).leftBorderVertices)
                text(obj(i).leftBorderVertices(1,j), obj(i).leftBorderVertices(2,j), 0, num2str(j), 'Color', 'k');
                text(obj(i).rightBorderVertices(1,j), obj(i).rightBorderVertices(2,j), 0, num2str(j), 'Color', 'k');
            end
        end
    end
    
end

% equal axes
axis equal

end

%------------- END CODE --------------