traces_to_plot = 1:length(rrtlist_files);
traces_to_plot = [12];
traces_to_plot = small_cost_traces;
for ff_i = traces_to_plot
    load([rrtlist_files(ff_i).folder,'/',rrtlist_files(ff_i).name]);
    find_final_configs;
    replay_simulation_in_webots;
    plot_trajectory_evolution(matlab_traj, ego, agent);
end