%% Get the state of the random number generator
rand_seed = rng;
tic;

%% Parameters
max_rrt_iter = 5000;
sim_dt = 0.01;
search_dt = 1.5;
prev_config_finder = @find_best_config_behind;
prev_config_finder_opts.anchor_agent = 1;
simulator = @simulate_vehicles;
immediate_cost_fnc = @ttc_and_impact_pt_cost;
transition_check_fnc = @transition_check;
transition_check_options.T = 0.01;
transition_check_options.nFail = 0;
transition_check_options.nFail_max = 5;
transition_check_options.alpha = 2;
transition_check_options.K = 100;

sim_env = SimulationEnvironment.instance(sim_dt);

%% Book keeping
configurations = []; % An array for the relations between corresponding nodes.
terminal_configs = []; % Marks the vertices that violates constraints and hence are not extensible.
config_history = [];  % Keeps a track of which config evolves to which config.
num_rejected_transition = 0;
num_accepted_transition = 0;
num_rejected_novelty = 0;
num_accepted_novelty = 0;

%% Define Roads
roads = [];
temp_road = SimRoad('id', 'west_east', 'start_x', -150, 'start_y', -7, ...
                    'rotation', 0);
temp_road.create_and_add_segment('length', 300, 'width', 14);
temp_road.compute_left_profile();
temp_road.compute_right_profile();
roads = [roads, temp_road];

temp_road = SimRoad('id', 'east_west', 'start_x', 150, 'start_y', 7, ...
                    'rotation', pi);
temp_road.create_and_add_segment('length', 300, 'width', 14);
temp_road.compute_left_profile();
temp_road.compute_right_profile();
roads = [roads, temp_road];

temp_road = SimRoad('id', 'south_north', 'start_x', 7, 'start_y', -150,...
                    'rotation', pi/2);
temp_road.create_and_add_segment('length', 300, 'width', 14);
temp_road.compute_left_profile();
temp_road.compute_right_profile();
roads = [roads, temp_road];

temp_road = SimRoad('id', 'north_south', 'start_x', -7, 'start_y', 150,...
                    'rotation', -pi/2);
temp_road.create_and_add_segment('length', 300, 'width', 14);
temp_road.compute_left_profile();
temp_road.compute_right_profile();
roads = [roads, temp_road];

%% Define vehicle parameters and create vehicles
agent(1).veh = Car('dt',sim_dt);
agent(2).veh = Car('dt',sim_dt);
ego(1).veh = DynamicCar('dt',sim_dt);

g_ndims = 3;
for ii = 1:length(agent)
    K_alpha = 3; K_beta = -1; K_a = 0.5;
    agent(ii).veh.add_driver(MoveToPoseDriverNoCollision(K_alpha, K_beta, K_a));
    agent(ii).veh.driver.set_sim_env(sim_env, ii);
    agent(ii).G = ExplorationGraph(g_ndims, 'distance', @angled_distance);
end
for ii = 1:length(ego)
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
    % TODO: Add path to follow to the Ego vehicle
    %ego(ii).veh.driver.add_to_target_path(ego(ii).x0 + [1000.0; 0.0; 0.0; 0.0]);
    
    ego(ii).G = ExplorationGraph(g_ndims, 'distance', @angled_distance);
end

%% Define set of initial states for agent and ego vehicles
agent(1).x0_s = cell(0);
for road_i = 1:length(roads)
    agent(1).x0_s{end+1} = SampleSpace([[0, 10]; [-3.5, 3.5]; [0 0]; [0, 15]]);
    temp_road = roads(road_i); %could not directly pass the function handle.
    agent(1).x0_s{end}.set_mapper(@temp_road.convert_road_to_world_coordinates);
end

agent(2).x0_s = cell(0);
for road_i = 1:length(roads)
    agent(2).x0_s{end+1} = SampleSpace([[15, 25]; [-3.5, 3.5]; [0 0]; [0, 15]]);
    temp_road = roads(road_i);
    agent(2).x0_s{end}.set_mapper(@temp_road.convert_road_to_world_coordinates);
end

