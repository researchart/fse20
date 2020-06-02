path_to_files = '../log/';
list_files = dir([path_to_files, 'falsification_many_cars_*.mat']);
falsification_costs = [];
for file_i = 1:length(list_files)
    fname = list_files(file_i).name;
    load([path_to_files, fname]);
    %find_final_configs;
    falsification_costs = [falsification_costs, results.run.bestCost];
    %final_ids(file_i) = final_config_id;
    %sim_durations(file_i) = length_of_min_cost_scenario;
end

mean_cost = mean(falsification_costs)
min_cost = min(falsification_costs)
max_cost = max(falsification_costs)
%mean_duration = mean(sim_durations)
%min_duration = min(sim_durations)
%max_duration = max(sim_durations)
