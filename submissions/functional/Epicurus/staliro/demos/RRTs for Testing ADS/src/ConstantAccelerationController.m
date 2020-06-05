% ConstantAccelerationController Car driver class
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
%    veh.add_driver(ConstantAccelerationController());
%
% See also VehicleDriver, Car, Vehicle, Bicycle.

% (C) C. E. Tuncali, ASU

classdef ConstantAccelerationController < VehicleDriver
    properties
        target_a
    end

    methods

        function driver = ConstantAccelerationController(target_a)
            driver.target_a = target_a;
        end
        
        function set_parameters(driver, target_a)
        %ConstantAccelerationController.set_parameters Change parameters after creation.
        %
        % Notes::
        % - Called externally by user (optionally).
            driver.target_a = target_a;
        end
        
        function clear_target_path(driver)
        %ConstantAccelerationController.clear_target_path Does nothing
        end
        
        function add_to_target_path(driver, wpt)
        %ConstantAccelerationController.add_to_target_path Does nothing
        end

        function [acc, gamma] = demand(driver)
        %ConstantAccelerationController.demand Compute speed and heading using Peter
        %Corke's (move to pose) controller (except the speed part).
        %
        % [SPEED,STEER] = R.demand() is the speed and steer angle to
        % drive the vehicle toward the next waypoint.  When the vehicle is
        % within R.dtresh a new waypoint is chosen.
        %
        % See also Bicycle, Vehicle.
       
            % Compute Controls
            gamma = 0.0;
            % set forward velocity
            acc = driver.target_a;
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
