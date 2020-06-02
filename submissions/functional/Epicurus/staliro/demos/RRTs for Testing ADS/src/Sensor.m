classdef Sensor < handle
    %SENSOR Models a sensor
    
    properties
        type
        id
        location
        orientation
        time_delay
        noise
        period
        ang_range
        dist_range
        prev_detections
        rel_pose
    end
    
    methods
        function s = Sensor(type,id,location,orientation,time_delay,noise,period,ang_range,dist_range)
            %SENSOR Construct an instance of this class
            %   Detailed explanation goes here
            s.type = type;
            s.id = id;
            s.location = location;
            s.orientation = orientation;
            s.time_delay = time_delay;
            s.noise = noise;
            s.period = period;
            s.ang_range = ang_range;
            s.dist_range = dist_range;
            s.prev_detections = [];
            s.rel_pose = SE2([s.location(1);s.location(2);s.orientation]);
        end
        
        function detections = detect(s,sim_items,cur_time)
            %DETECT Summary of this method goes here
            %   Detailed explanation goes here
            if mod(cur_time, s.period) ~= 0
                % Return old detections if sensor is not refreshed.
                detections = s.prev_detections;
            else
                detections = [];
                past_index = s.time_delay / sim_items.self_vhc.dt;
                if size(sim_items.self_vhc.x_hist,1) > past_index
                    x_self = sim_items.self_vhc.x_hist(end-past_index, :);  % Self vhc coordinates
                    %vhc_c = SE2(x_self(1:3));  % Self vehicle pose
                    vhc_c_T = eye(3);
                    vhc_c_T(1:2,1:2) = rot2(x_self(3));
                    vhc_c_T(1:2,3) = [x_self(1);x_self(2)];
                    %sensor_c = vhc_c*s.rel_pose;  % Sensor pose (coordinate system)
                    sensor_c_T = vhc_c_T*s.rel_pose.T;
                    for ii = 1:length(sim_items.other_vhc)
                        past_index = s.time_delay / sim_items.other_vhc(ii).dt;
                        if size(sim_items.other_vhc(ii).x_hist,1) > past_index
                            %TODO We only detect based on the center of the
                            %other vehicle, not the boundaries. This is
                            %a bit unrealistic.
                            x_det = sim_items.other_vhc(ii).x_hist(end-past_index, :);  % Detected item states
                            x_det_rel = sensor_c_T\[x_det(1);x_det(2);1];  % Detected item position in sensor coord. system.
                            pos_rel_ang = atan2(x_det_rel(2), x_det_rel(1));
                            dist = norm(x_det_rel(1:2));
                            if dist > s.dist_range(1) && dist < s.dist_range(2) && pos_rel_ang > s.ang_range(1) && pos_rel_ang < s.ang_range(2)
                                x_det_rel = vhc_c_T\[x_det(1);x_det(2);1];  % Detected item position in vehicle coord. system.
                                x_det_rel(3) = x_det(3) - x_self(3);  % Setting the relative angle of the detected item wrt vehicle.
                                detections(end+1).pos = x_det_rel; %#ok<AGROW>
                                detections(end).speed = [x_det(4)*cos(x_det_rel(3))-x_self(4), x_det(4)*sin(x_det_rel(3))]; % Rel. speed in x and y.
                                detections(end).sensor_id = s.id;
                                detections(end).sensor_type = s.type;
                            end
                        end
                    end
                end
            end
        end
        
    end
end
