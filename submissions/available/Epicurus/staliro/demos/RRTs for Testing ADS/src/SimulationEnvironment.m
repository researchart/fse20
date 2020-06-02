classdef SimulationEnvironment < Singleton
    %SIMULATIONENVIRONMENT Provides current states and histories of the
    %vehicles in the simulation environment (typically to
    %perception-simulating functions.) Implemented as a Singleton class.
    
    properties
        agent_x_hist
        ego_x_hist
        agent_x_hist_len
        ego_x_hist_len
        cur_time
        collisions
        agent_collisions
        agent_collision_checks
        dt
    end
    
    methods(Access=private)
      % Guard the constructor against external invocation.  We only want
      % to allow a single instance of this class.  See description in
      % Singleton superclass.
        function sim_env = SimulationEnvironment(dt)
            %SIMULATIONENVIRONMENT Construct an instance of this class
            sim_env.agent_x_hist = {};
            sim_env.ego_x_hist = {};
            sim_env.agent_x_hist_len = [];
            sim_env.ego_x_hist_len = [];
            sim_env.cur_time = 0;
            sim_env.dt = dt;
            sim_env.collisions = [];
            sim_env.agent_collisions = [];
            sim_env.agent_collision_checks = cell(0);
        end
    end
    
    methods(Static)
        % Concrete implementation.  See Singleton superclass.
        function sim_env = instance(dt)
            persistent uniqueInstance
            if isempty(uniqueInstance)
                sim_env = SimulationEnvironment(dt);
                uniqueInstance = sim_env;
            else
                sim_env = uniqueInstance;
            end
        end
    end
   
    methods        
        function sim_env = reset(sim_env, ego, agent, init_conf_ego, init_conf_agent)
            %RESET Clear all simulation items.
            sim_env.collisions = [];
            sim_env.agent_collisions = [];
            
            if nargin > 3
                for ii = 1:length(ego)
                    [sim_env.ego_x_hist{ii}, sim_env.ego_x_hist_len(ii)] = ...
                        set_initial_x_hist(ego(ii), init_conf_ego(ii));
                end
            else
                sim_env.ego_x_hist = {};
                sim_env.ego_x_hist_len = [];
                sim_env.cur_time = 0;
            end
            if nargin > 3
                for ii = 1:length(agent)
                    [sim_env.agent_x_hist{ii}, sim_env.agent_x_hist_len(ii)] = ...
                        set_initial_x_hist(agent(ii), init_conf_agent(ii));
                end
            else
                sim_env.agent_x_hist = {};
                sim_env.agent_x_hist_len = [];
            end

            function [x_hist, x_hist_len] = set_initial_x_hist(vhc, init_v_id)
                vdata = vhc.G.vdata(init_v_id);
                num_states = length(vdata.x);
                x_hist = zeros(1000,num_states);
                num_hist = size(vdata.x_hist,1);
                x_hist(1:num_hist,:) = vdata.x_hist;
                x_hist_len = num_hist;
            end
        end
        
        function sim_env = update_environment(sim_env,cur_time,agent,ego)
            %UPDATE_ENVIRONMENT Update simulation environment data with the
            %given vehicles states.
            sim_env.cur_time = cur_time;
            
            for ii = 1:length(agent)
                % Create x_hist for the vehicle if doesn't exist:
                if length(sim_env.agent_x_hist) < ii
                    num_states = length(agent(ii).veh.x);
                    sim_env.agent_x_hist{ii} = zeros(1000,num_states);
                    sim_env.agent_x_hist_len(ii) = 0;
                end
                % Double the size of the array if current length is same as
                % the memory allocated for the x_hist.
                if sim_env.agent_x_hist_len(ii) >= size(sim_env.agent_x_hist{ii},1)
                    sim_env.agent_x_hist{ii} = [sim_env.agent_x_hist{ii}; ...
                        zeros(size(sim_env.agent_x_hist{ii},1),...
                            size(sim_env.agent_x_hist{ii},2))];
                end
                % Add new state to the x_hist:
                sim_env.agent_x_hist_len(ii) = sim_env.agent_x_hist_len(ii) + 1;
                sim_env.agent_x_hist{ii}(sim_env.agent_x_hist_len(ii),:) = agent(ii).veh.x';
            end
            for ii = 1:length(ego)
                % Create x_hist for the vehicle if doesn't exist:
                if length(sim_env.ego_x_hist) < ii
                    num_states = length(ego(ii).veh.x);
                    sim_env.ego_x_hist{ii} = zeros(1000,num_states);
                    sim_env.ego_x_hist_len(ii) = 0;
                end
                % Double the size of the array if current length is same as
                % the memory allocated for the x_hist.
                if sim_env.ego_x_hist_len(ii) >= size(sim_env.ego_x_hist{ii},1)
                    % Double the size of array
                    sim_env.ego_x_hist{ii} = [sim_env.ego_x_hist{ii}; ...
                        zeros(size(sim_env.ego_x_hist{ii},1),...
                            size(sim_env.ego_x_hist{ii},2))];
                end
                % Add new state to the x_hist:
                sim_env.ego_x_hist_len(ii) = sim_env.ego_x_hist_len(ii) + 1;
                sim_env.ego_x_hist{ii}(sim_env.ego_x_hist_len(ii),:) = ego(ii).veh.x';
            end

            % Check collisions
            for e_i = 1:length(ego)
                for a_i = 1:length(agent)
                    if ~isempty(sim_env.collisions) && ...
                            sim_env.collisions(end).ego == e_i && ...
                            sim_env.collisions(end).agent == a_i
                        continue;
                    end
                    if sim_env.check_collision(ego(e_i).veh, agent(a_i).veh)
                        sim_env.collisions(end+1).ego = e_i;
                        sim_env.collisions(end).agent = a_i;
                        sim_env.collisions(end).time = cur_time;
                    end
                end
            end
            
            % Check agent-to-agent collisions
            if ~isempty(sim_env.agent_collision_checks)
                for e_i_i = 1:length(sim_env.agent_collision_checks{1})
                    e_i = sim_env.agent_collision_checks{1}(e_i_i);
                    for a_i_i = 1:length(sim_env.agent_collision_checks{2})
                        a_i = sim_env.agent_collision_checks{2}(a_i_i);
                        if e_i == a_i
                            continue;
                        end
                        if ~isempty(sim_env.agent_collisions) && ...
                                ((sim_env.agent_collisions(end).agent1 == e_i && ...
                                sim_env.agent_collisions(end).agent2 == a_i) || ...
                                (sim_env.agent_collisions(end).agent2 == e_i && ...
                                sim_env.agent_collisions(end).agent1 == a_i))
                            continue;
                        end
                        if sim_env.check_collision(agent(e_i).veh, agent(a_i).veh)
                            sim_env.agent_collisions(end+1).agent1 = e_i;
                            sim_env.agent_collisions(end).agent2 = a_i;
                            sim_env.agent_collisions(end).time = cur_time;
                        end
                    end
                end
            end
        end
        
        function [sim_items] = get_sim_items(sim_env,requesting_type,requesting_id,max_history_t)
            % GET_SIM_ITEMS Returns current states and histories of
            % the vehicles except the requesting vehicle. Requesting
            % vehicle type can be "agent", "ego" (or something else if the
            % caller need all vehicles.
            
            % TODO: If you have many vehicles calling this function at each
            % step, record the results so taht they are not reproduced
            % everytime this function is called. This is ignored for now
            % because we will have only one or two Ego vehicles calling
            % this function.
            sim_items.cur_time = sim_env.cur_time;
            sim_items.other_vhc = [];
            sim_items.self_vhc = [];
            for ii = 1:length(sim_env.agent_x_hist)
                vhc_info = sim_env.get_vehicle_info(...
                                sim_env.agent_x_hist{ii},...
                                sim_env.agent_x_hist_len(ii),...
                                max_history_t,'agent');
                if requesting_id == ii && strcmpi(requesting_type,'agent')
                    sim_items.self_vhc = vhc_info;
                else
                    sim_items.other_vhc = [sim_items.other_vhc, vhc_info]; %#ok<AGROW>
                end
            end
            for ii = 1:length(sim_env.ego_x_hist)
                vhc_info = sim_env.get_vehicle_info(...
                                    sim_env.ego_x_hist{ii},...
                                    sim_env.ego_x_hist_len(ii),...
                                    max_history_t,'ego');
                if requesting_id == ii && strcmpi(requesting_type,'ego')
                    sim_items.self_vhc = vhc_info;
                else
                    sim_items.other_vhc = [sim_items.other_vhc, vhc_info]; %#ok<AGROW>
                end
            end
        end
        
        function veh_info = get_vehicle_info(sim_env,veh_x_hist,hist_size,max_history_t,veh_type)
            %GET_VEHICLE_INFO Returns current state and history of a
            %vehicle.
            veh_info.x = veh_x_hist(hist_size,:)';
            veh_info.dt = sim_env.dt;
            num_history = round(max_history_t / sim_env.dt) + 1;
            start_ind = max(1, hist_size - num_history + 1);
            veh_info.x_hist = veh_x_hist(start_ind:hist_size,:);
            veh_info.veh_type = veh_type;
        end
        
    end
    
    methods(Static)
                
        function [is_coll] = check_collision(ego_veh, agent_veh)
            %check_collision Checks is there is a collision between vehicles.
            is_coll = false;
            % There cannot be a collision if the distance between
            % vehicles is larger than 8m.
            if norm(ego_veh.get_position() - agent_veh.get_position()) < 8
                % TODO: We can save and reuse polyhedron for performance.
                eP = Polyhedron(ego_veh.get_corners(ego_veh.x)');
                aP = Polyhedron(agent_veh.get_corners(agent_veh.x)');
                iP = intersect(eP, aP);
                if ~iP.isEmptySet()
                    is_coll = true;
                end
            end
        end
        
    end
end

