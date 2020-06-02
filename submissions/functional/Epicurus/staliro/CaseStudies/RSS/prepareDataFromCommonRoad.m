function [samples, dt_prediction, egoFrontCar, egoLeftCar, egoRightCar, obstacleLane, obstacleSamples, obstacleIDs, distancReflection] = prepareDataFromCommonRoad(inputFile, cut_from_end_of_trajectory)

global SHOW_PLOTS;
global cutLineErrorAcceptance;


% time interval of the scenario (step along trajectory of obstacles)
% (if ts == [], scenario will start at its beginning;
% if tf == [], scenario will run only for one time step)
% ToDO: tf to run the scenario until its end
ts_scenario = [];
% (dt_scenario is defined by given trajectory)
tf_scenario = [];

% time interval in seconds for prediction of the occupancy
ts_prediction = 0;%0
dt_prediction = 0.1;%0.1
tf_prediction = 10;%1.5

% time interval in seconds for visualization
ts_plot = ts_prediction;
dt_plot = dt_prediction;
tf_plot = tf_prediction;

% define whether trajectory shall be verifyed (i.e. checked for collision)
verify_trajectory = false;

% define output
writeOutput = false;

% --- Set-up Perception ---

% create perception from input (holding a map with all lanes, adjacency
% graph and all obstacles)
perception = globalPck.Perception(inputFile, ts_scenario);


% create time interval for occupancy calculation
timeInterval_prediction = globalPck.TimeInterval(ts_prediction, dt_prediction, tf_prediction);

%mohammad: make some fixes for some obstacles
if true
for i = 1:numel(perception.map.obstacles)
       [tmptmp,trjlen] = size(perception.map.obstacles(i).trajectory.position);
   if isempty(perception.map.obstacles(i).position) | perception.map.obstacles(i).position ~= perception.map.obstacles(i).trajectory.position(:,trjlen)
       set(perception.map.obstacles(i),'position', perception.map.obstacles(i).trajectory.position(:,trjlen));
   end
   if isempty(perception.map.obstacles(i).orientation)
       trjlen = length(perception.map.obstacles(i).trajectory.orientation);
       set(perception.map.obstacles(i),'orientation', perception.map.obstacles(i).trajectory.orientation(:,trjlen));
   end
   if isempty(perception.map.obstacles(i).time)
       set(perception.map.obstacles(i),'time', perception.map.obstacles(i).trajectory.timeInterval.tf);
   end
end
end


% An array to save the CommonRoad's id of all lanes 
lineID=[];


% Cell array of the lanes containing the center points (x,y) of the lanes. 
centerLine=cell(length(perception.map.lanes),1);


% Each road segment has a distance from the beginning of the lane which
% is saved in roadSegmentDist
roadSegmentDist=cell(length(perception.map.lanes),1);


% A cell array to save the lanelets of each lane
laneletsOfLanes=cell(length(perception.map.lanes),1);


% A cell array to save the list of all lanelets
laneletsList=cell(length(perception.map.lanelets),1);


% An array to save the CommonRoad's id of all lanelets 
laneletsIDs=zeros(length(perception.map.lanelets),1);


% An array of data structure to save the indices (of laneletsOfLanes) for
% four neighbors of the lanelets as follows:
% 'predec' for previous lanelet index,
% 'succes' for next lanelet index,
% 'left' for left lanelet index,
% 'right' for right lanelet index,
laneletsNeighbor=cell(length(perception.map.lanelets),1);


% A cell array that shows each point of the lane belongs to which lanelet.
% For each point of the lane (centerLine), this contains the index of the corresponding 
% laneletsOfLanes
laneletsOfLanePoints=cell(length(perception.map.lanes),1);

    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%
    if true(SHOW_PLOTS)

figure(2);
title('Lane IDs');
% axis equal;
hold on;

if true(RUN_TEST_MODE)
%TEST: draw images for paper
idSet = [775;779];
perception.plot(idSet);
hold on;
axis([-20 120 -12 18])
end
    end
    
% For loop to create the list of lanelets (laneletsList) and lanelet id's 
% in CommonRoad (laneletsIDs).
for i=1:length(perception.map.lanelets)
    laneletsList{i}=perception.map.lanelets(i);
    laneletsIDs(i)=perception.map.lanelets(i).id;
end

% For loop to create the list of lanelets's neighbours (laneletsNeighbor).
for i=1:length(laneletsList)
    predecIndx=[];
    for j=1:length(laneletsList{i}.predecessorLanelets)
        tempID=laneletsList{i}.predecessorLanelets(j).id;
        predecIndx(j)=find(laneletsIDs==tempID);
    end
    succesIndx=[];
    for j=1:length(laneletsList{i}.successorLanelets)
        tempID=laneletsList{i}.successorLanelets(j).id;
        succesIndx(j)=find(laneletsIDs==tempID);
    end
    leftIndx=[];
    for j=1:length(laneletsList{i}.adjacentLeft)
        tempID=laneletsList{i}.adjacentLeft(j).lanelet.id;
        leftIndx(j)=find(laneletsIDs==tempID);
    end
    rightIndx=[];
    for j=1:length(laneletsList{i}.adjacentRight)
        tempID=laneletsList{i}.adjacentRight(j).lanelet.id;
        rightIndx(j)=find(laneletsIDs==tempID);
    end
    laneletsNeighbor{i}=struct('predec',predecIndx,'succes',succesIndx,'left',leftIndx,'right',rightIndx);
end

