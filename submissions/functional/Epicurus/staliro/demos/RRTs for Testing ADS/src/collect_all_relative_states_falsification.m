
fals_all_rel_states = cell(0);
path_to_files = '../log/';
list_files = dir([path_to_files, 'falsification_*.mat']);
collisions = zeros(length(list_files), 1);
for file_i = 1:length(list_files)
    disp([num2str(file_i), '/', num2str(length(list_files))]);
    fname = list_files(file_i).name;
    load([path_to_files, fname]);

    if ~isfield(history, 'traj')
        inpArray = results.run.bestSample;
        dimX = size(init_cond,1);

        XPoint = inpArray(1:dimX);
        UPoint = inpArray(dimX+1:end);
        stepTime = [0:opt.SampTime:time];

        nb_ContPoints = cp_array;
        for cp_i = 2:length(cp_array)
            nb_ContPoints(cp_i) = nb_ContPoints(cp_i) + nb_ContPoints(cp_i-1); %incremental
        end

        InpSignal = ComputeInputSignals(stepTime, UPoint, opt.interpolationtype, nb_ContPoints, input_range, time, 1);

        [T, XT, YT, LT,CLG,GRD] = model_test_case_1(XPoint, time, stepTime, InpSignal);
        matlab_traj = XT(:,[1:3,6:8,10:12]);
        sim_env = SimulationEnvironment.instance(0.01);
        if ~isempty(sim_env.collisions)
            if sim_env.collisions(1).agent == 1
                collisions(file_i) = 1;
            elseif sim_env.collisions(1).agent == 2
                collisions(file_i) = 2;
            end
        end
        fals_all_rel_states{file_i, 1} = matlab_traj(:,4:5) - matlab_traj(:,1:2);
        fals_all_rel_states{file_i, 2} = matlab_traj(:,7:8) - matlab_traj(:,1:2);
        new_fname = [fname, '_traj'];
        save(new_fname);
    else
        ego(1).veh = DynamicCar('dt',0.01);
        agent(1).veh = Car('dt',0.01);
        agent(2).veh = Car('dt',0.01);
        bestInd = find(history.rob == results.run.bestRob);
        XT = history.traj{bestInd};
        matlab_traj = XT(:,[1:3,6:8,10:12]);
        fals_all_rel_states{file_i, 1} = matlab_traj(:,4:5) - matlab_traj(:,1:2);
        if check_collisions(ego(1).veh, agent(1).veh, matlab_traj(end,1:3), matlab_traj(end,4:6))
            collisions(file_i) = 1;
        end
        fals_all_rel_states{file_i, 2} = matlab_traj(:,7:8) - matlab_traj(:,1:2);
        if check_collisions(ego(1).veh, agent(2).veh, matlab_traj(end,1:3), matlab_traj(end,7:9))
            collisions(file_i) = 2;
        end
    end 
end

figure
for file_i = 1:length(list_files)
    if collisions(file_i) == 1
        plot(fals_all_rel_states{file_i, 1}(:,1), fals_all_rel_states{file_i, 1}(:,2), 'r');
    end
    hold on;
    if collisions(file_i) == 2
        plot(fals_all_rel_states{file_i, 2}(:,1), fals_all_rel_states{file_i, 1}(:,2), 'b');
    end
    hold on;
end

figure
for file_i = 1:length(list_files)
    if collisions(file_i) == 1
        plot(fals_all_rel_states{file_i, 1}(end,1), fals_all_rel_states{file_i, 1}(end,2), 'r.');
    end
    hold on;
    if collisions(file_i) == 2
        plot(fals_all_rel_states{file_i, 2}(end,1), fals_all_rel_states{file_i, 1}(end,2), 'b.');
    end
    hold on;
end


function [is_coll] = check_collisions(ego_veh, agent_veh, ego_x, agent_x)
    %check_collision Checks is there is a collision between vehicles.
    is_coll = false;
    % There cannot be a collision if the distance between
    % vehicles is larger than 8m.
    if norm(ego_x(1:2) - agent_x(1:2)) < 8
        % TODO: We can save and reuse polyhedron for performance.
        eP = Polyhedron(ego_veh.get_corners(ego_x)');
        aP = Polyhedron(agent_veh.get_corners(agent_x)');
        iP = intersect(eP, aP);
        if ~iP.isEmptySet()
            is_coll = true;
        end
    end
end