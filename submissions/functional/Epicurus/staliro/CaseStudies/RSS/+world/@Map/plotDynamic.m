function plotDynamic(obj)
%PLOTDYNAMIC plots the map for the given timeinterval with lanelets,
%   egoVehicle(s), obstacle(s) and goalRegion(s)
%
%   Syntax:
%       plotDynamic(map)
%
%   Inputs:
%       obj - Map object
%
%   Outputs:
%       none
%
% Other m-files required: none
% Subfunctions: Map.plot, Map.update
% MAT-files required: none
%
% Author:       Lukas Braunstorfer
% Written:      02-Mai-2017
% Last update:  24-August-2017 (Markus Koschi)
%
% Last revision:---

%------------- BEGIN CODE --------------

% determine start and end time for plot
if ~isempty(obj.egoVehicle) && ~isempty(obj.egoVehicle(1).trajectory) && ...
        ~isempty(obj.egoVehicle(1).goalRegion)
    tS = obj.egoVehicle(1).trajectory.timeInterval.ts; %0; 
    dt = obj.timeStepSize; %0.1;
    tF = max(obj.egoVehicle(1).goalRegion.time); %mean(obj.egoVehicle(1).goalRegion.time);
else
    tS = obj.obstacles(1).trajectory.timeInterval.ts;
    dt = obj.timeStepSize; %0.1;
    tF = obj.obstacles(end).trajectory.timeInterval.tf;
end

% plot the lanelets
obj.lanes.plot;

% plot the map for all time steps
for t = tS:dt:tF
    obj.update(t);
    obj.plot();
    if t==0
        disp('Type something to start');
        % click with mouse or keyboard to start dynamic plot
        w = waitforbuttonpress;
    end
    pause(0.01);
    clf();
end

end

%------------- END CODE --------------