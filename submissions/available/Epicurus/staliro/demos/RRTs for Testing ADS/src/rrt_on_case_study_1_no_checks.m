%% Get the state of the random number generator
rand_seed = rng;
tic;

%% Parameters
max_rrt_iter = 100;
sim_dt = 0.01;
search_dt = 2.5;
random_sampler = @in_road_random_path_sampler;
random_sampler_opts.temp_path_len = 100;
prev_config_finder = @find_best_config_w_dist_angle;
%prev_config_finder = @return_last_config;
prev_config_finder_opts.anchor_agent = 1;
simulator = @simulate_vehicles;
immediate_cost_fnc = @ttc_and_impact_pt_cost;
transition_check_fnc = @transition_check_all_okay;
transition_check_options.T = 0.001;
transition_check_options.nFail = 0;
transition_check_options.nFail_max = 10;
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

%% Define set of initial states for agent and ego vehicles
agent(1).x0_s = [[0, 10]; [-4, 4]; [0 0]; [0, 30]];  %[x,y,theta,v]
%agent(2).x0_s = [[190, 200]; [-4, 4]; [pi pi]; [0, 20]];
agent(2).x0_s = [[-20, 5]; [-4, 4]; [0 0]; [0, 30]];
ego(1).x0_s = [[20, 30]; [-2, 2]; [-pi/8 pi/8]; [0, 15]; [0, 0]]; %[x,y,theta,v,ang_v]

% Create an object that will do the novelty computations.
novelty_checker = NoveltyCheckerAllOkay(ego, agent);

%% Define sample space for agent vehicles
agent(1).x_s = [[10, 1000]; [-4, 4]; [-pi/4 pi/4]; [0, 30]];
%agent(2).x_s = [[0, 190]; [-4, 4]; [pi-pi/4 pi+pi/4]; [0, 20]];
agent(2).x_s = [[5, 1000]; [-4, 4]; [-pi/4 pi/4]; [0, 30]];

%% Sample initial states for agent and ego vehicles
for ii = 1:length(agent)
    agent(ii).x0 = rand_between(agent(ii).x0_s(:,1), agent(ii).x0_s(:,2));
end
for ii = 1:length(ego)
    ego(ii).x0 = rand_between(ego(ii).x0_s(:, 1), ego(ii).x0_s(:, 2));
end

%% Define vehicle parameters and create vehicles
for ii = 1:length(agent)
    agent(ii).veh = Car('dt',sim_dt, 'x0',agent(ii).x0);
    agent(ii).veh.add_driver(MoveToPoseDriver(3,-1,0.5));
end
for ii = 1:length(ego)
    ego(ii).veh = DynamicCar('dt',sim_dt, 'x0',ego(ii).x0);
    ego(ii).veh.add_driver(ConvoyMPCwithStanley());
    ego(ii).veh.driver.perception_system = PerceptionSystem('ego', ii);
    ego(ii).veh.driver.perception_system.add_sensor(Sensor('radar', 1, ...
        [0;0],0,0,[],0.01,[-pi/4, pi/4],[0, 60]));
    ego(ii).veh.driver.set_simulation_environment(sim_env);
    % TODO: Add path to follow to the Ego vehicle
    %ego(ii).veh.driver.add_to_target_path(ego(ii).x0 + [1000.0; 0.0; 0.0; 0.0]);
end

%% Initialize exploration graphs of agent and ego vehicles.
for ii = 1:length(agent)
    agent(ii).G = ExplorationGraph(3, 'distance', @angled_distance);
    n_id = agent(ii).G.add_node(agent(ii).x0(1:3));
    vdata = TreeNodeData(agent(ii).x0);
    agent(ii).G.setvdata(n_id, vdata);
    configurations(1).agent_node(ii) = n_id; %#ok<*SAGROW>
end
for ii = 1:length(ego)
    ego(ii).G = ExplorationGraph(3, 'distance', @angled_distance);
    n_id = ego(ii).G.add_node(ego(ii).x0(1:3));
    vdata = TreeNodeData(ego(ii).x0);
    ego(ii).G.setvdata(n_id, vdata);
    configurations(1).ego_node(ii) = n_id;
