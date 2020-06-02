function [obstacleNode,dt] = exportDynamicObstacle (doc,obstacle,exportType,timeStepSize,timeStart,timeFinish)
% exportDynamicObstacle - returns obstacle information as a DOM tree node
%
% Syntax:
%   exportDynamicObstacle(doc,obstacle,exportType,timeStepSize,timeStart,timeFinish)
%
% Inputs:
%   doc - DOM tree
%   obstacle - obstacle object to be exported
%   exportType - determine if trajectory, occupancySet or
%                probabilityDistribution should be exported.
%                0 = no obstacles (only lanelets)
%                1 = trajectory
%                2 = occupancy set
%                3 = probabilityDistribution
%   timeStepSize - time step size for inspection
%   timeStart - starting time of exported scenario
%   timeFinish - end point of exported scenario
%
% Outputs:
%   obstacleNode - DOM tree node containing all information about the
%   obstacle
%   timeStepSizeNew - timeStepSize of obstacle
%
%
% Other m-files required: exportShape.m, exportTrajectory.m,
%                           exportOccupancy.m


% Author:       Lukas Willinger
% Written:      10-April-2017
% Last update:  16-August-2017
%
% Last revision:---
%
%------------- BEGIN CODE --------------

switch exportType
    
    %%%%%%%%%%%%%%%%%%%%% export trajectory %%%%%%%%%%%%%%%%%%%%%%%%%%
    case 1
        % Check wheter Trajectory of obstacle is correct and in the requested time
        % interval
        if isempty(obstacle.trajectory)
            error(['Trajectory of obstacle with id = ', num2str(obstacle.id), ' is missing']);
        end
        
        % Check if trajectory is complete
        lengths = [size(obstacle.trajectory.position,2), ...
            size(obstacle.trajectory.acceleration,2), ...
            size(obstacle.trajectory.orientation,2), ...
            size(obstacle.trajectory.velocity,2)];
        if ~all(lengths(:) == lengths(:))
            error(['Trajectory of obstacle with id = ', num2str(obstacle.id), ' is in wrong format']);
        end
        
        % Save dt of current obstacle
        [tS,dt,tF] = obstacle.trajectory.timeInterval.getTimeInterval();
        if abs(timeStepSize - dt) > 0.00000001  % check if timeStepSize varies but avoid floating point inaccuracies
            warning(['Obstacle id = ', num2str(obstacle.id), ...
                ': timeStepSize of trajectory is not consistent with map timeStepSize']);
        end
        % 4 possible cases of start end finish times have to be
        % distinguished to determine right output interval
        % iS - start index for trajectory arrays
        % iF - end index for trajectory arrays
        if (timeStart <= tS)
            iS = 1; % First point of time to be exported <= first point of time of trajectory
        else
            iS = round((timeStart - tS)/dt) + 1;
            % Index to start exporting is calculated by the difference of the starting times
        end
        if timeFinish >= tF
            iF = length(obstacle.trajectory.orientation);
            % index to stop exporting is set to the last entry of the trajectory arrays
        else
            iF = round((timeFinish-tS)/dt) + 1;
            % Index to stop exporting is calculated by differnce of starting point of time
            % of the trajectory and the last point of time to be exported
        end
        
        % when the start index iS is lager than the finish index iF the
        % corresponding obstacle is not in the requested timeInterval and
        % therefore not exported
        
        if iS > iF
            return;
        end
        
        %%%%%%%%%%%%%%%%%%% export occupancySet %%%%%%%%%%%%%%%%%%%%%%%%%%
    case 2
        
        if isempty(obstacle.occupancy)
            error('Occupancy not specified.');
        end
        % save start and end point of time of obstacle occupancy
        [tS,dt,~] = obstacle.occupancy(1,1).timeInterval.getTimeInterval();
        [~,~,tF] = obstacle.occupancy(1,end).timeInterval.getTimeInterval();
        
        % calculate indices according to specified export time interval
        % 4 possible cases of start end finish times have to be
        % distinguished to determine right output interval
        % iS - start index for occupancy array
        % iF - end index for occupancy array
        
        if (timeStart <= tS)
            iS = 1; % First point of time to be exported <= first point of time of occupancy
        else
            iS = round((timeStart - tS)/dt) + 1;
            % Index to start exporting is calculated by the difference of the starting times
        end
        if timeFinish >= tF
            iF = size(obstacle.occupancy,2);
            % index to stop exporting is set to the last entry of the occupancy array
        else
            iF = round((timeFinish-tS)/dt);
            % Index to stop exporting is calculated by differnce of starting point of time
            % of the occupancy and the last point of time to be exported
        end
        
        % when the start index iS is lager than the finish index iF the
        % corresponding obstacle is not in the requested timeInterval and
        % therefore not exported
        
        if iS > iF
            return;
        end
        
        if dt ~= timeStepSize
            warning(['Obstacle id = ', num2str(obstacle.id),...
                ': timeStepSize of occupancy is not consistent with map timeStepSize']);
        end
        
        %%%%%%%%%%%%%%%%%%%%% export probabilityDistribution %%%%%%%%%%%%%
    case 3
        % ToDo
        
end

% convert obstacle data to XML node and append to document tree

% create obstacle node
obstacleNode = doc.createElement('obstacle');
obstacleNode.setAttribute('id',num2str(abs(obstacle.id)));

% create role and type nodes
role = doc.createElement('role');
obstacleNode.appendChild(role);
type = doc.createElement('type');
obstacleNode.appendChild(type);

% ToDo:
% role and type are set statically,
% dynamic initialization when parameter is implemented for objects
role.appendChild(doc.createTextNode('dynamic'));
type.appendChild(doc.createTextNode('car'));


% Export behavior
switch exportType
    case 1
        obstacleNode.appendChild(output.exportShape(doc,obstacle.shape));
        obstacleNode.appendChild(output.exportTrajectory(doc,obstacle.trajectory,iS,iF));
    case 2
        obstacleNode.appendChild(output.exportOccupancy(doc,obstacle.occupancy,iS,iF));
    case 3
        % ToDo
end

end

%------------- END CODE ------------------