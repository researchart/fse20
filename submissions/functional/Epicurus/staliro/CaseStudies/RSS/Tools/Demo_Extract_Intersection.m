% This demo extracts all the lanelet of the lines

% In Common roads, when there exists intersection between lines, the lanelets of
% the lines are the same. In this case the lanelets must be used to compute
% the lateral and longitudinal distances.


clear all;
close all;

xx=input('Enter the scenario number, a value between 1~28:');
inputFile = ['commonroad2017a/scenarios/NGSIM/Lankershim/NGSIM_Lanker_',num2str(xx),'.xml'];

% time interval of the scenario (step along trajectory of obstacles)
% (if ts == [], scenario will start at its beginning;
% if tf == [], scenario will run only for one time step)
% ToDO: tf to run the scenario until its end
ts_scenario = [];%*
% (dt_scenario is defined by given trajectory)
tf_scenario = [];

% time interval in seconds for prediction of the occupancy
ts_prediction = 0;
dt_prediction = 0.1;
tf_prediction = 1.5;

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

% plot initial configuration
if globalPck.PlotProperties.SHOW_INITAL_CONFIGURATION
    figure('Name','Initial configuration')
    perception.plot();
    if globalPck.PlotProperties.PRINT_FIGURE
        saveas(gcf,'Initial configuration','epsc')
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



figure(2);
title('Lane IDs');
% axis equal;
hold on;
for i=1:length(perception.map.lanelets)
    laneletsList{i}=perception.map.lanelets(i);
    laneletsIDs(i)=perception.map.lanelets(i).id;
end
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
    plot(x,y,'-b');
    plot(x(1),y(1),'og');
    text(x(1),y(1),num2str(i));
    plot(x(end),y(end),'or');
    text(x(end),y(end),num2str(i));
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
