find_final_configs;
end_times = zeros(1, length(final_configs));
for f_i = 1:length(final_configs)
    end_times(f_i) = configurations(final_configs(f_i)).end_time;
end
[max_end_time, et_ix] = max(end_times);
max_end_time
final_config_id = final_configs(et_ix)

