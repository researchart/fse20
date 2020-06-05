function x_webots = convert_x_to_webots(x)
    % x_pos_webots = -x_pos
    % y_pos_webots = y_pos (y will actually be used as z in webots)
    % theta_webots = theta - pi/2
    x_webots = [x(:,1), -x(:,2), x(:,3)+pi/2];
end