ego(1).x0_s = cell(0);
ego(1).x0_s{end+1} = SampleSpace([[50, 50]; [0, 0]; [0 0]; [15, 15]; [0, 0]]);
temp_road = roads(1);
ego(1).x0_s{end}.set_mapper(@temp_road.convert_road_to_world_coordinates);


%% Sample initial states for agent and ego vehicles
for ii = 1:length(agent)
    agent(ii).x0 = cell(0);
    for s_i = 1:length(agent(ii).x0_s)
        x0 = agent(ii).x0_s{s_i}.get_new_sample();
        node_id = agent(ii).G.add_node(x0(1:3));
        agent(ii).x0{end+1} = x0;
        vdata = TreeNodeData(x0);
        agent(ii).G.setvdata(node_id, vdata);
        agent_node(ii,s_i) = node_id;
    end
end
for ii = 1:length(ego)
    ego(ii).x0 = cell(0);
    x0 = ego(ii).x0_s{1}.get_new_sample();
    node_id = ego(ii).G.add_node(x0(1:3));
    ego(ii).x0{end+1} = x0;
    vdata = TreeNodeData(x0);
    ego(ii).G.setvdata(node_id, vdata);
    ego_node(ii) = node_id;
end

temp_config.end_time = 0;
temp_config.cost = 10000;
temp_config.cost_aux = {};
temp_config.novelty = 0;

for e_i = 1:length(ego)
    temp_config.ego_node(e_i) = ego_node(e_i);
    for a_i = 1:length(agent)
        for s_i = 1:length(agent(a_i).x0)
            temp_config.agent_node(a_i) = agent_node(a_i, s_i);
            for a_j = a_i+1:length(agent)
                for s_j = 1:length(agent(a_j).x0)
                    temp_config.agent_node(a_j) = agent_node(a_j, s_j);
                    configurations = [configurations, temp_config];
                end
            end
        end
    end
end


% Create an object that will do the novelty computations.
novelty_checker = RelativeStateBasedNovelty(ego, agent);
%novelty_checker = AcceptAllNovelty(ego, agent);

sample_to_path_converter = WptToWorldConverter();
sample_to_path_converter.add_road(roads);

%% Define sample space for agent vehicles
agent(1).x_s = SampleSpace([[0, 1]; [10, 300]; [-6, 6]; [-pi/4 pi/4]; [0, 30]]);
agent(1).x_s.set_mapper(@sample_to_path_converter.convert_sample_to_target_path);
agent(2).x_s = SampleSpace([[0, 1]; [5, 300]; [-6, 6]; [-pi/4 pi/4]; [0, 30]]);
agent(2).x_s.set_mapper(@sample_to_path_converter.convert_sample_to_target_path);

