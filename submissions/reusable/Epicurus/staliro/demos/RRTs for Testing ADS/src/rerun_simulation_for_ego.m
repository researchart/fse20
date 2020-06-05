% Does not sample for agents. Just replays the agents for the given
% configuration. Simulates ego vehicles from time 0 without stopping
% saving/setting controller/vehicle states.
visualize_webots = true;
if visualize_webots
    disp('Webots coordinate system and our coordinate system in Matlab is different. Coordinates are converted so that Webots display will match expectations!')
    if ~ispc
        try
            pyversion /usr/local/bin/python3.7
        catch
        end
    end
end
% Get Simulation time from the final configuration.
sim_time = configurations(final_config_id).end_time;

% Create the configuration trace. The order of config_id's in the original
% run.
config_trace = [];
cur_conf = final_config_id;
while ~isempty(cur_conf)
    config_trace = [cur_conf;config_trace]; %#ok<AGROW>
    prev_ind = find(config_history(:,2) == cur_conf, 1);
    cur_conf = config_history(prev_ind,1);
end

% Populate the agent state histories.
agent_x_hist = {};
for ii = 1:length(agent)
    agent_x_hist{ii} = []; %#ok<SAGROW>
    for c_i = 1:length(config_trace)
        node_i = configurations(c_i).agent_node(ii);
        vdata = agent(ii).G.vdata(config_trace(node_i));
        if ~isempty(vdata.x_hist)
            agent_x_hist{ii} = [agent_x_hist{ii}; vdata.x_hist];
        %else
        %    agent_x_hist{ii} = [agent_x_hist{ii}; vdata.x'];
        end
    end
end

% Populate ego state history from the original run (only for comparison)
old_ego_x_hist = {};
for ii = 1:length(ego)
    old_ego_x_hist{ii} = []; %#ok<SAGROW>
    for c_i = 1:length(config_trace)
        node_i = configurations(c_i).ego_node(ii);
        vdata = ego(ii).G.vdata(config_trace(node_i));
        if ~isempty(vdata.x_hist)
            old_ego_x_hist{ii} = [old_ego_x_hist{ii}; vdata.x_hist];
        end
    end
end

ego_old = ego;
agent_old = agent;
configurations_old = configurations;
config_history_old = config_history;

clear ego_rerun
clear agent_rerun
clear sim_env
clear sim_env_rerun
configurations_rerun = [];
config_history_rerun = [];

sim_dt = 0.01;
sim_env_rerun = SimulationEnvironment.instance(sim_dt);

%% Set initial states for agent and ego vehicles
for ii = 1:length(ego_old)
    node_i = configurations(config_trace(1)).ego_node(ii);
    vdata = ego_old(ii).G.vdata(node_i);
    ego_rerun(ii).x0 = vdata.x; %#ok<SAGROW>
end
for ii = 1:length(agent_old)
    node_i = configurations(config_trace(1)).agent_node(ii);
    vdata = agent_old(ii).G.vdata(node_i);
    agent_rerun(ii).x0 = vdata.x; %#ok<SAGROW>
    agent_rerun(ii).veh = ReplayCar('dt',sim_dt, 'x0',agent_rerun(ii).x0);
    agent_rerun(ii).veh.x_hist = agent_x_hist{ii};
end

for ii = 1:length(ego_rerun)
    ego_rerun(ii).veh = DynamicCar('dt',sim_dt, 'x0',ego_rerun(ii).x0);
    %ego(ii).veh.add_driver(ConvoyMPCwithStanley());
    ego_rerun(ii).veh.add_driver(PIDACCwithStanley());
    ego_rerun(ii).veh.driver.perception_system = PerceptionSystem('ego', ii);
    % front radar
    v_len = ego_rerun(ii).veh.front_length + ego_rerun(ii).veh.rear_length;
    sensor_id = 1; sensor_pos = [v_len,0]'; sensor_orient = 0; 
    sensor_time_delay = 0; sensor_noise = []; sensor_period = 0.01;
    sensor_ang_range = [-pi/8, pi/8]; sensor_dist_rang = [0, 60];
    ego_rerun(ii).veh.driver.perception_system.add_sensor(...
        Sensor('radar', sensor_id, sensor_pos, sensor_orient, ...
                sensor_time_delay, sensor_noise, sensor_period, ...
                sensor_ang_range, sensor_dist_rang) );
            
    % right radar
    sens_x = v_len*0.5 - ego_rerun(ii).veh.rear_length;
    sensor_id = 2; sensor_pos = [sens_x,-ego_rerun(ii).veh.width/2]'; sensor_orient = -pi/2; 
    sensor_time_delay = 0; sensor_noise = []; sensor_period = 0.01;
    sensor_ang_range = [-pi/4, pi/4]; sensor_dist_rang = [0, 10];
    ego_rerun(ii).veh.driver.perception_system.add_sensor(...
        Sensor('radar', sensor_id, sensor_pos, sensor_orient, ...
                sensor_time_delay, sensor_noise, sensor_period, ...
                sensor_ang_range, sensor_dist_rang) );
            
    % front-left radar
    sensor_id = 3; sensor_pos = [sens_x,ego_rerun(ii).veh.width/2]'; sensor_orient = pi/2; 
    sensor_time_delay = 0; sensor_noise = []; sensor_period = 0.01;
    sensor_ang_range = [-pi/4, pi/4]; sensor_dist_rang = [0, 10];
    ego_rerun(ii).veh.driver.perception_system.add_sensor(...
        Sensor('radar', sensor_id, sensor_pos, sensor_orient, ...
                sensor_time_delay, sensor_noise, sensor_period, ...
                sensor_ang_range, sensor_dist_rang) );
            
%     % front-right radar
%     sens_x = v_len*0.8 - ego_rerun(ii).veh.rear_length;
%     sensor_id = 2; sensor_pos = [sens_x,-ego_rerun(ii).veh.width/2]'; sensor_orient = -pi/2; 
%     sensor_time_delay = 0; sensor_noise = []; sensor_period = 0.01;
%     sensor_ang_range = [-pi/4, pi/4]; sensor_dist_rang = [0, 10];
%     ego_rerun(ii).veh.driver.perception_system.add_sensor(...
%         Sensor('radar', sensor_id, sensor_pos, sensor_orient, ...
%                 sensor_time_delay, sensor_noise, sensor_period, ...
%                 sensor_ang_range, sensor_dist_rang) );
%             
%     % front-left radar
%     sensor_id = 3; sensor_pos = [sens_x,ego_rerun(ii).veh.width/2]'; sensor_orient = pi/2; 
%     sensor_time_delay = 0; sensor_noise = []; sensor_period = 0.01;
%     sensor_ang_range = [-pi/4, pi/4]; sensor_dist_rang = [0, 10];
%     ego_rerun(ii).veh.driver.perception_system.add_sensor(...
%         Sensor('radar', sensor_id, sensor_pos, sensor_orient, ...
%                 sensor_time_delay, sensor_noise, sensor_period, ...
%                 sensor_ang_range, sensor_dist_rang) );
%             
%     % rear-right radar
%     sens_x = v_len*0.2 - ego_rerun(ii).veh.rear_length;
%     sensor_id = 4; sensor_pos = [sens_x,-ego_rerun(ii).veh.width/2]'; sensor_orient = -pi/2; 
%     sensor_time_delay = 0; sensor_noise = []; sensor_period = 0.01;
%     sensor_ang_range = [-pi/4, pi/4]; sensor_dist_rang = [0, 10];
%     ego_rerun(ii).veh.driver.perception_system.add_sensor(...
%         Sensor('radar', sensor_id, sensor_pos, sensor_orient, ...
%                 sensor_time_delay, sensor_noise, sensor_period, ...
%                 sensor_ang_range, sensor_dist_rang) );
%             
%     % rear-left radar
%     sensor_id = 5; sensor_pos = [sens_x,ego_rerun(ii).veh.width/2]'; sensor_orient = pi/2; 
%     sensor_time_delay = 0; sensor_noise = []; sensor_period = 0.01;
%     sensor_ang_range = [-pi/4, pi/4]; sensor_dist_rang = [0, 10];
%     ego_rerun(ii).veh.driver.perception_system.add_sensor(...
%         Sensor('radar', sensor_id, sensor_pos, sensor_orient, ...
%                 sensor_time_delay, sensor_noise, sensor_period, ...
%                 sensor_ang_range, sensor_dist_rang) );
            
    % rear-right-corner radar
    sens_x = -ego_rerun(ii).veh.rear_length;
    sensor_id = 4; sensor_pos = [sens_x,-ego_rerun(ii).veh.width/2]'; sensor_orient = -pi*140/180; 
    sensor_time_delay = 0; sensor_noise = []; sensor_period = 0.01;
    sensor_ang_range = [-pi/4, pi/4]; sensor_dist_rang = [0, 30];
    ego_rerun(ii).veh.driver.perception_system.add_sensor(...
        Sensor('radar', sensor_id, sensor_pos, sensor_orient, ...
                sensor_time_delay, sensor_noise, sensor_period, ...
                sensor_ang_range, sensor_dist_rang) );
            
    % rear-left-corner radar
    sensor_id = 5; sensor_pos = [sens_x,ego_rerun(ii).veh.width/2]'; sensor_orient = pi*140/180; 
    sensor_time_delay = 0; sensor_noise = []; sensor_period = 0.01;
    sensor_ang_range = [-pi/4, pi/4]; sensor_dist_rang = [0, 30];
    ego_rerun(ii).veh.driver.perception_system.add_sensor(...
        Sensor('radar', sensor_id, sensor_pos, sensor_orient, ...
                sensor_time_delay, sensor_noise, sensor_period, ...
                sensor_ang_range, sensor_dist_rang) );
            
    ego_rerun(ii).veh.driver.set_simulation_environment(sim_env_rerun);
    % TODO: Add path to follow to the Ego vehicle
    %ego_rerun(ii).veh.driver.add_to_target_path(ego_rerun(ii).x0 + [1000.0; 0.0; 0.0; 0.0]);
end

%% Initialize exploration graphs of agent and ego vehicles.
g_ndims = 3;
for ii = 1:length(agent_rerun)
    agent_rerun(ii).G = ExplorationGraph(g_ndims, 'distance', @angled_distance);
    node_id = agent_rerun(ii).G.add_node(agent_rerun(ii).x0(1:3));
    vdata = TreeNodeData(agent_rerun(ii).x0);
    agent_rerun(ii).G.setvdata(node_id, vdata);
    configurations_rerun(1).agent_node(ii) = node_id; %#ok<*SAGROW>
end
for ii = 1:length(ego_rerun)
    ego_rerun(ii).G = ExplorationGraph(g_ndims, 'distance', @angled_distance);
    node_id = ego_rerun(ii).G.add_node(ego_rerun(ii).x0(1:3));
    vdata = TreeNodeData(ego_rerun(ii).x0);
    ego_rerun(ii).G.setvdata(node_id, vdata);
    configurations_rerun(1).ego_node(ii) = node_id;
end
configurations_rerun(1).end_time = 0;
configurations_rerun(1).cost = 10000;
configurations_rerun(1).cost_aux = {};
configurations_rerun(1).novelty = 0;


new_config_id = length(configurations_rerun) + 1;
prev_config_id = 1;
prev_config = configurations_rerun(prev_config_id);
start_time = prev_config.end_time;

% Find previous tree nodes
best_v_agent = [];
for ii = 1:length(agent_rerun)
    best_v_agent(ii) = prev_config.agent_node(ii);
end
best_v_ego = [];
for ii = 1:length(ego_rerun)
    best_v_ego(ii) = prev_config.ego_node(ii);
end

%simulator = @simulate_vehicles; % Already in the environment.

% Simulate vehicles.
[agent_out, ego_out] = simulator(agent_rerun, ego_rerun, sim_time, ...
                best_v_agent, best_v_ego, sim_env_rerun, start_time, visualize_webots);
            
[cost, cost_aux] = immediate_cost_fnc(ego_out, agent_out, sim_env_rerun, start_time);

% Update search graphs with the simulation results.
for ii = 1:length(agent_out)
    if ~isempty(agent_out(ii).veh.x_hist)
        % Add the result as a new node.
        new_v = agent_rerun(ii).G.add_node(agent_out(ii).veh.x_hist(end, 1:3));
        newvdata = TreeNodeData(agent_out(ii).veh.x_hist(end, :)');
        % Update vertex data with the target_path that wasused.
        %newvdata.target_path = agent(ii).temp_target_path;
        newvdata.x_hist = agent_out(ii).veh.x_hist;
        newvdata.u_hist = agent_out(ii).veh.u_hist;
        %newvdata.controller_state = agent_out(ii).veh.driver.get_states();
        newvdata.cur_time = agent_rerun(ii).G.vdata(best_v_agent(ii)).cur_time + search_dt;
        agent_rerun(ii).G.setvdata(new_v, newvdata);
        % Connect previous state with the new one.
        agent_rerun(ii).G.add_edge(best_v_agent(ii), new_v);
        configurations_rerun(new_config_id).agent_node(ii) = new_v;
    end
end
for ii = 1:length(ego_out)
    if ~isempty(ego_out(ii).veh.x_hist)
        % Add the result as a new node.
        new_v = ego_rerun(ii).G.add_node(ego_out(ii).veh.x_hist(end, 1:3));
        newvdata = TreeNodeData(ego_out(ii).veh.x_hist(end, :)');
        newvdata.x_hist = ego_out(ii).veh.x_hist;
        newvdata.u_hist = ego_out(ii).veh.u_hist;
        newvdata.controller_state = ego_out(ii).veh.driver.get_states();
        newvdata.cur_time = ego_rerun(ii).G.vdata(best_v_ego(ii)).cur_time + search_dt;
        ego_rerun(ii).G.setvdata(new_v, newvdata);
        % Connect previous state with the new one.
        ego_rerun(ii).G.add_edge(best_v_ego(ii), new_v);
        configurations_rerun(new_config_id).ego_node(ii) = new_v;
    end
end
configurations_rerun(new_config_id).novelty = novelty;
configurations_rerun(new_config_id).cost = cost;
configurations_rerun(new_config_id).cost_aux = cost_aux;
configurations_rerun(new_config_id).end_time = start_time + search_dt;
config_history_rerun(end+1,:) = [prev_config_id, new_config_id];

