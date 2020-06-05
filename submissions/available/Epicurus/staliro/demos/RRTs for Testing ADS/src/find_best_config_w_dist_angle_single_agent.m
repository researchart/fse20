function [config_id] = find_best_config_w_dist_angle_single_agent(options, configurations, agent, terminal_configs)
%find_best_config_w_dist_angle Finds the best config to start from for the current
%sample using distance and angle.
    if isfield(options, 'num_minimum') && ~isempty(options.num_minimum)
        k = options.num_minimum;
    else
        k = 1;
    end
    acceptables_all = [];
    for c_i = 1:length(configurations)
        if length(terminal_configs) < c_i || ~terminal_configs(c_i)
            config_ok = true;
            for ii = 1:options.anchor_agent
                angle1 = agent(ii).temp_target_path(3, 1);
                n_id = configurations(c_i).agent_node(ii);
                angle2 = agent(ii).G.vertexlist(3,n_id);
                if sign(abs(angle1) - pi/2) ~= sign(abs(angle2) - pi/2)
                    config_ok = false;
                    break;
                else
                    if (sign(abs(angle2) - pi/2) < 0 && agent(ii).G.vertexlist(1,n_id) > agent(ii).temp_target_path(1, 1)) || ...
                        (sign(abs(angle2) - pi/2) > 0 && agent(ii).G.vertexlist(1,n_id) < agent(ii).temp_target_path(1, 1))
                        config_ok = false;
                        break;
                    end
                end
            end
            if config_ok
                acceptables_all(end+1) = c_i; %#ok<AGROW>
            end
        end
    end
    
    if ~isempty(acceptables_all)
        %num_acceptables = numel(acceptables_all);
%         config_id = acceptables_all(randperm(num_acceptables, 1)); % Randomly select one.
        % Minimize total distance.
        all_dist = zeros(length(acceptables_all), 1);
        for acc_i = 1:length(acceptables_all)
            c_i = acceptables_all(acc_i);
            for a_i = 1:options.anchor_agent
                node_i = configurations(c_i).agent_node(a_i);
                all_dist(acc_i) = all_dist(acc_i) + ...
                    norm(agent(a_i).G.vertexlist(1:2,node_i) - agent(a_i).temp_target_path(1:2, 1));
            end
        end
        if k == 1
            [~, best_acc_i] = min(all_dist);
            config_id = acceptables_all(best_acc_i);
        else
            [~, best_acc_i] = mink(all_dist,k);
            config_id = acceptables_all(best_acc_i);
        end
    else
        best_v = agent(options.anchor_agent).G.closest(agent(options.anchor_agent).temp_target_path(1:3, 1));
        for config_id = 1:length(configurations)
            if configurations(config_id).agent_node(options.anchor_agent) == best_v
                break;
            end
        end
    end
end

