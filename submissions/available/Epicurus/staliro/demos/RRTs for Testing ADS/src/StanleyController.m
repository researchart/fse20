classdef StanleyController < handle
    %StanleyController A Controller class implementing the Stanley
    %controller used in the Stanford DARPA Challenge steering controller.
    
    properties
        LAT_POS_IND
        SPEED_IND
        ORIENTATION_IND
        max_steering
        k
        k2
        k3
    end
    
    methods
        function contr = StanleyController()
        %StanleyController Construct an instance of this class
            
            %State indices:
            contr.LAT_POS_IND = 2;
            contr.ORIENTATION_IND = 3;
            contr.SPEED_IND = 4;
            contr.max_steering = pi/10;
            contr.k = 0.15;
            contr.k2 = 0.3;
            contr.k3 = 1.1;
        end
        
        function [control] = compute_control(contr, x, x_target)
        %vhc_stanley_controller_str Stanford's Stanley steering controller.

            target_lat_pos = x_target(contr.LAT_POS_IND);
            current_lat_pos = x(contr.LAT_POS_IND);
            lat_err = target_lat_pos - current_lat_pos;

            target_azimuth = x_target(contr.ORIENTATION_IND);
            current_azimuth = x(contr.ORIENTATION_IND);
            angle_err = target_azimuth - current_azimuth;
            angle_err = mod(angle_err + pi, (2 * pi)) - pi;

            speed = x(contr.SPEED_IND);
            if abs(speed) < 0.01
                steering = angle_err;
            else
                steering = contr.k2*angle_err + atan(contr.k*lat_err/(speed+contr.k3));
            end

            if speed < 0
                steering = -steering;
            end

            control = min(max(steering, -contr.max_steering), contr.max_steering);
%             if angle_err > pi/20
%                 if speed >= 0.0
%                     control = max(control, 0.0);
%                 else
%                     control = min(control, 0.0);
%                 end
%             elseif angle_err < -pi/20
%                 if speed >= 0.0
%                     control = min(control, 0.0);
%                 else
%                     control = max(control, 0.0);
%                 end
%             end
        end

    end
end

