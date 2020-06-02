function plot(obj)
% plot - plots a Lane object (or multiple Lane objects)
%
% Syntax:
%   plot(obj)
%
% Inputs:
%   obj - Lane object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      15-November-2016
% Last update:  25-August-2017
%
% Last revision:---

%------------- BEGIN CODE --------------
for i = 1:numel(obj)
    
    % plot vertices of left and right border
    plot(obj(i).leftBorder.vertices(1,:), obj(i).leftBorder.vertices(2,:),'k-');
    hold on
    plot(obj(i).rightBorder.vertices(1,:), obj(i).rightBorder.vertices(2,:),'k-');
    
    % plot front and end bound of the lane
    plot([obj(i).leftBorder.vertices(1,1), obj(i).rightBorder.vertices(1,1)], ...
        [obj(i).leftBorder.vertices(2,1), obj(i).rightBorder.vertices(2,1)],'k-');
    plot([obj(i).leftBorder.vertices(1,end), obj(i).rightBorder.vertices(1,end)], ...
        [obj(i).leftBorder.vertices(2,end), obj(i).rightBorder.vertices(2,end)],'k-');
    
    % patch face
    if globalPck.PlotProperties.SHOW_LANE_FACES
        patch([obj(i).leftBorder.vertices(1,:), fliplr(obj(i).rightBorder.vertices(1,:))], ...
            [obj(i).leftBorder.vertices(2,:), fliplr(obj(i).rightBorder.vertices(2,:))], 1, ...
            'FaceColor',  [.25 .25 .25], 'FaceAlpha', 0.2)%changed for better color in paper
            %'FaceColor', 'b', 'FaceAlpha', 0.2)
    end
    
    % plot center vertices
    if globalPck.PlotProperties.SHOW_LANE_CENTER_VERTICES && ~isempty(obj(i).center.vertices)
        plot(obj(i).center.vertices(1,:), obj(i).center.vertices(2,:),'k:');
    end
    
    % print description
    if globalPck.PlotProperties.SHOW_LANE_NAMES
        string = sprintf('lane %d', obj(i).id);
        middle = round(size(obj(i).center.vertices,2) / 2);
        %middle = 1+ round(obj(i).id / 1.8); % + round(size(obj(i).center.vertices,2) / 4);
        
        text(obj(i).center.vertices(1, middle), obj(i).center.vertices(2, middle), 0, string, 'Color', 'k');
        %text(obj(i).center.vertices(1, middle), obj(i).center.vertices(2, middle), 0, ['\leftarrow ', string], 'Color', 'k');
        %text(obj(i).obb.position(1), obj(i).obb.position(2), 0, string);
    end
    
    % plot all vertices with their index
    if globalPck.PlotProperties.SHOW_LANE_BORDER_VERTICES
        plot(obj(i).leftBorder.vertices(1,:), obj(i).leftBorder.vertices(2,:),'k.');
        plot(obj(i).rightBorder.vertices(1,:), obj(i).rightBorder.vertices(2,:),'k.');
        if globalPck.PlotProperties.SHOW_LANE_BORDER_VERTICES_NUMBERS
            for j = 1:length(obj(i).leftBorder.vertices)
                text(obj(i).leftBorder.vertices(1,j), obj(i).leftBorder.vertices(2,j), 0, num2str(j), 'Color', 'k');
                text(obj(i).rightBorder.vertices(1,j), obj(i).rightBorder.vertices(2,j), 0, num2str(j), 'Color', 'k');
            end
        end
    end
    
end

% equal axes
axis equal

end

%------------- END CODE --------------