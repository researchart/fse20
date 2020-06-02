path_to_files = '../rel_states/';
rrt_list_files = dir([path_to_files, 'rrt_*.dat']);
fals_list_files = dir([path_to_files, 'falsification_*.dat']);

for file_i = 1:length(rrt_list_files)
    if length(fals_list_files) < file_i
        break;
    end
    
    datetime
    
    fname = rrt_list_files(file_i).name;
    disp(['Working on: ', fname]);
    copyfile([path_to_files, fname], 'sample/relstates.dat');
    system(['./HTGmain testDisc.par >> ', fname,'.out']);
    
    fname = fals_list_files(file_i).name;
    disp(['Working on: ', fname]);
    copyfile([path_to_files, fname], 'sample/relstates.dat');
    system(['./HTGmain testDisc.par >> ', fname,'.out']);
end