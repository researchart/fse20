function plot_trajectory_evolution_falsification_case_study_2( traj )
%PLAY_SIMULATION Summary of this function goes here
%   Detailed explanation goes here

% First run replay_simulation_in_webots to create the trajectory data!!!
ego.veh = DynamicCar();
agent(1).veh = Car();
agent(2).veh = Car();
agent(3).veh = Car();
agent(4).veh = Car();
warning off
num_vehicle_states = 3;
num_agents = length(agent);
num_ego = length(ego);
agent_colors = {'red', 'blue', 'black', 'green'};

offset_vhc = [];
y_offset = 0;

plot_start_ind = 1;
skip_index = 50;
final_index = size(traj, 1);
h = figure;
order_no = 1;
min_x = min([traj(:,1);traj(:,4);traj(:,7);traj(:,10);traj(:,13)]);
max_x = max([traj(:,1);traj(:,4);traj(:,7);traj(:,10);traj(:,13)]);
patch([min_x-5 max_x+10  max_x+10 min_x-5], [-12 -12 12 12], [0.702 0.694 0.671]);
hold on;
plot([min_x - 5 max_x + 10],[10.5 10.5],'w-');
hold on;
plot([min_x - 5 max_x + 10],[7 7],'w--');
plot([min_x - 5 max_x + 10],[3.5 3.5],'w--');
plot([min_x - 5 max_x + 10],[0.0 0.0],'w--');
plot([min_x - 5 max_x + 10],[-3.5 -3.5],'w--');
plot([min_x - 5 max_x + 10],[-7 -7],'w--');
plot([min_x - 5 max_x + 10],[-10.5 -10.5],'w-');
for k = [plot_start_ind:skip_index:final_index-1, final_index]
    if ~isempty(offset_vhc)
        x_offset = traj(k, 3*(offset_vhc-1) + 1);
        %y_offset = traj(k, 3*(offset_vhc-1) + 2) + 5.25;
    else
        x_offset = 0;
    end
    last_state_ind = 0;
    for i = 1:num_ego + num_agents
        %Get vehicle related states
        end_state_ind = last_state_ind + num_vehicle_states;
        x = traj(k, last_state_ind+1:end_state_ind)' - [x_offset;y_offset;0];
        last_state_ind = end_state_ind;

        if i <= num_ego
            vhc_pts = ego(i).veh.get_corners(x);
            vhc_color = 'yellow';
        else
            a_i = i - num_ego;
            vhc_pts = agent(a_i).veh.get_corners(x);
            vhc_color = agent_colors{a_i};
        end
        vhc_P = Polyhedron(vhc_pts');
        if k == final_index
            plot(vhc_P,'color', vhc_color, 'edgecolor', vhc_color);
            text_color = 'white';
        elseif k == plot_start_ind
            plot(vhc_P,'color', vhc_color, 'edgecolor', vhc_color, 'Alpha', 0.3, 'edgealpha', 0.3);
            text_color = vhc_color;
        else
            plot(vhc_P,'color', vhc_color, 'wire', true, 'linewidth', 0.5, 'wirecolor', vhc_color, 'edgecolor', vhc_color, 'EdgeAlpha', 0.3+((k) / final_index)*0.7 );
            text_color = vhc_color;
        end
        hold on;
        if i == 1 || i == 2
            text('Position',[x(1) x(2)],'string',order_no,'color',text_color, 'FontSize', 16);
        end
        hold on;
    end
    order_no = order_no + 1;
end

ylabel('Lateral Position');
xlabel('Longitudinal Position');
axis equal;
ax = gca;
ax.YTick = [-10.5, -7.0, -3.5, 0.0, 3.5, 7.0, 10.5];
ax.YLim = [-12, 12];
ax.XLim = [min_x - 5, max_x + 10];
hold on;

getframe(h);
set(gca,'FontSize',20)

end

