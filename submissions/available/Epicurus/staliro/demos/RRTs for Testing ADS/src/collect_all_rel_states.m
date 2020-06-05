all_rel_states = [];
for c_i = 1:length(configurations)
    temp_rel_states = [];
    for e_i = 1:length(ego)
        ne_i = configurations(c_i).ego_node(e_i);
        if isempty(ego(e_i).G.vdata(ne_i).x_hist)
            continue;
        end
        for a_i = 1:length(agent)
            na_i = configurations(c_i).agent_node(a_i);
            temp_rel_states = [temp_rel_states, ...
                agent(a_i).G.vdata(na_i).x_hist(:,1:4) - ego(e_i).G.vdata(ne_i).x_hist(:,1:4)];
        end
    end
    all_rel_states = [all_rel_states; temp_rel_states];
end
