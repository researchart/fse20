function [traj, matlab_traj, full_traj, config_trace] = get_traj_for_webots(configurations, final_config_id, config_history, ego, agent)
%get_traj_for_webots Get trajectory in the format to replay in Webots.
% In the test generation framework, x is to the right, y is to the north,
% 0 angle is toward right (along x axis).
% However, in Webots, x is to the left, z is used instead of y, and 0 angle
% is toward north.
config_trace = [];

cur_conf = final_config_id;
while ~isempty(cur_conf)
    config_trace = [cur_conf;config_trace]; %#ok<AGROW>
    prev_ind = find(config_history(:,2) == cur_conf, 1);
    cur_conf = config_history(prev_ind,1);
end

matlab_traj = [];
if nargout > 2
    full_traj = [];
end
traj = [];
for c_i = 1:length(config_trace)
    traj_temp = [];
    matlab_traj_temp = [];
    full_traj_temp = [];
    for ii = 1:length(ego)
        node_i = configurations(config_trace(c_i)).ego_node(ii);
        vdata = ego(ii).G.vdata(node_i);
        if ~isempty(vdata.x_hist)
            traj_temp = [traj_temp, convert_x_to_webots(vdata.x_hist)];
            matlab_traj_temp = [matlab_traj_temp, vdata.x_hist(:,1:3)];
            full_traj_temp = [full_traj_temp, vdata.x_hist];
        else
            traj_temp = [traj_temp, convert_x_to_webots(vdata.x')];
            matlab_traj_temp = [matlab_traj_temp, vdata.x(1:3)'];
            full_traj_temp = [full_traj_temp, vdata.x'];
        end
    end
    for ii = 1:length(agent)
        node_i = configurations(config_trace(c_i)).agent_node(ii);
        vdata = agent(ii).G.vdata(node_i);
        if ~isempty(vdata.x_hist)
            traj_temp = [traj_temp, convert_x_to_webots(vdata.x_hist)];
            matlab_traj_temp = [matlab_traj_temp, vdata.x_hist(:,1:3)];
            full_traj_temp = [full_traj_temp, vdata.x_hist];
        else
            traj_temp = [traj_temp, convert_x_to_webots(vdata.x')];
            matlab_traj_temp = [matlab_traj_temp, vdata.x(1:3)'];
            full_traj_temp = [full_traj_temp, vdata.x'];
        end
    end
    traj = [traj;traj_temp];
    matlab_traj = [matlab_traj;matlab_traj_temp];
    if nargout > 2
        full_traj = [full_traj; full_traj_temp];
    end
end

end
