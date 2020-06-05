% VehicleDriver Vehicle driver class
%
% Driving a Vehicle object through a given sequence of waypoints.
%
% The driver object is attached to a Bicycle object by add_driver() method.
%
% Methods:
%  demand     return speed and steer angle for the next time instant
%  init       initialization
%  display    display the state and parameters in human readable form
%  char       convert to string the display method
%      
% Properties::
%  veh           the Vehicle object being controlled
%
% Example::
%
%    veh = Bicycle();
%    veh.add_driver(VehicleDriver());
%
% See also Vehicle, Bicycle.

% (C) C. E. Tuncali, ASU

classdef VehicleDriver < handle
    properties
        veh         % the vehicle we are driving
    end

    methods

        function driver = VehicleDriver()
        end
        
        function states = get_states(driver)
            states = [];
        end
        
        function driver = set_states(driver, states)
            
        end
                
        function init(driver)
        %AgentDriverStanley.init Initialize the driver
        % Nothing to initialize
        %
        % Notes::
        % - Called by Vehicle.run.
        end

        function [vf, gamma] = demand(driver)
        %VehicleDriver.demand Compute speed and heading
        %
        % [SPEED,STEER] = R.demand() is the speed and steer angle to
        % drive the vehicle toward the next waypoint.  When the vehicle is
        % within R.dtresh a new waypoint is chosen.
        %
        % See also Bicycle, Vehicle.
            % Compute Controls
            gamma = 0.0;

            % set forward velocity
            vf = 0;
        end
        

        % called by Vehicle superclass
        function plot(driver)
            clf
            xlabel('x');
            ylabel('y');
        end

        function display(driver)
        %VehicleDriver.display Display driver parameters and state
        %
        % R.display() displays driver parameters and state in compact
        % human readable form.
        %
        % Notes::
        % - This method is invoked implicitly at the command line when the result
        %   of an expression is a AgentDriverStanley object and the command has no trailing
        %   semicolon.
        %
        % See also VehicleDriver.char.
            loose = strcmp( get(0, 'FormatSpacing'), 'loose');
            if loose
                disp(' ');
            end
            disp([inputname(1), ' = '])
            disp( char(driver) );
        end % display()

        function s = char(driver)
        %VehicleDriver.char Convert to string
        %
        % s = VehicleDriver.char() is a string showing driver parameters and state in in 
        % a compact human readable format. 
            s = 'VehicleDriver driver object';
            s = char(s, sprintf('  '));
        end
        
    end % methods
end % classdef
