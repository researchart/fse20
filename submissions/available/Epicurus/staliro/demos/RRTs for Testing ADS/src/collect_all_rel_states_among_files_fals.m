all_rel_states = [];
path_to_files = '../log/';
list_files = dir([path_to_files, 'falsification_*.mat']);
for file_i = 1:length(list_files)
    fname = list_files(file_i).name;
    load([path_to_files, fname]);
    for h_i = 1:length(history)
        traj = history(h_i).traj;
        temp_rel_states = [traj(:,6:9) - traj(:,1:4), ...
            traj(:,10:13) - traj(:,1:4)];
        all_rel_states = [all_rel_states; temp_rel_states];
    end
end