end
configurations(1).end_time = 0;
configurations(1).cost = 10000;
configurations(1).cost_aux = {};
configurations(1).novelty = 0;

%% Search
r_i = 1;
while r_i < max_rrt_iter
    if mod(r_i, 10) == 0
        r_i
    end
    new_config_id = length(configurations) + 1;

    % Sample new points
    agent = random_sampler(random_sampler_opts, agent, ego);
    
    % Find the best previous configuration. (Best Neighbor)
    % TODO create a better metric to choose the best node in the graph.
    old_config_id = prev_config_finder(prev_config_finder_opts, ...
        configurations, agent, terminal_configs);
    start_time = configurations(old_config_id).end_time;
    
    % Find previous tree nodes
    best_v_agent = [];
    for ii = 1:length(agent)
        best_v_agent(ii) = configurations(old_config_id).agent_node(ii);
        if sign(abs(agent(ii).temp_target_path(3,1)) - pi/2) ~= sign(abs(agent(ii).G.vertexlist(3,best_v_agent(ii))) - pi/2)
            disp('different direction')
        end
    end
    best_v_ego = [];
    for ii = 1:length(ego)
        best_v_ego(ii) = configurations(old_config_id).ego_node(ii);
    end
       
    % Simulate vehicles.
    [agent_out, ego_out] = simulator(agent, ego, search_dt, best_v_agent, best_v_ego, sim_env, start_time);

    % Check Novelty.
    [is_novel, novelty, all_novelty] = novelty_checker.compute_novelty(ego_out, agent_out);
    % TODO: Stop search (mark as final config) if all agent and ego vehicles are on opposite
    % directions and passed each other (no hope for future collision).
    num_accepted_novelty = num_accepted_novelty + double(is_novel);
    num_rejected_novelty = num_rejected_novelty + double(~is_novel);
    if is_novel
        % Check if we will add the new node.
        % Corresponds to Transition Test in Transition-based RRT
        [cost, cost_aux] = immediate_cost_fnc(ego_out, agent_out);
        old_cost = configurations(old_config_id).cost;
        [transition_okay, transition_check_options] = transition_check_fnc(transition_check_options, old_cost, cost);
        num_accepted_transition = num_accepted_transition + double(transition_okay);
        num_rejected_transition = num_rejected_transition + double(~transition_okay);
        if transition_okay
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
                    newvdata.cur_time = agent(ii).G.vdata(best_v_agent(ii)).cur_time + search_dt;
                    agent(ii).G.setvdata(new_v, newvdata);
                    % Connect previous state with the new one.
                    agent(ii).G.add_edge(best_v_agent(ii), new_v);
                    configurations(new_config_id).agent_node(ii) = new_v;
                    if is_state_invalid(newvdata.x, agent(ii))
                        % We never set to "false" here because it may override a
                        % "true" that was set from another agent.
                        terminal_configs(new_config_id) = true;
                    end
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
                    newvdata.cur_time = ego(ii).G.vdata(best_v_ego(ii)).cur_time + search_dt;
                    ego(ii).G.setvdata(new_v, newvdata);
                    % Connect previous state with the new one.
                    ego(ii).G.add_edge(best_v_ego(ii), new_v);
                    configurations(new_config_id).ego_node(ii) = new_v;
                end
            end
            configurations(new_config_id).novelty = novelty;
            configurations(new_config_id).cost = cost;
            configurations(new_config_id).cost_aux = cost_aux;
            configurations(new_config_id).end_time = start_time + search_dt;
            config_history(end+1,:) = [old_config_id, new_config_id];
            r_i = r_i+1;
        end %transition check
    end %novelty check
    
       
    % TODO Check collisions and do necessary markings.
    % TODO: For more realistic simulations, simulate all vehicles together
    % and stop when they have a collision. Or at least check here and crop
    % the rest of the states from x_hist after a collision.
end
total_time_passed = toc;
