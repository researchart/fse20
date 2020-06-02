path_to_files = '../log/';
rrtstar_analyze_costs = [];
file_name_pattern = 'rrtstar_many_cars_*.mat';
rrtlist_files = dir([path_to_files, file_name_pattern]);
all_rrtstar_traj = [];
rrt_interesting_cases = cell(0);
rrt_collision_cases = cell(0);
rrt_collision_in_final_trace_cases = cell(0);
rrt_manual_collision_check_files = cell(0);
for file_i = 1:length(rrtlist_files)
    clear ego_collision_configs;
    loadfname = rrtlist_files(file_i).name;
    load([path_to_files, loadfname]);
    find_final_configs;
    rrtstar_analyze_costs = [rrtstar_analyze_costs, min_cost];
    final_ids(file_i) = final_config_id;
    sim_durations(file_i) = length_of_min_cost_scenario;
    [~, matlab_traj, ~, config_trace] = get_traj_for_webots(configurations, final_config_id, config_history, ego, agent);
    all_rrtstar_traj = [all_rrtstar_traj; matlab_traj];
    if ~isempty(find(matlab_traj(:,5)<1.75)) %Agent 1 passes below 3.5 in y-axis.
        rrt_interesting_cases{end+1}.file_index = file_i;
        rrt_interesting_cases{end}.fname = loadfname;
    end
    try
        if ~isempty(intersect(ego_collision_configs, config_trace))
            rrt_collision_in_final_trace_cases{end+1}.file_index = file_i;
            rrt_collision_in_final_trace_cases{end}.fname = loadfname;
        end
        if ~isempty(ego_collision_configs)
            rrt_collision_cases{end+1}.file_index = file_i;
            rrt_collision_cases{end}.fname = loadfname;
        end
    catch
        rrt_manual_collision_check_files{end+1} = loadfname;
    end
end

mean_cost = mean(rrtstar_analyze_costs);
min_cost = min(rrtstar_analyze_costs);
max_cost = max(rrtstar_analyze_costs);
mean_duration = mean(sim_durations);
min_duration = min(sim_durations);
max_duration = max(sim_durations);

disp('---------------------------------------------');
disp(['---------RRT* EXPERIMENT RESULTS-------------']);
disp(['Analyzed folder: ', path_to_files]);
disp(['Analyzed files: ', file_name_pattern]);
disp(['Number of experiments: ', num2str(length(rrtlist_files))]);
disp(['Average simulation duration: ', num2str(mean_duration)]);
disp('-');
disp(['Minimum cost: ', num2str(min_cost)]);
disp(['Mean cost: ', num2str(mean_cost)]);
disp(['Maximum cost: ', num2str(max_cost)]);
disp('-');
disp(['Number of cases Agent 1 was able to move into Ego lane: ',num2str(length(rrt_interesting_cases))]);
disp(['Number of cases Ego had a collision: ',num2str(length(rrt_collision_cases))]);
disp(['Number of cases Ego had a collision in the minimum cost trace: ',num2str(length(rrt_collision_in_final_trace_cases))]);
disp(['Number of cases with cost less than 10: ',num2str(length(find(rrtstar_analyze_costs<10)))]);
if ~isempty(rrt_manual_collision_check_files)
    disp('You should manually check collisions for the files in rrt_manual_collision_check_files!!!');
end
disp('---------------------------------------------');
