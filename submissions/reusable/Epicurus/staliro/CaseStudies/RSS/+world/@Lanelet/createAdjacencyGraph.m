function createAdjacencyGraph(lanelets)
% createAdjacencyGraph - finds all adjacent lanelets (according to the
% CommonRoad specifications) and saves the adjacency graph for each lanelet
%
% Syntax:
%   createAdjacencyGraph(lanelets)
%
% Inputs:
%   lanelets - array of lanelet objects
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      21-August-2017
% Last update:  25-August-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

% set parameters:
epsilion_lateral = 0.2; % thresold for lateral adjacency (left/right)
epsilion_lateral_merge = 0.2; % thresold for merging lanelets (lateral adjacency)
epsilion_lateral_fork = 0.2; % thresold for forking lanelets (lateral adjacency)
epsilion_longitudinal = 0.1; % thresold for longitudinal adjacency (successor/predecessor)

numLanelets = length(lanelets);
for i = 1:numLanelets
    for j = (i+1):numLanelets
        % check longitudinal adjacency (successor/predecessor):
        if norm(lanelets(i).leftBorderVertices(:,end) - lanelets(j).leftBorderVertices(:,1)) < epsilion_longitudinal && ...
                norm(lanelets(i).rightBorderVertices(:,end) - lanelets(j).rightBorderVertices(:,1)) < epsilion_longitudinal
            % lanelets(j) is succeeding lanelets(i)
            lanelets(i).addAdjacentLanelet('successor', lanelets(j));
            lanelets(j).addAdjacentLanelet('predecessor', lanelets(i));
        elseif norm(lanelets(j).leftBorderVertices(:,end) - lanelets(i).leftBorderVertices(:,1)) < epsilion_longitudinal && ...
                norm(lanelets(j).rightBorderVertices(:,end) - lanelets(i).rightBorderVertices(:,1)) < epsilion_longitudinal
            % lanelets(i) is succeeding lanelets(j)
            lanelets(j).addAdjacentLanelet('successor', lanelets(i));
            lanelets(i).addAdjacentLanelet('predecessor', lanelets(j));
        end
        if (norm(lanelets(i).leftBorderVertices(:,end) - lanelets(j).rightBorderVertices(:,end)) < epsilion_longitudinal && ...
                norm(lanelets(i).rightBorderVertices(:,end) - lanelets(j).leftBorderVertices(:,end)) < epsilion_longitudinal) || ...
                (norm(lanelets(i).leftBorderVertices(:,1) - lanelets(j).rightBorderVertices(:,1)) < epsilion_longitudinal && ...
                norm(lanelets(i).rightBorderVertices(:,1) - lanelets(j).leftBorderVertices(:,1)) < epsilion_longitudinal)
            warning(['Lanelet ' num2str(lanelets(i).id) ' and Lanelet ' ...
                num2str(lanelets(j).id) ' are longitudinal adjacent ' ...
                'but have different driving directions. ' ...
                '(Their adjcacency is not saved.)'])
        end
        
        % check lateral adjacency (left/right):
        if ( norm(lanelets(i).leftBorderVertices(:,1) - lanelets(j).rightBorderVertices(:,1)) < epsilion_lateral || ...
                (norm(lanelets(i).leftBorderVertices(:,1) - lanelets(j).leftBorderVertices(:,1)) < epsilion_lateral_fork && ...
                norm(lanelets(i).rightBorderVertices(:,1) - lanelets(j).rightBorderVertices(:,1)) < epsilion_lateral_fork) ) && ...
                ( norm(lanelets(i).leftBorderVertices(:,end) - lanelets(j).rightBorderVertices(:,end)) < epsilion_lateral || ...
                (norm(lanelets(i).leftBorderVertices(:,end) - lanelets(j).leftBorderVertices(:,end)) < epsilion_lateral_merge && ...
                norm(lanelets(i).rightBorderVertices(:,end) - lanelets(j).rightBorderVertices(:,end)) < epsilion_lateral_merge) )
            % lanelets(i) is to the right of lanelets(j) with same driving direction
            % (lanelets(i) and lanelets(j) might additionally merge or fork)
            lanelets(i).addAdjacentLanelet('adjacentLeft', {lanelets(j), 'same'});
            lanelets(j).addAdjacentLanelet('adjacentRight', {lanelets(i), 'same'});
        elseif ( norm(lanelets(j).leftBorderVertices(:,1) - lanelets(i).rightBorderVertices(:,1)) < epsilion_lateral || ...
                (norm(lanelets(j).leftBorderVertices(:,1) - lanelets(i).leftBorderVertices(:,1)) < epsilion_lateral_fork && ...
                norm(lanelets(j).rightBorderVertices(:,1) - lanelets(i).rightBorderVertices(:,1)) < epsilion_lateral_fork) ) && ...
                ( norm(lanelets(j).leftBorderVertices(:,end) - lanelets(i).rightBorderVertices(:,end)) < epsilion_lateral || ...
                (norm(lanelets(j).leftBorderVertices(:,end) - lanelets(i).leftBorderVertices(:,end)) < epsilion_lateral_merge && ...
                norm(lanelets(j).rightBorderVertices(:,end) - lanelets(i).rightBorderVertices(:,end)) < epsilion_lateral_merge) )
            % lanelets(j) is to the right of lanelets(i) with same driving direction
            % (lanelets(i) and lanelets(j) might additionally merge or fork)
            lanelets(j).addAdjacentLanelet('adjacentLeft', {lanelets(i), 'same'});
            lanelets(i).addAdjacentLanelet('adjacentRight', {lanelets(j), 'same'});
        elseif norm(lanelets(i).leftBorderVertices(:,1) - lanelets(j).leftBorderVertices(:,end)) < epsilion_lateral && ...
                norm(lanelets(i).leftBorderVertices(:,end) - lanelets(j).leftBorderVertices(:,1)) < epsilion_lateral
            % lanelets(i) is to the right of lanelets(j) with opposite driving direction
            lanelets(i).addAdjacentLanelet('adjacentLeft', {lanelets(j), 'opposite'});
            lanelets(j).addAdjacentLanelet('adjacentLeft', {lanelets(i), 'opposite'});
        elseif norm(lanelets(i).rightBorderVertices(:,1) - lanelets(j).rightBorderVertices(:,end)) < epsilion_lateral && ...
                norm(lanelets(i).rightBorderVertices(:,end) - lanelets(j).rightBorderVertices(:,1)) < epsilion_lateral
            % lanelets(j) is to the right of lanelets(i) with opposite driving direction
            lanelets(j).addAdjacentLanelet('adjacentRight', {lanelets(i), 'opposite'});
            lanelets(i).addAdjacentLanelet('adjacentRight', {lanelets(j), 'opposite'});
        end
        
        % lateral adjacency only considers the first and last vertices of a
        % lanelet. if you want to avoid that lanelets which split in
        % between are detected as lateral adjacent, use the funtion
        % checkLaneletAdjacency in the folder unused_files.
    end
    
    % % debug:
    % % plot lanelets(i) with colored edges depending of its adjacent lanelets
    %     figure()
    %     axis equal
    %     hold on
    %     if ~isempty(lanelets(i).predecessorLanelets)
    %         plot([lanelets(i).leftBorderVertices(1,1), lanelets(i).rightBorderVertices(1,1)], ...
    %             [lanelets(i).leftBorderVertices(2,1), lanelets(i).rightBorderVertices(2,1)],'c-');
    %     else
    %         plot([lanelets(i).leftBorderVertices(1,1), lanelets(i).rightBorderVertices(1,1)], ...
    %             [lanelets(i).leftBorderVertices(2,1), lanelets(i).rightBorderVertices(2,1)],'k-');
    %     end
    %     if ~isempty(lanelets(i).successorLanelets)
    %         plot([lanelets(i).leftBorderVertices(1,end), lanelets(i).rightBorderVertices(1,end)], ...
    %             [lanelets(i).leftBorderVertices(2,end), lanelets(i).rightBorderVertices(2,end)],'b-');
    %     else
    %         plot([lanelets(i).leftBorderVertices(1,end), lanelets(i).rightBorderVertices(1,end)], ...
    %             [lanelets(i).leftBorderVertices(2,end), lanelets(i).rightBorderVertices(2,end)],'k-');
    %     end
    %     if ~isempty(lanelets(i).adjacentLeft)
    %         plot(lanelets(i).leftBorderVertices(1,:), lanelets(i).leftBorderVertices(2,:),'g.');
    %     else
    %         plot(lanelets(i).leftBorderVertices(1,:), lanelets(i).leftBorderVertices(2,:),'k.');
    %     end
    %     if ~isempty(lanelets(i).adjacentRight)
    %         plot(lanelets(i).rightBorderVertices(1,:), lanelets(i).rightBorderVertices(2,:),'r.');
    %     else
    %         plot(lanelets(i).rightBorderVertices(1,:), lanelets(i).rightBorderVertices(2,:),'k.');
    %     end
    %     text(lanelets(i).centerVertices(1, round(size(lanelets(i).centerVertices,2) / 2)), ...
    %         lanelets(i).centerVertices(2, round(size(lanelets(i).centerVertices,2) / 2)), 0, num2str(lanelets(i).id));
end

end

%------------- END CODE --------------