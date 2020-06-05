clear all
close all

path_to_files = '../log/';
list_files = dir([path_to_files, 'falsification_*.mat']);
for file_i = 1:length(list_files)
    fname = list_files(file_i).name;
    load([path_to_files, fname]);
    
    clearvars -except temp_t file_i list_files path_to_files
    rng(int32(temp_t.Hour*10000+temp_t.Minute*100+temp_t.Second));
    try
        rrt_many_cars;
    catch e %e is an MException struct
        fprintf(1,'The identifier was:\n%s',e.identifier);
        fprintf(1,'There was an error! The message was:\n%s',e.message);
    end
end
