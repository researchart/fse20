function [position_PNR] = findPNR(obj)
% findPNR -
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

[ts_trajectory, dt, tf_trajectory] = map.egoVehicle.trajectory.timeInterval.getTimeInterval();
%numTimeIntervals = length(ts_trajectory:dt:(tf_trajectory-dt));

% test along the trajectory of the ego vehicle
for time = ts_trajectory:dt:(tf_trajectory-ts_trajectory)
    
    % initialise
    distance_weak_tminus1 = [];
    distance_tminus1 = [];
                
    if time == 1.3 || time == (tf_trajectory-ts_trajectory)
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
    i = 1; % HACK PNR overtaking obstacles(1)
    
    % update obstacle and predict occ based on new initial time
    map.obstacles(i).update(time);
    map.obstacles(i).computeOccupancyForObstacle(map, globalPck.TimeInterval(0, dt, tf_prediction));
    
    % iterate over all lanes
    %for l = 1:size(rechability_ego,1)
    l_ego = 1; % HACK PNR right lane
    % select the lane in which the ego vehicle is in
    l_obstacle = rechability_ego(l_ego,1).forLane == map.obstacles(i).occupancy(:,1).forLane;
    
    % iterate over all time intervals
    for t_ego = 1:length(rechability_ego(l_ego,:))
        
        if t_ego == 9
            a=1; %debug
        end
        
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
            % rear bound of ego vehicle
            [egoRearLeft, egoRearRight] = ...
                rearBound(rechability_ego(l_ego,t_ego), rechability_ego(l_ego,t_ego).forLane);
            
            % rear bound of obstacle
            [obstacleRearLeft, obstacleRearRight] = ...
                rearBound(occ_obstacle, occ_obstacle.forLane);
            
            if ~isempty(egoRearRight) && ~isempty(obstacleRearRight)
                %plot(obstacleRearRight(1),obstacleRearRight(2),'ro')
                %plot(egoRearRight(1),egoRearRight(2),'ro')
                
                
                % weak approach:
                % poisition of obstacle (x = x_0 + v_0*t)
                p_obstacle = map.obstacles(1).trajectory.position(1,1) + ...
                    map.obstacles(1).trajectory.velocity(1) * (time + rechability_ego(l_ego,t_ego).timeInterval.ts);
                %plot(p_obstacle,map.obstacles(1).trajectory.position(2,1),'ro')
                distance_weak = (p_obstacle - 0.5*map.obstacles(1).shape.length) - egoRearRight(1);
                
                % check weak PNR condition
                if ~exist('position_PNR_weak','var') && distance_weak < map.egoVehicle.shape.length
                    position_PNR_weak = map.egoVehicle.position; %map.egoVehicle.trajectory.position(:,uint8(time/dt+1));
                    disp(['position_PNR_weak: ' num2str(position_PNR_weak(1))]);
                    name_plot = ['Weak PNR at ' num2str(time) ' seconds.'];
                    figure('Name',name_plot)
                    map.lanes.plot();
                    map.egoVehicle.plot();
                    rechability_ego.plot(rechability_ego(l_ego,t_ego).timeInterval,'k');
                    %plot(p_obstacle,map.obstacles(1).trajectory.position(2,1),'ro');
                    map.obstacles(i).update(time+(t_ego-1)*dt);
                    map.obstacles(i).plot();
                    plot(position_PNR_weak(1),position_PNR_weak(2),'r*');
                    if exist('position_PNR','var')
                        return;
                    end
                end
                
                % formal approach:
                % check PNR condition
                %distance_norm = norm(egoRearRight - obstacleRearRight);
                distance = obstacleRearRight(1) - egoRearRight(1);
                
                if ~exist('position_PNR','var') && distance < map.egoVehicle.shape.length
                    
                    % PNR is at the current ego vehicles position
                    position_PNR =  map.egoVehicle.position;
                    
                    % plot
                    name_plot = ['Formal PNR at ' num2str(time) ' seconds.'];
                    figure('Name',name_plot)
                    map.lanes.plot();
                    map.egoVehicle.plot();
                    rechability_ego.plot(rechability_ego(l_ego,t_ego).timeInterval,'k');
                    map.obstacles(i).plot();
                    occ_obstacle.plot(occ_obstacle.timeInterval,map.obstacles(1).color);
                    plot(position_PNR(1),position_PNR(2),'rd');
                    disp(['position_PNR: ' num2str(position_PNR(1))]);
                    
                    if exist('position_PNR_weak','var')
                        return;
                    end
                else
                    % distance (on right lane boundary) > map.egoVehicle.shape.length
                    % i.e. 'evasive' trajectory in CIS_pre exists, but need
                    % to check consecutive time intervals if ego vehicle can stay behind obstacle
                    %continue;
                end
                
                % condition to terminate t_ego loop
                if ~isempty(distance_weak_tminus1) && ~isempty(distance_tminus1) && ...
                        distance_weak_tminus1 <= distance_weak && ...
                        distance_tminus1 == distance
                    break;
                end
                
                distance_weak_tminus1 = distance_weak;
                distance_tminus1 = distance;
                
            end
        end
    end % for t_ego
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
%                     rearBound(sortedVehicles{1,l}(i).occupancy(oIdx,t), map.lanes(l));

