function cost_hist = get_cost_history_for_webots(final_config_id, config_history, ego, agent, configurations)
%get_cost_history_for_webots Get trajectory in the format to replay in Webots.
config_trace = [];

cur_conf = final_config_id;
while ~isempty(cur_conf)
    config_trace = [cur_conf;config_trace]; %#ok<AGROW>
    prev_ind = find(config_history(:,2) == cur_conf, 1);
    cur_conf = config_history(prev_ind,1);
end

cost_hist = [];
for c_i = 1:length(config_trace)
    temp_cost_hist = configurations(config_trace(c_i)).cost_aux;
    temp = [];
    if ~isempty(temp_cost_hist)
        for e_i = 1:size(temp_cost_hist, 1)
            for a_i = 1:size(temp_cost_hist, 2)
                temp((e_i-1)*length(agent) + a_i, :) = temp_cost_hist{e_i, a_i};
            end
        end
    end
    cost_hist = [cost_hist, temp];
end

end

