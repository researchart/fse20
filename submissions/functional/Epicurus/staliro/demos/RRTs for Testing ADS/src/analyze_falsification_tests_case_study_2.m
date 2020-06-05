path_to_files = '../log/';
file_name_pattern = 'falsification_many_cars_*.mat';
fals_list_files = dir([path_to_files, file_name_pattern]);
falsification_costs = [];
all_fals_traj = [];
fals_interesting_cases = cell(0);
for file_i = 1:length(fals_list_files)
    floadfname = fals_list_files(file_i).name;
    load([path_to_files, floadfname]);
    falsification_costs = [falsification_costs, results.run.bestCost];
    best_ind = find(history.cost == results.run.bestCost, 1);
    assert(~isempty(best_ind), 'Best experiment could not be found');

    XT = history.traj{best_ind};
    all_fals_traj = [all_fals_traj; XT];
    if ~isempty(find(XT(:,7)<1.75))
        fals_interesting_cases{end+1}.file_index = file_i;
        fals_interesting_cases{end}.fname = floadfname;
    end
end

mean_cost = mean(falsification_costs);
min_cost = min(falsification_costs);
max_cost = max(falsification_costs);

disp('---------------------------------------------');
disp(['-------FALSIFICATION EXPERIMENT RESULTS------']);
disp(['Analyzed folder: ', path_to_files]);
disp(['Analyzed files: ', file_name_pattern]);
disp(['Number of experiments: ', num2str(length(fals_list_files))]);
disp(['Simulation duration: ', num2str(time)]);
disp('-');
disp(['Minimum cost: ', num2str(min_cost)]);
disp(['Mean cost: ', num2str(mean_cost)]);
disp(['Maximum cost: ', num2str(max_cost)]);
disp('-');
disp(['Number of cases Agent 1 was able to move into Ego lane: ',num2str(length(fals_interesting_cases))]);
disp(['Number of cases with cost less than 10: ',num2str(length(find(falsification_costs<10)))]);
disp('You should manually check collisions for the files in fals_interesting_cases!!!');
disp('---------------------------------------------');