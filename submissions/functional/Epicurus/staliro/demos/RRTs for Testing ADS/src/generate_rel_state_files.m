all_rel_states_rrt = [];
rrt_files_rel_states = cell(0);
path_to_files = '../log/';
rrt_list_files = dir([path_to_files, 'rrt_*.mat']);
num_zeros_rrt = zeros(length(rrt_list_files), 1);
x_min = -150;
x_max = 50;
y_min = -20;
y_max = 20;
temp_s = linspace(0,1,100);
xedges = x_min + temp_s*(x_max - x_min);
yedges = y_min + temp_s*(y_max - y_min);
disp('RRT files');
for file_i = 1:length(rrt_list_files)
    disp(file_i);
    rrt_files_rel_states{file_i} = [];
    fname = rrt_list_files(file_i).name;
    load([path_to_files, fname]);
    for c_i = 1:length(configurations)
        temp_rel_states = [];
        for e_i = 1:length(ego)
            ne_i = configurations(c_i).ego_node(e_i);
            if isempty(ego(e_i).G.vdata(ne_i).x_hist)
                continue;
            end
            for a_i = 1:length(agent)
                na_i = configurations(c_i).agent_node(a_i);
                temp_rel_states = [temp_rel_states, ...
                    agent(a_i).G.vdata(na_i).x_hist(:,1:4) - ego(e_i).G.vdata(ne_i).x_hist(:,1:4)];
            end
        end
        rrt_files_rel_states{file_i} = [rrt_files_rel_states{file_i}; temp_rel_states];
    end
    for c_i = 1:length(rejected_configurations)
        temp_rel_states = [];
        for e_i = 1:length(rejected_configurations(c_i).ego_node)
            ne_i = rejected_configurations(c_i).ego_node(e_i);
            if isempty(ego(e_i).rejectG.vdata(ne_i).x_hist)
                continue;
            end
            for a_i = 1:length(rejected_configurations(c_i).agent_node)
                na_i = rejected_configurations(c_i).agent_node(a_i);
                temp_rel_states = [temp_rel_states, ...
                    agent(a_i).rejectG.vdata(na_i).x_hist(:,1:4) - ego(e_i).rejectG.vdata(ne_i).x_hist(:,1:4)];
            end
        end
        rrt_files_rel_states{file_i} = [rrt_files_rel_states{file_i}; temp_rel_states];
    end
    rrt_files_rel_states{file_i} = rrt_files_rel_states{file_i}(1:10:end,:);
    all_rel_states_rrt = [all_rel_states_rrt; rrt_files_rel_states{file_i}];
end

disp('Falsification files');
all_rel_states_fals = [];
fals_files_rel_states = cell(0);
path_to_files = '../log/';
fals_list_files = dir([path_to_files, 'falsification_*.mat']);
for file_i = 1:length(fals_list_files)
    disp(file_i);
    fals_files_rel_states{file_i} = [];
    fname = fals_list_files(file_i).name;
    load([path_to_files, fname]);
    for h_i = 1:length(history.traj)
        traj = history.traj{h_i};
        fals_files_rel_states{file_i} = [fals_files_rel_states{file_i}; ...
            traj(:,6:9) - traj(:,1:4), traj(:,10:13) - traj(:,1:4)];
    end
    fals_files_rel_states{file_i} = fals_files_rel_states{file_i}(1:10:end, :);
    all_rel_states_fals = [all_rel_states_fals; fals_files_rel_states{file_i}];
end

%Compute min and max to normalize between 0 and 1
all_rel_states = [all_rel_states_rrt; all_rel_states_fals];
mins = min(all_rel_states, [], 1);
maxs = max(all_rel_states, [], 1);

% Write states to files
for file_i = 1:length(rrt_list_files)
    fname = rrt_list_files(file_i).name;
    
    rel_states = rrt_files_rel_states{file_i};
    rel_states = rel_states - mins;
    rel_states = rel_states ./ (maxs - mins);

    fileID = fopen(['../rel_states/', fname, '.dat'],'w');
    %fprintf(fileID,'%6.4f %6.4f %6.4f %6.4f\n',all_rel_states(:,1:4));
    fprintf(fileID,'%6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f\n',rel_states);
    fclose(fileID);
    %copyfile([fname, '.dat'], 'relstates.dat');
    %command = ['./HTGmain testDisc.par >> ', fname, '.txt'];
    %system(command);
end

% Write states to files
for file_i = 1:length(fals_list_files)
    fname = fals_list_files(file_i).name;
    
    rel_states = fals_files_rel_states{file_i};
    rel_states = rel_states - mins;
    rel_states = rel_states ./ (maxs - mins);

    fileID = fopen(['../rel_states/', fname, '.dat'],'w');
    %fprintf(fileID,'%6.4f %6.4f %6.4f %6.4f\n',all_rel_states(:,1:4));
    fprintf(fileID,'%6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f\n',rel_states);
    fclose(fileID);
    %copyfile([fname, '.dat'], 'relstates.dat');
    %command = ['./HTGmain testDisc.par >> ', fname, '.txt'];
    %system(command);
end
