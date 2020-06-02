function [config_id] = find_best_config_behind_single_agent(options, configurations, agent, terminal_configs)
%find_best_config_behind Finds the best config to start from for the current
%sample.
    acceptables_all = [];
    for c_i = 1:length(configurations)
        if length(terminal_configs) >= c_i && terminal_configs(c_i)
            continue;
        end
        unacceptable = false;
        for a_i = options.anchor_agent
            node_i = configurations(c_i).agent_node(a_i);
            prev_x = agent(a_i).G.vertexlist(:,node_i);
            new_x = agent(a_i).temp_target_path(:, 1);
            
            if floor((wrapToPi(new_x(3) + pi/4) + pi) / (pi/2)) == ...
                    floor((wrapToPi(prev_x(3) + pi/4) + pi) / (pi/2))
                same_direction = true;
            else
                same_direction = false;
            end
            if norm(prev_x(1:2)) > 25 && ~same_direction
                % Not close to the intersection and on different roads.
                % Hardcoded that the intersection is at 0,0.
                unacceptable = true;
                break;
            end
                
            % Eliminate if direction difference is larger than 3*pi/4:
            if abs(wrapToPi(new_x(3) - prev_x(3))) > 0.75*pi
                unacceptable = true;
                break;
            end
            % If the wpt if not in front of the prev_x, eliminate.
            temp_ang = wrapToPi(atan2(new_x(2)-prev_x(2), new_x(1)-prev_x(1)) - prev_x(3));
            % In this case, we check if it is in front with a wide angle.
            if abs(wrapToPi(temp_ang)) > 3*pi/8
                unacceptable = true;
                break;
            end
            % In this case, we eliminate if the distance is short and angle
            % is large, which makes the maneuver very difficult.
            if abs(wrapToPi(temp_ang)) > pi/8 && norm(new_x(1:2) - prev_x(1:2)) < 10.0
                unacceptable = true;
                break;
            end
        end
        if unacceptable
            continue;
        end
        
        acceptables_all(end+1) = c_i; %#ok<AGROW>
    end
    
    if ~isempty(acceptables_all)
        %num_acceptables = numel(acceptables_all);
%         config_id = acceptables_all(randperm(num_acceptables, 1)); % Randomly select one.
        % Minimize total distance.
        min_dist = inf;
        config_id = 1;
        for acc_i = 1:length(acceptables_all)
            c_i = acceptables_all(acc_i);
            total_dist = 0;
            for a_i = options.anchor_agent
                node_i = configurations(c_i).agent_node(a_i);
                total_dist = total_dist + ...
                            norm(agent(a_i).G.vertexlist(1:2,node_i) - ...
                                agent(a_i).temp_target_path(1:2, 1));
            end
            if total_dist < min_dist
                min_dist = total_dist;
                config_id = c_i;
            end
        end
    else
        best_v = agent(options.anchor_agent).G.closest(agent(options.anchor_agent).temp_target_path(1:3, 1))
        for config_id = 1:length(configurations)
            if configurations(config_id).agent_node(options.anchor_agent) == best_v
                break;
            end
        end
    end
end

