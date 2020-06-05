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

classdef MoveToPoseDriverNoCollision < MoveToPoseDriver
    properties
        sim_env
        self_id
    end

    methods

        function driver = MoveToPoseDriverNoCollision(varargin)
            driver = driver@MoveToPoseDriver(varargin{:});
            driver.sim_env = [];
            driver.self_id = 1;
        end
        
        function set_sim_env(driver, sim_env, self_id)
            driver.sim_env = sim_env;
            driver.self_id = self_id;
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
            [acc, gamma] = demand@MoveToPoseDriver(driver);

            [sim_items] = driver.sim_env.get_sim_items('agent',driver.self_id,1);
            for ii = 1:length(sim_items.other_vhc)
                if ~strcmpi(sim_items.other_vhc(ii).veh_type,'ego')
                    % Another Agent. We should not collide into it.
                    other_x = sim_items.other_vhc(ii).x;
                    [is_coll, acc] = driver.check_collision(other_x, acc, gamma);
                end
            end

        end
        
        function [is_coll, corrected_acc] = check_collision(driver, x_other, acc, gamma)
            is_coll = false;
            corrected_acc = acc;
            self_x = driver.veh.x;
            d = norm(x_other(1:2) - self_x(1:2));
            if d < 15 % Check if inside region of interest
                % Take points from different sides (index1 and 3)
                other_corners = driver.veh.get_corners(x_other);
                x1_o = other_corners(:,1);
                x2_o = other_corners(:,3);
                x_update = [cos(x_other(3)); sin(x_other(3))*x_other(4)*2.5]; %To check collision in 2.5 sec.
                x1_o_end = x1_o + x_update;
                x2_o_end = x2_o + x_update;
                l1_o = [x1_o;x1_o_end];
                l2_o = [x2_o;x2_o_end];
                
                self_corners = driver.veh.get_corners();
                x1_s = self_corners(:,1);
                x2_s = self_corners(:,3);
                x_update = [cos(self_x(3)); sin(self_x(3))*self_x(4)*2.5];
                x1_s_end = x1_s + x_update;
                x2_s_end = x2_s + x_update;
                l1_s = [x1_s;x1_s_end];
                l2_s = [x2_s;x2_s_end];
                if driver.check_line_segments_intersection(l1_o, l1_s) || ...
                    driver.check_line_segments_intersection(l1_o, l2_s) || ...
                    driver.check_line_segments_intersection(l2_o, l1_s) || ...
                    driver.check_line_segments_intersection(l2_o, l2_s)
                    corrected_acc = driver.veh.accelmin;
                    % disp('Agent to Agent collision estimate!!!')
                end
            end
        end
        
    end
    
    methods(Static)
        
        function intersect = check_line_segments_intersection(l1,l2)
            %l1: [x1, y1, x2, y2]
            %l2: [x3, y3, x4, y4]
            x=[l1(1) l1(3) l2(1) l2(3)];
            y=[l1(2) l1(4) l2(2) l2(4)];
            dt1=det([1,1,1;x(1),x(2),x(3);y(1),y(2),y(3)])*det([1,1,1;x(1),x(2),x(4);y(1),y(2),y(4)]);
            dt2=det([1,1,1;x(1),x(3),x(4);y(1),y(3),y(4)])*det([1,1,1;x(2),x(3),x(4);y(2),y(3),y(4)]);

            if(dt1<=0 && dt2<=0)
                intersect = true;         %If lines intesect
            else
                intersect = false;
            end
        end

    end % methods
end % classdef
