function [ is_coll_path, is_approaching, impact_pt ] = check_collision_path( ego_orientation, ego_old_orientation, ego_pts, ego_old_pts, agent_pts, agent_old_pts )
%check_collision_path Check if two vehicles are on a collision path.

is_coll_path = false;
if nargout > 1
    is_approaching = true;
end

if nargout > 2
    impact_pt = 1;
end

for pt_ind = 1:size(ego_old_pts, 2)
    ego_old_pt = ego_old_pts(:, pt_ind);
    if nargout > 2
        [left_most_old, right_most_old, lm_pt_old, rm_pt_old] = ...
            get_angle_range(ego_old_pt, ego_old_orientation, agent_old_pts);
    else
        [left_most_old, right_most_old] = ...
            get_angle_range(ego_old_pt, ego_old_orientation, agent_old_pts);
    end
    ego_new_pt = ego_pts(:, pt_ind);
    if nargout > 2
        [left_most_new, right_most_new, lm_pt_new, rm_pt_new] = ...
            get_angle_range(ego_new_pt, ego_orientation, agent_pts);
    else
        [left_most_new, right_most_new] = ...
            get_angle_range(ego_new_pt, ego_orientation, agent_pts);
    end
    if left_most_new >= left_most_old && right_most_new <= right_most_old
        is_coll_path = true;
    elseif left_most_new <= left_most_old && right_most_new >= right_most_old
        if nargout > 1
            is_approaching = false;
            is_coll_path = true;
        end
    end
    if is_coll_path
        if nargout > 2
            % TODO: correct this
            d_old_l = abs(lm_pt_old(2));
            d_new_l = abs(lm_pt_new(2));
            d_delta_l = d_new_l - d_old_l;
            
            d_old_r = abs(rm_pt_old(2));
            d_new_r = abs(rm_pt_new(2));
            d_delta_r = d_new_r - d_old_r;
            
            if abs(lm_pt_new(1)-lm_pt_old(1)) < 0.0001
                d_l_final = d_new_l;
            else
                t_l = abs(lm_pt_old(1) / (lm_pt_new(1)-lm_pt_old(1)));
                d_l_final = d_old_l + d_delta_l * t_l;
            end
            if abs(rm_pt_new(1)-rm_pt_old(1)) < 0.0001
                d_r_final = d_new_r;
            else
                t_r = abs(rm_pt_old(1) / (rm_pt_new(1)-rm_pt_old(1)));
                d_r_final = d_old_r + d_delta_r * t_r;
            end
            
            d_total = d_l_final + d_r_final;
            if d_l_final < d_r_final
                impact_pt = max(0, d_l_final/(d_total/2)); %impact_pt \in [0,1]
            else
                impact_pt = max(0, d_r_final/(d_total/2));
            end
            if abs(ego_new_pt(2)) < 0.01  % center point values \in [0.5,1]
                impact_pt = 0.5 + 0.5*impact_pt;
            else % Side point values \in [0, 0.5]
                impact_pt = 0.5*impact_pt;
            end
                
        end
        break;
    end
end

end


function [left_most_ang, right_most_ang, lm_pt, rm_pt] = get_angle_range(ego_pt, ego_orientation, agent_pts)
    % Get left-most and right-most angles of agent wrt ego.
    % Also returns the left-most and right-most points if nargout > 2
    R1 = cos(-ego_orientation);
    R2 = sin(-ego_orientation);
    R = [R1 -R2; R2 R1];
    agent_rel_pts = R*(agent_pts - ego_pt);
    agent_rel_angles = atan2(agent_rel_pts(2, :), agent_rel_pts(1, :));
    if nargout > 2
        [left_most_ang, lm_i] = max(agent_rel_angles);
        [right_most_ang, rm_i] = min(agent_rel_angles);
        lm_pt = agent_rel_pts(:, lm_i);
        rm_pt = agent_rel_pts(:, rm_i);
    else
        left_most_ang = max(agent_rel_angles);
        right_most_ang = min(agent_rel_angles);
    end
    if left_most_ang > pi/2 && right_most_ang < -pi/2
        temp = right_most_ang;
        right_most_ang = left_most_ang;
        left_most_ang = temp;
        if nargout > 2
            temp = rm_pt;
            rm_pt = lm_pt;
            lm_pt = temp;
        end
    end
end

