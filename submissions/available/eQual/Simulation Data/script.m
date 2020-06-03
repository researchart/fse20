data1 = load('old_data/500.txt');
data2 = load('old_data/1000.txt');
data3 = load('old_data/2000.txt');
size(data1);
size(data2);
size(data3);
data = [data1; data2; data3]; 
size(data);
labels = [repmat(1,size(data1,1),1) ; repmat(2,size(data2,1),1); repmat(3,size(data3,1),1)];
size(labels);


figure 
grid; 
hold on ; 
%ax1.GridAlpha = 1
b = subplot(1,1,1)
% GridAlpha(1)
%GridLineStyle(':')
h = boxplot(data,labels,'Symbol','b');
set(b, 'GridAlpha' , 1 , 'GridLineStyle' , ':' ) 
set(h,'linew',1)
%xlabel('Generation Size', 'FontSize', 11)


%title(names{i},'FontSize',13,'fontWeight','bold')
xticklabels({'c=500','c=1000','c=2000'})
xt = get(gca, 'XTick')
set(gca, 'FontSize', 24 )
ylabel('Generated Simulation Data (MB)' , 'FontSize', 24)
ylim([-4 100])






