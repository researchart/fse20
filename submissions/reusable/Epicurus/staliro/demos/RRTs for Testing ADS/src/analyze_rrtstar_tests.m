path_to_files = '../log/';
rrtstar_analyze_costs = [];
rrtlist_files = dir([path_to_files, 'rrtstar_many_cars_*.mat']);
for file_i = 1:length(rrtlist_files)
    loadfname = rrtlist_files(file_i).name;
    load([path_to_files, loadfname]);
    find_final_configs;
    rrtstar_analyze_costs = [rrtstar_analyze_costs, min_cost];
    final_ids(file_i) = final_config_id;
    sim_durations(file_i) = length_of_min_cost_scenario;
end

mean_cost = mean(rrtstar_analyze_costs)
min_cost = min(rrtstar_analyze_costs)
max_cost = max(rrtstar_analyze_costs)
mean_duration = mean(sim_durations)
min_duration = min(sim_durations)
max_duration = max(sim_durations)
