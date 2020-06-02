classdef WptToWorldConverter < handle
    %WptToWorldConverter Converts a sampled WPT to a target path segment in
    %world coordinates.
    
    properties
        roads
        segment_length = 100
    end
    
    methods
        function obj = WptToWorldConverter()
            %WptToWorldConverter Construct an instance of this class
            obj.roads = [];
        end
        
        function add_road(obj, road)
            % add_road adds the given road(s) to the roads list.
            obj.roads = [obj.roads, road];
        end
        
        function target_path = convert_sample_to_target_path(obj,sample)
            %convert_sample_to_target_path Adds an initial wpt from the
            %sample. Then adds new wpt along the sampled direction.
            % If the new path segment intersects with left or right
            % boundary of the road, breaks the leg at the intersection
            % points and adds the rests of the wpts along the road boundary
            % until desired path segment length is reached.
            target_path = []; % target_path is in the world coordinate system.
            road = obj.get_road_from_sample(sample);
            lp = road.get_left_profile();
            rp = road.get_right_profile();
            local_wpt = sample(2:end); %local_wpt is in the road coordinate system.
            local_wpts = cell(0);
            local_wpts{end+1} = local_wpt; % Added the first waypoint.
            
            % Now, adding the second watpoint. Will check if intersects
            % with left or right boundary of the road.
            prev_wpt = local_wpt;
            wpt_long = prev_wpt(1) + obj.segment_length*cos(prev_wpt(3));
            wpt_lat = prev_wpt(2) + obj.segment_length*sin(prev_wpt(3));
            [lx0,ly0,liout,ljout] = intersections(lp(:,1)',lp(:,2)',...
                    [prev_wpt(1), wpt_long],[prev_wpt(2), wpt_lat],'false');
            [rx0,ry0,riout,rjout] = intersections(rp(:,1)',rp(:,2)',...
                    [prev_wpt(1), wpt_long],[prev_wpt(2), wpt_lat],'false');
            if isempty(lx0) && isempty(rx0)
                % No intersection. Add the next wpt and we are done.
                local_wpt = [wpt_long; ...
                             wpt_lat; ...
                             atan2(wpt_lat-prev_wpt(2), wpt_long-prev_wpt(1))];
                if length(prev_wpt) > length(local_wpt)
                    local_wpt = [local_wpt; prev_wpt(length(local_wpt)+1:end)];
                end
                local_wpts{end+1} = local_wpt;
            else
                % Intersected. Find the closest intersection point and add
                % that one.
                if isempty(lx0)
                    closest = [rx0(1), ry0(1)];
                    closest_ind = floor(riout(1));
                    line = rp;
                    len = norm(closest - [prev_wpt(1), prev_wpt(2)]);
                elseif isempty(rx0)
                    closest = [lx0(1), ly0(1)];
                    closest_ind = floor(liout(1));
                    line = lp;
                    len = norm(closest - [prev_wpt(1), prev_wpt(2)]);
                else
                    left = [lx0(1), ly0(1)];
                    right = [rx0(1), ry0(1)];
                    left_len = norm(left - [prev_wpt(1), prev_wpt(2)]);
                    right_len = norm(right - [prev_wpt(1), prev_wpt(2)]);
                    if left_len < right_len
                        closest = [lx0(1), ly0(1)];
                        closest_ind = floor(liout(1));
                        line = lp;
                        len = left_len;
                    else
                        closest = [rx0(1), ry0(1)];
                        closest_ind = floor(riout(1));
                        line = rp;
                        len = right_len;
                    end
                end
                local_wpt = [closest(1); ...
                             closest(2); ...
                             atan2(closest(2)-prev_wpt(2), closest(1)-prev_wpt(1))];
                if length(prev_wpt) > length(local_wpt)
                    local_wpt = [local_wpt; prev_wpt(length(local_wpt)+1:end)];
                end
                local_wpts{end+1} = local_wpt;
                
                % Now, until desired length is achieved, add points along
                % the road boundary.
                temp_len = len;
                while temp_len < obj.segment_length - 0.0001 % using some epsilon against numerical errors
                    prev_wpt = local_wpt;
                    next_ind = closest_ind + 1;
                    if size(line,1) >= next_ind
                        closest = line(next_ind, :);
                        len = norm(closest - [prev_wpt(1), prev_wpt(2)]);
                    else
                        % The intersected segment is the last segment of
                        % the road. Add new wpt along the same direction as
                        % the last one.
                        closest = [prev_wpt(1) + (obj.segment_length-temp_len)*cos(prev_wpt(3)), ...
                                   prev_wpt(2) + (obj.segment_length-temp_len)*sin(prev_wpt(3))];
                        len = obj.segment_length-temp_len;
                    end
                    closest_ind = next_ind;
                    ratio = min(1, (obj.segment_length-temp_len)/len);
                    temp_ang = atan2(closest(2)-prev_wpt(2), closest(1)-prev_wpt(1));
                    local_wpts{end}(3) = temp_ang;
                    local_wpt = [prev_wpt(1) + ratio*(closest(1)-prev_wpt(1)); ...
                                 prev_wpt(2) + ratio*(closest(2)-prev_wpt(2)); ...
                                 temp_ang];
                    if length(prev_wpt) > length(local_wpt)
                        local_wpt = [local_wpt; prev_wpt(length(local_wpt)+1:end)];
                    end
                    local_wpts{end+1} = local_wpt;
                    len = norm(local_wpt(1:2) - prev_wpt(1:2));
                    temp_len = temp_len + len;
                    if len == 0
                        break;
                    end
                end
            end
            
            for l_i = 1:length(local_wpts)
                temp_wpt = road.convert_road_to_world_coordinates(local_wpts{l_i});
                target_path = [target_path, temp_wpt];
            end
        end
        
        function road = get_road_from_sample(obj, sample)
            window = 1/length(obj.roads);
            road_ind = min(length(obj.roads), max(ceil(sample(1)/window), 1));
            road = obj.roads(road_ind);
        end
    end
end

