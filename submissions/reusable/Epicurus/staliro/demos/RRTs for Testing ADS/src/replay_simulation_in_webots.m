%replay_simulation_in_webots Animate already executed simulation from start to the
%final config given in final_config_id

num_of_vehicles = length(agent) + length(ego);
time_step = search_dt;
if ~isempty(ego)
    follow_vhc_ind = 0;
    time_step = ego(1).veh.dt;
else
    follow_vhc_ind = 0;
    if ~isempty(agent)
       time_step = agent(1).veh.dt;
    end
end
follow_height = 100;
vehicle_model_ids = 5*ones(num_of_vehicles,1);
x_pos_ind = 0;
y_pos_ind = 1;
theta_ind = 2;
num_states_per_vhc = 3;

[traj, matlab_traj, full_traj, config_trace] = get_traj_for_webots(configurations, final_config_id, config_history, ego, agent);
cost_hist = get_cost_history_for_webots(final_config_id, config_history, ego, agent, configurations);

if ispc
    target_dest = 'D:/git_repos/sim-atav-assembla/Webots_Projects/controllers/replay_matlab_trace/matlab_trajectory.mat';
else
    target_dest = '/Users/erkan/git_repos/sim-atav_public/Webots_Projects/controllers/replay_matlab_trace/matlab_trajectory.mat';
end

save(target_dest, 'num_of_vehicles', 'follow_vhc_ind', ...
    'time_step', 'follow_height', 'vehicle_model_ids', 'x_pos_ind', ...
    'y_pos_ind', 'theta_ind', 'num_states_per_vhc', 'traj', 'cost_hist');
