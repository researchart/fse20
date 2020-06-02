%DynamicCar implement a car class with dynamics (not kinematics)
%
% This class models the dynamics of a car-like vehicle (bicycle
% or Ackerman model) on a plane. For given force and steering inputs, it
% updates the true vehicle state.
% This Car is controlled by Force and Steering angle inputs.
%
% Methods::
%   DynamicCar      constructor
%
% Properties (read/write)::
%   x            true vehicle state: x, y, orientation, v, ang. speed (5x1)
%
%
% Notes::
% - Subclasses the MATLAB handle class which means that pass by reference 
% . semantics apply.
%
% Reference::
%
%   Extends the classes from:
%   Robotics, Vision & Control, Chap 6
%   Peter Corke,
%   Springer 2011
%
% See also Car, Vehicle, Bicycle 


classdef DynamicCar < NewVehicle

    properties
        % state
        La % Center of mass to front axle
        Lb % Center of mass to rear axle
        front_length % From 0,0 coordinate offset (rear axle)
        rear_length
        width
        num_corners
        corners
        m  % Mass of vehicle
        Cy % Tire stiffness
        J  % Rotational inertia
        steermax
        accelmax
        accelmin
        speedmin
        u_prev
        u_hist      % input history
        force_min
        force_max
        
        
        X_IND
        Y_IND
        ORIENTATION_IND
        SPEED_IND
        ANG_SPEED_IND
        
        F_INP_IND
        STEER_INP_IND
    end

    methods

        function veh = DynamicCar(varargin)
            %DynamicCar.DynamicCar Vehicle object constructor
            %
            % V = DynamicCar(OPTIONS)  creates a DynamicCar object with the
            % dynamics of a bicycle (or Ackerman) vehicle.
            %
            % Notes::
            % - Subclasses the MATLAB handle class which means that pass by
            % reference semantics apply.

            veh = veh@NewVehicle(varargin{:});
            
            veh.x = zeros(5,1);

            opt.La = 2.25;
            opt.Lb = 2.25;
            opt.front_length = 3.61; % Those front/rear length are Tesla Model 3 from Webots
            opt.rear_length = 0.89;
            opt.width = 1.8;
            opt.num_corners = 8;
            opt.m = 1850.0;
            opt.Cy = 25000.0;
            opt.J = 2534.0;
            
            opt.steermax = 0.6;
            opt.accelmax = 4.5;
            opt.accelmin = -8.0;
            opt.speedmin = -10.0;
            opt.speedmax = 60.0;
            
            opt.force_min = -7000;
            opt.force_max = 8300;

            veh = tb_optparse(opt, veh.options, veh);
            veh.u_prev = [0, 0];
            veh.x = veh.x0;
            
            veh.X_IND = 1;
            veh.Y_IND = 2;
            veh.ORIENTATION_IND = 3;
            veh.SPEED_IND = 4;
            veh.ANG_SPEED_IND = 5;

            veh.F_INP_IND = 1;
            veh.STEER_INP_IND = 2;
            
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
            %DynamicCar.init Reset state
            %
            % V.init() sets the state V.x := V.x0, initializes the driver 
            % object (if attached) and clears the history.
            %
            % V.init(X0) as above but the state is initialized to X0.
            % x0_cont is used to initialize vehicle driver to an initial
            % controller state.
            %
            % V.init(X0, last_input) also sets the last given input.
            
            if nargin > 1
                veh.x = x0(:);
                veh.x0 = veh.x;
            else
                veh.x = veh.x0;
            end
            veh.u_prev = [0, 0];
            if nargin > 2
                if ~isempty(last_input)
                    veh.u_prev = last_input;
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
            %veh.x(veh.SPEED_IND) = 0;
            %veh.x(veh.ANG_SPEED_IND) = 0;
            veh.x_hist = [veh.x_hist; veh.x'];
        end
        
        function corners = get_corners(veh, x)
            %DynamicCar.get_corners returns 2xveh.num_corners points.
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
        
        function corners_hist = get_corners_hist(veh)
            % Populate vehicle corners for each time step in x_hist
            corners_hist = cell(size(veh.x_hist, 1)+1, 1);
            corners_hist{1} = veh.get_corners(veh.x0);
            for x_i = 1:size(veh.x_hist, 1)
                corners_hist{x_i+1} = veh.get_corners(veh.x_hist(x_i, :));
            end
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
        
        function orientations_hist = get_orientations_hist(veh)
            % Populate vehicle orientations for each time step in x_hist
            try
                orientations_hist = [veh.x0(3); veh.x_hist(:, 3)];
            catch
                orientations_hist = veh.x0(3);
                if ~isempty(veh.x_hist) && size(veh.x_hist,2) > 2
                    orientations_hist = [orientations_hist; veh.x_hist(:, 3)];
                end
            end
        end

        function xnext = f(veh, x, odo, w)
            %DynamicCar.f Predict next state based on odometry
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
            %DynamicCar.deriv  Time derivative of state
            %
            % DX = V.deriv(T, X, U) is the time derivative of state (5x1) 
            % at the state X (5x1) with input U (2x1).
            %
            % Notes::
            % - The parameter T is ignored but called from a continuous 
            % time integrator such as ode45 or Simulink.
            
            % TODO: You may want to limit the change in the steering too.

            % Implement steering angle limit
            u(veh.STEER_INP_IND) = min(veh.steermax, max(u(veh.STEER_INP_IND), -veh.steermax));
            
            % Lateral forces:
            if abs(x(veh.SPEED_IND)) < 3.0
                % Ignore lateral forces if speed is really low. This also
                % avoids division by zero.
                Fyf = veh.Cy*(u(veh.STEER_INP_IND) - veh.La*x(veh.ANG_SPEED_IND)/3.0);
                Fyr = veh.Cy*(veh.Lb*x(veh.ANG_SPEED_IND)/3.0);
            else
                Fyf = veh.Cy*(u(veh.STEER_INP_IND) - veh.La*x(veh.ANG_SPEED_IND)/x(veh.SPEED_IND));
                Fyr = veh.Cy*(veh.Lb*x(veh.ANG_SPEED_IND)/x(veh.SPEED_IND));
            end
            
            % Change in speed per time
            temp_acc_dx = (((u(veh.F_INP_IND)/veh.m)*cos(u(veh.STEER_INP_IND))) - ...
                (2*Fyf*sin(u(veh.STEER_INP_IND))/veh.m));
            % implement acceleration limit if required
            if temp_acc_dx > veh.accelmax
                % Limit the input
                u(veh.F_INP_IND) = ((veh.accelmax + ...
                    (2*Fyf*sin(u(veh.STEER_INP_IND))/veh.m)) / cos(u(veh.STEER_INP_IND))) * veh.m;
                % Update temp_acc_dx with limited input
                temp_acc_dx = (((u(veh.F_INP_IND)/veh.m)*cos(u(veh.STEER_INP_IND))) - ...
                    (2*Fyf*sin(u(veh.STEER_INP_IND))/veh.m));
            elseif temp_acc_dx < veh.accelmin
                % Limit the input
                u(veh.F_INP_IND) = ((veh.accelmin + ...
                    (2*Fyf*sin(u(veh.STEER_INP_IND))/veh.m)) / cos(u(veh.STEER_INP_IND))) * veh.m;
                % Update temp_acc_dx with limited input
                temp_acc_dx = (((u(veh.F_INP_IND)/veh.m)*cos(u(veh.STEER_INP_IND))) - ...
                    (2*Fyf*sin(u(veh.STEER_INP_IND))/veh.m));
            end
            
            % implement speed limit if required
            delta_v_max = max(0, veh.speedmax - x(veh.SPEED_IND));
            delta_v_min = min(0, veh.speedmin - x(veh.SPEED_IND));
            if temp_acc_dx*veh.dt > delta_v_max
                % Limit the input
                u(veh.F_INP_IND) = ((delta_v_max/veh.dt + ...
                    (2*Fyf*sin(u(veh.STEER_INP_IND))/veh.m)) / cos(u(veh.STEER_INP_IND)))*veh.m;
                % Update temp_acc_dx with limited input
                temp_acc_dx = (((u(veh.F_INP_IND)/veh.m)*cos(u(veh.STEER_INP_IND))) - ...
                    (2*Fyf*sin(u(veh.STEER_INP_IND))/veh.m));
            elseif temp_acc_dx*veh.dt < delta_v_min
                % Limit the input
                u(veh.F_INP_IND) = ((delta_v_min/veh.dt + ...
                    (2*Fyf*sin(u(veh.STEER_INP_IND))/veh.m)) / cos(u(veh.STEER_INP_IND)))*veh.m;
                % Update temp_acc_dx with limited input
                temp_acc_dx = (((u(veh.F_INP_IND)/veh.m)*cos(u(veh.STEER_INP_IND))) - ...
                    (2*Fyf*sin(u(veh.STEER_INP_IND))/veh.m));
            end
            
            % Avoid vehicle to go from positive to negative speed in one
            % step.
            if (x(veh.SPEED_IND) > 0) && ...
                    (x(veh.SPEED_IND) + temp_acc_dx*veh.dt < 0.0)
                % Limit the input
                u(veh.F_INP_IND) = (((x(veh.SPEED_IND)/veh.dt) + ...
                    (2*Fyf*sin(u(veh.STEER_INP_IND))/veh.m))/cos(u(veh.STEER_INP_IND)))*veh.m;
                % Update temp_acc_dx with limited input
                temp_acc_dx = (((u(veh.F_INP_IND)/veh.m)*cos(u(veh.STEER_INP_IND))) - ...
                    (2*Fyf*sin(u(veh.STEER_INP_IND))/veh.m));
            end

            % dx
            dx = zeros(length(x), 1);
            dx(veh.X_IND) = x(veh.SPEED_IND)*cos(x(veh.ORIENTATION_IND));
%             if isnan(dx(veh.X_IND))
%                 dx(veh.X_IND) = 0.0;
%                 disp('NAN detected: X!')
%             end
            dx(veh.Y_IND) = x(veh.SPEED_IND)*sin(x(veh.ORIENTATION_IND));
%             if isnan(dx(veh.Y_IND))
%                 dx(veh.Y_IND) = 0.0;
%                 disp('NAN detected: Y!')
%             end
            dx(veh.SPEED_IND) = temp_acc_dx;
%             if isnan(dx(veh.SPEED_IND))
%                 dx(veh.SPEED_IND) = 0.0;
%                 disp('NAN detected: SPEED_IND!')
%             end
            dx(veh.ORIENTATION_IND) = x(veh.ANG_SPEED_IND);
%             if isnan(dx(veh.ORIENTATION_IND))
%                 dx(veh.ORIENTATION_IND) = 0.0;
%                 disp('NAN detected: ORIENTATION_IND!')
%             end
            dx(veh.ANG_SPEED_IND) = (veh.La*(u(veh.F_INP_IND)*sin(u(veh.STEER_INP_IND)) + ...
                2*Fyf*cos(u(veh.STEER_INP_IND))) - 2*veh.Lb*Fyr)/veh.J;
            if dx(veh.ANG_SPEED_IND) > pi
                %disp(['FAST ANG_SPEED: ', num2str(dx(veh.ANG_SPEED_IND))]);
                dx(veh.ANG_SPEED_IND) = pi;
            elseif dx(veh.ANG_SPEED_IND) < -pi
                %disp(['FAST ANG_SPEED: ', num2str(dx(veh.ANG_SPEED_IND))]);
                dx(veh.ANG_SPEED_IND) = -pi;
            end
%             if isnan(dx(veh.ANG_SPEED_IND))
%                 dx(veh.ANG_SPEED_IND) = 0.0;
%                 disp('NAN detected: ANG_SPEED_IND!')
%             end
            veh.u_prev = u;
        end
        
        function odo = update(veh, u)
            %DynamicCar.update Update the vehicle state
            %
            % ODO = V.update(U) is the true odometry value for
            % motion with U=[force,steer].
            %
            % Notes::
            % - Appends new state to state history property x_hist.
            % - Odometry is also saved as property odometry.

            % update the state
            [ddx, u] = veh.deriv([], veh.x, u);
            dx = veh.dt * ddx;
            if veh.x(veh.SPEED_IND) > 0
                start_vel_positive = true;
            else
                start_vel_positive = false;
            end
            veh.x = veh.x + dx;
            
            % Apply speed limit.
            if veh.x(veh.SPEED_IND) > veh.speedmax
                veh.x(veh.SPEED_IND) = veh.speedmax;
            elseif veh.x(veh.SPEED_IND) < veh.speedmin
                veh.x(veh.SPEED_IND) = veh.speedmin;
            end
            % Avoid vehicle to go from positive to negative speed in one
            % step.
            if veh.x(veh.SPEED_IND) < 0 && start_vel_positive
                veh.x(veh.SPEED_IND) = 0.0;
            end
            
            %Normalize orientation between +-pi
            veh.x(veh.ORIENTATION_IND) = mod(veh.x(veh.ORIENTATION_IND)+pi, (2*pi)) - pi;

            % compute and save the odometry
            odo = [norm(dx([veh.X_IND, veh.Y_IND])) dx(veh.ORIENTATION_IND)];
            veh.odometry = odo;

            veh.x_hist = [veh.x_hist; veh.x'];   % maintain history
            veh.u_hist = [veh.u_hist; u];   % maintain history
        end
        
        function u = control(veh, force, steer)
            %DynamicCar.control Compute the control input to vehicle
            %
            % U = V.control(FORCE, STEER) is a control input (1x2)
            %
            % U = V.control() as above but demand originates with a 
            % "driver" object if one is attached, the driver's DEMAND() 
            % method is invoked. If no driver is attached then inputs are 
            % assumed to be zero.
            %
            % See also DynamicCar.step, Vehicle.step.
            if nargin < 2
                % if no explicit demand, and a driver is attached, use
                % it to provide demand
                if ~isempty(veh.driver)
                    [force, steer] = veh.driver.demand();
                else
                    % no demand, do something safe
                    force = 0;
                    steer = 0;
                end
            end
            u = [force, steer];
            u(1) = max(min(veh.force_max, force), veh.force_min);
        end
        
        function [p, u_hist] = run(veh, nsteps)
            %DynamicCar.run Run the vehicle simulation
            %
            % V.run(N) runs the vehicle model for N timesteps and plots
            % the vehicle pose at each step.
            %
            % P = V.run(N) runs the vehicle simulation for N timesteps and
            % return the state history (Nx5) without plotting.  Each row
            % is (x,y,orientation,v,angular velocity).
            %
            % See also DynamicCar.step, Vehicle.step, Vehicle.run.

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
            %DynamicCar.plot Plot vehicle
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
                veh.vhandle = ...
                    Vehicle.plotv(veh.x([veh.X_IND, veh.Y_IND, veh.ORIENTATION_IND]), ...
                    varargin{:});
            end
            
            if ~isempty(varargin) && isnumeric(varargin{1})
                % V.plot(X)
                pos = varargin{1}; % use passed value
            else
                % V.plot()
                % use current state
                pos = veh.x([veh.X_IND, veh.Y_IND, veh.ORIENTATION_IND]);
            end
            
            % animate it
            try
                Vehicle.plotv(veh.vhandle, pos);
            catch
                veh.vhandle = ...
                    Vehicle.plotv(veh.x([veh.X_IND, veh.Y_IND, veh.ORIENTATION_IND]), ...
                    varargin{:});
                Vehicle.plotv(veh.vhandle, pos);
            end
        end

% Commented out the following because they are incorrect.
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
            %DynamicCar.char Convert to a string
            %
            % s = V.char() is a string showing vehicle parameters and state
            % in a compact human readable format. 
            %
            % See also Bicycle.display.

            ss = char@Vehicle(veh); 

            s = 'Car object';
            s = char(s, sprintf('  La=%g, Lb=%g, m=%g, steer.max=%g, accel.max=%g, accel.min=%g, speed.max=%g, speed.min=%g', ...
                veh.La, veh.Lb, veh.m, veh.steermax, veh.accelmax, veh.accelmin, veh.speedmax, veh.speedmin));
            s = char(s, ss);
        end
    end % method

end % classdef
