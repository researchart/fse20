if ~isempty(config_history)
    final_configs = setdiff(config_history(:,2), config_history(:,1));
    min_costs = inf*ones(length(final_configs), 1);
    end_times = [configurations(final_configs).end_time]';
    for f_i = 1:length(final_configs)
        last_config = final_configs(f_i);
        last_cost = configurations(last_config).cost;
        if last_cost < min_costs(f_i)
            min_costs(f_i) = last_cost;
        end
        while last_config > 1
            row_i = find(config_history(:,2) == last_config);
            if ~isempty(row_i)
                last_config = config_history(row_i,1);
                last_cost = configurations(last_config).cost;
                if last_cost < min_costs(f_i)
                    min_costs(f_i) = last_cost;
                end
            else
                break
            end
        end
    end
    last_configs_with_costs_and_end_times = [final_configs, min_costs, end_times];
    [min_cost, m_ind] = min(last_configs_with_costs_and_end_times(:,2));
    min_cost
    min_cost_config_ind = last_configs_with_costs_and_end_times(m_ind,1)
    length_of_min_cost_scenario = configurations(min_cost_config_ind).end_time
    final_config_id = min_cost_config_ind
else
    min_cost = inf;
    final_config_id = 0;
    length_of_min_cost_scenario = 0;
end