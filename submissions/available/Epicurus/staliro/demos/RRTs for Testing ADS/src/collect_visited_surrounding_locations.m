max_rear = 50;
max_front = 50;
max_side = 10;
car_half_width = 0.9;
X = 1;
Y = 2;
REAR_LEFT = 1;
FRONT_LEFT = 2;
FRONT = 3;
FRONT_RIGHT = 4;
REAR_RIGHT = 5;
REAR = 6;
visited_locations = zeros(2, 6);

for rel_i = 1:size(all_rel_states, 1)
    for agent_i = 1:2
        offset = 4*(agent_i-1);
        rel_pos = all_rel_states(rel_i, offset+1:offset+2);
        if rel_pos(X) < -max_rear || rel_pos(X) > max_front || ...
                abs(rel_pos(Y)) > max_side
            continue;
        end

        if rel_pos(X) < 0
            if abs(rel_pos(Y)) <= car_half_width
                visited_locations(agent_i, REAR) = visited_locations(agent_i, REAR) + 1;
            elseif rel_pos(Y) > car_half_width
                visited_locations(agent_i, REAR_LEFT) = visited_locations(agent_i, REAR_LEFT) + 1;
            elseif rel_pos(Y) < -car_half_width
                visited_locations(agent_i, REAR_RIGHT) = visited_locations(agent_i, REAR_RIGHT) + 1;
            end
        else
            if abs(rel_pos(Y)) <= car_half_width
                visited_locations(agent_i, FRONT) = visited_locations(agent_i, FRONT) + 1;
            elseif rel_pos(Y) > car_half_width
                visited_locations(agent_i, FRONT_LEFT) = visited_locations(agent_i, FRONT_LEFT) + 1;
            elseif rel_pos(Y) < -car_half_width
                visited_locations(agent_i, FRONT_RIGHT) = visited_locations(agent_i, FRONT_RIGHT) + 1;
            end
        end
    end
end
