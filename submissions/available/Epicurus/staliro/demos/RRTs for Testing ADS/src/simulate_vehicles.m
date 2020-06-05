function [agents, ego_vehicles] = simulate_vehicles(agents,ego_vehicles,...
    sim_time,init_conf_agent,init_conf_ego,sim_env,start_time,visualize_webots)
% SIMULATE_VEHICLES Simulate all vehicles
    % Reset simulation environment to the last configurations of vehicles.
    if nargin < 8
        visualize_webots = false;
    end
    
    num_agents = length(agents);
    num_ego = length(ego_vehicles);
    
    % Initialize vehicles to their starting states.
    for ii = 1:length(agents)
        vdata = agents(ii).G.vdata(init_conf_agent(ii));
        if ~isempty(vdata.u_hist)
            agents(ii).veh.init(vdata.x, vdata.u_hist(end, :));
        else
            agents(ii).veh.init(vdata.x);
        end
        if ~isempty(agents(ii).veh.driver)
            agents(ii).veh.driver.clear_target_path(); % This may be redundant after init.
            agents(ii).veh.driver.add_to_target_path(agents(ii).temp_target_path);
        end
    end
    for ii = 1:length(ego_vehicles)
        vdata = ego_vehicles(ii).G.vdata(init_conf_ego(ii));
        if ~isempty(vdata.u_hist)
            ego_vehicles(ii).veh.init(vdata.x, vdata.u_hist(end, :));
        else
            ego_vehicles(ii).veh.init(vdata.x);
        end
        % TODO Add target path to the Ego vehicle.
    end
    
    sim_env.reset(ego_vehicles, agents, init_conf_ego, init_conf_agent);

    % Decide dt
    dt_list = zeros(1, num_agents + num_ego);
    for ii = 1:num_agents
        dt_list(ii) = agents(ii).veh.dt;
    end
    for ii = 1:num_ego
        dt_list(ii + num_agents) = ego_vehicles(ii).veh.dt;
    end
    if numel(unique(dt_list)) ~= 1
        error('All vehicles must have the same dt to use simulate_vehicles.');
    end
    dt = dt_list(1);
    
    % Initialize controllers:
    for ii = 1:num_agents
        if ~isempty(agents(ii).veh.driver)
            agents(ii).veh.driver.init();
            controller_state = ...
                agents(ii).G.vdata(init_conf_agent(ii)).controller_state;
            if ~isempty(controller_state)
                agents(ii).veh.driver.set_states(controller_state);
            end
        end
    end
    for ii = 1:num_ego
        if ~isempty(ego_vehicles(ii).veh.driver)
            ego_vehicles(ii).veh.driver.init()
            controller_state = ...
                ego_vehicles(ii).G.vdata(init_conf_ego(ii)).controller_state;
            if ~isempty(controller_state)
                ego_vehicles(ii).veh.driver.set_states(controller_state);
            end
        end
    end

    nsteps = round(sim_time / dt);

    for step_i = 1:nsteps
        if visualize_webots
            states = [];
            for ii = 1:length(ego_vehicles)
                states = [states, convert_x_to_webots(ego_vehicles(ii).veh.x')];
            end
            for ii = 1:length(agents)
                states = [states, convert_x_to_webots(agents(ii).veh.x')];
            end
            if step_i == 1
                configurator = py.step_by_step_visualizer.set_initial_states(states);
            else
                py.step_by_step_visualizer.update_states(states, configurator);
            end
        end
        if isa(sim_env, 'SimulationEnvironment')
            sim_env.update_environment(start_time + step_i*dt,agents,ego_vehicles);
        end
        if isempty(sim_env.collisions) && isempty(sim_env.agent_collisions)
            % stop simulation when there is a collision.
            for ii = 1:length(agents)
                agents(ii).veh.step();
            end
            for ii = 1:length(ego_vehicles)
                ego_vehicles(ii).veh.step();
            end
        end
    end
end
