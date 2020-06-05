% MoveToPoseDriver Car driver class
%
% Driving a Vehicle object through a given sequence of waypoints using the
% move to pose controller from Peter Corke's book (except the speed part).
%
% The driver object is attached to a Car object by add_driver() method.
%
% Methods:
%  demand     return speed and steer angle for the next time instant
%  init       initialization
%  display    display the state and parameters in human readable form
%  char       convert to string the display method
%      
% Properties::
%  target_path % target path as a list of waypoints: [x; y; theta]
%
% Example::
%
%    veh = Car();
%    veh.add_driver(MoveToPoseDriver());
%
% See also VehicleDriver, Car, Vehicle, Bicycle.

% (C) C. E. Tuncali, ASU

classdef MoveToPoseDriver < VehicleDriver
    properties
        target_path % target path as a list of waypoints: [x; y; theta; v]
        Kp_alpha  % Gain for alpha
        Kp_beta  % Gain for beta
        Kp_accel % Gain for acceleration
        acc_delta_max
        acc_delta_min
        reach_d
        reach_d_relaxed
        reach_theta
        min_target_d
    end

    methods

        function driver = MoveToPoseDriver(gain_alpha, gain_beta, gain_acc)
            driver.clear_target_path();
            driver.Kp_alpha = gain_alpha;
            driver.Kp_beta = gain_beta;
            driver.Kp_accel = gain_acc;
            driver.acc_delta_max = 0.1;
            driver.acc_delta_min = -0.5;
            driver.reach_d = 1.0;
            driver.reach_d_relaxed = 2.5;
            driver.reach_theta = pi/4;
            driver.min_target_d = inf;
        end
        
        function set_parameters(driver, gain_alpha, gain_beta, gain_acc)
        %MoveToPoseDriver.set_parameters Change parameters after creation.
        %
        % Notes::
        % - Called externally by user (optionally).
            driver.Kp_alpha = gain_alpha;
            driver.Kp_beta = gain_beta;
            driver.Kp_accel = gain_acc;
        end
        
        function set_sim_env(driver, sim_env, self_id)
        end
        
        function clear_target_path(driver)
        %MoveToPoseDriver.clear_target_path Clear the target path
        %
        % Notes::
        % - Called externally by user.
            driver.target_path = [];
            driver.min_target_d = inf;
        end
        
        function add_to_target_path(driver, wpt)
        %MoveToPoseDriver.add_to_target_path Add wpt(s) to the target path
        %
        % Notes::
        % - Called externally by user.
            if (size(wpt,1) == 4)
                driver.target_path = [driver.target_path, wpt];
            elseif (size(wpt,2) == 4)
                driver.target_path = [driver.target_path, wpt'];
            else
                disp(wpt);
                error('target wpt is not 4 x n (x,y,theta,v)');
            end
        end

        function [acc, gamma] = demand(driver)
        %MoveToPoseDriver.demand Compute speed and heading using Peter
        %Corke's (move to pose) controller (except the speed part).
        %
        % [SPEED,STEER] = R.demand() is the speed and steer angle to
        % drive the vehicle toward the next waypoint.  When the vehicle is
        % within R.dtresh a new waypoint is chosen.
        %
        % See also Bicycle, Vehicle.
        
            % check if we have reached the waypoint
            if ~isempty(driver.target_path)
                dist_to_target = norm(driver.target_path(1:2, 1) - driver.veh.x(1:2));
                % If we reached the target or we came closeby and now
                % getting far.
                if dist_to_target < driver.reach_d || ...
                        (dist_to_target < driver.reach_d_relaxed && ...
                        dist_to_target > driver.min_target_d + 0.1) 
                    %&& ...
                        %abs(driver.target_path(3, 1) - driver.veh.x(3)) < driver.reach_theta
                    % disp(driver.target_path(:,1));
                    driver.target_path(:,1) = [];
                    driver.min_target_d = inf; % switched to new target.
                elseif dist_to_target < driver.reach_d_relaxed && dist_to_target < driver.min_target_d
                    driver.min_target_d = dist_to_target;
                end
            else
                driver.min_target_d = inf;
            end

            if isempty(driver.target_path)
                % Compute Controls
                gamma = 0.0;
                % set forward velocity
                acc = 0;
            else
                % Current robot pose [x;y;theta]
                start_pose = driver.veh.x;
                target_pose = driver.target_path(:, 1);
                start_pose(3) = mod((start_pose(3) + pi), (2 * pi)) - pi;
                target_pose(3) = mod((target_pose(3) + pi), (2 * pi)) - pi;
                y_diff = target_pose(2) - start_pose(2);
                x_diff = target_pose(1) - start_pose(1);
                alpha = mod((atan2(y_diff, x_diff) - start_pose(3) + pi), (2 * pi)) - pi;
                beta = mod((target_pose(3) - start_pose(3) - alpha + pi), (2 * pi)) - pi;
                gamma = driver.Kp_alpha * alpha + driver.Kp_beta * beta;

                start_v = driver.veh.x(4);
                target_v = target_pose(4);
                acc = driver.Kp_accel * (target_v - start_v);
                acc = min(driver.veh.aprev + driver.acc_delta_max, max(driver.veh.aprev + driver.acc_delta_min, acc));
                acc = min(driver.veh.accelmax, max(driver.veh.accelmin, acc));
            end
        end
        
        % called by Vehicle superclass
        function plot(driver)
            clf
            axis([[min(driver.target_path(1,:))-5, max(driver.target_path(1,:))+5] [min(driver.target_path(2,:))-1, max(driver.target_path(2,:))+1]]);
            hold on
            xlabel('x');
            ylabel('y');
            axis equal;
        end
        
    end % methods
end % classdef
