% ConvoyMPCwithStanley Car driver class
%
%
% The driver object is attached to a DynamicCar object by add_driver() method.
%
% Methods:
%  demand     return force and steer angle inputs for the next time instant
%  init       initialization
%  display    display the state and parameters in human readable form
%  char       convert to string the display method
%      
% Properties::
%  target_path % target path as a list of waypoints: [x; y; theta]
%
% Example::
%
%    veh = DynamicCar();
%    veh.add_driver(ConvoyMPCwithStanley());
%
% See also VehicleDriver, DynamicCar, Car, Vehicle, Bicycle.

% (C) C. E. Tuncali, ASU

classdef ConvoyMPCwithStanley < VehicleDriver
    properties
        % Controller states
        driving_mode
        collision_avoidance_time_counter
        last_detections
        
        % Object references
        long_mpc
        lat_contr
        perception_system
        sim_env
        
        % Configurable parameters
        area_of_interest % Distance in front, rear and side that defines the area of interest for detected vehicles
        future_estimate_dt
        future_estimate_horizon
        collision_risk_area % Distance in front, rear and side that defines the area of conflict
        max_coll_avoid_duration
        
        % Vehicle related constants/parameters
        X_IND
        Y_IND
        ORIENTATION_IND
        SPEED_IND
        ANG_SPEED_IND
        FRONT_CORR_WIDTH
        
        % For future use
        target_path % target path as a list of waypoints: [x; y; theta; v]
        target_speed
    end

    methods

        function driver = ConvoyMPCwithStanley()
            driver.reset();
        end
        
        function driver = reset(driver)
            driver.driving_mode = 'normal';
            driver.collision_avoidance_time_counter = 0;
            driver.last_detections = [];
            
            driver.long_mpc = ConvoyMPC(0.01);
            driver.lat_contr = StanleyController();
            driver.perception_system = [];
            driver.sim_env = [];
            
            driver.area_of_interest = [50, 20, 5]; %FRONT, REAR, SIDE
            driver.future_estimate_dt = 0.1;
            driver.future_estimate_horizon = 3;
            driver.collision_risk_area = [8, 4, 2.5]; %FRONT, REAR, SIDE
            driver.max_coll_avoid_duration = 3.0;
            
            driver.X_IND = 1;
            driver.Y_IND = 2;
            driver.ORIENTATION_IND = 3;
            driver.SPEED_IND = 4;
            driver.ANG_SPEED_IND = 5;
            driver.FRONT_CORR_WIDTH = 2.0;
            
            driver.target_path = [];
            driver.target_speed = driver.long_mpc.v_ref;
        end
        
        function init(driver)
            driver.long_mpc.dt = driver.veh.dt;
            driver.long_mpc.init_mpc();
        end
        
        function states = get_states(driver)
            states.driving_mode = driver.driving_mode;
            states.collision_avoidance_time_counter = driver.collision_avoidance_time_counter;
            states.last_detections = driver.last_detections;
        end
        
        function driver = set_states(driver, states)
            if ~isempty(states)
                driver.driving_mode = states.driving_mode;
                driver.collision_avoidance_time_counter = states.collision_avoidance_time_counter;
                driver.last_detections = states.last_detections;
            end
        end
        
        function driver = set_perception_system(driver, perc_system)
            driver.perception_system = perc_system;
        end
        
        function driver = set_simulation_environment(driver, sim_env)
            driver.sim_env = sim_env;
        end
        
        function detections = get_detections(driver)
            detections = [];
            if isa(driver.perception_system, 'PerceptionSystem')
                detections = driver.perception_system.get_all_detections(driver.sim_env);
            end
            ignore_list = []; %#ok<NASGU>
            for d_i = 1:length(detections)
                if detections(d_i).pos(driver.X_IND) > driver.area_of_interest(1) || ...
                        detections(d_i).pos(driver.X_IND) < -driver.area_of_interest(2) || ...
                        abs(detections(d_i).pos(driver.Y_IND)) > driver.area_of_interest(3)
                    % Detection is outside the area of interest
                    ignore_list = [ignore_list, d_i]; %#ok<AGROW>
                end
            end
            if ~isempty(ignore_list)
                detections(ignore_list) = []; %#ok<AGROW>
            end
        end
        
        function detections_future_estimates = estimate_future_of_detections(driver, detections)
            % Estimate relative future positions of the detections.
            num_future_estimate = round(driver.future_estimate_horizon / driver.future_estimate_dt);
            detections_future_estimates = {};

            if ~isempty(detections)
                for d_i = 1:length(detections)
                    det_future_estimate = repmat([detections(d_i).pos(1); ...
                                                    detections(d_i).pos(2); ...
                                                    detections(d_i).pos(3); ...
                                                    detections(d_i).speed(1); ...
                                                    detections(d_i).speed(2)], 1, num_future_estimate);
                    for ii = 2:num_future_estimate
                        det_future_estimate(1, ii) = ...
                            det_future_estimate(1, ii-1) + ...
                            det_future_estimate(4, ii-1)*driver.future_estimate_dt;
                        det_future_estimate(2, ii) = ...
                            det_future_estimate(2, ii-1) + ...
                            det_future_estimate(5, ii-1)*driver.future_estimate_dt;
                    end
                    detections_future_estimates{d_i} = det_future_estimate;
                end
            end
        end
        
        function [in_area, area_name] = get_occupied_area(driver,rel_pos)
            REARLEFT = 1;
            FRONTLEFT = 2;
            FRONT = 3;
            FRONTRIGHT = 4;
            REARRIGHT = 5;
            
            in_area = false;
            area_name = FRONT;
            if abs(rel_pos(2)) < driver.collision_risk_area(3) && ...
                    rel_pos(1) < 15.0 && rel_pos(1) > 0
                in_area = true;
                area_name = FRONT;
            % Commented out the following, because the relative lateral position
            % should always be positive for LEFT and negative for RIGHT
            % objects regardless of Ego orientation.
            %elseif (rel_pos(2) > 0 && abs(driver.veh.x(driver.ORIENTATION_IND)) < pi/2) || ... 
                %(rel_pos(2) < 0 && abs(driver.veh.x(driver.ORIENTATION_IND)) > pi/2)
            elseif rel_pos(2) > 0
                if rel_pos(1) < 15.0 && rel_pos(1) > 0
                    in_area = true;
                    area_name = FRONTLEFT;
                elseif rel_pos(1) > -15.0 && rel_pos(1) < 0
                    in_area = true;
                    area_name = REARLEFT;
                end
            %elseif (rel_pos(2) < 0 && abs(driver.veh.x(driver.ORIENTATION_IND)) < pi/2) || ... 
            %        (rel_pos(2) > 0 && abs(driver.veh.x(driver.ORIENTATION_IND)) > pi/2)
            elseif rel_pos(2) < 0
                if rel_pos(1) < 15.0 && rel_pos(1) > 0
                    in_area = true;
                    area_name = FRONTRIGHT;
                elseif rel_pos(1) > -15.0 && rel_pos(1) < 0
                    in_area = true;
                    area_name = REARRIGHT;
                end
            end
        end
        
        function area_occupancies = compute_area_occupancies(driver,detections_future_estimates)
            REARLEFT = 1;
            FRONTLEFT = 2;
            FRONT = 3;
            FRONTRIGHT = 4;
            REARRIGHT = 5;
            NUM_OF_AREAS = 5;
            area_occupancies = cell(1, NUM_OF_AREAS);
            for d_i = 1:length(detections_future_estimates)
                for ii = 1:size(detections_future_estimates{d_i}, 2)
                    [in_area, area_name] = driver.get_occupied_area(...
                        detections_future_estimates{d_i}(:,ii));
                    if in_area
                        if isempty(area_occupancies{area_name}) || ...
                                area_occupancies{area_name}(end) ~= d_i
                            % If this item was estimated to be on one side
                            % and now estimated to be on other side, then
                            % we don't add current estimation as it can't
                            % pass inside the ego vehicle.
                            if (area_name == REARLEFT || area_name == FRONTLEFT) && ...
                                (~isempty(find(area_occupancies{REARRIGHT}==d_i,1)) || ...
                                ~isempty(find(area_occupancies{FRONTRIGHT}==d_i,1)))
                                continue
                            end
                            if (area_name == REARRIGHT || area_name == FRONTRIGHT) && ...
                                (~isempty(find(area_occupancies{REARLEFT}==d_i,1)) || ...
                                ~isempty(find(area_occupancies{FRONTLEFT}==d_i,1)))
                                continue
                            end
                            area_occupancies{area_name} = [area_occupancies{area_name}, d_i];
                        end
                    end
                end
            end
            % If the same object is counted in the area_occupacy multiple
            % times, remove duplicates:
            for ii = 1:length(area_occupancies)
                area_occupancies{ii} = unique(area_occupancies{ii});
            end
        end
        
        function future_collisions = estimate_future_collisions(driver,detections_future_estimates)
            REARLEFT = 1;
            FRONTLEFT = 2;
            FRONT = 3;
            FRONTRIGHT = 4;
            REARRIGHT = 5;
            NUM_OF_AREAS = 5;
            future_collisions = cell(1, NUM_OF_AREAS);
            
            for d_i = 1:length(detections_future_estimates)
                is_collision = false;
                for ii = 1:size(detections_future_estimates{d_i}, 2)
                    future_rel_pos = detections_future_estimates{d_i}(:,ii);
                    if (abs(future_rel_pos(2)) < driver.collision_risk_area(3) ...
                        && future_rel_pos(1) < driver.collision_risk_area(1) ...
                        && future_rel_pos(1) > -driver.collision_risk_area(2))
                        
                        is_collision = true;
                        cur_rel_pos = detections_future_estimates{d_i}(:,1);
                        ego_going_to_right = abs(driver.veh.x(driver.ORIENTATION_IND)) < pi/2;
                        det_y_positive = cur_rel_pos(2) > 0;
                        if future_rel_pos(1) > 0 % Front collision
                            % Decide the collision side based on current config.
                            if abs(cur_rel_pos(2)) < driver.collision_risk_area(3)
                                % Already in front
                                area_name = FRONT;
                            else
                                if (ego_going_to_right && det_y_positive) || ...
                                        (~ego_going_to_right && ~det_y_positive)
                                    area_name = FRONTLEFT;
                                else
                                    area_name = FRONTRIGHT;
                                end
                            end
                        else % Rear collision
                            % Decide the collision side based on current config.
                            if (ego_going_to_right && det_y_positive) || ...
                                    (~ego_going_to_right && ~det_y_positive)
                                area_name = REARLEFT;
                            else
                                area_name = REARRIGHT;
                            end
                        end
                        break; % Already found a collision for this detection.
                    end
                end
                if is_collision
                    future_collisions{area_name} = [future_collisions{area_name}, d_i];
                end
            end
        end
        
        function risky_detections = plan_driving_mode(driver,area_occupancies,future_collisions)
            REARLEFT = 1;
            FRONTLEFT = 2;
            FRONT = 3;
            FRONTRIGHT = 4;
            REARRIGHT = 5;
            risky_detections = [];
            old_mode = driver.driving_mode; % For debug
            % Decide on a policy based on the collision estimates.
            if driver.collision_avoidance_time_counter >= driver.max_coll_avoid_duration
                % Maneuver timed out. Switch to normal driving.
                driver.driving_mode = 'normal';
                driver.collision_avoidance_time_counter = 0;
            end
            if strcmpi(driver.driving_mode, 'normal')% && ~isempty(future_collisions)
                driver.collision_avoidance_time_counter = 0;
                % Collision risk. Decide maneuver.
                if ~isempty(future_collisions{FRONT})
                    risky_detections = future_collisions{FRONT};
                    if isempty(area_occupancies{REARLEFT})
                        driver.driving_mode = 'rearleft';
                    elseif isempty(area_occupancies{REARRIGHT})
                        driver.driving_mode = 'rearright';
                    else
                        driver.driving_mode = 'emergencybrake';
                    end
                elseif ~isempty(future_collisions{FRONTLEFT})
                    risky_detections = future_collisions{FRONTLEFT};
                    if isempty(area_occupancies{REARRIGHT})
                        driver.driving_mode = 'rearright';
                    else
                        driver.driving_mode = 'emergencybrake';
                    end
                elseif ~isempty(future_collisions{FRONTRIGHT})
                    risky_detections = future_collisions{FRONTRIGHT};
                    if isempty(area_occupancies{REARLEFT})
                        driver.driving_mode = 'rearleft';
                    else
                        driver.driving_mode = 'emergencybrake';
                    end
                elseif ~isempty(future_collisions{REARLEFT})
                    risky_detections = future_collisions{REARLEFT};
                    if isempty(area_occupancies{FRONTRIGHT}) && ...
                            isempty(area_occupancies{FRONT})
                        driver.driving_mode = 'frontright';
                    elseif isempty(area_occupancies{FRONT}) && ...
                            isempty(future_collisions{FRONTRIGHT})
                        driver.driving_mode = 'speedup';
                    elseif isempty(area_occupancies{REARRIGHT})
                        driver.driving_mode = 'rearright';
                    else
                        driver.driving_mode = 'emergencybrake';
                    end
                elseif ~isempty(future_collisions{REARRIGHT})
                    risky_detections = future_collisions{REARRIGHT};
                    if isempty(area_occupancies{FRONTLEFT}) && ...
                            isempty(area_occupancies{FRONT})
                        driver.driving_mode = 'frontleft';
                    elseif isempty(area_occupancies{FRONT}) && ...
                            isempty(future_collisions{FRONTLEFT})
                        driver.driving_mode = 'speedup';
                    elseif isempty(area_occupancies{REARLEFT})
                        driver.driving_mode = 'rearleft';
                    else
                        driver.driving_mode = 'emergencybrake';
                    end
                end
            else
                % We were doing a maneuver but that area is not empty
                % anymore. Just do emergency braking in this case.
                driver.collision_avoidance_time_counter = driver.collision_avoidance_time_counter + driver.veh.dt;
                if (strcmpi(driver.driving_mode, 'speedup') && ~isempty(area_occupancies{FRONT})) || ...
                        (strcmpi(driver.driving_mode, 'frontleft') && ~isempty(area_occupancies{FRONTLEFT})) || ...
                        (strcmpi(driver.driving_mode, 'rearleft') && ~isempty(area_occupancies{REARLEFT})) || ...
                        (strcmpi(driver.driving_mode, 'frontright') && ~isempty(area_occupancies{FRONTRIGHT})) || ...
                        (strcmpi(driver.driving_mode, 'rearright') && ~isempty(area_occupancies{REARRIGHT}))
                    % New maneuver type. Reset counter.
                    driver.collision_avoidance_time_counter = 0;
                    driver.driving_mode = 'emergencybrake';
                end
            end
            %if ~strcmpi(old_mode, driver.driving_mode)
            %    disp(driver.driving_mode);
            %end
        end
        
        function [front_vhc_position_estimate, dist] = get_front_vhc_position(driver, detections)
            front_ind = 0;
            front_vhc_position_estimate = [];
            dist = inf;
            
            for d_i = 1:length(detections)
                if detections(d_i).pos(1) > 0 && abs(detections(d_i).pos(2)) < driver.FRONT_CORR_WIDTH
                    if front_ind == 0 || detections(d_i).pos(1) < detections(front_ind).pos(1)  %Closer then prev detection
                        front_ind = d_i;
                    end
                end
            end
            if front_ind > 0
                dist = detections(front_ind).pos(1);
                front_vhc_position_estimate = zeros(driver.long_mpc.N+1,1);
                front_vhc_position_estimate(1) = driver.veh.x(driver.X_IND) + ...
                    detections(front_ind).pos(1);
                for ii = 2:driver.long_mpc.N+1
                    front_vhc_position_estimate(ii) = ...
                        front_vhc_position_estimate(ii-1) + ...
                        (driver.veh.x(driver.SPEED_IND) + ...
                        detections(front_ind).speed(1))*driver.long_mpc.dt;
                end
            end
        end
        
        function [force, steer] = compute_control_for_driving_mode(driver, detections, risky_detections)
            if strcmpi(driver.driving_mode, 'normal')
                % MPC for normal driving.
                % Decide on the vehicle in front (Here we ignore the cut-ins
                % and maybe there will be falsifications because of this)
                if strcmpi(driver.driving_mode, 'normal')
                    driver.long_mpc.v_ref = driver.target_speed;
                else
                    driver.long_mpc.v_ref = driver.target_speed * 2.0;
                end
                [front_vhc_position_estimate, dist] = driver.get_front_vhc_position(detections);
                force = driver.long_mpc.compute_mpc(driver.veh.x, ...
                                                    driver.veh.u_prev(1), ...
                                                    dist, ...
                                                    front_vhc_position_estimate);
                steer = driver.lat_contr.compute_control(driver.veh.x, zeros(5,1));
            else
                % Longitudinal control for collision avoidance.
                if strcmpi(driver.driving_mode, 'emergencybrake') || ...
                        strcmpi(driver.driving_mode, 'rearleft') || ...
                        strcmpi(driver.driving_mode, 'rearright')
                    if driver.veh.x(driver.SPEED_IND) > 0
                        force = driver.long_mpc.u_min;
                    else
                        force = 0.0;
                    end
                elseif strcmpi(driver.driving_mode, 'frontleft') || ...
                        strcmpi(driver.driving_mode, 'frontright') || ...
                        strcmpi(driver.driving_mode, 'speedup')
                    if driver.veh.x(driver.SPEED_IND) > driver.veh.speedmax - 1.0
                        force = 0.0;
                    else
                        force = driver.long_mpc.u_max;
                    end
                else % This won't happen
                    force = 0.0;
                end
                
                % Lateral control for collision avoidance.
                % Go to the next lane or at least 2m away from the risky
                % object. As half width of a car is around 0.9m, we compute
                % the safe distance as 3.8m = 2*0.9m + 2m.
                if strcmpi(driver.driving_mode, 'frontleft') || ...
                        strcmpi(driver.driving_mode, 'rearleft')
                    % TODO: Target orientation is hard-coded as 0 or pi here.
                    % Update this when you allow a target path for the ego
                    % or arbitrary road shapes.
                    % TODO: A reference lateral escape target as 4.0/-4.0
                    % is hard-coded here as the target path is along
                    % x-axis. Change it to the next lane with respect to
                    % the current target path when you add a target path
                    % for the Ego vehicle.
                    target = zeros(5,1);
                    min_side_dist = 10.0;
                    for rd_i = 1:length(risky_detections)
                        d_i = risky_detections(rd_i);
                        if abs(detections(d_i).pos(2)) < min_side_dist
                            min_side_dist = abs(detections(d_i).pos(2));
                        end
                    end
                    if abs(driver.veh.x(driver.ORIENTATION_IND)) < pi/2
                        target(driver.lat_contr.LAT_POS_IND) = ...
                            max(9.5, driver.veh.x(driver.Y_IND)-min_side_dist+3.8);
                    else
                        target(driver.lat_contr.LAT_POS_IND) = ...
                            min(-9.5, driver.veh.x(driver.Y_IND)+min_side_dist-3.8);
                        target(driver.lat_contr.ORIENTATION_IND) = pi;
                    end
                    steer = driver.lat_contr.compute_control(driver.veh.x, target);
                elseif strcmpi(driver.driving_mode, 'frontright') || ...
                        strcmpi(driver.driving_mode, 'rearright')
                    target = zeros(5,1);
                    min_side_dist = 10.0;
                    for rd_i = 1:length(risky_detections)
                        d_i = risky_detections(rd_i);
                        if abs(detections(d_i).pos(2)) < min_side_dist
                            min_side_dist = abs(detections(d_i).pos(2));
                        end
                    end
                    if abs(driver.veh.x(driver.ORIENTATION_IND)) < pi/2
                        target(driver.lat_contr.LAT_POS_IND) = ...
                            min(-9.5, driver.veh.x(driver.Y_IND)+min_side_dist-3.8);
                    else
                        target(driver.lat_contr.LAT_POS_IND) = ...
                            max(9.5, driver.veh.x(driver.Y_IND)-min_side_dist+3.8);
                        target(driver.lat_contr.ORIENTATION_IND) = pi;
                    end
                    steer = driver.lat_contr.compute_control(driver.veh.x, target);
                else
                    steer = 0.0;
                end
            end
        end
        
        function [force, steer] = demand(driver)
