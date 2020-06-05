all_rel_states_rrt = [];
path_to_files = '../log/';
list_files = dir([path_to_files, 'rrt_*.mat']);
num_zeros_rrt = zeros(length(list_files), 1);
x_min = -150;
x_max = 50;
y_min = -20;
y_max = 20;
temp_s = linspace(0,1,100);
xedges = x_min + temp_s*(x_max - x_min);
yedges = y_min + temp_s*(y_max - y_min);

for file_i = 1:length(list_files)
    file_rel_states = [];
    fname = list_files(file_i).name;
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
        file_rel_states = [file_rel_states; temp_rel_states];
    end
    [N] = histcounts2(file_rel_states(:,1),file_rel_states(:,2),xedges,yedges);
    num_zeros_rrt(file_i) = nnz(~N);
    all_rel_states_rrt = [all_rel_states_rrt; file_rel_states];
end
[N] = histcounts2(all_rel_states_rrt(:,1),all_rel_states_rrt(:,2),xedges,yedges);
overall_num_zeros = nnz(~N);