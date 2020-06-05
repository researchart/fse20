function [T, XT, YT, LT, clg, grd] = model_test_case_1(X0, simT, TU, U, U_state)
%model_test_case_1 Models the simulation of 2 agent + 1 ego on a straight
%3-lane road.

sim_dt = 0.01;
try
    clear sim_env;
catch
end
sim_env = SimulationEnvironment.instance(sim_dt);
sim_env.reset();

% Transfer initial states from X0 for agent and ego vehicles
ego(1).x0 = [X0(1); X0(2); X0(3); X0(4); 0];
agent(1).x0 = [X0(5); X0(6); 0; X0(7)];
agent(2).x0 = [X0(8); X0(9); 0; X0(10)];

[agent(1).wpts, agent(1).time_pts] = convertTimeSignalToTargetWpts(TU, U(:,1)', U(:,2)', agent(1).x0);
[agent(2).wpts, agent(2).time_pts] = convertTimeSignalToTargetWpts(TU, U(:,3)', U(:,4)', agent(1).x0);

% Define Ego vehicle
for ii = 1:length(ego)
    ego(ii).veh = DynamicCar('dt',sim_dt, 'x0',ego(ii).x0);
    %ego(ii).veh.add_driver(ConvoyMPCwithStanley());
    ego(ii).veh.add_driver(PIDACCwithStanley());
    ego(ii).veh.driver.perception_system = PerceptionSystem('ego', ii);
    % front radar
    v_len = ego(ii).veh.front_length + ego(ii).veh.rear_length;
    sensor_id = 1; sensor_pos = [v_len,0]'; sensor_orient = 0; 
    sensor_time_delay = 0; sensor_noise = []; sensor_period = 0.01;
    sensor_ang_range = [-pi/8, pi/8]; sensor_dist_rang = [0, 60];
    ego(ii).veh.driver.perception_system.add_sensor(...
        Sensor('radar', sensor_id, sensor_pos, sensor_orient, ...
                sensor_time_delay, sensor_noise, sensor_period, ...
                sensor_ang_range, sensor_dist_rang) );

    % right radar
    sens_x = v_len*0.5 - ego(ii).veh.rear_length;
    sensor_id = 2; sensor_pos = [sens_x,-ego(ii).veh.width/2]'; sensor_orient = -pi/2; 
    sensor_time_delay = 0; sensor_noise = []; sensor_period = 0.01;
    sensor_ang_range = [-pi/4, pi/4]; sensor_dist_rang = [0, 10];
    ego(ii).veh.driver.perception_system.add_sensor(...
        Sensor('radar', sensor_id, sensor_pos, sensor_orient, ...
                sensor_time_delay, sensor_noise, sensor_period, ...
                sensor_ang_range, sensor_dist_rang) );

    % front-left radar
    sensor_id = 3; sensor_pos = [sens_x,ego(ii).veh.width/2]'; sensor_orient = pi/2; 
    sensor_time_delay = 0; sensor_noise = []; sensor_period = 0.01;
    sensor_ang_range = [-pi/4, pi/4]; sensor_dist_rang = [0, 10];
    ego(ii).veh.driver.perception_system.add_sensor(...
        Sensor('radar', sensor_id, sensor_pos, sensor_orient, ...
                sensor_time_delay, sensor_noise, sensor_period, ...
                sensor_ang_range, sensor_dist_rang) );

    % rear-right-corner radar
    sens_x = -ego(ii).veh.rear_length;
    sensor_id = 4; sensor_pos = [sens_x,-ego(ii).veh.width/2]'; sensor_orient = -pi*140/180; 
    sensor_time_delay = 0; sensor_noise = []; sensor_period = 0.01;
    sensor_ang_range = [-pi/4, pi/4]; sensor_dist_rang = [0, 30];
    ego(ii).veh.driver.perception_system.add_sensor(...
        Sensor('radar', sensor_id, sensor_pos, sensor_orient, ...
                sensor_time_delay, sensor_noise, sensor_period, ...
                sensor_ang_range, sensor_dist_rang) );

    % rear-left-corner radar
    sensor_id = 5; sensor_pos = [sens_x,ego(ii).veh.width/2]'; sensor_orient = pi*140/180; 
    sensor_time_delay = 0; sensor_noise = []; sensor_period = 0.01;
    sensor_ang_range = [-pi/4, pi/4]; sensor_dist_rang = [0, 30];
    ego(ii).veh.driver.perception_system.add_sensor(...
        Sensor('radar', sensor_id, sensor_pos, sensor_orient, ...
                sensor_time_delay, sensor_noise, sensor_period, ...
                sensor_ang_range, sensor_dist_rang) );

    ego(ii).veh.driver.set_simulation_environment(sim_env);
end

for ii = 1:length(agent)
    agent(ii).veh = Car('dt',sim_dt, 'x0',agent(ii).x0);
    K_alpha = 3; K_beta = -1; K_a = 0.5;
    agent(ii).veh.add_driver(MoveToPoseDriverNoCollision(K_alpha, K_beta, K_a));
    agent(ii).veh.driver.set_sim_env(sim_env, ii);
end

% Simulate vehicles.
% Initialize vehicles to their starting states.
for ii = 1:length(ego)
    ego(ii).veh.init(ego(ii).x0);
    ego(ii).veh.driver.init();
end
for ii = 1:length(agent)
    agent(ii).veh.init(agent(ii).x0);
    if ~isempty(agent(ii).veh.driver)
        agent(ii).veh.driver.init();
        agent(ii).veh.driver.clear_target_path(); % This may be redundant after init.
        agent(ii).veh.driver.add_to_target_path(agent(ii).wpts);
    end
end

nsteps = length(TU)-1;
last_step = nsteps + 1;
for step_i = 1:nsteps
    if isempty(sim_env.collisions)
        if isa(sim_env, 'SimulationEnvironment')
            sim_env.update_environment(TU(step_i),agent,ego);
        end
        % stop simulation when there is a collision.
        for ii = 1:length(agent)
            % Update target waypoints as their time arrive:
            if ~isempty(agent(ii).time_pts) && TU(step_i) >= agent(ii).time_pts(1)
                agent(ii).time_pts(1) = [];
                if ~isempty(agent(ii).veh.driver.target_path) && isequal(agent(ii).veh.driver.target_path(:,1), agent(ii).wpts(:,1))
                    % We don't remove without checking because maybe car
                    % has already arrived at this wpt and removed it by
                    % itself.
                    agent(ii).veh.driver.target_path(:,1) = [];
                end
                agent(ii).wpts(:,1) = [];
            end
            agent(ii).veh.step();
        end
        for ii = 1:length(ego)
            ego(ii).veh.step();
        end
    else
        last_step = step_i;
        for ii = 1:length(agent)
            agent(ii).veh.x_hist = [agent(ii).veh.x_hist; repmat(agent(ii).veh.x',nsteps-step_i+1 ,1)];
        end
        for ii = 1:length(ego)
            ego(ii).veh.x_hist = [ego(ii).veh.x_hist; repmat(ego(ii).veh.x',nsteps-step_i+1 ,1)];
        end
        break;
    end
end
T = TU(1:last_step);
XT = [[ego(1).veh.x0'; ego(1).veh.x_hist], [agent(1).veh.x0'; agent(1).veh.x_hist], [agent(2).veh.x0'; agent(2).veh.x_hist]];
XT = XT(1:last_step, :);
YT = [];
LT = ego(1).veh.driver.driving_mode_history;
clg = [];
grd = [];

end

