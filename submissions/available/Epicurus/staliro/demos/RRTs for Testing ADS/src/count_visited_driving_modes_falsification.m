path_to_files = '../log/';
fals_location_count = {};
list_files = dir([path_to_files, 'falsification_*.mat']);
for file_i = 1:length(list_files)
    fname = list_files(file_i).name;
    load([path_to_files, fname]);
    locs = zeros(1,7);
    for h_i = 1:length(history.hs)
        for l_i = 1:size(history.hs{h_i}.LT,1)
            locs(history.hs{h_i}.LT(l_i)) = locs(history.hs{h_i}.LT(l_i)) + 1;
        end
    end
    fals_location_count{file_i} = locs;
    disp(locs);
end
