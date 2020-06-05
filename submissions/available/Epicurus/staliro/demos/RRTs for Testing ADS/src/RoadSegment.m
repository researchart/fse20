classdef RoadSegment < handle
    %RoadSegment Describes a road segment which can be straight or curved.
    % A RoadSegment is part of a SimRoad and coordinates of a segment is
    % described in the coordinate system of the SimRoad that it belongs to.
    
    properties
        id = 'unset'
        type = 'straight'
        start_long_pos = 0 % wrt SimRoad coordinate system. Considering the road as a straight line along x-axis.
        start_x = 0 % Relative to the road start position.
        start_y = 0 % Relative to the road start position.
        end_x = 0 % Relative to the road start position.
        end_y = 0 % Relative to the road start position.
        length = 100
        rotation = 0 % Positive rotation angle is toward left
        start_height = 0
        end_height = 0
        start_left_width = 7
        end_left_width = 7
        start_right_width = 7
        end_right_width = 7
        width = 14
        turn_angle = 0 % If turn_angle is 0, this is a straight segment. Otherwise, curved. Positive turn_angle is toward left.
        center = [] % Center is meaningful only if the road segment is curved
        radius = [] % Radius is meaningful only if the road segment is curved
    end
    
    methods
        function obj = RoadSegment(varargin)
            %RoadSegment Construct an instance of this class
            obj.set_parameter(varargin{:});
        end
        
        function set_parameter(obj, varargin)
            % set_parameter takes parameter name and value pairs.
            assert(mod(nargin, 2) == 1, 'set_parameter takes a list of parameter name and value pairs!');
            for n_i = 1:(nargin-1) / 2
                param_name = varargin{2*n_i - 1};
                param_value = varargin{2*n_i};
                % Error checking:
                assert(isprop(obj, param_name) || strcmpi(param_name, 'width'), ...
                    'RoadSegment does not have a parameter named %s!',param_name);
                assert(~strcmpi(param_name, 'type'), ...
                    'Type of a road segment can not be directly set! Use turn_angle parameter.');
                assert(~strcmpi(param_name, 'center') || ~strcmpi(obj.type, 'straight'), ...
                    'Center of a STRAIGHT road segment can not be set! It has no meaning for straight segments.');
                assert(~strcmpi(param_name, 'radius') || ~strcmpi(obj.type, 'straight'), ...
                    'Radius of a STRAIGHT road segment can not be set! It has no meaning for straight segments.');

                if strcmpi(param_name, 'width')
                    half_width = param_value/2;
                    obj.start_left_width = half_width;
                    obj.end_left_width = half_width;
                    obj.start_right_width = half_width;
                    obj.end_right_width = half_width;
                end
                obj.(param_name) = param_value;
                if strcmpi(param_name, 'turn_angle')
                    if obj.turn_angle == 0
                        obj.type = 'straight';
                        obj.center = [];
                    else
                        obj.type = 'curved';
                    end
                end
            end
            
            % In case only side widths are set, make sure width is
            % consistent with the side widths.
            obj.width = mean(obj.start_left_width, obj.end_left_width) ...
                    + mean(obj.start_right_width, obj.end_right_width);
            % After all settings are done, compute the parameters that we
            % need to compute.
            if strcmpi(obj.type, 'curved')
                obj.compute_center_and_radius;
            end
            obj.compute_end_position();
        end
        
        function compute_center_and_radius(obj)
            %compute_center Computes center and radius for curved road
            %segments.
            assert(obj.turn_angle ~= 0, ...
                'RoadSegment center cannot be computed for straight segments.')
            direction_factor = sign(obj.turn_angle);
            obj.radius = obj.length / abs(obj.turn_angle);
            temp_center = [0; direction_factor*obj.radius];
            real_center = rot2(obj.rotation) * temp_center + ...
                            [obj.start_x; obj.start_y];
            obj.center = real_center';
        end
        
        function compute_end_position(obj)
            if strcmpi(obj.type, 'straight')
                obj.end_x = obj.start_x + obj.length*cos(obj.rotation);
                obj.end_y = obj.start_y + obj.length*sin(obj.rotation);
            else
                direction_factor = sign(obj.turn_angle);
                end_angle = wrapToPi(-direction_factor*pi/2 + obj.rotation + obj.turn_angle);
                obj.end_x = obj.center(1) + obj.radius*cos(end_angle);
                obj.end_y = obj.center(2) + obj.radius*sin(end_angle);
            end
        end
        
        function r_x = convert_segment_to_road_coordinates(obj, s_x)
            % convert_segment_to_road_coordinates Converts [x,y,theta] from
            % segment to road coordinates.
            long_pos = s_x(1) - obj.start_long_pos;
            if strcmpi(obj.type, 'straight')
                pos = rot2(obj.rotation)*[long_pos;s_x(2)] + ...
                        [obj.start_x; obj.start_y];
                rot = obj.rotation + s_x(3);
                r_x = [pos(1); pos(2); rot];
            else
                temp_angle = (long_pos/obj.length) * obj.turn_angle;
                direction_factor = sign(obj.turn_angle);
                end_angle = wrapToPi(-direction_factor*pi/2 + obj.rotation + temp_angle);
                r_x = [obj.center(1) + (obj.radius-direction_factor*s_x(2))*cos(end_angle); ...
                       obj.center(2) + (obj.radius-direction_factor*s_x(2))*sin(end_angle); ...
                       obj.rotation + temp_angle + s_x(3)];
            end
        end
    end
end

