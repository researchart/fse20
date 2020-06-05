path_to_files = '../log/';
list_files = dir([path_to_files, 'rrt_2019214*.mat']);
rrt_all_rel_states = cell(0);
collisions = zeros(length(list_files), 1);
for file_i = 1:length(list_files)
    fname = list_files(file_i).name;
    load([path_to_files, fname]);
    find_final_configs;
    try
        [~, matlab_traj] = get_traj_for_webots(configurations, final_config_id, config_history, ego, agent);
    catch
        disp('err');
    end
    rrt_all_rel_states{file_i, 1} = matlab_traj(:,4:5) - matlab_traj(:,1:2);
    if check_collisions(ego(1).veh, agent(1).veh, matlab_traj(end,1:3), matlab_traj(end,4:6))
        collisions(file_i) = 1;
    end
    rrt_all_rel_states{file_i, 2} = matlab_traj(:,7:8) - matlab_traj(:,1:2);
    if check_collisions(ego(1).veh, agent(2).veh, matlab_traj(end,1:3), matlab_traj(end,7:9))
        collisions(file_i) = 2;
    end
end

figure
for file_i = 1:length(list_files)
    if collisions(file_i) == 1
        plot(rrt_all_rel_states{file_i, 1}(:,1), rrt_all_rel_states{file_i, 1}(:,2), 'r');
    end
    hold on;
    if collisions(file_i) == 2
        plot(rrt_all_rel_states{file_i, 2}(:,1), rrt_all_rel_states{file_i, 1}(:,2), 'b');
    end
    hold on;
end

figure
for file_i = 1:length(list_files)
    if collisions(file_i) == 1
        plot(rrt_all_rel_states{file_i, 1}(end,1), rrt_all_rel_states{file_i, 1}(end,2), 'r.');
    end
    hold on;
    if collisions(file_i) == 2
        plot(rrt_all_rel_states{file_i, 2}(end,1), rrt_all_rel_states{file_i, 1}(end,2), 'b.');
    end
    hold on;
end


function [is_coll] = check_collisions(ego_veh, agent_veh, ego_x, agent_x)
    %check_collision Checks is there is a collision between vehicles.
    is_coll = false;
    % There cannot be a collision if the distance between
    % vehicles is larger than 8m.
    if norm(ego_x(1:2) - agent_x(1:2)) < 8
        % TODO: We can save and reuse polyhedron for performance.
        eP = Polyhedron(ego_veh.get_corners(ego_x)');
        aP = Polyhedron(agent_veh.get_corners(agent_x)');
        iP = intersect(eP, aP);
        if ~iP.isEmptySet()
            is_coll = true;
        end
    end
end