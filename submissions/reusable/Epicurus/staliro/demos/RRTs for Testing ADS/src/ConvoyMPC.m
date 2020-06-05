% ConvoyMPCwithStanley Car driver class
%
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
%    veh.add_driver(ConvoyMPCwithStanley());
%
% See also VehicleDriver, Car, Vehicle, Bicycle.

% (C) C. E. Tuncali, ASU

classdef ConvoyMPC < handle
    properties
        LONG_POS_IND
        SPEED_IND
        
        N
        d_lane
        d_safe
        d_max
        s_ref
        v_ref
        u_min
        u_max
        v_min
        v_max
        delta_u_max
        delta_u_min
        mpc_q_normal
        mpc_qf_normal
        mpc_r_normal
        mpc_rf_normal
        mpc_q_dangerous
        mpc_qf_dangerous
        mpc_r_dangerous
        mpc_rf_dangerous
        R_preCalc
        R_inf
        R_2bar_preCalc
        R_2bar_inf
        H_preCalc
        H_inf
        Q
        vec_d
        S
        Su
        Sx
        Vu
        Aa
        b
        ub
        lb
        opts
        behavior
        dt
        
        vhc_mass
        wind_coef
    end

    methods

        function mpc = ConvoyMPC(dt)
            mpc.vhc_mass = 1000.0;
            mpc.wind_coef = 100.0;

            mpc.LONG_POS_IND = 1;
            mpc.SPEED_IND = 4;
            
            mpc.N = 15;
            mpc.d_lane = 0.5;
            mpc.d_safe = 9.0;
            mpc.d_max = 50.0;
            mpc.s_ref = 20.0;
            mpc.v_ref = 15.0;
            mpc.u_min = -2000;
            mpc.u_max = 3462;
            mpc.v_min = 0.0;
            mpc.v_max = 30.0;
            mpc.delta_u_max = 1000;
            mpc.delta_u_min = -1000;
            mpc.mpc_q_normal = 5;
            mpc.mpc_qf_normal = 5;
            mpc.mpc_r_normal = 50;
            mpc.mpc_rf_normal = 50;
            mpc.mpc_q_dangerous = 3;
            mpc.mpc_qf_dangerous = 5;
            mpc.mpc_r_dangerous = 50;
            mpc.mpc_rf_dangerous = 50;
            mpc.R_preCalc = [];
            mpc.R_inf = [];
            mpc.R_2bar_preCalc = [];
            mpc.R_2bar_inf = [];
            mpc.H_preCalc = [];
            mpc.H_inf = [];
            mpc.Q = [];
            mpc.vec_d = [];
            mpc.S = [];
            mpc.Su = [];
            mpc.Sx = [];
            mpc.Vu = [];
            mpc.Aa = [];
            mpc.b = [];
            mpc.ub = [];
            mpc.lb = [];
            mpc.opts = [];
            mpc.behavior = 'normal';
            
            mpc.dt = dt;
        end
        
        function [ mpc ] = init_mpc(mpc)
            %INIT_MPC Initialize and configure the MPC controller.

            % Discretized system: x(k+1) = Ax(k)+Bu(k) - paper:(12)
            % Create matrix A:
            A = [1 mpc.dt; 0 (1 - (mpc.wind_coef * mpc.dt / mpc.vhc_mass))];
            % Create matrix B:
            B = [0; (mpc.dt / mpc.vhc_mass)];

            % MPC modeling with N prediction horizon
            % calculate the Nth power of A. (will be used in constructing Sx and Su)
            An = eye(2); % A^0
            for ii = 1:mpc.N
                An = An * A;
                cell_An(ii) = {An}; %cell_An{j} = A^j
            end

            %constructing the Su and Sx matrices. - paper (14). 
            mpc.Sx = eye(2);
            mpc.Su = [];
            for ii = 1:mpc.N
                mpc.Sx = [mpc.Sx; cell_An{ii}];
                mpc.Vu = []; %Vu is the current column.
                temp_i = 0;
                for s_i = 1:mpc.N+1
                    if s_i < ii+1
                        mpc.Vu = [mpc.Vu; zeros(2,1)];
                    elseif s_i == ii+1
                        mpc.Vu = [mpc.Vu; B];
                        temp_i = s_i;
                    else                
                        mpc.Vu = [mpc.Vu; cell_An{s_i-temp_i} * B];
                    end
                end
                mpc.Su = [mpc.Su, mpc.Vu];
            end

            % S matrix - paper (17) (page 4 paragprah 1) - ref. free headway set matrix
            mpc.S = repmat([mpc.s_ref; 0], mpc.N+1, 1);

            % Q_bar and R_bar for MPC - paper: (18)
            if strcmpi(mpc.behavior, 'dangerous') % dangerous lane change detected
                % the original value in ACC15 here is Q=5,R=50.
                temp = [repmat([0, mpc.mpc_q_normal], 1, mpc.N), [0, mpc.mpc_qf_normal]];
                mpc.Q = diag(temp);
                temp = [repmat([mpc.mpc_r_normal, 0], 1, mpc.N), [mpc.mpc_rf_normal, 0]];
                mpc.R_preCalc = diag(temp);
            else
                % the original value in ACC15 here is Q=1,R=50.
                temp = [repmat([0, mpc.mpc_q_dangerous], 1, mpc.N), [0, mpc.mpc_qf_dangerous]];
                mpc.Q = diag(temp);
                temp = [repmat([mpc.mpc_r_dangerous, 0], 1, mpc.N), [mpc.mpc_rf_dangerous, 0]];
                mpc.R_preCalc = diag(temp);
            end
            
            % Before cut-in : pure tracking preferred speed
            % area cost inactive in this case as the quad matrix R is set as empty.
            mpc.R_inf = zeros(2*mpc.N + 2, 2*mpc.N + 2); %R_bar for MPC - paper: (18)
            
            %------------------------------------------------------------------------%
            % uncomment this part to use a static lateral distance for simulation
            % dist from vehicle to lane mark, lateral
            % Matrix D - paper (20) (last paragraph of section IV)
            mpc.vec_d = diag(repmat([mpc.d_lane; 0], mpc.N+1, 1));
            
            % Matrix R double bar - paper(20) (last paragraph of section IV)
            mpc.R_2bar_preCalc = mpc.vec_d'*mpc.R_preCalc*mpc.vec_d;
            mpc.R_2bar_inf = mpc.vec_d'*mpc.R_inf*mpc.vec_d;
            % Matrix H - paper (20) (last paragraph of section IV)
            mpc.H_preCalc = mpc.Su'*(mpc.Q+mpc.vec_d'*mpc.R_preCalc*mpc.vec_d)*mpc.Su;
            mpc.H_preCalc = (mpc.H_preCalc+mpc.H_preCalc')*0.5; % To remove "your Hessian is not symmetric warning"
            mpc.H_inf = mpc.Su'*(mpc.Q+mpc.vec_d'*mpc.R_inf*mpc.vec_d)*mpc.Su;
            mpc.H_inf = (mpc.H_inf+mpc.H_inf')*0.5; % To remove "your Hessian is not symmetric warning"
            %------------------------------------------------------------------------%
            %input constraints
            Aa1 = zeros(mpc.N-1, mpc.N);
            Aa2 = zeros(mpc.N-1, mpc.N);
            for r = 1:mpc.N-1
                Aa1(r, r) = -1;
                Aa1(r, r+1) = 1;
                Aa2(r, r) = 1;
                Aa2(r, r+1) = -1;
            end
            mpc.Aa = [Aa1; Aa2];

            mpc.b = mpc.delta_u_max*ones(2*mpc.N-2, 1);%maximun delta_u range

            mpc.ub = mpc.u_max*ones(mpc.N, 1);%maximum force
            mpc.lb = mpc.u_min*ones(mpc.N, 1);%minimum force

            %Optimization (quad programming) options:
            mpc.opts = optimset('Algorithm', 'interior-point-convex', 'Display', 'off');
        end
        
        function [control] = compute_mpc(mpc, x, u_prev, dist, front_vhc_position_estimate)
            %COMPUTE_MPC Compute input(s) with MPC.

            cur_x = [x(mpc.LONG_POS_IND);x(mpc.SPEED_IND)];
            
            if isempty(front_vhc_position_estimate)
                front_vhc_position_estimate = (x(mpc.LONG_POS_IND)+mpc.s_ref)*ones(mpc.N+1,1);
                for ii = 2:mpc.N+1
                    front_vhc_position_estimate(ii) = front_vhc_position_estimate(ii-1) + x(mpc.SPEED_IND)*mpc.dt;
                end
            end

            % nice A matrix - paper (17) (page 4 paragraph 1) - reference velocity matrix
            x_ref = repmat([0; mpc.v_ref], mpc.N+1, 1);

            if dist == inf % Before cut-in : pure tracking preferred speed
                R = mpc.R_inf; %R_bar for MPC - paper: (18)
                R_2bar = mpc.R_2bar_inf;
                H = mpc.H_inf;
            else
                R = mpc.R_preCalc; %R_bar for MPC - paper: (18)
                R_2bar = mpc.R_2bar_preCalc;
                H = mpc.H_preCalc;
            end

            % Matrix L - paper (20) (last paragraph of section IV)
            L = zeros(2*mpc.N+2,1);
            L(1:2:end,:) = front_vhc_position_estimate;
            Cx1 = mpc.v_max*ones(2*mpc.N+2,1);
            Cx1(1:2:end) = front_vhc_position_estimate-mpc.d_safe;
            Cx2 = mpc.v_min*ones(2*mpc.N+2,1);
            Cx2(1:2:end) = front_vhc_position_estimate-mpc.d_max;

            %---------the optimization core of the MPC controller----------------%
            % define the constraints of u_0-u_b(one step before)
            Abf = zeros(2, mpc.N);
            Abf(1, 1) = -1;
            Abf(2, 1) = 1;
            b_scale = mpc.b(1);
            bbf = [b_scale-u_prev; b_scale+u_prev];
            AA = [mpc.Aa; mpc.Su; -mpc.Su; Abf];% AA is the final version constraint matrix for AA*u<=b in QP
            b2 = [mpc.b; Cx1-mpc.Sx*cur_x; mpc.Sx*cur_x-Cx2; bbf];% final version of item 'b' in A*u<=b
            % Matrix A bar - paper(20) (last paragraph of section IV)
            A_bar = mpc.Q*x_ref;
            
            % Matrix F - paper (20) (last paragraph of section IV)
            Ft = (cur_x'*mpc.Sx'*(mpc.Q + R_2bar)+mpc.S'*R*mpc.vec_d-L'*R_2bar-A_bar')*mpc.Su;

            % Solve the optimization problem
            [u_temp, ~, flag] = quadprog(H, Ft', AA, b2, [], [], mpc.lb, mpc.ub, [], mpc.opts);

            if flag < 1 %No feasible solution
                if isempty(u_temp)
                    if front_vhc_position_estimate(1) - cur_x(1) <= mpc.s_ref/mpc.d_lane %P.s_ref/P.d_lane is approximately reference following distance
                        temp_u_val = max(mpc.u_min, u_prev + mpc.delta_u_min);
                        u_temp = temp_u_val*ones(1, mpc.N);
                        %fprintf('Optimization problem infeasible BRAKING\n');
                    else
                        u_temp = u_prev*ones(1, mpc.N);
                        %fprintf('Optimization problem infeasible applying prev INPUT\n');
                    end
                end
            end
            control = u_temp(1);
        end
        
    end % methods
end % classdef