%             debug_s = driver.sim_env.get_sim_items(driver.perception_system.vhc_type,...
%                                           driver.perception_system.vhc_id,...
%                                           driver.perception_system.max_delay);
%             for s_i = 1:length(debug_s.self_vhc)
%                 disp(['s ', num2str(s_i), ': ', num2str(debug_s.self_vhc(s_i).x')])
%             end
%             for s_i = 1:length(debug_s.other_vhc)
%                 disp([num2str(s_i), ': ', num2str(debug_s.other_vhc(s_i).x')])
%             end
            
            % demand Compute control inputs to the vehicle
            detections = driver.get_detections();
            driver.last_detections = detections;
            detections_future_estimates = ...
                driver.estimate_future_of_detections(detections);
            
            % Detect future collisions and occupancies
            % I tried using containers.Map for area_occupancies and future_collisions
            % but it was slow. Now, using cell arrays.
            area_occupancies = driver.compute_area_occupancies(detections_future_estimates);
            future_collisions = driver.estimate_future_collisions(detections_future_estimates);
            risky_detections = driver.plan_driving_mode(area_occupancies,future_collisions);
            [force, steer] = driver.compute_control_for_driving_mode(detections, risky_detections);
        end
        
        % called by Vehicle superclass
        function plot(driver)
            clf
            axis([[min(driver.target_path(1,:))-5, max(driver.target_path(1,:))+5] ...
                [min(driver.target_path(2,:))-1, max(driver.target_path(2,:))+1]]);
            hold on
            xlabel('x');
            ylabel('y');
            axis equal;
        end
        
    end % methods
end % classdef
