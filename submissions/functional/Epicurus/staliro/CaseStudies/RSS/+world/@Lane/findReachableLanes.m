function [reachableLanes] = findReachableLanes(obj, varargin)
% findReachableLanes - search all Lane objects to return the lanes which 
% can be reached by the obstacle according to the adjacency graph and contraint5
%
% Syntax:
%   [reachableLanes] = findReachableLanes(obj, constraint5, lane/lanelet, side)
%
% Inputs:
%   obj - all Lane Objects of the map
%   varargin{1} - constraint5 - whether an illegal lane change is allowed
%   varargin{2} - lane/lanelets - a Lane or Lanelet object(s)
%   varargin{3} - side - 'left' or 'right' to specify the search direction
%
% Outputs:
%   reachableLanes - Lane objects which can be reached
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: Althoff and Magdici, 2016, Set-Based Prediction of Traffic
% Participants on Arbitrary Road Networks, IV. Occupancy Prediction

% Author:       Markus Koschi
% Written:      09-January-2017
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

% for now, we assume it is allowed to change in lateral adjacent
% lanes with same driving direction. A change into lanes with
% opposite driving direction is forbidden, if constraint5 is true.

if nargin >= 3
    constraint5 = varargin{1};
    
    leftLane = [];
    rightLane = [];
    
    if isa(varargin{2}, 'world.Lane')
        % find reachable lanes from a lane (not recommended)
        searchLane = varargin{2};
        
        % find the left adjacent lanes of the lane
        % (nargin = length(varargin)+1)
        if (length(varargin) == 2 || strcmp(varargin{3}, 'left')) && ...
                ~isempty(searchLane.adjacentLeft) && ...
                ( strcmp(searchLane.adjacentLeft.driving, 'same') || ...
                (strcmp(searchLane.adjacentLeft.driving, 'opposite') && ...
                ~constraint5) )
            leftLane = [searchLane.adjacentLeft.lane, ...
                obj.findReachableLanes(constraint5, searchLane.adjacentLeft.lane, 'left')];
        end
        
        % find the right adjacent lanes of the lane
        if (length(varargin) == 2 || strcmp(varargin{3}, 'right')) && ...
                ~isempty(searchLane.adjacentRight) && ...
                ( strcmp(searchLane.adjacentRight.driving, 'same') || ...
                (strcmp(searchLane.adjacentRight.driving, 'opposite') && ...
                ~constraint5) )
            rightLane = [searchLane.adjacentRight.lane, ...
                obj.findReachableLanes(constraint5, searchLane.adjacentRight.lane, 'right')];
        end
        
    elseif isa(varargin{2}, 'world.Lanelet')
        % find reachable lanes from lanelet(s)
        searchLanelet = varargin{2};
        
        % find all lanelets which are left or right adjacent to the lanelet(s)
        for i = 1:numel(searchLanelet)
            % search left
            if  (length(varargin) == 2 || strcmp(varargin{3}, 'left')) && ...
                    ~isempty(searchLanelet(i).adjacentLeft) && ...
                    ( strcmp(searchLanelet(i).adjacentLeft.driving, 'same') || ...
                    (strcmp(searchLanelet(i).adjacentLeft.driving, 'opposite') && ...
                    ~constraint5) )
                
                if ismember(searchLanelet(i).adjacentLeft.lanelet, searchLanelet)
                    % DEBUG
                    warning('left adjacent lanelet is also searchLanet')
                end
                
                adjacentLeftLane = obj.findLaneByLanelet(searchLanelet(i).adjacentLeft.lanelet);
                %leftLane = [leftLane, adjacentLeftLane(~ismember(adjacentLeftLane, leftLane))];
                if numel(adjacentLeftLane) >= 2 && i == numel(searchLanelet)
                    % try to detect and remove merged lanes
                    adjacentLeftLane = adjacentLeftLane(1);
                    %                         furtherAdjacentLeftLanes2 = obj.findReachableLanes(constraint5, adjacentLeftLane(2).lanelets, 'left');
                    %                     else
                    %                         furtherAdjacentLeftLanes2 = [];
                end
                
                % recursively continue the search
                if ~isempty(searchLanelet(i).adjacentLeft) && strcmp(searchLanelet(i).adjacentLeft.driving, 'same')
                    furtherAdjacentLeftLanes = obj.findReachableLanes(constraint5, adjacentLeftLane(1).lanelets, 'left');
                    %if only one lane change is allowed: furtherAdjacentLeftLanes = [];
                else % strcmp(searchLanelet(i).adjacentLeft.driving, 'opposite')
                    % since the driving direction is opposite, left and
                    % right are flipped and we must search to the right
                    % but for now, we restrict the illeagal movement to one
                    % lane with opposite driving direction
                    %furtherAdjacentLeftLanes1 = obj.findReachableLanes(constraint5, adjacentLeftLane(1).lanelets, 'right');
                    furtherAdjacentLeftLanes = [];
                end
                
                % add only new adjacent lanes
                %leftLane = [leftLane, ...
                %    furtherAdjacentLeftLanes(~ismember(furtherAdjacentLeftLanes, leftLane))];
                %leftLane = [adjacentLeftLane, furtherAdjacentLeftLanes1];
                leftLane = [leftLane, adjacentLeftLane(~ismember(adjacentLeftLane, leftLane)), ...
                    furtherAdjacentLeftLanes(~ismember(furtherAdjacentLeftLanes, leftLane))];
            end
            
            % search right
            if (length(varargin) == 2 || strcmp(varargin{3}, 'right')) && ...
                    ~isempty(searchLanelet(i).adjacentRight) && ...
                    ( strcmp(searchLanelet(i).adjacentRight.driving, 'same') || ...
                    (strcmp(searchLanelet(i).adjacentRight.driving, 'opposite') && ...
                    ~constraint5) )
                
                if ismember(searchLanelet(i).adjacentRight.lanelet, searchLanelet)
                    warning('right adjacent lanelet is also searchLanet')
                end
                
                adjacentRightLane = obj.findLaneByLanelet(searchLanelet(i).adjacentRight.lanelet);
                if numel(adjacentRightLane) >= 2 && i == numel(searchLanelet)
                    adjacentRightLane = adjacentRightLane(1);
                end
                
                % recursively continue the search                
                if ~isempty(searchLanelet(i).adjacentRight) && strcmp(searchLanelet(i).adjacentRight.driving, 'same')
                    furtherAdjacentRightLanes = obj.findReachableLanes(constraint5, adjacentRightLane(1).lanelets, 'right'); %HACK Sebastian
                    %if only one lane change is allowed: furtherAdjacentRightLanes = [];
                else % if strcmp(searchLanelet(i).adjacentLeft.driving, 'opposite')
                    % since the driving direction is opposite, left and
                    % right are flipped and we must search to the left
                    % but for now, we restrict the illeagal movement to one
                    % lane with opposite driving direction
                    %furtherAdjacentRightLanes = obj.findReachableLanes(constraint5, adjacentRightLane(1).lanelets, 'left');
                    furtherAdjacentRightLanes = [];
                end
                
                % add only new adjacent lanes
                rightLane = [rightLane, adjacentRightLane(~ismember(adjacentRightLane, rightLane)), ...
                    furtherAdjacentRightLanes(~ismember(furtherAdjacentRightLanes, rightLane))];
            end
        end
        
    end
    
    % return reachable lanes
    reachableLanes = [leftLane, rightLane];
else
%     warning(['Incorrect input arguments. '...
%             'Warning in world.Lane/findReachableLanes']);
    reachableLanes = []; 
end

end

%------------- END CODE --------------