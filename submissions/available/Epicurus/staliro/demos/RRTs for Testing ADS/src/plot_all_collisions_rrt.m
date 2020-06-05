for ff_i = 1:length(rrt_collision_in_final_trace_cases)
    load(['../log/',rrt_collision_in_final_trace_cases{ff_i}.fname]);
    find_final_configs;
    replay_simulation_in_webots;
    plot_trajectory_evolution(matlab_traj, ego, agent);
end