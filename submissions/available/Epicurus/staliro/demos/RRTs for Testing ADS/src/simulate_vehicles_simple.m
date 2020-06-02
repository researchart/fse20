function [agent_out, ego_out] = simulate_vehicles_simple(agents,ego_vehicles,sim_time, init_conf_agent, init_conf_ego)
% SIMULATE_VEHICLES Simulate all vehicles

    % Initialize vehicles to their starting states.
    for ii = 1:length(agents)
        if ~isempty(agents(ii).G.vdata(init_conf_agent(ii)).u_hist)
            agents(ii).veh.init(agent(ii).G.vdata(init_conf_agent(ii)).x, ...
                agents(ii).G.vdata(init_conf_agent(ii)).u_hist(end, :));
        else
            agents(ii).veh.init(agent(ii).G.vdata(init_conf_agent(ii)).x);
        end
        agents(ii).veh.driver.clear_target_path(); % This may be redundant after init.
        agents(ii).veh.driver.add_to_target_path(agents(ii).temp_target_path);
    end
    for ii = 1:length(ego_vehicles)
        vdata = ego_vehicles(ii).G.vdata(init_conf_ego(ii));
        % TODO give agent vehicles to ego as a perception system output.
        ego_vehicles(ii).veh.init(vdata.x);
        ego_vehicles(ii).veh.driver.clear_target_path(); % This may be redundant after init.
        % TODO this will all change for ego vehicle.
        ego_vehicles(ii).veh.driver.add_to_target_path(ego_vehicles(ii).x0 + [1000.0; 0.0; 0.0; 0.0]);
    end
    
    for ii = 1:length(agents)
        [x_hist, u_hist] = agents(ii).veh.run(round(sim_time / agents(ii).veh.dt));
        agent_out(ii).x_hist = x_hist;
        agent_out(ii).u_hist = u_hist;
    end
    for ii = 1:length(ego_vehicles)
        [x_hist, u_hist] = ego_vehicles(ii).veh.run(round(sim_time / ego_vehicles(ii).veh.dt));
        ego_out(ii).x_hist = x_hist;
        ego_out(ii).u_hist = u_hist;
    end
end

