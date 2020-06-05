% PIDACC PID Adaptive Cruise Control.
% Currently, only proportional control not a pid.

% (C) C. E. Tuncali, ASU

classdef PIDACC < handle
    properties
        LONG_POS_IND
        SPEED_IND
        
        d_ref
        v_ref
        
        u_min
        u_max
        
        P_speed = 200.0;
        P_dist = 100.0;
    end

    methods

        function pid = PIDACC()
            pid.LONG_POS_IND = 1;
            pid.SPEED_IND = 4;
            
            pid.d_ref = 20.0;
            pid.v_ref = 15.0;
        end
        
        function [ pid ] = init(pid)
            %INIT Initialize and configure the controller.
            
        end
        
        function [control] = compute_control(pid, x, dist)
            %COMPUTE_CONTROL Compute control inputs.
            
            speed_error = pid.v_ref - x(pid.SPEED_IND);
            speed_control = pid.P_speed * speed_error;
            if dist > 0 && dist < 60
                dist_error = pid.d_ref - dist;
                dist_control = pid.P_dist * dist_error;
                control = min(speed_control, dist_control);
            else
                control = speed_control;
            end
        end
        
    end % methods
end % classdef
