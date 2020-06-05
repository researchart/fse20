classdef SimRoad < handle
    %SimRoad consists of a list of segments, position and rotation in world coordinates.
    % Note: The name Road was taken by Matlab automated driving toolbox.
    
    properties
        id = 'road'
        segments = [] % List of road segments
        start_x = 0 % In world coordinates. Translates all segments.
        start_y = 0 % In world coordinates. Translates all segments.
        rotation = 0 % In world coordinates. Rotates all segments (at creation time).
        left_profile = [] % List of points defining left boundary. In road coordinates.
        right_profile = [] % List of points defining right boundary. In road coordinates.
    end
    
    methods
        function obj = SimRoad(varargin)
            %Road Construct an instance of this class.
            % Given rotation is applied to all segments at the tim eof
            % creation. So, we don't apply rotation again when we need to
            % convert to the world coordinates.
            assert(mod(nargin, 2) == 0, ...
                'Road takes a list of parameter name and value pairs!');
            for n_i = 1:nargin/2
                param_name = varargin{2*n_i - 1};
                param_value = varargin{2*n_i};
                % Error checking:
                assert(isprop(obj, param_name), ...
                    'Road does not have a parameter named %s!',param_name);
                obj.(param_name) = param_value;
            end
        end
        
        function add_segment(obj,segment)
            %add_segment Adds given segment to the road.
            segment.set_parameter('id', [obj.id, '_', length(obj.segments)+1]);
            obj.segments = [obj.segments, segment];
            obj.left_profile = []; % If it was computed before, reset it.
            obj.right_profile = []; % If it was computed before, reset it.
        end
        
        function create_and_add_segment(obj,varargin)
            %create_and_add_segment First creates a segment, then adds to tthe road.
            % Given rotation field is assumed to be relative to the
            % previous segment.
            if isempty(obj.segments)
                last_pos = [0, 0];
                last_rotation = obj.rotation;
                last_long_pos = 0;
            else
                last_pos = [obj.segments(end).end_x, obj.segments(end).end_y];
                last_rotation = obj.segments(end).rotation + obj.segments(end).turn_angle;
                last_long_pos = obj.segments(end).start_long_pos + obj.segments(end).length;
            end
            segment = RoadSegment(varargin{:});
            segment.set_parameter('start_x', last_pos(1), 'start_y', last_pos(2));
            segment.set_parameter('rotation', segment.rotation + last_rotation);
            segment.set_parameter('start_long_pos', last_long_pos);
            obj.add_segment(segment);
        end
        
        function segment_ind = find_segment_index_for_long_pos(obj, long_pos)
            % find_segment_index_for_long_pos Finds the corresponding
            %segment to the given longitudinal position.
            segment_ind = [];
            if ~isempty(obj.segments)
                for s_i = length(obj.segments):-1:1
                    if long_pos > obj.segments(s_i).start_long_pos
                        segment_ind = s_i;
                        break;
                    end
                end
            end
        end
        
        function w_x = convert_road_to_world_coordinates(obj, r_x)
            % convert_road_to_world_coordinates Converts [x,y,theta] from
            % road to world coordinates. Refer to the note about the 
            % rotation in the class constructor. Directly passes the rest
            % of the coordinates if it has more than 3 elements.
            segment_ind = obj.find_segment_index_for_long_pos(r_x(1));
            if isempty(segment_ind)
                pos = rot2(obj.rotation) * [r_x(1);r_x(2)] + ...
                    [obj.start_x; obj.start_y];
                rot = obj.rotation + r_x(3);
                w_x = [pos(1); pos(2); rot];
            else
                w_x = obj.segments(segment_ind).convert_segment_to_road_coordinates(r_x);
                w_x = w_x + [obj.start_x; obj.start_y; 0];
            end
            if length(r_x) > 3
                w_x = [w_x; r_x(4:end)];
            end
        end
        
        function lp = get_left_profile(obj)
            % get_left_profile Returns left profile as nx2 (2 for x,y).
            % Does not compute again if already computed.
            if ~isempty(obj.left_profile)
                lp = obj.left_profile;
            else
                obj.compute_left_profile();
                lp = obj.left_profile;
            end
        end
        
        function rp = get_right_profile(obj)
            % get_left_profile Returns right profile as nx2 (2 for x,y).
            % Does not compute again if already computed.
            if ~isempty(obj.right_profile)
                rp = obj.right_profile;
            else
                obj.compute_right_profile();
                rp = obj.right_profile;
            end
        end
        
        function compute_left_profile(obj)
            % Computes left profile as nx2 (2 for x,y).
            obj.left_profile = zeros(2*length(obj.segments), 2);
            for s_i = 1:length(obj.segments)
                temp = [obj.segments(s_i).start_long_pos, obj.segments(s_i).start_left_width];
                obj.left_profile(2*s_i - 1,:) = temp;
                temp = [obj.segments(s_i).start_long_pos+obj.segments(s_i).length, obj.segments(s_i).end_left_width];
                obj.left_profile(2*s_i,:) = temp;
            end
        end
        
        function compute_right_profile(obj)
            % Computes right profile as nx2 (2 for x,y).
            obj.right_profile = zeros(2*length(obj.segments), 2);
            for s_i = 1:length(obj.segments)
                temp = [obj.segments(s_i).start_long_pos, -obj.segments(s_i).start_right_width];
                obj.right_profile(2*s_i - 1,:) = temp;
                temp = [obj.segments(s_i).start_long_pos+obj.segments(s_i).length, -obj.segments(s_i).end_right_width];
                obj.right_profile(2*s_i,:) = temp;
            end
        end
    end
end

