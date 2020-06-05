function [stateNode] = exportState (varargin)
% exportState - returns state information as a DOM tree node
%
% Syntax:
%   exportState(varargin) 
%   exportState(doc,goalRegion)
%   exportState(doc,trajectory)
%   exportState(doc,position,orientation,velocity,acceleration,time)
%
%
% Outputs:
%   stateNode - DOM tree node containing all information about the state
% 
%
% Other m-files required: exportRectangle.m, exportCircle.m,
%                         exportTriangle.m, exportPoint.m, exportPolygon.m 
% Subfunctions: exportPosition, exportOrientation, exportTime,
%               exportVelocity, exportAcceleration
% MAT-files required: none

% Author:       Lukas Willinger
% Written:      10 April 2017
% Last update:
%
% Last revision:---
%
%------------- BEGIN CODE --------------

    doc = varargin{1};
    
    % set parameters according to the state to be exported
    % Export state for goal region inital state
    if nargin == 6 
        position = varargin{2};
        orientation = varargin{3};
        velocity = varargin{4};
        acceleration = varargin{5};
        time = varargin{6};
        % create state Node
        stateNode = doc.createElement('initialState');
    
    % Export state for goal regions final states
    elseif nargin == 2 && isa(varargin{2},'globalPck.GoalRegion')
        goalRegion = varargin{2};
        position = goalRegion.position;
        orientation = goalRegion.orientation;
        time = goalRegion.time;
        if ~isempty(goalRegion.velocity)
            velocity = goalRegion.velocity;
        end
        if ~isempty(goalRegion.acceleration)
            acceleration = goalRegion.acceleration;
        end
        % create state Node
        stateNode = doc.createElement('state');
    
    % Export state for Trajectory
    elseif nargin == 4 && isa(varargin{2},'globalPck.Trajectory')
        i = varargin{3};
        trajectory = varargin{2};
        position = trajectory.position(:,i);
        orientation = trajectory.orientation(i);
        time = varargin{4};
        if ~isempty(trajectory.velocity)
            velocity = trajectory.velocity(i);
        end
        if ~isempty(trajectory.acceleration)
            acceleration = trajectory.acceleration(i); 
        end
        % create state Node
        stateNode = doc.createElement('state');
    else
        error('exportState input parameters not correct');
    end

    % add information to the state node
    stateNode.appendChild(exportPosition(doc,position));
    stateNode.appendChild(exportOrientation(doc,orientation));
    stateNode.appendChild(exportTime(doc,time));

    % optional information
    if exist('velocity','var')
       stateNode.appendChild(exportVelocity(doc,velocity));
    end
    if exist('acceleration','var')
       stateNode.appendChild(exportAcceleration(doc,acceleration));
    end
end


% ----- Additional functions to export all information for the states ------
function [positionNode] = exportPosition (doc,position)
    positionNode = doc.createElement('position');
    if isa(position,'geometry.Rectangle')
        positionNode.appendChild(output.exportRectangle(doc,position));
    elseif isa(position,'geometry.Circle')
        positionNode.appendChild(output.exportCircle(doc,position));
    elseif isa(position,'geometry.Polygon')
        positionNode.appendChild(output.exportPolygon(doc,position.vertices));
    elseif isa(position,'geometry.Triangle')
        positionNode.appendChild(output.exportTriangle(doc,position.vertices));
    elseif isa(position,'world.Lane')
        lane = doc.createElement('lane');
        lane.setAttribute('ref',num2str(abs(position.id)));
        positionNode.appendChild(lane);
    elseif isa(position,'world.Lanelet')
        lanelet = doc.createElement('lanelet');
        lanelet.setAttribute('ref',num2str(abs(position.id)));
        positionNode.appendChild(lanelet);
    elseif isfloat(position)
        positionNode.appendChild(output.exportPoint(doc,position(1),position(2)));
    end        
end

function [orientationNode] = exportOrientation(doc,orientation)

    orientationNode = doc.createElement('orientation');
    if length(orientation) == 2
        intervalStart = doc.createElement('intervalStart');
        intervalStart.appendChild(doc.createTextNode(num2str(orientation(1))));
        orientationNode.appendChild(intervalStart);
        intervalEnd = doc.createElement('intervalEnd');
        intervalEnd.appendChild(doc.createTextNode(num2str(orientation(2))));
        orientationNode.appendChild(intervalEnd);
    else
        exact = doc.createElement('exact');
        orientationNode.appendChild(exact);
        exact.appendChild(doc.createTextNode(num2str(orientation)));
    end
end

function [timeNode] = exportTime(doc,time)
    timeNode = doc.createElement('time');
    if length(time) == 2
        intervalStart = doc.createElement('intervalStart');
        intervalStart.appendChild(doc.createTextNode(num2str(time(1))));
        timeNode.appendChild(intervalStart);
        intervalEnd = doc.createElement('intervalEnd');
        intervalEnd.appendChild(doc.createTextNode(num2str(time(2))));
        timeNode.appendChild(intervalEnd);
    else
        exact = doc.createElement('exact');
        timeNode.appendChild(exact);
        exact.appendChild(doc.createTextNode(num2str(time)));
    end
end

function [velocityNode] = exportVelocity(doc,velocity)

    velocityNode = doc.createElement('velocity');
    if length(velocity) == 2
        intervalStart = doc.createElement('intervalStart');
        intervalStart.appendChild(doc.createTextNode(num2str(velocity(1))));
        velocityNode.appendChild(intervalStart);
        intervalEnd = doc.createElement('intervalEnd');
        intervalEnd.appendChild(doc.createTextNode(num2str(velocity(2))));
        velocityNode.appendChild(intervalEnd);
    else
        exact = doc.createElement('exact');
        velocityNode.appendChild(exact);
        exact.appendChild(doc.createTextNode(num2str(velocity)));
    end
end

function [accelerationNode] = exportAcceleration(doc,acceleration)
    accelerationNode = doc.createElement('acceleration'); 
    if length(acceleration) == 2
        intervalStart = doc.createElement('intervalStart');
        intervalStart.appendChild(doc.createTextNode(num2str(acceleration(1))));
        accelerationNode.appendChild(intervalStart);
        intervalEnd = doc.createElement('intervalEnd');
        intervalEnd.appendChild(doc.createTextNode(num2str(acceleration(2))));
        accelerationNode.appendChild(intervalEnd);
    else
        exact = doc.createElement('exact');
        accelerationNode.appendChild(exact);
        exact.appendChild(doc.createTextNode(num2str(acceleration)));
    end
end

%------------- END CODE ------------------