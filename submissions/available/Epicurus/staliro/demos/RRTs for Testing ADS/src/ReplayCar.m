%ReplayCar Bicycle class with acceleration
%
% This class is used to replay the vehicle with the saved x_hist.
%
% See also Car, Vehicle


classdef ReplayCar < Car

    properties
        cur_hist_ind = 1;
    end

    methods

        function veh = ReplayCar(varargin)
            %Car.Car Vehicle object constructor
            %
            % V = Car(OPTIONS)  creates a Bicycle object with the kinematics of a
            % bicycle (or Ackerman) vehicle.
            %
            % Options::
            % 'steermax',M    Maximu steer angle [rad] (default 0.5)
            % 'accelmax',M    Maximum acceleration [m/s2] (default Inf)
            %--
            % 'covar',C       specify odometry covariance (2x2) (default 0)
            % 'speedmax',S    Maximum speed (default 1m/s)
            % 'L',L           Wheel base (default 1m)
            % 'x0',x0         Initial state (default (0,0,0) )
            % 'dt',T          Time interval (default 0.1)
            % 'rdim',R        Robot size as fraction of plot window (default 0.2)
            % 'verbose'       Be verbose
            %
            % Notes::
            % - The covariance is used by a "hidden" random number generator within the class. 
            % - Subclasses the MATLAB handle class which means that pass by reference semantics
            %   apply.
            %
            % Notes::
            % - Subclasses the MATLAB handle class which means that pass by reference semantics
            %   apply.
            
            veh = veh@Car(varargin{:});
        end
        
        function init(veh, x0, last_input)
            %Car.init Reset state
            %
            % V.init() sets the state V.x := V.x0, initializes the driver 
            % object (if attached) and clears the history.
            %
            % V.init(X0) as above but the state is initialized to X0.
            % x0_cont is used to initialize vehicle driver to an initial
            % controller state.
            
            if nargin > 1
                veh.x = x0(:);
                veh.x0 = veh.x;
            else
                veh.x = veh.x0;
            end
            if nargin > 2
                if ~isempty(last_input)
                    veh.aprev = last_input(1);
                end
            end
            
            if ~isempty(veh.driver)
                veh.driver.init();
            end
            
            veh.vhandle = [];
        end
 
        function odo = step(veh, varargin)
            %ReplayCar.step Advance one timestep
            u = [];

            % compute the true odometry and update the state
            odo = veh.update(u);

            % add noise to the odometry
            if ~isempty(veh.V)
                odo = veh.odometry + randn(1,2)*sqrtm(veh.V);
            end
        end
        
        function odo = update(veh, u)
            %Bicycle.update Update the vehicle state
            %
            % ODO = V.update(U) is the true odometry value for
            % motion with U=[speed,steer].
            %
            % Notes::
            % - Appends new state to state history property x_hist.
            % - Odometry is also saved as property odometry.

            % update the state
            old_x = veh.x;
            veh.x = veh.x_hist(veh.cur_hist_ind, :)';
            veh.cur_hist_ind = veh.cur_hist_ind + 1;
            dx = veh.x - old_x;
            odo = [ norm(dx(1:2)) dx(3) ];
            veh.odometry = odo;
        end

    end % method

end % classdef
