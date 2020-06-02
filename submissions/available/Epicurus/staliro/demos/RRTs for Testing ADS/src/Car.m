%Car Bicycle class with acceleration
%
% This concrete class models the kinematics of a car-like vehicle (bicycle
% or Ackerman model) on a plane.  For given steering and velocity inputs it
% updates the true vehicle state and returns noise-corrupted odometry
% readings.
%
% Methods::
%   Bicycle      constructor
%   add_driver   attach a driver object to this vehicle
%   control      generate the control inputs for the vehicle
%   deriv        derivative of state given inputs
%   init         initialize vehicle state
%   f            predict next state based on odometry
%   Fx           Jacobian of f wrt x
%   Fv           Jacobian of f wrt odometry noise
%   update       update the vehicle state
%   run          run for multiple time steps
%   step         move one time step and return noisy odometry
%
% Plotting/display methods::
%   char             convert to string
%   display          display state/parameters in human readable form
%   plot             plot/animate vehicle on current figure
%   plot_xy          plot the true path of the vehicle
%   Vehicle.plotv    plot/animate a pose on current figure
%
% Properties (read/write)::
%   x               true vehicle state: x, y, theta (3x1)
%   V               odometry covariance (2x2)
%   odometry        distance moved in the last interval (2x1)
%   rdim             dimension of the robot (for drawing)
%   L               length of the vehicle (wheelbase)
%   alphalim        steering wheel limit
%   maxspeed        maximum vehicle speed
%   T               sample interval
%   verbose         verbosity
%   x_hist          history of true vehicle state (Nx3)
%   driver          reference to the driver object
%   x0              initial state, restored on init()
%
% Examples::
%
% Odometry covariance (per timstep) is
%       V = diag([0.02, 0.5*pi/180].^2);
% Create a vehicle with this noisy odometry
%       v = Bicycle( 'covar', diag([0.1 0.01].^2 );
% and display its initial state
%       v 
% now apply a speed (0.2m/s) and steer angle (0.1rad) for 1 time step
%       odo = v.step(0.2, 0.1)
% where odo is the noisy odometry estimate, and the new true vehicle state
%       v
%
% We can add a driver object
%      v.add_driver( RandomPath(10) )
% which will move the vehicle within the region -10<x<10, -10<y<10 which we
% can see by
%      v.run(1000)
% which shows an animation of the vehicle moving for 1000 time steps
% between randomly selected wayoints.
%
% Notes::
% - Subclasses the MATLAB handle class which means that pass by reference semantics
%   apply.
%
% Reference::
%
%   Robotics, Vision & Control, Chap 6
%   Peter Corke,
%   Springer 2011
%
% See also Vehicle


classdef Car < NewVehicle

    properties
        % state
        L           % length of vehicle
        width
        La % Center of mass to front axle
        Lb % Center of mass to rear axle
        front_length
        rear_length
        num_corners
        corners
        steermax
        accelmax
        accelmin
        speedmin
        aprev
        u_hist      % input history
    end

    methods

        function veh = Car(varargin)
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
            
            veh = veh@NewVehicle(varargin{:});
            
            veh.x = zeros(4,1);

            opt.L = 4.5;
            opt.La = 3.61;
            opt.Lb = 0.89;
            opt.front_length = 3.61; % Those front/rear length are Tesla Model 3 from Webots
            opt.rear_length = 0.89;
            opt.width = 1.8;
            opt.steermax = 0.6;
            opt.accelmax = 5.0;
            opt.accelmin = -8.0;
            opt.speedmin = -10.0;
            opt.speedmax = 45.0;
            opt.num_corners = 4;
            veh = tb_optparse(opt, veh.options, veh);
            veh.aprev = 0;
            veh.x = veh.x0;
            if veh.num_corners == 4
                % corners: starts at front-left or center, goes in cw direction.
                veh.corners = [veh.front_length, -veh.width/2.0;
                               veh.front_length, veh.width/2.0;
                              -veh.rear_length, veh.width/2.0;
                              -veh.rear_length, -veh.width/2.0;]';
            else
                veh.corners = [veh.front_length, 0.0;
                               veh.front_length, veh.width/2.0;
                               0.0, veh.width/2.0;
                              -veh.rear_length, veh.width/2.0;
                              -veh.rear_length, 0.0;
                              -veh.rear_length, -veh.width/2.0;
                               0.0, -veh.width/2.0;
                               veh.front_length, -veh.width/2.0]';
            end
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
            veh.x_hist = [];
            veh.u_hist = [];
            
            if ~isempty(veh.driver)
                veh.driver.init();
            end
            
            veh.vhandle = [];
        end
        
        function update_for_collision(veh)
            %update_for_collision Repeats the last state assuming a
            %collision
            %veh.x(4) = 0;
            veh.x_hist = [veh.x_hist; veh.x'];
        end
        
        function corners = get_corners(veh, x)
            %Car.get_corners returns 2xveh.num_corners points.
            if nargin > 1
                xx = x;
            else
                xx = veh.x;
            end
            theta = xx(3);
            
            R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
            corners = R*veh.corners;
            corners = corners + [xx(1); xx(2)];
        end
        
        function corners_x_hist = get_corners_hist(veh)
            % Populate vehicle corners for each time step in x_hist
            corners_x_hist = cell(size(veh.x_hist, 1)+1, 1);
            corners_x_hist{1} = veh.get_corners(veh.x0);
            for x_i = 1:size(veh.x_hist, 1)
                corners_x_hist{x_i+1} = veh.get_corners(veh.x_hist(x_i, :));
            end
        end
        
        function orientations_hist = get_orientations_hist(veh)
            % Populate vehicle orientations for each time step in x_hist
            orientations_hist = [veh.x0(3); veh.x_hist(:, 3)];
        end
        
        function pos = get_position(veh, x)
            % get_position Return vehicle x,y position from vehicle states.
            if nargin > 1
                xx = x;
            else
                xx = veh.x;
            end
            pos = xx(1:2);
        end

        function xnext = f(veh, x, odo, w)
            %Car.f Predict next state based on odometry
            %
            % XN = V.f(X, ODO) is the predicted next state XN (1x4) based on current
            % state X (1x4) and odometry ODO (1x2) = [distance, heading_change].
            %
            % XN = V.f(X, ODO, W) as above but with odometry noise W.
            %
            % Notes::
            % - Supports vectorized operation where X and XN (Nx3).
            if nargin < 4
                w = [0 0];
            end

            dd = odo(1) + w(1);
            dth = odo(2) + w(2);

            % straightforward code:
            % thp = x(3) + dth;
            % xnext = zeros(1,3);
            % xnext(1) = x(1) + (dd + w(1))*cos(thp);
            % xnext(2) = x(2) + (dd + w(1))*sin(thp);
            % xnext(3) = x(3) + dth + w(2);
            %
            % vectorized code:

            thp = x(:,3) + dth;
            %xnext = x + [(dd+w(1))*cos(thp)  (dd+w(1))*sin(thp) ones(size(x,1),1)*dth+w(2)];
            xnext = x + [dd*cos(thp)  dd*sin(thp) ones(size(x,1),1)*dth 0];
        end

        function [dx,u] = deriv(veh, t, x, u)
            %Bicycle.deriv  Time derivative of state
            %
            % DX = V.deriv(T, X, U) is the time derivative of state (4x1) at the state
            % X (4x1) with input U (2x1).
            %
            % Notes::
            % - The parameter T is ignored but  called from a continuous time integrator such as ode45 or
            %   Simulink.
            
            % implement acceleration limit if required
            %if ~isinf(veh.accelmax)
            u(1) = min(veh.accelmax, max(u(1), veh.accelmin));
            %end
            
            % implement speed limit if required
            %if ~isinf(veh.speedmax)
            delta_v_max = max(0, veh.speedmax - veh.x(4));
            delta_v_min = min(0, veh.speedmin - veh.x(4));
            u(1) = min(delta_v_max / veh.dt, max(u(1), delta_v_min / veh.dt));
            %end
            % Avoid vehicle to go from positive to negative speed in one
            % step.
            if (veh.x(4) > 0) && (veh.x(4) + u(1) * veh.dt < 0.0)
                u(1) = -veh.x(4) / veh.dt;
            end
            
            % Implement steering angle limit
            u(2) = min(veh.steermax, max(u(2), -veh.steermax));

            % compute the derivative
            dx = zeros(3,1);
            dx(1) = x(4)*cos(x(3));
            dx(2) = x(4)*sin(x(3));
            dx(3) = x(4)/veh.L * tan(u(2));
            dx(4) = u(1);
            
            veh.aprev = u(1);
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
            [ddx, u] = veh.deriv([], veh.x, u);
            dx = veh.dt * ddx;
            if veh.x(4) > 0
                start_vel_positive = true;
            else
                start_vel_positive = false;
            end
            veh.x = veh.x + dx;
            
            % Apply speed limit.
            if veh.x(4) > veh.speedmax
                veh.x(4) = veh.speedmax;
            elseif veh.x(4) < veh.speedmin
                veh.x(4) = veh.speedmin;
            end
            % Avoid vehicle to go from positive to negative speed in one
            % step.
            if veh.x(4) < 0 && start_vel_positive
                veh.x(4) = 0.0;
            end
            
            %Normalize between +-pi
            veh.x(3) = mod(veh.x(3) + pi, (2 * pi)) - pi;

            % compute and save the odometry
            odo = [ norm(dx(1:2)) dx(3) ];
            veh.odometry = odo;

            veh.x_hist = [veh.x_hist; veh.x'];   % maintain history
            veh.u_hist = [veh.u_hist; u];   % maintain history
        end
        
        function u = control(veh, accel, steer)
            %Car.control Compute the control input to vehicle
            %
            % U = V.control(SPEED, STEER) is a control input (1x2) = [speed,steer]
            % based on provided controls SPEED,STEER to which speed and steering angle
            % limits have been applied.
            %
            % U = V.control() as above but demand originates with a "driver" object if
            % one is attached, the driver's DEMAND() method is invoked. If no driver is
            % attached then speed and steer angle are assumed to be zero.
            %
            % See also Vehicle.step, RandomPath.
            if nargin < 2
                % if no explicit demand, and a driver is attached, use
                % it to provide demand
                if ~isempty(veh.driver)
                    [accel, steer] = veh.driver.demand();
                else
                    % no demand, do something safe
                    accel = 0;
                    steer = 0;
                end
            end
            u = [accel, steer];
        end
        
        function [p, u_hist] = run(veh, nsteps)
            %Vehicle.run Run the vehicle simulation
            %
            % V.run(N) runs the vehicle model for N timesteps and plots
            % the vehicle pose at each step.
            %
            % P = V.run(N) runs the vehicle simulation for N timesteps and
            % return the state history (Nx3) without plotting.  Each row
            % is (x,y,theta).
            %
            % See also Vehicle.step, Vehicle.run2.

            if nargin < 2
                nsteps = 1000;
            end
            if ~isempty(veh.driver)
                veh.driver.init()
            end
            %veh.clear();
            if ~isempty(veh.driver) && nargout == 0
                veh.driver.plot();
            end

            if nargout == 0
                veh.plot();
            end
                
            for i=1:nsteps
                veh.step();
                if nargout == 0
                    % if no output arguments then plot each step
                    veh.plot();
                    drawnow
                end
            end
            p = veh.x_hist;
            if nargout > 1
                u_hist = veh.u_hist;
            end
        end
        
        function h = plot(veh, varargin)
            %Vehicle.plot Plot vehicle
            %
            % The vehicle is depicted graphically as a narrow triangle that travels
            % "point first" and has a length V.rdim.
            %
            % V.plot(OPTIONS) plots the vehicle on the current axes at a pose given by
            % the current robot state.  If the vehicle has been previously plotted its
            % pose is updated.  
            %
            % V.plot(X, OPTIONS) as above but the robot pose is given by X (1x3).
            %
            % H = V.plotv(X, OPTIONS) draws a representation of a ground robot as an 
            % oriented triangle with pose X (1x3) [x,y,theta].  H is a graphics handle.
            %
            % V.plotv(H, X) as above but updates the pose of the graphic represented
            % by the handle H to pose X.
            %
            % Options::
            % 'scale',S    Draw vehicle with length S x maximum axis dimension
            % 'size',S     Draw vehicle with length S
            % 'color',C    Color of vehicle.
            % 'fill'       Filled
            % 'trail',S    Trail with line style S, use line() name-value pairs
            %
            % Example::
            %          veh.plot('trail', {'Color', 'r', 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'MarkerSize', 3})

            % Notes::
            % - The last two calls are useful if animating multiple robots in the same
            %   figure.
            %
            % See also Vehicle.plotv, plot_vehicle.

            if isempty(veh.vhandle)
                veh.vhandle = Vehicle.plotv(veh.x(1:3), varargin{:});
            end
            
            if ~isempty(varargin) && isnumeric(varargin{1})
                % V.plot(X)
                pos = varargin{1}; % use passed value
            else
                % V.plot()
                pos = veh.x(1:3);    % use current state
            end
            
            % animate it
            try
                Vehicle.plotv(veh.vhandle, pos);
            catch
                veh.vhandle = ...
                    Vehicle.plotv(veh.x([1:3]), ...
                    varargin{:});
                Vehicle.plotv(veh.vhandle, pos);
            end
        end

% Commented out the following because they may be incorrect.
%         function J = Fx(veh, x, odo)
%         %Car.Fx  Jacobian df/dx
%         %
%         % J = V.Fx(X, ODO) is the Jacobian df/dx (4x4) at the state X, for
%         % odometry input ODO (1x2) = [distance, heading_change].
%         %
%         % See also Bicycle.f, Vehicle.Fv.
%             dd = odo(1);
%             dth = odo(2);
%             thp = x(3) + dth;
% 
%             J = [
%                 1   0   -dd*sin(thp) 0
%                 0   1   dd*cos(thp) 0
%                 0   0   1 0
%                 0   0   0 0
%                 ];
%         end
% 
%         function J = Fv(veh, x, odo)
%             %Car.Fv  Jacobian df/dv
%             %
%             % J = V.Fv(X, ODO) is the Jacobian df/dv (3x2) at the state X, for
%             % odometry input ODO (1x2) = [distance, heading_change].
%             %
%             % See also Bicycle.F, Vehicle.Fx.
%             dd = odo(1); dth = odo(2);
%             thp = x(3);
% 
%             J = [
%                 cos(thp)    0 
%                 sin(thp)    0 
%                 0           1
%                 0           0
%                 ];
%         end

        function s = char(veh)
            %Car.char Convert to a string
            %
            % s = V.char() is a string showing vehicle parameters and state in 
            % a compact human readable format. 
            %
            % See also Bicycle.display.

            ss = char@Vehicle(veh); 

            s = 'Car object';
            s = char(s, sprintf('  L=%g, steer.max=%g, accel.max=%g, accel.min=%g, speed.max=%g, speed.min=%g', ...
                veh.L, veh.steermax, veh.accelmax, veh.accelmin, veh.speedmax, veh.speedmin));
            s = char(s, ss);
        end
    end % method

end % classdef
