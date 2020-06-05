function [agent] = all_random_path_sampler(rand_opts, agent, ego)
%ALL_RANDOM_PATH_SAMPLER Samples a new random target waypoint for all agent vehicles.
% Waypoint format: (x,y,theta,v)

    for ii = 1:length(agent)
        x_rand = rand_between(agent(ii).x_s(:,1), agent(ii).x_s(:,2));
        % Sample a further waypoint along the direction of the sampled
        % random target state. This is to make sure vehicle that follows a 
        % target even if it reaches the target within search time step.
        x_temp = x_rand + [rand_opts.temp_path_len*sin(x_rand(3)); ...
                           rand_opts.temp_path_len*cos(x_rand(3)); ...
                           0; ...
                           0];
        agent(ii).temp_target_path = [x_rand, x_temp];
    end

end
