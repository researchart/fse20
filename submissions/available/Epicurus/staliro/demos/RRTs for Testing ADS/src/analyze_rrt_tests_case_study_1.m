path_to_files = '../log_case_study_1/';
rrt_analyze_costs = [];
file_name_pattern = 'rrtstar_*.mat';
rrtlist_files = dir([path_to_files, file_name_pattern]);
for file_i = 1:length(rrtlist_files)
    clear ego_collision_configs;
    loadfname = rrtlist_files(file_i).name;
    load([path_to_files, loadfname]);
    find_final_configs;
    rrt_analyze_costs = [rrt_analyze_costs, min_cost];
    final_ids(file_i) = final_config_id;
    sim_durations(file_i) = length_of_min_cost_scenario;
end

mean_cost = mean(rrt_analyze_costs);
min_cost = min(rrt_analyze_costs);
max_cost = max(rrt_analyze_costs);
mean_duration = mean(sim_durations);
min_duration = min(sim_durations);
max_duration = max(sim_durations);

disp('---------------------------------------------');
disp(['---------RRT EXPERIMENT RESULTS (CASE 1)-----']);
disp(['Analyzed folder: ', path_to_files]);
disp(['Analyzed files: ', file_name_pattern]);
disp(['Number of experiments: ', num2str(length(rrtlist_files))]);
disp(['Average simulation duration: ', num2str(mean_duration)]);
disp('-');
disp(['Minimum cost: ', num2str(min_cost)]);
disp(['Mean cost: ', num2str(mean_cost)]);
disp(['Maximum cost: ', num2str(max_cost)]);
disp('---------------------------------------------');
