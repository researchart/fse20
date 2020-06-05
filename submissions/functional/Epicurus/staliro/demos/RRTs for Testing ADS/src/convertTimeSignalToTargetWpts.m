function [wpts, time_pts] = convertTimeSignalToTargetWpts(tu, ysignal, vsignal, x0)
%convertTimeSignalToTargetWpts Converts a target y position over time
%signal with a corresponding target speed signal to a series of target
%waypoints represented as (x,y,theta,speed)
jump_pts = find(diff(vsignal)) + 1;
time_pts = tu(jump_pts);
wpts = [];

cur_x = x0(1);
cur_y = x0(2);
cur_v = x0(4);
cur_t = 0;
for j_i = 1:length(jump_pts)
    % y position at next wpt:
    next_y = ysignal(jump_pts(j_i));
    
    % Trying to find x position of next wpt
    d = (time_pts(j_i) - cur_t) * cur_v;
    delta_y = next_y - cur_y;
    if d^2 > delta_y^2
        delta_x = sqrt(d^2 - delta_y^2);
    else
        delta_x = 10;
    end
    next_x = cur_x + delta_x;
    
    % speed at next wpt
    next_v = vsignal(jump_pts(j_i));
    
    % Trying to find theta of next wpt
    if j_i < length(jump_pts)
        next_next_y = ysignal(jump_pts(j_i+1));
        d = (time_pts(j_i+1) - time_pts(j_i)) * next_v;
        delta_y = next_next_y - next_y;
        if d^2 > delta_y^2
            delta_x = sqrt(d^2 - delta_y^2);
        else
            delta_x = 10;
        end
        theta = atan2(delta_y, delta_x);
    else
        theta = 0;
    end
    
    % add next wpt to the list:
    wpts = [wpts, [next_x; next_y; theta; next_v]];
    
    cur_x = next_x;
    cur_y = next_y;
    cur_v = next_v;
end

end

