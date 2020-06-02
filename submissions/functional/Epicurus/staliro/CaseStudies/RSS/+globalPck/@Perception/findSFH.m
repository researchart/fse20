function [position_SFH] = findSFH(obj)
% findSFH -
%
% Syntax:
%
%
% Inputs:
%   obj - perception object
%
% Outputs:
%
%
% Other m-files required:
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      24-February-2017
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------
map = obj.map;

% loosen assumptions
%map.obstacles(1).set('speedingFactor',inf)
%map.obstacles(1).set('v_s',inf)
%map.obstacles(2).set('speedingFactor',inf)
%map.obstacles(2).set('v_s',inf)
%map.obstacles(2).set('v_max',69.44)
%map.obstacles(2).set('a_max',10)

[ts_trajectory, dt, tf_trajectory] = map.egoVehicle.trajectory.timeInterval.getTimeInterval();
%numTimeIntervals = length(ts_trajectory:dt:(tf_trajectory-dt));

% test along the trajectory of the ego vehicle
for time = ts_trajectory:dt:(tf_trajectory-ts_trajectory)
    
    % initialise
    distance_weak_tminus1 = [];
    distance_tminus1 = [];
    
    if time == 3.7 || time == (tf_trajectory-ts_trajectory)
        a=1; %debug
    end
    
    map.egoVehicle.update(time);
    %obj.update(time);
    
    % rechability ego vehicle (currently, i.e. set-based occupancy)
    tf_prediction = tf_trajectory-time;%3;
    rechability_ego = prediction.Occupancy().computeOccupancyCore(map.egoVehicle, map, globalPck.TimeInterval(0, dt, tf_prediction));
    
    % check if reachability of ego vehicle is behind the obstacles' occupancy:
    % iterate over all obstacles
    %for i = 1:numel(map.obstacle)
    i = 1; % HACK SFH overtaking obstacles(1)
    j = 2; % HACK SFH oncoming obstacles(2)
    
    % update obstacle and predict occ based on new initial time
    map.obstacles(i).update(time);
    map.obstacles(i).computeOccupancyForObstacle(map, globalPck.TimeInterval(0, dt, tf_prediction));
    
    map.obstacles(j).update(time);
    map.obstacles(j).computeOccupancyForObstacle(map, globalPck.TimeInterval(0, dt, tf_prediction));
    
    % safe approach:
    t_trajectory = uint8(time/dt+1);
    k = 3; % HACK SFH lane after overtaking
    if ~isempty(map.egoVehicle.occupancy_trajectory(k,t_trajectory).vertices)
        boundingBox = [map.lanes(2).leftBorder.vertices(1,:), map.lanes(2).rightBorder.vertices(1,:); map.lanes(2).leftBorder.vertices(2,:), map.lanes(2).rightBorder.vertices(2,:)];
        [x, y] = polybool('intersection', map.egoVehicle.occupancy_trajectory(k,t_trajectory).vertices(1,:), map.egoVehicle.occupancy_trajectory(k,t_trajectory).vertices(2,:), ...
            boundingBox(1,:), boundingBox(2,:));
        % check safe SFH condition
        if isempty(x) && isempty(y)
            position_SFH_safe = map.egoVehicle.trajectory.position(:,uint8(time/dt+1));
            disp(['position_SFH_safe: ' num2str(position_SFH_safe(1))]);
            name_plot = ['Safe SFH at ' num2str(time) ' seconds.'];
            figure('Name',name_plot)
            map.lanes.plot();
            map.egoVehicle.plot();
            map.obstacles(i).plot();
            map.obstacles(j).plot();
            plot(position_SFH_safe(1),position_SFH_safe(2),'r*');
            
            if exist('position_SFH_weak','var') && exist('position_SFH','var')
                return;
            end
        end
    end
    
    % iterate over all lanes
    %for l = 1:size(rechability_ego,1)
    l_ego = 1; % HACK SFH right lane
    %l_ego_j = 2; % HACK SFH left lane
    % select the lane in which the ego vehicle is in
    l_obstacle = rechability_ego(l_ego,1).forLane == map.obstacles(i).occupancy(:,1).forLane;
    %l_obstacle_j = rechability_ego(l_ego_j,1).forLane == map.obstacles(j).occupancy(:,1).forLane;
    
    % iterate over all time intervals
    if ~exist('position_SFH_safe','var')
        for t_ego = 1:length(rechability_ego(l_ego,:))
            % select the occupancy which has the same time interval as the one of the ego vehicle
            occ_obstacle = findobj(map.obstacles(i).occupancy(l_obstacle,:), 'timeInterval', rechability_ego(l_ego,t_ego).timeInterval);
            %         ts_ego = rechability_ego(l_ego,t_ego).timeInterval.ts + time;
            %         for t_obstacle = 1:size(map.obstacles(i).occupancy(l_obstacle,:),2)
            %             if map.obstacles(i).occupancy(l_obstacle,t_obstacle).timeInterval.ts == ts_ego
            %                 occ_obstacle = map.obstacles(i).occupancy(l_obstacle,t_obstacle);
            %                 break;
            %             end
            %         end
            
            if ~isempty(occ_obstacle)
                % front bound of ego vehicle
                [egoFrontLeft, egoFrontRight] = ...
                    frontBound(rechability_ego(l_ego,t_ego), rechability_ego(l_ego,t_ego).forLane);
                
                % front bound of obstacle
                [obstacleFrontLeft, obstacleFrontRight] = ...
                    frontBound(occ_obstacle, occ_obstacle.forLane);
                
                % check collision with oncoming vehicle
                %             occ_obstacle_j = findobj(map.obstacles(j).occupancy(l_obstacle_j,:), 'timeInterval', rechability_ego(l_ego_j,t_ego).timeInterval);
                %             if ~isempty(rechability_ego(l_ego_j,t_ego).vertices) && ...
                %                                 ~isempty(occ_obstacle_j.vertices)
                %                             check if intersection is empty
                %                             [x, y] = polybool('intersection', rechability_ego(l_ego_j,t_ego).vertices(1,:), rechability_ego(l_ego_j,t_ego).vertices(2,:), ...
                %                                 occ_obstacle_j.vertices(1,:), occ_obstacle_j.vertices(2,:));
                %
                %                             if ~isempty(x) && ~isempty(y)
                %                                 break;
                %                             end
                %             end
                % check if ego is back on safe lane
                %             if map.egoVehicle.position(2) <
                %                 boundingBox = [map.lanes(2).leftBorder.vertices(1,:), map.lanes(2).rightBorder.vertices(1,:); map.lanes(2).leftBorder.vertices(2,:), map.lanes(2).rightBorder.vertices(2,:)];
                %                 [x, y] = polybool('intersection', rechability_ego(l_ego_j,t_ego).vertices(1,:), rechability_ego(l_ego_j,t_ego).vertices(2,:), ...
                %                                              boundingBox(1,:), boundingBox(2,:));
                %             end
                %             if isempty(x) && isempty(y)
                
                if ~isempty(egoFrontRight) && ~isempty(obstacleFrontRight)
                    %plot(obstacleFrontRight(1),obstacleFrontRight(2),'ro')
                    %plot(egoFrontRight(1),egoFrontRight(2),'ro')
                    
                    
                    % weak approach:
                    % poisition of obstacle (x = x_0 + v_0*t)
                    p_obstacle = map.obstacles(1).trajectory.position(1,1) + ...
                        map.obstacles(1).trajectory.velocity(1) * (time + rechability_ego(l_ego,t_ego).timeInterval.ts);
                    %plot(p_obstacle,map.obstacles(1).trajectory.position(2,1),'ro')
                    distance_weak = egoFrontRight(1) - (p_obstacle + 0.5*map.obstacles(1).shape.length);
                    
                    % check weak SFH condition
                    if ~exist('position_SFH_weak','var') && distance_weak > map.egoVehicle.shape.length
                        position_SFH_weak = map.egoVehicle.trajectory.position(:,uint8(time/dt+1));
                        disp(['position_SFH_weak: ' num2str(position_SFH_weak(1))]);
                        name_plot = ['Weak SFH at ' num2str(time) ' seconds.'];
                        figure('Name',name_plot)
                        map.lanes.plot();
                        map.egoVehicle.plot();
                        rechability_ego.plot(rechability_ego(l_ego,t_ego).timeInterval);
                        %plot(p_obstacle,map.obstacles(1).trajectory.position(2,1),'ro');
                        map.obstacles(i).update(time+(t_ego-1)*dt);
                        map.obstacles(i).plot();
                        plot(position_SFH_weak(1),position_SFH_weak(2),'r*');
                        
                        if exist('position_SFH','var') && exist('position_SFH_safe','var')
                            return;
                        end
                    end
                    
                    % formal approach:
                    % check SFH condition
                    %distance = norm(egoFrontRight - obstacleFrontRight);
                    distance = egoFrontRight(1) - obstacleFrontRight(1);
                    if ~exist('position_SFH','var') && distance > map.egoVehicle.shape.length
                        
                        % SFH is at the position of this trajectory position
                        position_SFH = map.egoVehicle.trajectory.position(:,uint8(time/dt+1));
                        
                        % plot
                        name_plot = ['Formal SFH at ' num2str(time) ' seconds.'];
                        figure('Name',name_plot)
                        map.lanes.plot();
                        map.egoVehicle.plot();
                        rechability_ego.plot(rechability_ego(l_ego,t_ego).timeInterval,'k');
                        map.obstacles(i).plot();
                        %map.obstacles(j).plot();
                        occ_obstacle.plot(occ_obstacle.timeInterval,map.obstacles(i).color);
                        %occ_obstacle_j.plot(occ_obstacle_j.timeInterval,map.obstacles(j).color);
                        plot(position_SFH(1),position_SFH(2),'rd');
                        disp(['position_SFH: ' num2str(position_SFH(1))]);
                        
                        if exist('position_SFH_weak','var') && exist('position_SFH_safe','var')
                            return;
                        end
                    else
                        % distance (on right lane boundary) > map.egoVehicle.shape.length
                        % i.e. 'evasive' trajectory in CIS_pre exists, but need
                        % to check consecutive time intervals if ego vehicle can stay behind obstacle
                        %continue;
                    end
                    
                    % condition to terminate t_ego loop
                    %                 if ~isempty(distance_weak_tminus1) && ~isempty(distance_tminus1) && ...
                    %                         distance_weak_tminus1 <= distance_weak && ...
                    %                         distance_tminus1 == distance
                    %                     break;
                    %                 end
                    
                    distance_weak_tminus1 = distance_weak;
                    distance_tminus1 = distance;
                    
                end
            end
        end % for t_ego
    end
    % jump to next point of planned trajetory
