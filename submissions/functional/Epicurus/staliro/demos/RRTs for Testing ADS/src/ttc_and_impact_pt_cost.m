function [cost, cost_aux] = ttc_and_impact_pt_cost(ego_out, agent_out, sim_env, start_time)
%ttc_and_impact_pt_cost Compute the immediate cost based on TTC, (expected)
% collision speed and (expected) collision impact point.
% Minimum TTC over all agents for the current simulation leg (from the last
% configuration to the new configuration) is the cost.
% cost_aux contains the all computed ttc for each agent.

% Assumptions: x_hist for all vehicles are of same length.

    % Populate ego orientations and corners for each time step in x_hist
    ego_orientations = cell(length(ego_out), 1);
    ego_corners = cell(length(ego_out), 1);
    for e_i = 1:length(ego_out)
        ego_orientations{e_i} = ego_out(e_i).veh.get_orientations_hist();
        ego_corners{e_i} = ego_out(e_i).veh.get_corners_hist();
    end
    
    % Populate agent corners for each time step in x_hist
    agent_corners = cell(length(agent_out), 1);
    for a_i = 1:length(agent_out)
        agent_corners{a_i} = agent_out(a_i).veh.get_corners_hist();
    end
    
    min_overall_ttc = 10000;
    min_overall_cost = inf;
    ttc_list = cell(length(ego_out), length(agent_out));
    cost_list = cell(length(ego_out), length(agent_out));
    for e_i = 1:length(ego_out)
        for a_i = 1:length(agent_out)
            ttc_list{e_i, a_i} = 10000 * ones(size(ego_out(e_i).veh.x_hist, 1), 1);
            for x_i = 1:size(ego_out(e_i).veh.x_hist, 1)
                % Check if agent and ego are on a collision path:
                ego_old_orientation = ego_orientations{e_i}(x_i);
                ego_new_orientation = ego_orientations{e_i}(x_i+1);
                ego_old_corners = ego_corners{e_i}{x_i};
                ego_new_corners = ego_corners{e_i}{x_i+1};
                agent_old_corners = agent_corners{a_i}{x_i};
                agent_new_corners = agent_corners{a_i}{x_i+1};
                is_coll = false;
                for coll_i = 1:length(sim_env.collisions)
                    if sim_env.collisions(coll_i).ego == e_i && ...
                        sim_env.collisions(coll_i).agent == a_i && ...
                        abs(sim_env.collisions(coll_i).time - (start_time + x_i*ego_out(e_i).veh.dt)) < ego_out(e_i).veh.dt/2
                        is_coll = true;
                    end
                end
                [is_coll_path, is_approaching, impact_pt] = ...
                    check_collision_path(ego_new_orientation, ...
                    ego_old_orientation, ego_new_corners, ego_old_corners, ...
                    agent_new_corners, agent_old_corners);
                % Compute TTC between ego and agent:
                if is_coll_path || is_coll
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
                    [ttc, v_c] = compute_TTC(ego_p, agent_p, ego_v, agent_v, true);
                    if is_coll
                        ttc = 0;
                    end
                else
                    impact_pt = 1;
                    ttc = 10000;
                    v_c = 10000;
                end
                ttc_list{e_i, a_i}(x_i) = ttc;
                if ttc >= 0 && ttc < min_overall_ttc
                    min_overall_ttc = ttc;
                end
                
                cost = (1+impact_pt)*(v_c^2 + ttc^2);
                cost_list{e_i, a_i}(x_i) = cost;
                if cost < min_overall_cost
                    min_overall_cost = cost;
                end
            end
        end
    end

    cost = min_overall_cost;
    cost_aux = cost_list;
end