%% Search
last_r_i = 1;
r_i = 1;
disp('----- Starting ------');
datetime
starttime = tic;
max_duration_s = 900;
while toc(starttime) < max_duration_s %r_i < max_rrt_iter
    if (mod(r_i, 10) == 0 || mod(r_i, uint32(0.1*max_rrt_iter)) == 0) && r_i ~= last_r_i
        disp(['RRT: ', num2str(r_i), '/', num2str(max_rrt_iter)]);
        datetime
    end
    last_r_i = r_i;
    new_config_id = length(configurations) + 1;

    % Sample temp_target_path for agents.
    for a_i = 1:length(agent)
        agent(a_i).temp_target_path = agent(a_i).x_s.get_new_sample();
    end
    
    % Find the best previous configuration. (Best Neighbor)
    % TODO create a better metric to choose the best node in the graph.
    prev_config_id = prev_config_finder(prev_config_finder_opts, ...
        configurations, agent, terminal_configs);
    prev_config = configurations(prev_config_id);
    start_time = prev_config.end_time;
    
    % Find previous tree nodes
    best_v_agent = [];
    for ii = 1:length(agent)
        best_v_agent(ii) = prev_config.agent_node(ii);
    end
    best_v_ego = [];
    for ii = 1:length(ego)
        best_v_ego(ii) = prev_config.ego_node(ii);
    end
    
    % Simulate vehicles.
    [agent_out, ego_out] = simulator(agent, ego, search_dt, ...
                    best_v_agent, best_v_ego, sim_env, start_time);

    % Check if we will add the new node.
    % Corresponds to Transition Test in Transition-based RRT
    [cost, cost_aux] = immediate_cost_fnc(ego_out, agent_out, sim_env, start_time);
    [transition_okay, transition_check_options] = ...
        transition_check_fnc(transition_check_options, prev_config.cost, cost);
    num_accepted_transition = num_accepted_transition + double(transition_okay);
    num_rejected_transition = num_rejected_transition + double(~transition_okay);
    if transition_okay
        % Check Novelty.
        [is_novel, novelty, all_novelty] = novelty_checker.compute_novelty(ego_out, agent_out);
        num_accepted_novelty = num_accepted_novelty + double(is_novel); % Bookkeeping
        num_rejected_novelty = num_rejected_novelty + double(~is_novel);
        if is_novel || cost < 0.8*prev_config.cost
            % Update search graphs with the simulation results.
            for ii = 1:length(agent_out)
                if ~isempty(agent_out(ii).veh.x_hist)
                    % Add the result as a new node.
                    new_v = agent(ii).G.add_node(agent_out(ii).veh.x_hist(end, 1:3));
                    newvdata = TreeNodeData(agent_out(ii).veh.x_hist(end, :)');
                    % Update vertex data with the target_path that wasused.
                    newvdata.target_path = agent(ii).temp_target_path;
                    newvdata.x_hist = agent_out(ii).veh.x_hist;
                    newvdata.u_hist = agent_out(ii).veh.u_hist;
                    newvdata.controller_state = agent_out(ii).veh.driver.get_states();
                    newvdata.cur_time = agent(ii).G.vdata(best_v_agent(ii)).cur_time + length(agent_out(ii).veh.x_hist)*agent_out(ii).veh.dt;
                    agent(ii).G.setvdata(new_v, newvdata);
                    % Connect previous state with the new one.
                    agent(ii).G.add_edge(best_v_agent(ii), new_v);
                    configurations(new_config_id).agent_node(ii) = new_v;
%                     if is_state_invalid(newvdata.x, agent(ii))
%                         % We never set to "false" here because it may override a
%                         % "true" that was set from another agent.
%                         terminal_configs(new_config_id) = true;
%                     end
                end
            end
            for ii = 1:length(ego_out)
                if ~isempty(ego_out(ii).veh.x_hist)
                    % Add the result as a new node.
                    new_v = ego(ii).G.add_node(ego_out(ii).veh.x_hist(end, 1:3));
                    newvdata = TreeNodeData(ego_out(ii).veh.x_hist(end, :)');
                    newvdata.x_hist = ego_out(ii).veh.x_hist;
                    newvdata.u_hist = ego_out(ii).veh.u_hist;
                    newvdata.controller_state = ego_out(ii).veh.driver.get_states();
                    newvdata.cur_time = ego(ii).G.vdata(best_v_ego(ii)).cur_time + length(ego_out(ii).veh.x_hist)*ego_out(ii).veh.dt;
                    ego(ii).G.setvdata(new_v, newvdata);
                    % Connect previous state with the new one.
                    ego(ii).G.add_edge(best_v_ego(ii), new_v);
                    configurations(new_config_id).ego_node(ii) = new_v;
                end
            end
            configurations(new_config_id).novelty = novelty;
            configurations(new_config_id).cost = cost;
            configurations(new_config_id).cost_aux = cost_aux;
            configurations(new_config_id).end_time = start_time + length(ego_out(1).veh.x_hist)*ego_out(1).veh.dt;
            config_history(end+1,:) = [prev_config_id, new_config_id];
            if ~isempty(sim_env.collisions)
                terminal_configs(new_config_id) = true;
            end
            r_i = r_i+1;
            % TODO: Stop search (mark as final config) if all agent and ego vehicles are on opposite
            % directions and passed each other (no hope for future collision).
        end %transition check
    end %novelty check
end
total_time_passed = toc;
tt = datetime('now');
fname = ['../log/rrt_4way_',num2str(tt.Year),num2str(tt.Month),num2str(tt.Day),'_',num2str(tt.Hour),'_',num2str(tt.Minute)]
save(fname);

