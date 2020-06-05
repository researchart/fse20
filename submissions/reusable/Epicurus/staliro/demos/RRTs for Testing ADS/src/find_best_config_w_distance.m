function [config_id] = find_best_config_w_distance(options, configurations, agent, terminal_configs)
%find_best_config_w_distance Finds the best config to start from for the current
%sample.
    acceptables_all = [];
    for c_i = 1:length(configurations)
        if length(terminal_configs) < c_i || ~terminal_configs(c_i)
            acceptables_all(end+1) = c_i; %#ok<AGROW>
        end
    end
    
    if ~isempty(acceptables_all)
        %num_acceptables = numel(acceptables_all);
%         config_id = acceptables_all(randperm(num_acceptables, 1)); % Randomly select one.
        % Minimize total distance.
        all_dist = zeros(length(acceptables_all), 1);
        for acc_i = 1:length(acceptables_all)
            c_i = acceptables_all(acc_i);
            for a_i = 1:length(agent)
                node_i = configurations(c_i).agent_node(a_i);
                all_dist(acc_i) = all_dist(acc_i) + ...
                    norm(agent(a_i).G.vertexlist(1:2,node_i) - agent(a_i).temp_target_path(1:2, 1));
            end
        end

        [~, best_acc_i] = min(all_dist);
        config_id = acceptables_all(best_acc_i);
    else
        best_v = agent(options.anchor_agent).G.closest(agent(options.anchor_agent).temp_target_path(1:3, 1));
        for config_id = 1:length(configurations)
            if configurations(config_id).agent_node(options.anchor_agent) == best_v
                break;
            end
        end
    end
end