end
%end

% % Iterate over all time intervals of the ego vehicle
% for t = 1:size(map.obstacles(1).occupancy) % TODO Other method to get all time intervals
%     % Iterate over all lanes
%     for l = 1:length(map.lanes)
%         % Iterate through the sortedVehicles array from front (1) to back (end):
%         % For every vehicle except the last one, adapt the occupancy of the
%         % following vehicle.
%
%             % Find out which occupancy corresponds to lane l
%             for oIdx = 1:length(sortedVehicles{1,l}(i).occupancy(:,1))
%                 if map.lanes(l).id == sortedVehicles{1,l}(i).occupancy(oIdx,t).forLane.id
%                     break;
%                 end
%             end
%
% [precedingFrontLeft, precedingFrontRight] = ...
%                     frontBound(sortedVehicles{1,l}(i).occupancy(oIdx,t), map.lanes(l));

end

function [leftCorner, rightCorner] = frontBound(occupancy, lane)
% TODO This is copied from frontBound of Hannes
% TODO This is a naive, inefficient implementation

leftCorner = [];
rightCorner = [];

% PARAMETERS
% Our assumed maximum lane width
maxLaneWidth = 10.0;
% Our vehicle width
vehicleWidth = 2.0;

frontPointCandidates = cell(0);
for centerIdx = length(lane.center.vertices):-1:2
    currCenterVertex = lane.center.vertices(:,centerIdx);
    nextCenterVertex = lane.center.vertices(:,centerIdx-1);
    centerSegmentVec = nextCenterVertex - currCenterVertex;
    for occIdx = 1:length(occupancy.vertices)
        oPoint = occupancy.vertices(:,occIdx);
        % Determine whether oPoint is in the lane segment between
        % currCenterVertex and nextCenterVertex
        coVec1 = oPoint - currCenterVertex;
        coVec2 = oPoint - nextCenterVertex;
        phi1 = geometry.vectorAngle(coVec1', centerSegmentVec');
        phi2 = geometry.vectorAngle(coVec2', centerSegmentVec');
        % The following conditions have to be met for oPoint to be
        % in the current lane segment:
        if abs(norm(coVec1)*cos(phi1)) < norm(centerSegmentVec) && ...
                abs(norm(coVec2)*cos(phi2)) < norm(centerSegmentVec) && ...
                abs(norm(coVec1)*sin(phi1)) < (maxLaneWidth / 2)
            frontPointCandidates{end+1} = oPoint;
        end
    end
    
    if ~isempty(frontPointCandidates)
        % TODO determine leftCorner, rightCorner
        %                 for foobar = 1:length(lane.leftBorder.vertices)
        %                     text(lane.leftBorder.vertices(1,foobar), lane.leftBorder.vertices(2,foobar), strcat('l', num2str(foobar)));
        %                 end
        %                 for fpIdx = 1:length(frontPointCandidates)
        %                     text(frontPointCandidates{fpIdx}(1), frontPointCandidates{fpIdx}(2), strcat('c', num2str(fpIdx)));
        %                 end
        % Determine the frontmost point in frontPointCandidates
        % cDistanceFun calculates the distance of oPt to
        % currCenterVertex perpendicular to centerSegmentVec
        %cDistanceFun = @(oPt) cos(geometry.vectorAngle(oPt'-currCenterVertex', centerSegmentVec'))*norm(oPt-currCenterVertex);
        %distances = cellfun(cDistanceFun, frontPointCandidates);
        %[~, minIdx] = min(distances);
        %frontPoint = frontPointCandidates{minIdx};
        
        % check if vehicle width fits in the lane (HACK SFH)
        flag_fit = false;
        currLeftVertex = lane.leftBorder.vertices(:,centerIdx);
        for i = 1:size(frontPointCandidates,2)
            if abs(currLeftVertex(2) - frontPointCandidates{i}(2)) > vehicleWidth
                %plot(currLeftVertex(1),currLeftVertex(2),'g*')
                %plot(frontPointCandidates{i}(1),frontPointCandidates{i}(2),'go')
                flag_fit = true;
                break;
            end
        end
        if ~flag_fit
            continue;
        end
        
        %HACK: right lane:
        currRightVertex = lane.rightBorder.vertices(:,centerIdx);
        rDistanceFun = @(oPt) norm(oPt - currRightVertex);
        distances = cellfun(rDistanceFun, frontPointCandidates);
        [~, minIdx] = min(distances);
        frontPoint = frontPointCandidates{minIdx};
        %         % determine the frontmost points (minimum x value)
        %         frontPointCandidates_minX{1} = frontPointCandidates{1};
        %         for i = 2:size(frontPointCandidates,2)
        %             if frontPointCandidates_minX{1}(1) > frontPointCandidates{i}(1)
        %                 frontPointCandidates_minX{:} = frontPointCandidates{i};
        %             elseif frontPointCandidates_minX{1}(1) == frontPointCandidates{i}(1)
        %                 frontPointCandidates_minX{end+1} = frontPointCandidates{i};
        %             end
        %         end
        %         % select the frontPoint with minimum y value
        %         frontPoint = frontPointCandidates{1};
        %         for i = 2:size(frontPointCandidates,2)
        %             if frontPoint(2) > frontPointCandidates{i}(2)
        %                 frontPoint = frontPointCandidates{i};
        %             end
        %         end
        
        % The index of the point on the left border that is closest
        % to frontPoint.
        lbIdx = dsearchn(lane.leftBorder.vertices', frontPoint');
        nearestLeftLanePt = lane.leftBorder.vertices(:,lbIdx);
        % Project frontPoint onto the left lane border. For this,
        % consider the vertices before and after nearestLeftLanePt.
        if lbIdx == 1
            % The point nearestLeftLanePt is the first vertex on
            % the left border.
            % flProjected is the projection of flCandidate on the
            % left lane border.
            [flProjected, ~, ~] = geometry.project_point_line_segment(...
                nearestLeftLanePt, lane.leftBorder.vertices(:,lbIdx+1), frontPoint);
        elseif lbIdx == length(lane.leftBorder.vertices)
            % The point nearestLeftLanePt is the last vertex on
            % the left border.
            % flProjected is the projection of flCandidate on the
            % left lane border.
            [flProjected, ~, ~] = geometry.project_point_line_segment(...
                nearestLeftLanePt, lane.leftBorder.vertices(:,lbIdx-1), frontPoint);
        else
            % The point nearestLeftLanePt is somewhere between the
            % first and last vertex on the left lane border.
            % flProjected is the projection of flCandidate on the
            % left lane border.
            [flProjected, ~, ~] = geometry.project_point_line_segment(...
                nearestLeftLanePt, lane.leftBorder.vertices(:,lbIdx+1), frontPoint);
            if flProjected == nearestLeftLanePt
                [flProjected, ~, ~] = geometry.project_point_line_segment(...
                    nearestLeftLanePt, lane.leftBorder.vertices(:,lbIdx-1), frontPoint);
                % Note that flProjected == nearestLeftLanePt could
                % still be true.
            end
        end
        leftCorner = flProjected;
        
        %         % check if vehicle width fits in the lane (HACK SFH)
        %         if abs(nearestLeftLanePt(2) - frontPoint(2)) < vehicleWidth
        %             %plot(frontPoint(1),frontPoint(2),'g*')
        %             %plot(nearestLeftLanePt(1),nearestLeftLanePt(2),'go')
        %             break;
        %         end
        
        % Same procedure for the right lane border:
        rbIdx = dsearchn(lane.rightBorder.vertices', frontPoint');
        nearestRightLanePt = lane.rightBorder.vertices(:,rbIdx);
        if rbIdx == 1
            [frProjected, ~, ~] = geometry.project_point_line_segment(...
                nearestRightLanePt, lane.rightBorder.vertices(:,rbIdx+1), frontPoint);
        elseif rbIdx == length(lane.rightBorder.vertices)
            [frProjected, ~, ~] = geometry.project_point_line_segment(...
                nearestRightLanePt, lane.rightBorder.vertices(:,rbIdx-1), frontPoint);
        else
            [frProjected, ~, ~] = geometry.project_point_line_segment(...
                nearestRightLanePt, lane.rightBorder.vertices(:,rbIdx+1), frontPoint);
            if frProjected == nearestRightLanePt
                [frProjected, ~, ~] = geometry.project_point_line_segment(...
                    nearestRightLanePt, lane.rightBorder.vertices(:,rbIdx-1), frontPoint);
            end
        end
        rightCorner = frProjected;
        break;
    end
end
end

%------------- END CODE --------------
