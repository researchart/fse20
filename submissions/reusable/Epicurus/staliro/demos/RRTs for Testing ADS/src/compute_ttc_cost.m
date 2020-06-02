function [cost, cost_aux] = compute_ttc_cost(ego_out, agent_out)
%compute_ttc_cost Compute the immediate cost based on TTC.
% Minimum TTC over all agents for the current simulation leg (from the last
% configuration to the new configuration) is the cost.
% cost_aux contains the all computed ttc for each agent.

% Assumptions: x_hist for all vehicles are of same length.

    % Populate ego orientations and corners for each time step in x_hist
    ego_orientations = cell(length(ego_out), 1);
    
    if ~isempty(ego_out)
        ego_corners = cell(length(ego_out), size(ego_out(1).veh.x_hist, 1));
    else
        ego_corners = {};
    end
    for e_i = 1:length(ego_out)
        ego_orientations{e_i} = ego_out(e_i).veh.x0(3) * ...
                ones(size(ego_out(e_i).veh.x_hist, 1), 1);
        ego_orientations{e_i}(1) = ego_out(e_i).veh.x0(3);  % Cell array of doubles
        % ego_corners: Cell array of cells that are 2xn arrays of doubles:
        ego_corners{e_i, 1} = ego_out(e_i).veh.get_corners(ego_out(e_i).veh.x0);
        for x_i = 1:size(ego_out(e_i).veh.x_hist, 1)
            ego_orientations{e_i}(x_i+1) = ego_out(e_i).veh.x_hist(x_i, 3);
            ego_corners{e_i, x_i+1} = ...
                ego_out(e_i).veh.get_corners(ego_out(e_i).veh.x_hist(x_i, :));
        end
    end
    
    % Populate agent corners for each time step in x_hist
    if ~isempty(agent_out)
        agent_corners = cell(length(agent_out), size(agent_out(1).veh.x_hist, 1));
    else
        agent_corners = {};
    end
    for a_i = 1:length(agent_out)
        % agent_corners: Cell array of cells that are 2xn arrays of doubles:
        agent_corners{a_i, 1} = agent_out(a_i).veh.get_corners(agent_out(a_i).veh.x0);
        for x_i = 1:size(agent_out(a_i).veh.x_hist, 1)
            agent_corners{a_i, x_i+1} = ...
                agent_out(a_i).veh.get_corners(agent_out(a_i).veh.x_hist(x_i, :));
        end
    end
    
    min_overall_ttc = 10000;
    ttc_list = cell(length(ego_out), length(agent_out));
    for e_i = 1:length(ego_out)
        for a_i = 1:length(agent_out)
            ttc_list{e_i, a_i} = 10000 * ones(size(ego_out(e_i).veh.x_hist, 1), 1);
            for x_i = 1:size(ego_out(e_i).veh.x_hist, 1)
                % Check if agent and ego are on a collision path:
                ego_old_orientation = ego_orientations{e_i}(x_i);
                ego_new_orientation = ego_orientations{e_i}(x_i+1);
                ego_old_corners = ego_corners{e_i, x_i};
                ego_new_corners = ego_corners{e_i, x_i+1};
                agent_old_corners = agent_corners{a_i, x_i};
                agent_new_corners = agent_corners{a_i, x_i+1};
                is_coll_path = check_collision_path(ego_new_orientation, ...
                    ego_old_orientation, ego_new_corners, ego_old_corners, ...
                    agent_new_corners, agent_old_corners);
                % Compute TTC between ego and agent:
                if is_coll_path
                    ego_p = [ego_out(e_i).veh.x_hist(x_i, 1);
                             ego_out(e_i).veh.x_hist(x_i, 2)];
                    agent_p = [agent_out(a_i).veh.x_hist(x_i, 1);
                               agent_out(a_i).veh.x_hist(x_i, 2)];
                    ego_v = ego_out(e_i).veh.x_hist(x_i, 4) * ...
                            [cos(ego_out(e_i).veh.x_hist(x_i, 3)); ...
                             sin(ego_out(e_i).veh.x_hist(x_i, 3))];
                    agent_v = agent_out(a_i).veh.x_hist(x_i, 4) * ...
                              [cos(agent_out(a_i).veh.x_hist(x_i, 3)); ...
                               sin(agent_out(a_i).veh.x_hist(x_i, 3))];
                    ttc = compute_TTC(ego_p, agent_p, ego_v, agent_v);
                else
                    ttc = 10000;
                end
                ttc_list{e_i, a_i}(x_i) = ttc;
                if ttc < min_overall_ttc
                    min_overall_ttc = ttc;
                end
            end
        end
    end

    cost = min_overall_ttc;
    cost_aux = ttc_list;
end