% For loop to create the lanelet of each lane (laneletsOfLanes)
for i=1:length(perception.map.lanes)
    x=perception.map.lanes(i).center.vertices(1,:);
    y=perception.map.lanes(i).center.vertices(2,:);
    laneletsOfLanePoints{i}=zeros(length(x),1);
    lineID=[lineID,perception.map.lanes(i).id];
    centerLine{i} = [x;y];
    segDist=[];
    segDist(1)=0;
    dist=0;
    for j=2:length(x)
        dist=dist+sqrt((x(j-1)-x(j))^2+(y(j-1)-y(j))^2);
        segDist(j)=dist;
    end
    roadSegmentDist{i}=segDist;
    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%
    if true(SHOW_PLOTS)
    %plot(x,y,'-m');
    plot(x,y,'--w','LineWidth',2);
    plot(x(1),y(1),'og');
    text(x(1),y(1),num2str(i));
    plot(x(end),y(end),'or');
    text(x(end),y(end),num2str(i));
    end
    for j=1:length(perception.map.lanes(i).lanelets)
        laneletsOfLanes{i}=[laneletsOfLanes{i},find(laneletsIDs==perception.map.lanes(i).lanelets(j).id)];
    end
    for j=1:length(x)
        for k=1:length(laneletsOfLanes{i})
            indexX=find(laneletsList{laneletsOfLanes{i}(k)}.centerVertices(1,:)==x(j));
            indexY=find(laneletsList{laneletsOfLanes{i}(k)}.centerVertices(2,:)==y(j));
            if isempty(indexX)==0 && isempty(indexY)==0
                laneletsOfLanePoints{i}(j)=laneletsOfLanes{i}(k);
                break;
            end
        end
        if laneletsOfLanePoints{i}(j)==0
            error('lanelet of lane point is not found');
        end
    end
end



%Some trajectories start or end outside of their lane-boundary
%here, we cut the outside part of each abostacles trajectory
num_in_obs = 0;
new_obstacles = [];
for i=1:length(perception.map.obstacles)
    new_x = perception.map.obstacles(i).trajectory.position(1,:);
    new_y = perception.map.obstacles(i).trajectory.position(2,:);
    index_cnt = findLane(centerLine, length(perception.map.lanes), new_x, new_y);
    if isscalar(index_cnt)
        new_index = index_cnt;
    else
        new_index = index_cnt(1);
    end
    cl_xs = centerLine{new_index,1}(1,1);
    cl_xe = centerLine{new_index,1}(1,length(centerLine{new_index,1}));
    %cl_ys = centerLine{new_index,1}(2,1);
    %cl_ye = centerLine{new_index,1}(2,length(centerLine));

    %Todo: in future the assumption of fixed direction lanes must be
    %removed
    fidx_x = find(new_x >= cl_xs & new_x <= cl_xe);
    if isempty(fidx_x)==0
        x_len = length(new_x);
        new_x = new_x(:,fidx_x(1):x_len);
        new_y = new_y(:,fidx_x(1):x_len);
        new_theta = perception.map.obstacles(i).trajectory.orientation;
        new_v = perception.map.obstacles(i).trajectory.velocity;
        new_a = perception.map.obstacles(i).trajectory.acceleration;
        new_theta = new_theta(fidx_x(1):x_len);
        new_v = new_v(fidx_x(1):x_len);
        new_a = new_a(fidx_x(1):x_len);
        % setTrajectory - adds the given array of states to the trajectory object
        %   setTrajectory(obj, t, x, y, theta, v, a)
        new_ts = perception.map.obstacles(i).trajectory.timeInterval.ts;
        new_tf = perception.map.obstacles(i).trajectory.timeInterval.tf;
        new_dt = perception.map.obstacles(i).trajectory.timeInterval.dt;
        new_ts = new_ts + (fidx_x(1)-1)* new_dt; 
        new_timeInterval = [new_ts, new_ts+new_dt, new_tf];
        setTrajectory(perception.map.obstacles(i).trajectory, new_timeInterval, new_x, new_y, new_theta, new_v, new_a);
        %num_in_obs = num_in_obs+1;
        %new_obstacles(num_in_obs) = perception.map.obstacles(i);
    else
        setTrajectory(perception.map.obstacles(i).trajectory, [], [], [], [], [], []);
    end
    if isempty(perception.map.obstacles(i).trajectory)==0 && isempty(perception.map.obstacles(i).trajectory.position)==0
        new_x = perception.map.obstacles(i).trajectory.position(1,end);
        if new_x < (cl_xe-cut_from_end_of_trajectory)
            num_in_obs = num_in_obs+1;
            new_obstacles = [new_obstacles,perception.map.obstacles(i)];
        end
    end
end
setObstacles(perception.map, new_obstacles);

        %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%
    if true(SHOW_PLOTS)
        if true(RUN_TEST_MODE)
        plot(perception.map.obstacles(6));
        plot(perception.map.obstacles(10));
        end
    

%figure(3);
%title({'Vehicles which change lanes are non-yellow. Border lines are blue.';' The crossing points at lane borders are represented in Asterisk (*).'});
% axis equal;
%hold on;
    end
% An array of the size of lanes
szLane=length(perception.map.lanes);
fprintf('Number of lanes is %.0f\n', szLane(1));

tempDist=[];