end

function [leftCorner, rightCorner] = rearBound(occupancy, lane)
% TODO This is copied from frontBound of Hannes
% TODO This is a naive, inefficient implementation

leftCorner = [];
rightCorner = [];

% PARAMETERS
% Our assumed maximum lane width
maxLaneWidth = 10.0;
% Our vehicle width
vehicleWidth = 2.0;

rearPointCandidates = cell(0);
for centerIdx = 1:length(lane.center.vertices)-1
    currCenterVertex = lane.center.vertices(:,centerIdx);
    nextCenterVertex = lane.center.vertices(:,centerIdx+1);
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
            rearPointCandidates{end+1} = oPoint;
        end
    end
    
    if ~isempty(rearPointCandidates)
        % TODO determine leftCorner, rightCorner
        %                 for foobar = 1:length(lane.leftBorder.vertices)
        %                     text(lane.leftBorder.vertices(1,foobar), lane.leftBorder.vertices(2,foobar), strcat('l', num2str(foobar)));
        %                 end
        %                 for fpIdx = 1:length(rearPointCandidates)
        %                     text(rearPointCandidates{fpIdx}(1), rearPointCandidates{fpIdx}(2), strcat('c', num2str(fpIdx)));
        %                 end
        % Determine the rearmost point in rearPointCandidates
        % cDistanceFun calculates the distance of oPt to
        % currCenterVertex perpendicular to centerSegmentVec
        %cDistanceFun = @(oPt) cos(geometry.vectorAngle(oPt'-currCenterVertex', centerSegmentVec'))*norm(oPt-currCenterVertex);
        %distances = cellfun(cDistanceFun, rearPointCandidates);
        %[~, minIdx] = min(distances);
        %rearPoint = rearPointCandidates{minIdx};
        
        % check if vehicle width fits in the lane (HACK PNR)
        flag_fit = false;
        currLeftVertex = lane.leftBorder.vertices(:,centerIdx);
        for i = 1:size(rearPointCandidates,2)
            if abs(currLeftVertex(2) - rearPointCandidates{i}(2)) > vehicleWidth
                %plot(currLeftVertex(1),currLeftVertex(2),'g*')
                %plot(rearPointCandidates{i}(1),rearPointCandidates{i}(2),'go')
                flag_fit = true;
                break;
            end
        end
        if ~flag_fit
            rearPointCandidates = cell(0);
            continue;
        end
        
        %HACK: right lane:
        currRightVertex = lane.rightBorder.vertices(:,centerIdx);
        rDistanceFun = @(oPt) norm(oPt - currRightVertex);
        distances = cellfun(rDistanceFun, rearPointCandidates);
        [~, minIdx] = min(distances);
        rearPoint = rearPointCandidates{minIdx};
        %         % determine the rearmost points (minimum x value)
        %         rearPointCandidates_minX{1} = rearPointCandidates{1};
        %         for i = 2:size(rearPointCandidates,2)
        %             if rearPointCandidates_minX{1}(1) > rearPointCandidates{i}(1)
        %                 rearPointCandidates_minX{:} = rearPointCandidates{i};
        %             elseif rearPointCandidates_minX{1}(1) == rearPointCandidates{i}(1)
        %                 rearPointCandidates_minX{end+1} = rearPointCandidates{i};
        %             end
        %         end
        %         % select the rearPoint with minimum y value
        %         rearPoint = rearPointCandidates{1};
        %         for i = 2:size(rearPointCandidates,2)
        %             if rearPoint(2) > rearPointCandidates{i}(2)
        %                 rearPoint = rearPointCandidates{i};
        %             end
        %         end
        
        % The index of the point on the left border that is closest
        % to rearPoint.
        lbIdx = dsearchn(lane.leftBorder.vertices', rearPoint');
        nearestLeftLanePt = lane.leftBorder.vertices(:,lbIdx);
        % Project rearPoint onto the left lane border. For this,
        % consider the vertices before and after nearestLeftLanePt.
        if lbIdx == 1
            % The point nearestLeftLanePt is the first vertex on
            % the left border.
            % flProjected is the projection of flCandidate on the
            % left lane border.
            [flProjected, ~, ~] = geometry.project_point_line_segment(...
                nearestLeftLanePt, lane.leftBorder.vertices(:,lbIdx+1), rearPoint);
        elseif lbIdx == length(lane.leftBorder.vertices)
            % The point nearestLeftLanePt is the last vertex on
            % the left border.
            % flProjected is the projection of flCandidate on the
            % left lane border.
            [flProjected, ~, ~] = geometry.project_point_line_segment(...
                nearestLeftLanePt, lane.leftBorder.vertices(:,lbIdx-1), rearPoint);
        else
            % The point nearestLeftLanePt is somewhere between the
            % first and last vertex on the left lane border.
            % flProjected is the projection of flCandidate on the
            % left lane border.
            [flProjected, ~, ~] = geometry.project_point_line_segment(...
                nearestLeftLanePt, lane.leftBorder.vertices(:,lbIdx+1), rearPoint);
            if flProjected == nearestLeftLanePt
                [flProjected, ~, ~] = geometry.project_point_line_segment(...
                    nearestLeftLanePt, lane.leftBorder.vertices(:,lbIdx-1), rearPoint);
                % Note that flProjected == nearestLeftLanePt could
                % still be true.
            end
        end
        leftCorner = flProjected;
        
        %         % check if vehicle width fits in the lane (HACK PNR)
        %         if abs(nearestLeftLanePt(2) - rearPoint(2)) < vehicleWidth
        %             %plot(rearPoint(1),rearPoint(2),'g*')
        %             %plot(nearestLeftLanePt(1),nearestLeftLanePt(2),'go')
        %             break;
        %         end
        
        % Same procedure for the right lane border:
        rbIdx = dsearchn(lane.rightBorder.vertices', rearPoint');
        nearestRightLanePt = lane.rightBorder.vertices(:,rbIdx);
        if rbIdx == 1
            [frProjected, ~, ~] = geometry.project_point_line_segment(...
                nearestRightLanePt, lane.rightBorder.vertices(:,rbIdx+1), rearPoint);
        elseif rbIdx == length(lane.rightBorder.vertices)
            [frProjected, ~, ~] = geometry.project_point_line_segment(...
                nearestRightLanePt, lane.rightBorder.vertices(:,rbIdx-1), rearPoint);
        else
            [frProjected, ~, ~] = geometry.project_point_line_segment(...
                nearestRightLanePt, lane.rightBorder.vertices(:,rbIdx+1), rearPoint);
            if frProjected == nearestRightLanePt
                [frProjected, ~, ~] = geometry.project_point_line_segment(...
                    nearestRightLanePt, lane.rightBorder.vertices(:,rbIdx-1), rearPoint);
            end
        end
        rightCorner = frProjected;
        break;
    end
end
end

%------------- END CODE --------------