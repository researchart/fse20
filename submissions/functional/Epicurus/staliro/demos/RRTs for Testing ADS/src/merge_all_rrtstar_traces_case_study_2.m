
path_to_files = '../log/';
rrtstarlist_files = dir([path_to_files, 'rrtstar_many_cars_*.mat']);
all_rrtstar_traj = [];
interestings = cell(0);
for rfile_i = 1:length(rrtstarlist_files)
    loadfname = rrtstarlist_files(rfile_i).name;
    load([path_to_files, loadfname]);
    find_final_configs;

    [~, matlab_traj] = get_traj_for_webots(configurations, final_config_id, config_history, ego, agent);
    all_rrtstar_traj = [all_rrtstar_traj; matlab_traj];
    if ~isempty(find(matlab_traj(:,5)<3.5))
        rfile_i
        interestings{end+1} = loadfname;
    end
end

