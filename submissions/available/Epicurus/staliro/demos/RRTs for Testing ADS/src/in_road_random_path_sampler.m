function [agent] = in_road_random_path_sampler(rand_opts, agent, ego)
%in_road_random_path_sampler Samples a new random target waypoint for all 
% agent vehicles such that the sampled target path is inside the boundaries
% of the road.
% Waypoint format: (x,y,theta,v)

    for ii = 1:length(agent)
        x_rand = rand_between(agent(ii).x_s(:,1), agent(ii).x_s(:,2));
        % Sample a further waypoint along the direction of the sampled
        % random target state. This is to make sure vehicle that follows a 
        % target even if it reaches the target within search time step.
        x_temp_y = x_rand(2) + rand_opts.temp_path_len*cos(x_rand(3));
        do_correction = false;
        if x_temp_y > agent(ii).x_s(2,2)
            new_l = (agent(ii).x_s(2,2) - x_rand(2)) / cos(x_rand(3));
            do_correction = true;
        elseif x_temp_y < agent(ii).x_s(2,1)
            new_l = (agent(ii).x_s(2,1) - x_rand(2)) / cos(x_rand(3));
            do_correction = true;
        end
        if do_correction
            x_temp_x = x_rand(1) + new_l*sin(x_rand(3));
            x_temp_y = x_rand(2) + new_l*cos(x_rand(3));
        else
            x_temp_x = x_rand(1) + rand_opts.temp_path_len*sin(x_rand(3));
        end
            
        x_temp = x_rand + [x_temp_x; ...
                           x_temp_y; ...
                           0; ...
                           0];

        agent(ii).temp_target_path = [x_rand, x_temp];
        
        % If we did a correction and reduced the path length, add another
        % segment along the road.
        if do_correction
            %TODO: We are assuming the road is straight along x axis.
            if abs(x_temp(3)) < pi/2
                x_temp(3) = 0.0;
                x_temp = x_temp + [rand_opts.temp_path_len;0;0;0];
            else
                x_temp(3) = pi;
                x_temp = x_temp + [-rand_opts.temp_path_len;0;0;0];
            end
            agent(ii).temp_target_path = [agent(ii).temp_target_path, x_temp];
        end
    end

end
