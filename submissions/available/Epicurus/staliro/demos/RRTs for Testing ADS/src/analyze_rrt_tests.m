path_to_files = '../log/';
rrt_costs = [];
list_files = dir([path_to_files, 'rrt_*.mat']);
for file_i = 1:length(list_files)
    fname = list_files(file_i).name;
    load([path_to_files, fname]);
    find_final_configs;
    rrt_costs = [rrt_costs, min_cost];
    final_ids(file_i) = final_config_id;
    sim_durations(file_i) = length_of_min_cost_scenario;
end

mean_cost = mean(rrt_costs)
min_cost = min(rrt_costs)
max_cost = max(rrt_costs)
mean_duration = mean(sim_durations)
min_duration = min(sim_durations)
max_duration = max(sim_durations)
