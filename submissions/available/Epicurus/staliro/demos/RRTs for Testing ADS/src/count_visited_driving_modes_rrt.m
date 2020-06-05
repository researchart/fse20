path_to_files = '../log/';
rrt_location_count = {};
list_files = dir([path_to_files, 'rrt_*.mat']);
for file_i = 1:length(list_files)
    fname = list_files(file_i).name;
    load([path_to_files, fname]);
    locs = zeros(1,7);
    for c_i = 1:length(configurations)
        n_i = configurations(c_i).ego_node(1);
        vdata = ego(1).G.vdata(n_i);
        if ~isempty(vdata.controller_state) && ~isempty(vdata.controller_state.driving_mode_history)
            mode_hist = vdata.controller_state.driving_mode_history;
            for l_i = 1:size(mode_hist)
                locs(mode_hist(l_i)) = locs(mode_hist(l_i)) + 1;
            end
        end
    end
    rrt_location_count{file_i} = locs;
    disp(locs);
end
