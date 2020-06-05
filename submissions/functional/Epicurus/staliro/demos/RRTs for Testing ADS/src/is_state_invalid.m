function [invalid] = is_state_invalid(x,agent)
%IS_STATE_INVALID Check if this state is inextensible.
invalid = (x(2) < agent.x_s(2, 1) - 2.0 || x(2) > agent.x_s(2, 2) + 2.0);

end

