
%%% reading the data 
files = dir('results_new/results_50/*Synthesizer.txt');
data_50 = [];
names_50 = {};
names = {'AJStat' , 'Apache' , 'BDB C', 'BDB J' , 'Clasp' , 'LLVM'}
for file = files'
    csv = load(strcat('results_new/results_50/' ,file.name));
    data_50(:,end+1) = csv';
    names_50{end+1} = file.name;
    
end
names_50

files = dir('results_new/results_100/*Synthesizer.txt');
data_100 = [];
names_100 = {};
for file = files'
    csv = load(strcat('results_new/results_100/' ,file.name));
    data_100(:,end+1) = csv';
    names_100{end+1} = file.name;
    
end
names_100

files = dir('results_new/results_200/*Synthesizer.txt');
data_200 = [];
names_200 = {};
for file = files'
    csv = load(strcat('results_new/results_200/' ,file.name));
    data_200(:,end+1) = csv';
    names_200{end+1} = file.name;
    
end
names_200



f = figure
t = text(0.5,0.5,'text here');
grid on ; 
hold on 

index = [ 1 4 3 2 5 6 ] 
ii = 1
for i=index 
    ii;
    b = subplot(2,3,ii);
    
    grid; 
    hold on ; 
    %ax1.GridAlpha = 1
    
   % GridAlpha(1)
    %GridLineStyle(':')
    h = boxplot([data_50(:,i),data_100(:,i),data_200(:,i)],'Symbol','b' );
    set(b, 'GridAlpha' , 1 , 'GridLineStyle' , ':' ) 
    set(h,'linew',1)
    xlabel('Generation Size', 'FontSize', 11)
    ylabel('Optimal Proximity' , 'FontSize', 11)
    title(names{i},'FontSize',13,'fontWeight','bold')
    xticklabels({'50','100','200'})
    if ii < 4
        ylim([0.75 1.05]);
     %   kk  =0.3*(ii-1)+0.15
      %  set(b , 'Position', [kk , 0.65 , 0.2 , 0.3]) ;
    else 
        ylim([-0.1 1.1]);
      %  kk  =0.3*(ii-4)+0.15
       % set(b , 'Position', [kk , 0.2 , 0.2 , 0.3]) ;
    end
    if ii < 4
        kk  =0.34*(ii-1)+0.05;
        set(b , 'Position', [kk , 0.80 , 0.25 , 0.15]) ;
    else 
           kk  =0.34*(ii-4)+0.05;
           set(b , 'Position', [kk , 0.57 , 0.25 , 0.15]) ;
      
    end
    ii= ii+1;
    hold off ; 
    %pos1 = get(b,'Position')
    %pos1(3) =  0.1823;
    
    
%    if i==5
 %       text(2, -0.4, 'Bottom title')
  %  end
end


%align([f t],'VerticalAlignment','center')

%subplot(1,2,1:2)
%distributionPlot(data,'xyOri','flipped','showMM',0),
 %        xlim([0 1])
%boxplot(data)

%figure
 %        distributionPlot(data,'widthDiv',[2 1],'histOri','left','color','b','yLabel', 'teset', 'histopt' , 1.1)
  %       distributionPlot(gca,data,'widthDiv',[2 2],'histOri','right','color','k', 'histopt' , 1.1)
%      ylim([ 2])

   

