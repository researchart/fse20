Starting point for case study 1:
- run_case_study_1_rrtstar_vs_falsification_indefinitely

Starting point for case study 2:
- run_case_study_2_rrtstar_vs_falsification_indefinitely

Analyzing Case Study 1 results:
- generate_box_plot_for_paper_case_study_1

Analyzing Case Study 2 results:
- generate_box_plot_for_paper_case_study_2

Visualizing an RRT(*) best result in Webots:
- find_final_configs   (This will search for the best result)
- replay_simulation_in_webots  (This will create a trajectory to replay in Sim-ATAV)
- In Webots: Start replay_matlab_world_empty.wbt from Sim-ATAV distribution

Visualizing Falsification best result in Webots for Case Study 1:
- (option 1) replay_case_study_1_falsification_result_from_history  (This will use the trajectory saved in the history for the modified S-Taliro)
- (option 2) If you don't have modified S-Taliro (or trajectories in the history), a longer solution: replay_case_study_1_falsification_result
- In Webots: Start replay_matlab_world_empty.wbt from Sim-ATAV distribution

Visualizing Falsification best result in Webots for Case Study 2:
- (option 1) replay_case_study_2_falsification_result_from_history  (This will use the trajectory saved in the history for the modified S-Taliro)
- (option 2) If you don't have modified S-Taliro (or trajectories in the history), a longer solution: replay_case_study_2_falsification_result
- In Webots: Start replay_matlab_world_empty.wbt from Sim-ATAV distribution

Plot Vehicle Trajectories in Matlab:
- plot_trajectory_evolution_falsification_case_study_1
- plot_trajectory_evolution_falsification_case_study_2
- plot_trajectory_evolution_rrtstar_case_study_1
- plot_trajectory_evolution_rrtstar_case_study_2

Visualizing simulation in Webots step-by-step:
This is for debugging the controller etc. at every simulation time step, configuration is displayed in Webots and by putting break points in the Matlab code, you can do debugging.
- Open empty_world in Webots
- Run simulate_vehicles with visualize_webots argument set to true.

Notes:
- In the code, I used to use "many_cars" for the case study 2. Any left over file/code that contains many_cars should be for experimenting something on case study 2.

enjoy!
Erkan
