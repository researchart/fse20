inpArray = results.run.bestSample;
dimX = size(init_cond,1);

XPoint = inpArray(1:dimX);
UPoint = inpArray(dimX+1:end);
stepTime = [0:opt.SampTime:time];

nb_ContPoints = [10, 20, 30, 40]; %incremental

InpSignal = ComputeInputSignals(stepTime, UPoint, opt.interpolationtype, nb_ContPoints, input_range, time, 1);

[T, XT, YT, LT,CLG,GRD] = model_test_case_1(XPoint, time, stepTime, InpSignal);
traj = XT(:,[1:3,6:8,10:12]);
traj(:,1:3) = convert_x_to_webots(traj(:,1:3));
traj(:,4:6) = convert_x_to_webots(traj(:,4:6));
traj(:,7:9) = convert_x_to_webots(traj(:,7:9));

num_of_vehicles = 3;
follow_vhc_ind = 0;
time_step = 0.01;
follow_height = 100;
vehicle_model_ids = 5*ones(num_of_vehicles,1);
x_pos_ind = 0;
y_pos_ind = 1;
theta_ind = 2;
num_states_per_vhc = 3;
if ispc
    target_dest = 'D:/git_repos/sim-atav-assembla/Webots_Projects/controllers/replay_matlab_trace/matlab_trajectory.mat';
else
    target_dest = '/Users/erkan/git_repos/sim-atav_public/Webots_Projects/controllers/replay_matlab_trace/matlab_trajectory.mat';
end

save(target_dest, 'num_of_vehicles', 'follow_vhc_ind', ...
    'time_step', 'follow_height', 'vehicle_model_ids', 'x_pos_ind', ...
    'y_pos_ind', 'theta_ind', 'num_states_per_vhc', 'traj');
