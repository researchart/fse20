tv = []
tv = [tv,car_statistics(:).total_violation]
tv = tv'
tv = tv(2:end)
tc = []
tc = [tc,car_statistics(:).total_calls]
tc = tc'
tc = tc(2:end)
tv2tc=tv./tc
tv2tc=(tv./tc)*100

[idxv,cntv]=kmeans(tv2tc,2)
tc(find(idxv==2))
tc(find(idxv==1))


tcars = [];
tcars = [tcars,car_statistics(:).total_cars]
tcars = tcars'
tcars = tcars(2:end)
close all;
figure;
hold on;
plthdl = plot(tv2tc, tcars, '*');
title('Violation Distribution');
xlabel('violation percentage');
ylabel('number of cars');
ylim([20 90]);