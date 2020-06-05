% Uncomment the following two lines to first run the analysis on the data
% in the log folder:
analyze_rrt_tests_case_study_1
analyze_falsification_tests_case_study_1

% Generate box plot:
figure;
boxplot([rrt_analyze_costs;falsification_costs]');
hold on;
% Also add the mean of the data:
plot(mean([rrt_analyze_costs;falsification_costs]'), 'dk')
% Sprinkle it with some text on the labels:
ylabel('Achieved Minimum Cost')
set(gca,'xticklabel',{'RRT-based', 'Falsification-based'})
ax = gca;
ax.YGrid = 'on';
ax.GridLineStyle = '-';

