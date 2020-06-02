function writeToXML(map, filename, exportType, timeStart, timeFinish)
% writeToXML - writes all data of traffic scenario to a XML file
%
% Inputs:
%   map - object file of type Map which contains all data of the scenario
%   filename - full path- and filename to the XML file
%   exportType - determine if trajectory, occupancySet or
%                probabilityDistribution should be exported.
%                0 = no obstacles (only lanelets)
%                1 = trajectory
%                2 = occupancy set
%                3 = probabilityDistribution
%   timeStart - starting time of exported scenario
%   timeFinish - end point of exported scenario
%
% Outputs:
%   xml file containing all scenario information is saved at specified location
%
% Other m-files required: exportLanelet.m exportStaticObstacle.m
%                         exportDynamicObstacle.m exportState.m
% Subfunctions: none
% MAT-files required: none
%
%
% Author:       Lukas Willinger
% Written:      03-April-2017
% Last update:  22-August-2017 Markus Koschi
%
%

%------------- BEGIN CODE --------------

format long;

% check number of arguments
switch nargin
    case 5
    case 4
        warning('Time interval not complete. Finish time is set to INF');
        timeFinish = inf;
    case 3
        timeStart = -inf;
        timeFinish = inf;
    case 2
        timeStart = -inf;
        timeFinish = inf;
        exportType = 1;
        warning('DEFAULT: Trajectories are exported (exportType = 1).');
    case 1
        error('Input argument error: No filename defined');
    otherwise
        error('Wrong input arguments');
end

% check if file already exists
[pathstr,name,ext] = fileparts(filename);
if strcmp(pathstr,'')
    pathstr = pwd;
end
filename = fullfile(pathstr, [name ext]);
if exist(filename,'file') == 2
    error('File exists already. Rename file to avoid overwriting.');
end

% check exportType
if ~ismember([0,1,2,3],exportType)
    error('exportType has to be 0, 1, 2, or 3. Check description!');
end

% create XML file and header
doc = com.mathworks.xml.XMLUtils.createDocument('commonRoad');
rootNode = doc.getDocumentElement();
rootNode.setAttribute('commonRoadVersion', '2017a');
if ~isempty(map.scenarioID)
    rootNode.setAttribute('benchmarkID',map.scenarioID);
else
    rootNode.setAttribute('benchmarkID','UNKNOWN');
end
rootNode.setAttribute('date', datestr(datetime, 'yyyy-mm-dd'));


%-----------------LANELETS-------------------------------------------%

for i = 1:numel(map.lanelets)
    laneletNode = output.exportLanelet(doc,map.lanelets(i));
    doc.getDocumentElement.appendChild(laneletNode);
end


% ---------- OBSTACLES ----------------------------------------------%

% export obstacles and ego vehicle only if exportType is 1, 2, or 3
if ismember([1,2,3],exportType)
    
    %map.update(timeStart);    
    timeStepSize = map.timeStepSize;
    
    for i = 1:numel(map.obstacles)
        % Distuingish between static and dynamic obstacles and export
        % accordingly
        if isa(map.obstacles(i),'world.StaticObstacle')
            for j = 1:numel(map.obstacles(i).shape) % Export multiple obstacles for multiple shape elements
                obstacleNode = output.exportStaticObstacle(doc,map.obstacles(i),map.obstacles(i).shape(j));
                doc.getDocumentElement.appendChild(obstacleNode);
            end
        elseif isa(map.obstacles(i),'world.DynamicObstacle')
            [obstacleNode,timeStepSizeNew] = output.exportDynamicObstacle(doc,...
                map.obstacles(i),exportType,map.timeStepSize,timeStart,timeFinish);
            doc.getDocumentElement.appendChild(obstacleNode);
            
            % Adjust timeStepSize for varying timeSteps
            if abs(timeStepSize - timeStepSizeNew) > 0.00000001  % check if timeStepSize varies but avoid floating point inaccuracies
                timeStepSize = timeStepSizeNew;
                warning (strcat('timeStepSize of obstacles inconsistent with other obstacles or timeStepSize specified in map object.'));
            end
        else
            warning('Obstacle type UNKNOWN.');
        end
        
    end
    
    
    %------------------- EGO VEHICLES ------------------------------------%
    
    for i = 1:numel(map.egoVehicle)
        if ~isa(map.egoVehicle(i),'world.EgoVehicle')
            warning('EgoVehicle not of type egoVehicle.');
            continue;
        end
        planningProblem = doc.createElement('planningProblem');
        doc.getDocumentElement.appendChild(planningProblem);
        planningProblem.setAttribute('id',num2str(abs(map.egoVehicle(i).id)));
        planningProblem.appendChild(output.exportState(doc,map.egoVehicle(i).position,...
            map.egoVehicle(i).orientation,map.egoVehicle(i).velocity,...
            map.egoVehicle(i).acceleration,map.egoVehicle(i).time));
        for j = 1:numel(map.egoVehicle(i).goalRegion)
            goalRegion = doc.createElement('goalRegion');
            planningProblem.appendChild(goalRegion);
            goalRegion.appendChild(output.exportState(doc,map.egoVehicle(i).goalRegion(j)));
        end
    end
end


% Adjust timeStepSize according to obstacles
if exist('timeStepSize','var')
    rootNode.setAttribute('timeStepSize',num2str(timeStepSize));
elseif ~isempty(map.timeStepSize)
    rootNode.setAttribute('timeStepSize',num2str(map.timeStepSize))
else
    rootNode.setAttribute('timeStepSize','UNKNOWN');
end

% write DOM tree to XML and save with specified name
xmlwrite(filename, doc);

end

%------------- END CODE ------------------