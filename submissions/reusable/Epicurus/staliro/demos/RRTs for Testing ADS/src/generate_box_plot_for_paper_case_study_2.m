% Uncomment the following two lines to first run the analysis on the data
% in the log folder:
analyze_rrtstar_tests_case_study_2
analyze_falsification_tests_case_study_2

% Generate box plot:
figure;
boxplot([rrtstar_analyze_costs;falsification_costs]');
hold on;
% Also add the mean of the data:
plot(mean([rrtstar_analyze_costs;falsification_costs]'), 'dk')
% Sprinkle it with some text on the labels:
ylabel('Achieved Minimum Cost')
set(gca,'xticklabel',{'RRT-based', 'Falsification-based'})
ax = gca;
ax.YGrid = 'on';
ax.GridLineStyle = '-';