% A cell array to save the lanes of each vehicle
% If the vehicle i changes the lane, then obstacles{i} is an array as follows
% [first lane, first sample in the first lane, last sample in the first lane;
% second lane, first sample in the second lane, last sample in the second lane; 
% third lane, first sample in the third lane, last sample in the third lane; 
obstacleLane=cell(length(perception.map.obstacles),1);

% A cell array to save the projection of the vehicle with respect to its
% lane. obstaclePoint contains the results of the function laneBasedPoints 
% which computes the lane-based coordination. 
obstaclePoint=cell(length(perception.map.obstacles),1);
totalTime=0;
%maximum times that an obstacle might renter the same lane
maxReEnter = 1;
%a loop to find lane based point of the vehicle with respect to the current
%and neighbor's lanes
for i=1:length(perception.map.obstacles)
    %if perception.map.obstacles(i).trajectory.timeInterval.ts~=0
    %    i;
    %    perception.map.obstacles(i).trajectory.timeInterval.ts;
    %end
    if totalTime<perception.map.obstacles(i).trajectory.timeInterval.tf
        totalTime=perception.map.obstacles(i).trajectory.timeInterval.tf;
    end
    %Some trajectories start or end outside of their lane-boundary
    %here, we cut the outside part of each abostacles trajectory
    
    x=perception.map.obstacles(i).trajectory.position(1,:);
    y=perception.map.obstacles(i).trajectory.position(2,:);
    index_cnt=findLane(centerLine,szLane,x,y);
    if isscalar(index_cnt)
        index = index_cnt;
    else
        index = index_cnt(1);
    end
    cl_xs = centerLine{index,1}(1,1);
    cl_xe = centerLine{index,1}(1,length(centerLine));
    cl_ys = centerLine{index,1}(2,1);
    cl_ye = centerLine{index,1}(2,length(centerLine));

    longDist=[];
    latDist=[];
    px=[];%projection x the star on the figure
    py=[];%projection y
    %added by Mohammad
    %this checks for each sector of the trajectory if it 
    %changes lane or not. Before, there was an assumption that
    %a trajectory only can cut the borders once
    sectorSize = cutLineErrorAcceptance;
    oldTmpIndex = 0;
    newIndex = [];
    
    for m=1:sectorSize:length(x)-sectorSize
        tmpIndex = findLane(centerLine,szLane,x(m:m+sectorSize-1),y(m:m+sectorSize-1));
        if (isscalar(tmpIndex) && oldTmpIndex~=tmpIndex)
            oldTmpIndex = tmpIndex;
            newIndex = [newIndex,tmpIndex];
        elseif (~isscalar(tmpIndex) && oldTmpIndex==tmpIndex(1))
            oldTmpIndex = tmpIndex(2);
            newIndex = [newIndex,tmpIndex(2)];
        elseif (~isscalar(tmpIndex) && oldTmpIndex~=tmpIndex(1))
            oldTmpIndex = tmpIndex(2);
            newIndex = [newIndex,tmpIndex];
        end
    end
    %index=findLane(centerLine,szLane,x,y);
    index = newIndex;
    if isempty(index) && length(x)<=sectorSize
        index = findLane(centerLine,szLane,x,y);
    end
    %end of changed by Mohammad
    
    if isscalar(index)==1 
        [px,py,longDist,latDist] = laneBasedPoints(x,y,centerLine,index,roadSegmentDist);
        obstacleLane{i}=index;
    else
    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%
    if true(SHOW_PLOTS)
        %plot(x,y,'.');
        plot(x,y,'--o',...
            'LineWidth',1,...
        'MarkerSize',1,...
        'MarkerEdgeColor','c',...
        'MarkerFaceColor',[0.5,0.5,0.5]);
      
    end
        cut_in=[];
        if length(index)>=2%changed by Mohammad from length(index)==2
            if index(1)>index(2) % turn left
                start=1;
                for j=index(1):-1:index(2)+1
                    ll=findCutInTime(perception.map.lanes(j).leftBorder.vertices,1,x(start:end),y(start:end));
                    if isempty(ll)==1
                        break;
                    end
                    ll=ll+start-1;
                    changedLaneValue = 0;
                    if maxReEnter < fix(length(ll)/2)
                        maxReEnter = fix(length(ll)/2);
                    end
                    for cutIndex=1:2:length(ll)%added by Mohammad
    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%
    if true(SHOW_PLOTS)
                    plot(x(ll(cutIndex)),y(ll(cutIndex)),'k*');
                    plot(x(ll(cutIndex+1)),y(ll(cutIndex+1)),'r*');
    end
                        cut_in=[cut_in;j-changedLaneValue,start,ll(cutIndex)];%changed by Mohammad
                        start=ll(cutIndex+1);
                        if changedLaneValue == 0
                            changedLaneValue = 1;
                        else
                            changedLaneValue = 0;
                        end
                    end
                end
                if isempty(ll)==1
                    cut_in=[cut_in;index(1),start,length(x)];
                else
                    cut_in=[cut_in;index(2),start,length(x)];
                end
                szci=size(cut_in);
                points={};
                for j=1:szci(1)
                    px=[];
                    py=[];
                    longDist=[];
                    latDist=[];
                    [px,py,longDist,latDist] = laneBasedPoints(x(cut_in(j,2):cut_in(j,3)),y(cut_in(j,2):cut_in(j,3)),centerLine,cut_in(j,1),roadSegmentDist);
                    points{j}=[px;py;longDist;latDist];
                end
            elseif index(1)<index(2) % turn right
                start=1;
                for j=index(1):index(2)-1
                    ll=findCutInTime(perception.map.lanes(j).rightBorder.vertices,0,x(start:end),y(start:end));
                    if isempty(ll)==1
                        break;
                    end
                    ll=ll+start-1;
                    changedLaneValue = 0;
                    if maxReEnter < fix(length(ll)/2)
                        maxReEnter = fix(length(ll)/2);
                    end
                    for cutIndex=1:2:length(ll)%added by Mohammad
    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%
    if true(SHOW_PLOTS)
                    plot(x(ll(cutIndex)),y(ll(cutIndex)),'k*');
                    plot(x(ll(cutIndex+1)),y(ll(cutIndex+1)),'r*');
    end
                        cut_in=[cut_in;j+changedLaneValue,start,ll(cutIndex)];%changed by Mohammad
                        start=ll(cutIndex+1);
                        if changedLaneValue == 0
                            changedLaneValue = 1;
                        else
                            changedLaneValue = 0;
                        end
                    end
                    %cut_in=[cut_in;j,start,ll(1)];
                    %start=ll(2);
                end
                if isempty(ll)==1
                    cut_in=[cut_in;index(1),start,length(x)];
                else
                    cut_in=[cut_in;index(2),start,length(x)];
                end
                szci=size(cut_in);
                points={};
                for j=1:szci(1)
                    px=[];
                    py=[];
                    longDist=[];
                    latDist=[];
                    [px,py,longDist,latDist] = laneBasedPoints(x(cut_in(j,2):cut_in(j,3)),y(cut_in(j,2):cut_in(j,3)),centerLine,cut_in(j,1),roadSegmentDist);
                    points{j}=[px;py;longDist;latDist];
                end
            end
        elseif isempty(index)
            error('crossing line is empty');
        else
            error('crossing line is more than 2!');
        end
        obstacleLane{i}=cut_in;
        fprintf('Vehicle %d changes lane\n', i);
    end
    if isscalar(obstacleLane{i})==1
        obstaclePoint{i}=[px;py;longDist;latDist];
    elseif isempty(obstacleLane{i})==0
        obstaclePoint{i}=points;
    end
end

    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%
    if true(SHOW_PLOTS)

% plot initial configuration
if globalPck.PlotProperties.SHOW_INITAL_CONFIGURATION
    figure('Name','Initial configuration')
    perception.plot();
    if globalPck.PlotProperties.PRINT_FIGURE
        saveas(gcf,'Initial configuration','epsc')
    end
end
%TEST
if true(RUN_TEST_MODE)
axis([-20 120 -12 18])
end
    end   
% Contains the number of vehicles
szObst=size(obstaclePoint);

% Contains initial sample of each vehicle
initSample=zeros(szObst(1),1);

% This Contains the number of samples in the scenario
samples= ceil(totalTime/dt_prediction)+1;

% A three dimension array for showing the samples in which the vehicles are 
% represented (exist) in the driving scenario:
% obstacleSamples(A,B,C)=1 when vehicle A exists in sample B and
% in lane C
% obstacleSamples(A,B,C)=0 when vehicle A does not exist in sample B and
% in lane C
obstacleSamples=zeros(szObst(1),samples,szLane(1));


% An array to save the CommonRoad's id of all vehicles 
obstacleIDs=zeros(szObst(1),1);
for i = 1:szObst(1)
    if isscalar(obstacleLane{i})==1
        interval=perception.map.obstacles(i).trajectory.timeInterval;
        indexS=interval.ts/interval.dt+1;
        indexE=interval.tf/interval.dt+1;
        for j=round(indexS):round(indexE)
            obstacleSamples(i,j,obstacleLane{i})=1;
        end
        initSample(i)=round(indexS-1);
        obstacleIDs(i)=perception.map.obstacles(i).id;
    elseif isempty(obstacleLane{i})==0
        interval=perception.map.obstacles(i).trajectory.timeInterval;
        indexS=interval.ts/interval.dt+1;
        indexE=interval.tf/interval.dt+1;
        initSample(i)=round(indexS-1);
        cut_in=obstacleLane{i};
        szci=size(cut_in);
        for j=1:szci(1)
            for k=cut_in(j,2):cut_in(j,3)
                obstacleSamples(i,k,cut_in(j,1))=1;
            end
        end
        obstacleIDs(i)=perception.map.obstacles(i).id;        
    end
end
for i = 1:szObst(1)
    if isscalar(obstacleLane{i})==1
        zz=size(obstaclePoint{i});
        if zz(2)~=0
            jj=find(obstacleSamples(i,:,obstacleLane{i})==1);
            if zz(2)~=length(jj)
                error('Incorrect number of samples');
            end
        else
            obstacleSamples(i,:,:)=0;
        end
    elseif isempty(obstacleLane{i})==0
        cut_in=obstacleLane{i};
        for j=1:length(obstaclePoint{i})
            zz=size(obstaclePoint{i}{j});
            if zz(2)~=0
                jj=find(obstacleSamples(i,:,cut_in(j,1))==1);
                if zz(2)>length(jj)%changed by Mohammad from zz(2)~=length(jj)
                    error('Incorrect number of samples');
                end
            else
                obstacleSamples(i,:,:)=0;
            end
        end
    else
        obstacleSamples(i,:,:)=0;
    end
end
% distancReflection contains the lateral and longitudinal distances of
% each vehicle with respect to its neighboring lanes.
distancReflection=cell(length(obstaclePoint),szLane(1));

% distancReflection contains the first sample for the vehicles which their
% lane
fistSampleChangeLane=zeros(length(obstaclePoint),szLane(1));
for i=1:length(obstacleLane)
    if isscalar(obstacleLane{i})==1
        distancReflection{i,obstacleLane{i}}=obstaclePoint{i};
        px=[];
        py=[];
        longDist=[];
        latDist=[];
        x=perception.map.obstacles(i).trajectory.position(1,:);
        y=perception.map.obstacles(i).trajectory.position(2,:);
        if obstacleLane{i}==1
            [px,py,longDist,latDist] = laneBasedPoints(x,y,centerLine,2,roadSegmentDist);
            distancReflection{i,2}=[px;py;longDist;latDist];
        elseif obstacleLane{i}==szLane(1)
            [px,py,longDist,latDist] = laneBasedPoints(x,y,centerLine,szLane(1)-1,roadSegmentDist);
            distancReflection{i,szLane(1)-1}=[px;py;longDist;latDist];
        else
            [px,py,longDist,latDist] = laneBasedPoints(x,y,centerLine,obstacleLane{i}-1,roadSegmentDist);
            distancReflection{i,obstacleLane{i}-1}=[px;py;longDist;latDist];
            px=[];
            py=[];
            longDist=[];
            latDist=[];
            [px,py,longDist,latDist] = laneBasedPoints(x,y,centerLine,obstacleLane{i}+1,roadSegmentDist);
            distancReflection{i,obstacleLane{i}+1}=[px;py;longDist;latDist];
        end
    elseif isempty(obstacleLane{i})==0
        cut_in=obstacleLane{i};
        szci=size(cut_in);
        x=perception.map.obstacles(i).trajectory.position(1,:);
        y=perception.map.obstacles(i).trajectory.position(2,:);
        start=1;
        %for j=1:szci(1)%todo: commented by Mohammad
        %    currentLine=cut_in(j,1);
        %    distancReflection{i,currentLine}=obstaclePoint{i}{j};
        %    fistSampleChangeLane(i,currentLine)=cut_in(j,2);%todo: check this later
        %end
        
        %holds the index of the obstaclePoint with respect to the
        %currentLine
        tmpObstaclePointIndex = zeros(i,szLane(1));
        for j=1:szci(1)%todo: commented by Mohammad
           currentLine=cut_in(j,1);
           tmpObstaclePointIndex(i,currentLine) = j;
           fistSampleChangeLane(i,currentLine)=cut_in(1,2);%todo: check this later
        end
        for j=1:szci(1)
            currentLine=cut_in(j,1);
            px=[];
            py=[];
            longDist=[];
            latDist=[];
            xr=[];
            xr2=[];
            index=[];
            index2=[];

            if currentLine==1 
                xr=xor(obstacleSamples(i,:,1),obstacleSamples(i,:,2));
                xr2=and(obstacleSamples(i,:,1),xr);
                index=find(xr2==1);
                index2=find(obstacleSamples(i,:,2)==1);
                [px,py,longDist,latDist] = laneBasedPoints(x(index),y(index),centerLine,2,roadSegmentDist);
                temp=[px;py;longDist;latDist];
                if   isempty(index2)==1
                    distancReflection{i,2}=temp;
                    fistSampleChangeLane(i,2)=index(1);
                elseif   index(1)>index2(end) 
                    distancReflection{i,2}=[obstaclePoint{i}{tmpObstaclePointIndex(i,2)},temp]; 
                    %distancReflection{i,2}=[distancReflection{i,2},temp];%todo: commented by Mohammad 
                elseif  index(end)<index2(1)
                    distancReflection{i,2}=[temp,obstaclePoint{i}{tmpObstaclePointIndex(i,2)}];
                    %distancReflection{i,2}=[temp,distancReflection{i,2}];%todo: commented by Mohammad
                    fistSampleChangeLane(i,2)=index(1);
                elseif index2(1) < index(end)%added by Mohammad
                    %fistSampleChangeLane(i,currentLine+1)=index2(1);
                    newTemp = [];
                    overHead = 0;
                    for k=1:szci(1)
                        if cut_in(k,1) == (currentLine+1)
                            newTemp = [newTemp,obstaclePoint{i}{k}];
                            overHead = overHead + cut_in(k,3)-cut_in(k,2)+1;
                        elseif cut_in(k,1) == (currentLine)
                            newTemp = [newTemp,temp(:,cut_in(k,2)-overHead:cut_in(k,3)-overHead)];
                        else
                            newTemp = [newTemp,NaN([4,cut_in(k,3)-cut_in(k,2)+1])];
                        end
                    end
                    distancReflection{i,currentLine+1}=newTemp;%end of added by Mohammad
                else
                    error('ERROR');
                end
            elseif currentLine==szLane(1)
                xr=xor(obstacleSamples(i,:,szLane(1)),obstacleSamples(i,:,szLane(1)-1));
                xr2=and(obstacleSamples(i,:,szLane(1)),xr);
                index=find(xr2==1);
                index2=find(obstacleSamples(i,:,szLane(1)-1)==1);
                [px,py,longDist,latDist] = laneBasedPoints(x(index),y(index),centerLine,szLane(1)-1,roadSegmentDist);
                temp=[px;py;longDist;latDist];
                if   isempty(index2)==1
                    distancReflection{i,szLane(1)-1}=temp;
                    fistSampleChangeLane(i,szLane(1)-1)=index(1);
                elseif   index(1)>index2(end)
                    distancReflection{i,szLane(1)-1}=[obstaclePoint{i}{tmpObstaclePointIndex(i,currentLine-1)},temp]; 
                    %distancReflection{i,szLane(1)-1}=[distancReflection{i,szLane(1)-1},temp]; 
                elseif  index(end)<index2(1)
                    distancReflection{i,szLane(1)-1}=[temp,obstaclePoint{i}{tmpObstaclePointIndex(i,currentLine-1)}]; 
                    %distancReflection{i,szLane(1)-1}=[temp,distancReflection{i,szLane(1)-1}];
                    fistSampleChangeLane(i,szLane(1)-1)=index(1);
                elseif index2(1) < index(end)%added by Mohammad
                    %fistSampleChangeLane(i,currentLine-1)=index2(1);
                    newTemp = [];
                    overHead = 0;
                    for k=1:szci(1)
                        if cut_in(k,1) == (currentLine-1)
                            newTemp = [newTemp,obstaclePoint{i}{k}];
                            overHead = overHead + cut_in(k,3)-cut_in(k,2)+1;
                        elseif cut_in(k,1) == (currentLine)
                            newTemp = [newTemp,temp(:,cut_in(k,2)-overHead:cut_in(k,3)-overHead)];
                        else
                            newTemp = [newTemp,NaN([4,cut_in(k,3)-cut_in(k,2)+1])];
                        end
                    end
                    distancReflection{i,currentLine-1}=newTemp;%end of added by Mohammad
                else
                    error('ERROR');
                end
            else
                xr=xor(obstacleSamples(i,:,currentLine-1),obstacleSamples(i,:,currentLine));
                xr2=and(obstacleSamples(i,:,currentLine),xr);
                index=find(xr2==1);
                index2=find(obstacleSamples(i,:,currentLine-1)==1);
                [px,py,longDist,latDist] = laneBasedPoints(x(index),y(index),centerLine,currentLine-1,roadSegmentDist);
                temp=[px;py;longDist;latDist];
                if   isempty(index2)==1
                    distancReflection{i,currentLine-1}=temp;
                    fistSampleChangeLane(i,currentLine-1)=index(1);
                elseif   index(1)>index2(end)
                    distancReflection{i,currentLine-1}=[obstaclePoint{i}{tmpObstaclePointIndex(i,currentLine-1)},temp]; 
                    %distancReflection{i,currentLine-1}=[distancReflection{i,currentLine-1},temp]; 
                elseif  index(end)<index2(1)
                    distancReflection{i,currentLine-1}=[temp,obstaclePoint{i}{tmpObstaclePointIndex(i,currentLine-1)}]; 
                    %distancReflection{i,currentLine-1}=[temp,distancReflection{i,currentLine-1}];
                    fistSampleChangeLane(i,currentLine-1)=index(1);
                elseif index2(1) < index(end)%added by Mohammad
                    %fistSampleChangeLane(i,currentLine-1)=index2(1);
                    newTemp = [];
                    overHead = 0;
                    for k=1:szci(1)
                        if cut_in(k,1) == (currentLine-1)
                            newTemp = [newTemp,obstaclePoint{i}{k}];
                            overHead = overHead + cut_in(k,3)-cut_in(k,2)+1;
                        elseif cut_in(k,1) == (currentLine)
                            newTemp = [newTemp,temp(:,cut_in(k,2)-overHead:cut_in(k,3)-overHead)];
                        else
                            newTemp = [newTemp,NaN([4,cut_in(k,3)-cut_in(k,2)+1])];
                        end
                    end
                    distancReflection{i,currentLine-1}=newTemp;%end of added by Mohammad 
                else
                    error('ERROR');
                end
                px=[];
                py=[];
                longDist=[];
                latDist=[];
                xr=[];
                xr2=[];
                index=[];
                index2=[];
                xr=xor(obstacleSamples(i,:,currentLine+1),obstacleSamples(i,:,currentLine));
                xr2=and(obstacleSamples(i,:,currentLine),xr);
                index=find(xr2==1);
                index2=find(obstacleSamples(i,:,currentLine+1)==1);
                [px,py,longDist,latDist] = laneBasedPoints(x(index),y(index),centerLine,currentLine+1,roadSegmentDist);
                temp=[px;py;longDist;latDist];
                if   isempty(index2)==1
                    distancReflection{i,currentLine+1}=temp;
                    fistSampleChangeLane(i,currentLine+1)=index(1);
                elseif   index(1)>index2(end)
                    distancReflection{i,currentLine+1}=[obstaclePoint{i}{tmpObstaclePointIndex(i,currentLine+1)},temp]; 
                    %distancReflection{i,currentLine+1}=[distancReflection{i,currentLine+1},temp]; 
                elseif  index(end)<index2(1)
                    distancReflection{i,currentLine+1}=[temp,obstaclePoint{i}{tmpObstaclePointIndex(i,currentLine+1)}]; 
                    %distancReflection{i,currentLine+1}=[temp,distancReflection{i,currentLine+1}];
                    fistSampleChangeLane(i,currentLine+1)=index(1);
                elseif index2(1) < index(end)%added by Mohammad
                    %fistSampleChangeLane(i,currentLine+1)=index2(1);
                    newTemp = [];
                    overHead = 0;
                    for k=1:szci(1)
                        if cut_in(k,1) == (currentLine+1)
                            newTemp = [newTemp,obstaclePoint{i}{k}];
                            overHead = overHead + cut_in(k,3)-cut_in(k,2)+1;
                        elseif cut_in(k,1) == (currentLine)
                            newTemp = [newTemp,temp(:,cut_in(k,2)-overHead:cut_in(k,3)-overHead)];
                        else
                            newTemp = [newTemp,NaN([4,cut_in(k,3)-cut_in(k,2)+1])];
                        end
                    end
                    distancReflection{i,currentLine+1}=newTemp;%end of added by Mohammad
                else
                    error('ERROR');
                end
            end%end of currnetLine == 1
        end%end of for j=1:szci(1)
    end
end%end of for i

% Cell array that contains the vehicle indices of each lane
sameLines=cell(szLane(1),1);

% Cell array that contains the vehicle indices of the front car for each vehicle.
% If vehicle j changes the lane, then frontID{j} is a two dimension array as
% follow:
% [ line1 , front car index in line1;
%   line2 , front car index in line2;
%   line3 , front car index in line3]
frontID=cell(szObst(1),1);

% Cell array that contains the vehicle indices of the left car for each vehicle.
% If vehicle j changes the lane, then leftID{j} is a two dimension array as
% follow:
% [ line1 , left car index with respect to line1;
%   line2 , left car index with respect to line2;
%   line3 , left car index with respect to line3]
leftID=cell(szObst(1),1);

% Cell array that contains the vehicle indices of the right car for each vehicle.
% If vehicle j changes the lane, then rightID{j} is a two dimension array as
% follow:
% [ line1 , right car index with respect to line1;
%   line2 , right car index with respect to line2;
%   line3 , right car index with respect to line3]
rightID=cell(szObst(1),1);

for i = 1:szObst(1)
    if isscalar(obstacleLane{i})==1
        line=obstacleLane{i};
        sameLines{line}=[sameLines{line},i];
    else
        cut_in=obstacleLane{i};
        szci=size(cut_in);
        for j=1:szci(1)
            if isempty(find(sameLines{cut_in(j,1)}==i))%added by Mohammad
                sameLines{cut_in(j,1)}=[sameLines{cut_in(j,1)},i];
            end
        end
    end
end
%mfills the empty beginning and ending of trajectories
for i = 1:szObst(1)
    if  isscalar(obstacleLane{i})==1%obstacleLane(i)~=0
        indeces=find(obstacleSamples(i,:,obstacleLane{i})==1);
        for k=1:szLane(1)
            prefix=[];%from the beginning of the simulation to the start time of the obstcle 
            %(for the absence of the obstcles in the beginning)
            suffix=[];%from stop time of the obstacle to the end of the simulation
            %prefix and suffix are filling the gaps of the whole simulation when the ostacle does not exist 
            if isempty(distancReflection{i,k})==0
                if isempty(indeces)==0 && indeces(1)~=1
                    for j=1:indeces(1)-1
                        prefix=[prefix,distancReflection{i,k}(:,1)];
                    end
                    distancReflection{i,k}=[prefix,distancReflection{i,k}];
                end
                if isempty(indeces)==0 && obstacleSamples(i,end,obstacleLane{i})==0
                    for j=indeces(end)+1:samples
                        suffix=[suffix,distancReflection{i,k}(:,end)];
                    end
                    distancReflection{i,k}=[distancReflection{i,k},suffix];
                end
            end
        end
    else
        for j=1:szLane(1)
            if  fistSampleChangeLane(i,j)~=0
                prefix=[];
                suffix=[];
                for k=1:fistSampleChangeLane(i,j)-1
                    prefix=[prefix,distancReflection{i,j}(:,1)];
                end
                distancReflection{i,j}=[prefix,distancReflection{i,j}];
                ll=size(distancReflection{i,j});
                for k=ll(2)+1:samples
                    suffix=[suffix,distancReflection{i,j}(:,end)];
                end
                distancReflection{i,j}=[distancReflection{i,j},suffix];
            end
        end             
    end
end

for i = 1:szObst(1)
    for k=1:szLane(1)
        zz=size(distancReflection{i,k});
        if zz(2)~=samples && zz(2)~=0
            error('samples are not equal');
        end
    end
end
%this loop finds all the front cars for each obstacle
for i = 1:szLane(1)
    for j=1:length(sameLines{i})
        indeces=[];
        obstacleID=sameLines{i}(j);
        toalIndeces = {[]};%added by Mohammad: begin
        indecesIn=find(obstacleSamples(obstacleID,:,i)==1);%changed by Mohammad
        revisitIdx = find(diff(indecesIn)~=1);
        if isempty(revisitIdx)==0
            revCount = length(revisitIdx)+1;
            sIdx = 1;
            for k=1:revCount-1
               toalIndeces{k} = indecesIn(sIdx:revisitIdx(k));
               sIdx = revisitIdx(k)+1;
            end
               toalIndeces{k+1} = indecesIn(find(indecesIn >= indecesIn(sIdx)));
        else
            revCount = 1;
            toalIndeces{1} = indecesIn;
        end
        for revIdx=1:revCount
            indeces = toalIndeces{revIdx};%end of added by Mohammad
            for indx=1:length(indeces)
                locs=[];
                frontIndex=[];
                for k=1:length(sameLines{i})
                    if k~=j && obstacleSamples(sameLines{i}(k),indeces(indx),i)==1
                        locs=[locs,distancReflection{sameLines{i}(k),i}(3,indeces(indx))];
                    else
                        locs=[locs,-100000];
                    end
                end       
                [frontIndex]=find(locs>distancReflection{obstacleID,i}(3,indeces(indx)));
                if isempty(frontIndex)==0
                    minIndex=[];
                    minValue=[];
                    [ minValue minIndex]=min(locs(frontIndex));
                    if isscalar(obstacleLane{obstacleID})==1
                        found=[];
                        found=find(frontID{obstacleID}==sameLines{i}(frontIndex(minIndex)));
                        if isempty(found)
                            frontID{obstacleID}=[frontID{obstacleID},sameLines{i}(frontIndex(minIndex))];
                        end
                    else
                        found=[];
                        if isempty(frontID{obstacleID})==0
                            found=find(frontID{obstacleID}(:,2)==sameLines{i}(frontIndex(minIndex)));
                        end
                        if isempty(found)
                            frontID{obstacleID}=[frontID{obstacleID};i,sameLines{i}(frontIndex(minIndex))];
                        elseif length(found) < revCount%added by Mohammad
                            frontID{obstacleID}=[frontID{obstacleID};i,sameLines{i}(frontIndex(minIndex))];
                        end
                    end
                end
            end%idx
        end%revCount
    end
end
%finds the left and right vehicles of each obstacle
for i = 1:szLane(1)
    for j=1:length(sameLines{i})
        indeces=[];
        obstacleID=sameLines{i}(j);
        toalIndeces = {[]};%added by Mohammad: begin
        indecesIn=find(obstacleSamples(obstacleID,:,i)==1);%changed by Mohammad
        revisitIdx = find(diff(indecesIn)~=1);
        if isempty(revisitIdx)==0
            revCount = length(revisitIdx)+1;
            sIdx = 1;
            for k=1:revCount-1
               toalIndeces{k} = indecesIn(sIdx:revisitIdx(k));
               sIdx = revisitIdx(k)+1;
            end
               toalIndeces{k+1} = indecesIn(find(indecesIn >= indecesIn(sIdx)));
        else
            revCount = 1;
            toalIndeces{1} = indecesIn;
        end
        for revIdx=1:revCount
            indeces = toalIndeces{revIdx};%end of added by Mohammad        
            if i<szLane(1)
                for indx=1:length(indeces)
                    locs=[];
                    rightIndex=[];
                    for k=1:length(sameLines{i+1})
                        if obstacleSamples(sameLines{i+1}(k),indeces(indx),i+1)==1
                            locs=[locs,distancReflection{sameLines{i+1}(k),i}(3,indeces(indx))];
                        else
                            locs=[locs,-100000];
                        end
                    end       
                    [rightIndex]=find(locs>distancReflection{obstacleID,i}(3,indeces(indx)));
                    if isempty(rightIndex)==0
                        if isscalar(obstacleLane{obstacleID})==1
                            if isempty(rightID{obstacleID})==1
                                rightID{obstacleID}=sameLines{i+1}(rightIndex);
                            else
                                found=[];
                                newIndex=[];
                                for k=1:length(rightIndex)
                                    found=find(rightID{obstacleID}==sameLines{i+1}(rightIndex(k)));
                                    if  isempty(found)==1
                                        newIndex=[newIndex,sameLines{i+1}(rightIndex(k))];
                                    end
                                end
                                rightID{obstacleID}=[rightID{obstacleID},newIndex];
                            end
                        else
                            if isempty(rightID{obstacleID})==1
                                newIndex=[];
                                for k=1:length(rightIndex)
                                    newIndex=[newIndex;i+1,sameLines{i+1}(rightIndex(k))];
                                end
                                rightID{obstacleID}=newIndex;
                            else
                                found=[];
                                newIndex=[];
                                for k=1:length(rightIndex)
                                    found=find(rightID{obstacleID}(:,2)==sameLines{i+1}(rightIndex(k)));
                                    if  isempty(found)==1
                                        newIndex=[newIndex;i+1,sameLines{i+1}(rightIndex(k))];
                                    elseif length(found) < revCount%added by Mohammad
                                        newIndex=[newIndex;i+1,sameLines{i+1}(rightIndex(k))];
                                    end
                                end
                                rightID{obstacleID}=[rightID{obstacleID};newIndex];

                            end
                        end     
                    end
                end
            end
            if i>1
                for indx=1:length(indeces)
                    locs=[];
                    leftIndex=[];
                    for k=1:length(sameLines{i-1})
                        if obstacleSamples(sameLines{i-1}(k),indeces(indx),i-1)==1
                            locs=[locs,distancReflection{sameLines{i-1}(k),i}(3,indeces(indx))];
                        else
                            locs=[locs,-100000];
                        end
                    end       
                    [leftIndex]=find(locs>distancReflection{obstacleID,i}(3,indeces(indx)));
                    if isempty(leftIndex)==0
                        if isscalar(obstacleLane{obstacleID})==1
                            if isempty(leftID{obstacleID})==1
                                leftID{obstacleID}=sameLines{i-1}(leftIndex);
                            else
                                found=[];
                                newIndex=[];
                                for k=1:length(leftIndex)
                                    found=find(leftID{obstacleID}==sameLines{i-1}(leftIndex(k)));
                                    if  isempty(found)==1
                                        newIndex=[newIndex,sameLines{i-1}(leftIndex(k))];
                                    end
                                end
                                leftID{obstacleID}=[leftID{obstacleID},newIndex];
                            end
                        else
                            if isempty(leftID{obstacleID})==1
                                newIndex=[];
                                for k=1:length(leftIndex)
                                    newIndex=[newIndex;i-1,sameLines{i-1}(leftIndex(k))];
                                end
                                leftID{obstacleID}=newIndex;
                            else
                                found=[];
                                newIndex=[];
                                for k=1:length(leftIndex)
                                    found=find(leftID{obstacleID}(:,2)==sameLines{i-1}(leftIndex(k)));
                                    if  isempty(found)==1
                                        newIndex=[newIndex;i-1,sameLines{i-1}(leftIndex(k))];
                                    elseif length(found) < revCount%added by Mohammad
                                        newIndex=[newIndex;i-1,sameLines{i-1}(leftIndex(k))];
                                    end
                                end
                                leftID{obstacleID}=[leftID{obstacleID};newIndex];

                            end
                        end     
                    end
                end%indx
            end%i>1
        end%revIdx
    end%j
end%i
% A vector of the ego vehicle index and its corresponding front car in the 
% following format:
% [ line index of ego vehicle, ego vehicle index , ego vehicle's front car index ]
egoFrontCar=[];

% A vector of the ego vehicle index and its corresponding left car in the 
% following format:
% [ line index of ego vehicle, ego vehicle index , ego vehicle's left car index ]
egoLeftCar=[];

% A vector of the ego vehicle index and its corresponding right car in the 
% following format:
% [ line index of ego vehicle, ego vehicle index , ego vehicle's right car index ]
egoRightCar=[];

for i=1:length(obstacleLane)
    if  isscalar(obstacleLane{i})==1
        currLine=obstacleLane{i};
        for j=1:length(frontID{i})
            found=[];
            found=find(frontID{i}(j)==sameLines{currLine});
            if isempty(found)
                error('frontID is incorrect');
            end
            egoFrontCar=[egoFrontCar;currLine,i,frontID{i}(j)];
        end
        if currLine>1
            for j=1:length(leftID{i})
                found=[];
                found=find(leftID{i}(j)==sameLines{currLine-1});
                if isempty(found)
                    error('leftID is incorrect');
                end
                egoLeftCar=[egoLeftCar;currLine,i,leftID{i}(j)];
            end
        end
        if currLine<szLane(1)
            for j=1:length(rightID{i})
                found=[];
                found=find(rightID{i}(j)==sameLines{currLine+1});
                if isempty(found)
                    error('leftID is incorrect');
                end
                egoRightCar=[egoRightCar;currLine,i,rightID{i}(j)];
            end
        end
    else%multi lane
        szid=size(obstacleLane{i});
        visLineList = [];
        for j=1:szid(1)
            currLine=obstacleLane{i}(j,1);
            newLine = false;%added by Mohammad
            if isempty(find(visLineList==currLine))
                visLineList = [visLineList,currLine];
                newLine = true;
            end
            if isempty(frontID{i})==0 & newLine%changed by Mohammad
                szfid=size(frontID{i});
                for k=1:szfid(1)
                    if frontID{i}(k,1)==currLine
                        found=[];
                        found=find(frontID{i}(k,2)==sameLines{currLine});
                        if isempty(found)
                            error('frontID is incorrect');
                        end 
                        egoFrontCar=[egoFrontCar;currLine,i,frontID{i}(k,2)];
                    end
                end
            end
            if currLine>1 && isempty(leftID{i})==0 & newLine%changed by Mohammad
                szlid=size(leftID{i});
                for k=1:szlid(1)
                    if leftID{i}(k,1)==currLine-1
                        found=[];
                        found=find(leftID{i}(k,2)==sameLines{currLine-1});
                        if isempty(found)
                            error('leftID is incorrect');
                        end 
                        egoLeftCar=[egoLeftCar;currLine,i,leftID{i}(k,2)];
                    end
                end
            end
            if currLine<szLane(1) && isempty(rightID{i})==0 & newLine%changed by Mohammad
                szrid=size(rightID{i});
                for k=1:szrid(1)
                    if rightID{i}(k,1)==currLine+1
                        found=[];
                        found=find(rightID{i}(k,2)==sameLines{currLine+1});
                        if isempty(found)
                            error('rightID is incorrect');
                        end
                        egoRightCar=[egoRightCar;currLine,i,rightID{i}(k,2)];
                    end
                end
            end
        end
    end
end

%-------------------------------------------------
%currently only rear cars are considered as ego vehicle which should
%monitor the opponent
%%%NEW implentation to be done
%todo: egoLeftCar and egoRightCar should be updated with considering to be
%back of ego cars too
%ex. assume egoCar==10 leftCar==12 on the lane 3 (lane of the ego car)
%this representation is saved in the follwoing matrix in egoLeftCar:
%[3, 10, 12]
%for considering latteral safety with respect to rear cars the following
%data should be added to egoRightCar:
%[2, 12, 10]
%-------------------------------------------------

% outputDataResult = struct('samples', samples ,...
%                     'dt_prediction', dt_prediction ,...
%                     'egoFrontCar', egoFrontCar ,...
%                     'egoLeftCar', egoLeftCar ,...
%                     'egoRightCar', egoRightCar ,...
%                     'obstacleLane', obstacleLane ,...
%                     'obstacleSamples', obstacleSamples ,...
%                     'obstacleIDs', obstacleIDs);

end

