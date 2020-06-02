yn=input('Did you run Demo_S_Taliro_wihtout_intersection.m before this? 0) No  1) Yes ');
colors=[0,0,1;0,1,0;1,0,0;0,1,1;1,1,0;1,0,1;0,0,0];
numColors = length(colors);
runTest = true;
showAllCars = false;
yn = 1;
testSafeDist = [];
testSafeLatDist = [];
if yn==1
    if true(runTest)
        on = 2;
        caseNum = 11;
        safetyStruct = lat_longSafety;
        vn(1) = safetyStruct(caseNum).egoID;
        vn(2) = safetyStruct(caseNum).frontID;
        testSafeDist = safetyStruct(caseNum).safeDist;
        testSafeLatDist = safetyStruct(caseNum).safeLatDist;
        startTime = safetyStruct(caseNum).t_blame - safetyStruct(caseNum).i_blame*dt_prediction;
        blameTime = safetyStruct(caseNum).t_blame;
    elseif true(showAllCars)
        on = length(obstacleIDs);
        vn = zeros(1,on);
        for i=1:on
            vn(i) = i;
        end
    else
        fprintf('Choose the number of objects between 1 and %d\n',length(obstacleLane));
        on=input('');
        if on<1 || on>length(obstacleLane)
            error('Obstacle number is wrong');
        end
        vn=zeros(on,1);
        for i=1:on
            fprintf('Choose vehicle number between 1 and %d\n',length(obstacleLane));
            vn(i)=input('');
            if on<1 || on>length(obstacleLane)
                error('Obstacle number is wrong');
            end
        end
    end
%     curFig = figure;
%     hold on;
%     axis equal;
%     for i=1:szLane
%         lb=perception.map.lanes(i).leftBorder.vertices;
%         rb=perception.map.lanes(i).rightBorder.vertices;
%         plot(lb(1,:),lb(2,:),'k');
%         plot(rb(1,:),rb(2,:),'k');
%     end
    X=cell(on,1);
    Y=cell(on,1);
    minSample=10000;
    maxSample=0;
    for i=1:on
        X{i}=perception.map.obstacles(vn(i)).trajectory.position(1,:);
        Y{i}=perception.map.obstacles(vn(i)).trajectory.position(2,:);
        if  minSample>initSample(vn(i))
            minSample=initSample(vn(i));
        end
        if  maxSample<initSample(vn(i))+length(X{i})
            maxSample=initSample(vn(i))+length(X{i});
        end
    end
    k=0;
    bc = 1;

    for i=minSample:maxSample
%         i
        k=k+1;
         h=figure;
         axis equal;
         hold on;
        for j=1:szLane
            lb=perception.map.lanes(j).leftBorder.vertices;
            rb=perception.map.lanes(j).rightBorder.vertices;
            plot(lb(1,:),lb(2,:),'k');
            plot(rb(1,:),rb(2,:),'k');
        end
        bothAvailable = false;
        for j=1:on
%             j
            if i-initSample(vn(j))<length(Y{j}) && i>=initSample(vn(j))
                plot(X{j}(i-initSample(vn(j))+1),Y{j}(i-initSample(vn(j))+1),'s','color',colors(mod(j-1,numColors)+1,:),'MarkerFaceColor',colors(mod(j-1,numColors)+1,:));
                text(X{j}(i-initSample(vn(j))+1)+1,Y{j}(i-initSample(vn(j))+1)+1,num2str(obstacleIDs(vn(j))));
                text(0,60,['Time: ',num2str((i)*0.1)]);
                if  runTest && startTime <= (i)*dt_prediction && j==1 && bc <= length(testSafeDist)
                    text(0,50,['SafeDist Lon: ',num2str(testSafeDist(bc))]);
                    text(0,40,['SafeDist Lat: ',num2str(testSafeLatDist(bc))]);
                    bc = bc + 1;
                    bothAvailable = true;
                end
            end
        end
        if true(runTest) & blameTime <= (i+1)*dt_prediction & true(bothAvailable) & bc <= length(testSafeDist)+1
            text(20,60,[' <- In Dangerous Time, Blame Time: ',num2str(blameTime)],'color','red');
        end
        
        saveas(h,sprintf('FIG%d.png',k));
        figNum = h.Number;
        close 
    end
end