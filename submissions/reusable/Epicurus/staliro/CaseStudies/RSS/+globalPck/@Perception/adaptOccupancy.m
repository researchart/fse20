function [] = adaptOccupancy( obj )
%ADAPTOCCUPANCY Summary of this function goes here
%   Detailed explanation goes here

map = obj.map;


% PARAMETERS
% Our assumed maximum lane width
maxLaneWidth = 10.0;

    function angle = vectorsAngle(v1, v2)
        %VECTORSANGLE Computes the clockwise angle between two vectors
        %   We're using the atan2 function for this. The result is
        %   normalized to the interval [0, 2*pi).
        angle = atan2(v1(2), v1(1)) - atan2(v2(2), v2(1));
        while angle < 0
            angle = angle + 2*pi;
        end
        while angle >= 2*pi
            angle = angle - 2*pi;
        end
    end


    function result = inbetween(border1, border2, point, varargin)
        % Edge cases:
        % 1.) point lies on border1 or border1
        if point == border1 | point == border2
            % return true
            result = 1;
            return;
        end
        % 2.) border1 == border2
        if border1 == border2
            % return true, if point also lies on border1
            result = point == border1;
            return;
        end
        
        numvarargs = length(varargin);
        if numvarargs > 0
            maxDeviation = varargin{1};
        else
            % default maxDeviation is 4 degrees
            maxDeviation = 4*2*pi/360;
        end
        v1 = border1-point;
        v1 = 1/norm(v1)*v1;
        v2 = point-border2;
        v2 = 1/norm(v2)*v2;
        % angle between v1 and v2
        a = acos(dot(v1, v2));
        % if both vectors point roughly in the same direction point is
        % between border1 and border2
        if a < maxDeviation
            result = 1;
        else
            result = 0;
        end
    end


    function [leftCorner, rightCorner] = frontBound(occupancy, lane)
        % TODO This is a naive, inefficient implementation
        
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
            
            if length(frontPointCandidates) > 0
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
                cDistanceFun = @(oPt) cos(geometry.vectorAngle(oPt'-currCenterVertex', centerSegmentVec'))*norm(oPt-currCenterVertex);
                distances = cellfun(cDistanceFun, frontPointCandidates);
                [~, minIdx] = min(distances);
                frontPoint = frontPointCandidates{minIdx};
                
                
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


    function polygon = cutPolygon(pfl, pfr, ffl, ffr, lane, carlength)
        % pfl: left front corner of the preceding vehicle
        % pfr: right front corner of the preceding vehicle
        % ffl: left front corner of the following vehicle
        % ffr: right front corner of the following vehicle
        
        % calculation of the tail points ptl (=preceding tail left), ptr of
        % the preceding vehicle. 
        % TODO: merge the for loops in this function (might be a bit
        % tricky)
        remainingDistanceLeft = carlength;
        remainingDistanceRight = carlength;
        
        for laneIdx = length(lane.leftBorder.vertices(1,:)):-1:2
            % Iterate backwards over the lane borders.
            currLeft = lane.leftBorder.vertices(:,laneIdx);
            prevLeft = lane.leftBorder.vertices(:,laneIdx - 1);
            currRight = lane.rightBorder.vertices(:,laneIdx);
            prevRight = lane.rightBorder.vertices(:,laneIdx - 1);
            if ~exist('ptl', 'var')
                if inbetween(currLeft, prevLeft, pfl)
                    % We reached pfl. Now we have to go backwards along the
                    % lane border.
                    % remainingDistanceLeft indicates how far we still have to
                    % go backwards. If pfl==prevLeft this statement will be
                    % reached twice.
                    remainingDistanceLeft = remainingDistanceLeft - norm(pfl-prevLeft);
                    if remainingDistanceLeft <= 0.0 
                        % i.e. ptl is between currLeft and prevLeft
                        ptl = pfl + carlength*(prevLeft-pfl)/norm(prevLeft-pfl);
                    end
                elseif (0.0 < remainingDistanceLeft) && (remainingDistanceLeft < carlength)
                    % We have passed ptl, but not gone backward by carlength
                    % yet.
                    if remainingDistanceLeft <= norm(prevLeft-currLeft)
                        % ptl is between prevLeft and currLeft. Now we
                        % interpolate to get the exact point on the lane
                        % border.
                        ptl = currLeft + remainingDistanceLeft*(prevLeft-currLeft)/norm(prevLeft-currLeft);
                    end
                    remainingDistanceLeft = remainingDistanceLeft - norm(prevLeft-currLeft);
                end
            end
            
            % Same procedure for ptr:
            if ~exist('ptr', 'var')
                if inbetween(currRight, prevRight, pfr)
                    remainingDistanceRight = remainingDistanceRight - norm(pfr-prevRight);
                    if remainingDistanceRight <= 0.0 
                        ptr = pfr + carlength*(prevRight-pfr)/norm(prevRight-pfr);
                    end
                elseif (0.0 < remainingDistanceRight) && (remainingDistanceRight < carlength)
                    if remainingDistanceRight <= norm(prevRight-currRight)
                        ptr = currRight + remainingDistanceRight*(prevRight-currRight)/norm(prevRight-currRight);
                    end
                    remainingDistanceRight = remainingDistanceRight - norm(prevRight-currRight);
                end
            end
            
            if exist('ptl', 'var') && exist('ptr', 'var')
                % We have found both tail corners
                break;
            end
        end
        
        
        
        % TODO DEBUG
%          for laneIdx = length(lane.leftBorder.vertices(1,:)):-1:1
%              text(lane.leftBorder.vertices(1,laneIdx), lane.leftBorder.vertices(2,laneIdx), strcat('l', num2str(laneIdx)));
%              text(lane.rightBorder.vertices(1,laneIdx), lane.rightBorder.vertices(2,laneIdx), strcat('r', num2str(laneIdx)));
%          end
%         text(pfl(1), pfl(2), 'pfl');
%         text(pfr(1), pfr(2), 'pfr');
%         text(ffl(1), ffl(2), 'ffl');
%         text(ffr(1), ffr(2), 'ffr');
%         text(ptl(1), ptl(2), 'ptl');
%         text(ptr(1), ptr(2), 'ptr');
        % END DEBUG
        
        
            
        %DEBUG1
%         text(ptl(1), ptl(2), 'ptl');
        
        % The cut polygon is a polygon that includes all of the above
        % points and all lane border points inbetween
        polygonLeft = zeros(2, 3);
        polygonRight = zeros(2, 3);
        pLeftSize = 0;
        pRightSize = 0;
        
        landmarkPointsLeft = 0;
        landmarkPointsRight = 0;
        % This for loop relies on the invariant that the left border has
        % exaclty as many vertices as the right border.
        for laneIdx = 2:length(lane.leftBorder.vertices(1,:))-1
            if landmarkPointsLeft < 3
                currLeft = lane.leftBorder.vertices(:,laneIdx);
                prevLeft = lane.leftBorder.vertices(:,laneIdx - 1);
                % TODO more elegant solution:
                % First collect all landmark points within the segment.
                % Then add them, ordered by distance.
                if inbetween(currLeft, prevLeft, ptl)
                    landmarkPointsLeft = landmarkPointsLeft + 1;
                    pLeftSize = pLeftSize + 1;
                    polygonLeft(:,pLeftSize) = ptl;
                end
                if inbetween(currLeft, prevLeft, pfl)
                    landmarkPointsLeft = landmarkPointsLeft + 1;
                    if inbetween(currLeft, prevLeft, ffl)
                        landmarkPointsLeft = landmarkPointsLeft + 1;
                        % ffl and pfl are within currLeft and prevLeft. To
                        % ensure the right order of vertices we have to
                        % check which one comes first.
                        if norm(prevLeft - ffl) < norm(prevLeft - pfl)
                            % ffl comes first
                            pLeftSize = pLeftSize + 1;
                            polygonLeft(:,pLeftSize) = ffl;
                            pLeftSize = pLeftSize + 1;
                            polygonLeft(:,pLeftSize) = pfl;
                        else
                            % pfl comes first (or both are the same)
                            pLeftSize = pLeftSize + 1;
                            polygonLeft(:,pLeftSize) = pfl;
                            pLeftSize = pLeftSize + 1;
                            polygonLeft(:,pLeftSize) = ffl;
                        end
                    else
                        pLeftSize = pLeftSize + 1;
                        polygonLeft(:,pLeftSize) = pfl;
                    end
                elseif inbetween(currLeft, prevLeft, ffl)
                    landmarkPointsLeft = landmarkPointsLeft + 1;
                    pLeftSize = pLeftSize + 1;
                    polygonLeft(:,pLeftSize) = ffl;
                end
                if landmarkPointsLeft > 0 && landmarkPointsLeft < 3
                    pLeftSize = pLeftSize + 1;
                    polygonLeft(:,pLeftSize) = currLeft;
                end    
            end
            if landmarkPointsRight < 3
                currRight = lane.rightBorder.vertices(:,length(lane.rightBorder.vertices(1,:)) - laneIdx);
                prevRight = lane.rightBorder.vertices(:,length(lane.rightBorder.vertices(1,:)) - laneIdx + 1);
                if inbetween(currRight, prevRight, pfr)
                    landmarkPointsRight = landmarkPointsRight + 1;
                    pRightSize = pRightSize + 1;
                    polygonRight(:,pRightSize) = pfr;
                end
                if inbetween(currRight, prevRight, ffr)
                    landmarkPointsRight = landmarkPointsRight + 1;
                    pRightSize = pRightSize + 1;
                    polygonRight(:,pRightSize) = ffr;
                end
                if inbetween(currRight, prevRight, ptr)
                    landmarkPointsRight = landmarkPointsRight + 1;
                    pRightSize = pRightSize + 1;
                    polygonRight(:,pRightSize) = ptr;
                end
                if landmarkPointsRight > 0 && landmarkPointsRight < 3
                    pRightSize = pRightSize + 1;
                    polygonRight(:,pRightSize) = currRight;
                end    
            end
        end
        polygon = [polygonLeft, polygonRight];
        %patch(polygon(1,:), polygon(2,:), 1, 'FaceColor', 'r');
    end

% Step 1: Sort vehicles in a lane from the frontmost vehicle to the 
% last one

% sortedVehicles is the cell array of all vehicles sorted by lane and
% position within the lane. 
% The following invariant holds on all lanes map.lanes(l): 
% sortedVehicles{l, i} is in front of sortedVehicles{l, i+1}
sortedVehicles = cell(1, length(map.lanes));
% We estimate the position of a vehicle by finding the lane center vertex 
% id closest to each car. The smaller the id, the further back the vehicle
% is.
for l = 1:length(map.lanes)
    % obstaclesInLane contains all vehicles in lane map.lanes(l)
    obstaclesInLane = world.Vehicle.empty();
    for ob = 1:length(map.obstacles)
        % skip static obstacles
        if isa(map.obstacles(ob), 'world.StaticObstacle')
            continue;
        end
        if any([map.obstacles(ob).inLane.id] == map.lanes(l).id)
            obstaclesInLane(length(obstaclesInLane)+1) = map.obstacles(ob);
        end
    end
    if isempty(obstaclesInLane)
        continue;
    end
    closestCenterIndices = dsearchn(map.lanes(l).center.vertices', [obstaclesInLane.position]');
    sortedVehicles{1, l} = world.Vehicle.empty();
    while any(closestCenterIndices)
        [~, index] = max(closestCenterIndices);
%         sortedVehicles{l, 1} = obstaclesInLane(index);
        sortedVehicles{1, l}(length(sortedVehicles{1, l})+1) = obstaclesInLane(index);
        closestCenterIndices(index) = 0;
    end
end


%DEBUG
for l = 1:length(sortedVehicles)
    for vehIdx = 1:length(sortedVehicles{1, l})
        fprintf('Vehicle %d is numer %d in lane %d\n', sortedVehicles{1, l}(vehIdx).id, vehIdx, map.lanes(l).id);
    end
end


% Step 2: Adapt all occupancies.

% Check if all lanes are empty
% allempty = 1;
% for l = 1:length(sortedVehicles)
%     if ~isempty(sortedVehicles{1,l})
%         allempty = 0;
%         break;
%     end
% end
% if allempty
%     return;
% end

if isempty(map.obstacles)
    warning('There seem to be no obstacles on this map.');
    return;
end
% Iterate over all time intervals
for t = 1:length(map.obstacles(1).occupancy) % TODO Other method to get all time intervals
    % Iterate over all lanes
    for l = 1:length(map.lanes)
        % Iterate through the sortedVehicles array from front (1) to back (end):
        % For every vehicle except the last one, adapt the occupancy of the 
        % following vehicle.
        for i = 1:length(sortedVehicles{1,l})-1
            % Find out which occupancy corresponds to lane l
            for oIdx = 1:length(sortedVehicles{1,l}(i).occupancy(:,1))
                if map.lanes(l).id == sortedVehicles{1,l}(i).occupancy(oIdx,t).forLane.id
                    break;
                end
            end
            % TODO same for following
        
            % DEBUG
%             fprintf('Obstacle %d is t=%d, l=%d, i=%d\n', sortedVehicles{1,l}(i).id, t, l, i);
%              if l == 1 && i == 1 && t == 5
%                  patch(sortedVehicles{1,l}(i).occupancy(oIdx,t).vertices(1,:), sortedVehicles{1,l}(i).occupancy(oIdx,t).vertices(2,:), 1, 'FaceColor', 'r');
%                  for bar = 1:length(sortedVehicles{1,l}(i+1).occupancy(oIdx,t).vertices(1,:))
%                      text(sortedVehicles{1,l}(i+1).occupancy(oIdx,t).vertices(1,bar), sortedVehicles{1,l}(i+1).occupancy(oIdx,t).vertices(2,bar), strcat('o', num2str(bar)));
%                  end
%                  foo = 42;
%              end
            
            % sortedVehicles(i) is the preceding vehicle, sortedVehicles(i+1) the
            % following.
            % precedingFrontLeft and precedingFrontRight are the front points of
            % the occupancy of the preceding vehicle, projected onto the lane
            % border.
            if isempty(sortedVehicles{1,l}(i).occupancy(oIdx,t).vertices)
                warning('The occupancy of the preceding vehicle %d at time interval %d is empty!', sortedVehicles{oIdx,l}(i).id, t);
                continue;
            else
                [precedingFrontLeft, precedingFrontRight] = ...
                    frontBound(sortedVehicles{1,l}(i).occupancy(oIdx,t), map.lanes(l));
            end
            if isempty(sortedVehicles{1,l}(i+1).occupancy(oIdx,t).vertices)
                warning('The occupancy of the following vehicle %d at time interval %d is empty!', sortedVehicles{1,l}(i).id, t);
                continue;
            else
                [followingFrontLeft, followingFrontRight] = ...
                    frontBound(sortedVehicles{1,l}(i+1).occupancy(oIdx,t), map.lanes(l));
            end
            if isnan(precedingFrontLeft(1)) || isnan(precedingFrontLeft(2)) || ...
                    isnan(precedingFrontRight(1)) || isnan(precedingFrontRight(2)) || ...
                    isnan(followingFrontLeft(1)) || isnan(followingFrontLeft(2)) || ...
                    isnan(followingFrontRight(1)) || isnan(followingFrontRight(2))
                % patch(sortedVehicles{1,l}(i).occupancy(1,t).vertices(1,:), sortedVehicles{1,l}(i).occupancy(1,t).vertices(2,:), 1, 'FaceColor', 'r');
                warning('Could not find the front bound of the occupancy of obstacle %d at time interval %d', sortedVehicles{1,l}(i).id, t);
            else
               cp = cutPolygon(precedingFrontLeft, precedingFrontRight, ...
                    followingFrontLeft, followingFrontRight, map.lanes(l), sortedVehicles{1,l}(i).shape.length);
                %[adaptionX, adaptionY] = polybool('intersection', sortedVehicles{l, i+1}.occupancy(1,t).vertices(1,:), sortedVehicles{l, i+1}.occupancy(1,t).vertices(2,:), cp(1,:), cp(2,:));
                [newOccupancyX, newOccupancyY] = polybool('subtraction', sortedVehicles{1,l}(i+1).occupancy(oIdx,t).vertices(1,:), sortedVehicles{1,l}(i+1).occupancy(oIdx,t).vertices(2,:), ...
                    cp(1,:), cp(2,:));
                % polybool might return several polygons, separated by
                % NaN. We assume the first one to be the one we want
                % (otherwise we could compare sizes, since the "other"
                % polygons have close to no or no area at all.
                polygonEnd = find(isnan(newOccupancyX));
                if polygonEnd % i.e. if there is a NaN separator in the polygon
                    newOccupancyX(polygonEnd:end) = [];
                    newOccupancyY(polygonEnd:end) = [];
                end

                sortedVehicles{1,l}(i+1).occupancy(oIdx,t).updateOccupancy([newOccupancyX; newOccupancyY]);
            end
        end
    end
end


% OLD CODE
    function [leftCorner, rightCorner] = cornersOld(occupancy, lane)
        % TODO DEBUG
%         patch(occupancy.vertices(1,:), occupancy.vertices(2,:), 1, 'FaceColor', 'y');
%         for laneIdx = length(lane.leftBorder.vertices(1,:)):-1:1
%             text(lane.leftBorder.vertices(1,laneIdx), lane.leftBorder.vertices(2,laneIdx), strcat('l', num2str(laneIdx)));
%             text(lane.rightBorder.vertices(1,laneIdx), lane.rightBorder.vertices(2,laneIdx), strcat('r', num2str(laneIdx)));
%         end
        
        % We calculate leftCorner and rightCorner as
        % follows:
        % Iterate through all vertices in the occupancy polygon. The first
        % four points that form a 'horseshoe' (i.e. they make a u-turn by
        % at least 360 degrees) form the front of the occupancy. The second
        % and third point of this horseshoe are leftCorner and rightCorner:
        % ... -----------1------------2
        %                    | alpha1 |
        %                    |--------|
        %                    | alpha2 |
        % ... -----------4------------3
        for vi = 1:(length(occupancy.vertices(1,:)) - 3)
            % curr: the currently looked at point
            curr = occupancy.vertices(:,vi);
            
            
            
            % TODO Debug
%             text(curr(1), curr(2), strcat('o', num2str(vi)));
            
            
            
            % flCandidate: the current candidate for precedingFrontLeft
            flCandidate = occupancy.vertices(:,vi+1);
            % frCandidate: the current candidate for precedingFrontRight
            frCandidate = occupancy.vertices(:,vi+2);
            % endPt: The fourth point needed for the calculation
            endPt = occupancy.vertices(:,vi+3);
            % alpha1: The inner angle of the 1-2-3 corner.
            alpha1 = vectorsAngle(frCandidate - flCandidate, curr - flCandidate);
            if alpha1 > 3/4*pi
                % If alpha1 is too big, it's highly unlikely that 
                % flCandidate is an actual corner
                continue;
            end
            % frCandidate could be a vertex in the middle of the lane and
            % the actual front right corner could be one or more vertices
            % away. Thus, we have to search for the front right corner. 
            % distanceFromFLC is the distance of the current front right
            % corner candidate from the front left corner candidate.
            distanceFromFLC = norm(flCandidate - frCandidate);
            % offset is the index offset
            offset = 0;
            while distanceFromFLC < maxLaneWidth
                % alpha2: The outer angle of the 2-3-4 corner.
                alpha2 = vectorsAngle(endPt - frCandidate, flCandidate - frCandidate);
                if alpha2 < 3/4*pi
                    % the angle is small enough to form a proper corner.
                    break;
                end
                offset = offset + 1;
                frCandidate = occupancy.vertices(:,vi+2+offset);
                endPt = occupancy.vertices(:,vi+3+offset);
                distanceFromFLC = norm(flCandidate - frCandidate);
            end
            if distanceFromFLC > maxLaneWidth
                % flCandidate isn't the point we are searching for.
                continue;
            end
            
            angleSum = alpha1 + alpha2;
            if angleSum < 5/4*pi && pi/2 < angleSum
                % The vertices form a u-turn
                % Find the nearest lane point
                % The index of the point on the left border that is closest
                % to flCandidate.
                lbIdx = dsearchn(lane.leftBorder.vertices', flCandidate');
                nearestLeftLanePt = lane.leftBorder.vertices(:,lbIdx);
                % Project flCandidate onto the left lane border. For this,
                % consider the vertices before and after nearestLeftLanePt.
                if lbIdx == 1
                    % The point nearestLeftLanePt is the first vertex on
                    % the left border.
                    % flProjected is the projection of flCandidate on the
                    % left lane border.
                    [flProjected, ~, ~] = geometry.project_point_line_segment(...
                        nearestLeftLanePt, lane.leftBorder.vertices(:,lbIdx+1), flCandidate);
                elseif lbIdx == length(lane.leftBorder.vertices)
                    % The point nearestLeftLanePt is the last vertex on
                    % the left border.
                    % flProjected is the projection of flCandidate on the
                    % left lane border.
                    [flProjected, ~, ~] = geometry.project_point_line_segment(...
                        nearestLeftLanePt, lane.leftBorder.vertices(:,lbIdx-1), flCandidate);
                else
                    % The point nearestLeftLanePt is somewhere between the
                    % first and last vertex on the left lane border.
                    % flProjected is the projection of flCandidate on the
                    % left lane border.
                    [flProjected, ~, ~] = geometry.project_point_line_segment(...
                        nearestLeftLanePt, lane.leftBorder.vertices(:,lbIdx+1), flCandidate);
                    if flProjected == nearestLeftLanePt
                        [flProjected, ~, ~] = geometry.project_point_line_segment(...
                            nearestLeftLanePt, lane.leftBorder.vertices(:,lbIdx-1), flCandidate);
                        % Note that flProjected == nearestLeftLanePt could
                        % still be true.
                    end
                end
                leftCorner = flProjected;
                
                % Same procedure for the right lane border:
                rbIdx = dsearchn(lane.rightBorder.vertices', frCandidate');
                nearestRightLanePt = lane.rightBorder.vertices(:,rbIdx);
                if rbIdx == 1
                    [frProjected, ~, ~] = geometry.project_point_line_segment(...
                        nearestRightLanePt, lane.rightBorder.vertices(:,rbIdx+1), frCandidate);
                elseif rbIdx == length(lane.rightBorder.vertices)
                    [frProjected, ~, ~] = geometry.project_point_line_segment(...
                        nearestRightLanePt, lane.rightBorder.vertices(:,rbIdx-1), frCandidate);
                else
                    [frProjected, ~, ~] = geometry.project_point_line_segment(...
                        nearestRightLanePt, lane.rightBorder.vertices(:,rbIdx+1), frCandidate);
                    if frProjected == nearestRightLanePt
                        [frProjected, ~, ~] = geometry.project_point_line_segment(...
                            nearestRightLanePt, lane.rightBorder.vertices(:,rbIdx-1), frCandidate);
                    end
                end
                rightCorner = frProjected;
                break;
            end
        end
        if ~exist('leftCorner', 'var')
            % DEBUG
%             for oIndex = 1:length(occupancy.vertices(1,:))
%                 text(occupancy.vertices(1,oIndex), occupancy.vertices(2,oIndex), strcat('o', num2str(oIndex)));
%             end
             
            warning('Corners function could not determine the front left corner.');
            leftCorner = [NaN; NaN];
        end
        if ~exist('rightCorner', 'var')
            warning('Corners function could not determine the front right corner.');
            rightCorner = [NaN; NaN];
        end
        %patch(occupancy.vertices(1,:), occupancy.vertices(2,:), 1, 'FaceColor', 'r');
        %text(leftCorner(1), leftCorner(2), 'l');
        %text(rightCorner(1), rightCorner(2), 'r');
    end

end