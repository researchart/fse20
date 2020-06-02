function disp(obj)
% display - displays a GoalRegion object
%
% Syntax:
%   display(obj)
%
% Inputs:
%   obj - GoalRegion object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      18-April-2017
% Last update:  08-June-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

disp('-----------------------------------');

% display type
disp('type: GoalRegion');

% display properties
if ~isempty(obj.position)
    %disp(['position Object: ' class(obj.position)])
    obj.position.disp();
end

if ~isempty(obj.orientation)
    if size(obj.orientation,1) == 2 || size(obj.orientation,2) == 2
        disp(['orientation: [' num2str(obj.orientation(1)) '; ' num2str(obj.orientation(2)) ']']);
    else
        disp(['orientation: ' num2str(obj.orientation)]);
    end
end

if ~isempty(obj.time)
    if size(obj.time,1) == 2 || size(obj.time,2) == 2
        disp(['time: [' num2str(obj.time(1)) '; ' num2str(obj.time(2)) ']']);
    else
        disp(['time: ' num2str(obj.time)]);
    end
end

if ~isempty(obj.velocity)
    if size(obj.velocity,1) == 2 || size(obj.velocity,2) == 2
        disp(['velocity: [' num2str(obj.velocity(1)) '; ' num2str(obj.velocity(2)) ']']);
    else
        disp(['velocity: ' num2str(obj.velocity)]);
    end
end

if ~isempty(obj.acceleration)
    if size(obj.acceleration,1) == 2 || size(obj.acceleration,2) == 2
        disp(['acceleration: [' num2str(obj.acceleration(1)) '; ' num2str(obj.acceleration(2)) ']']);
    else
        disp(['acceleration: ' num2str(obj.acceleration)]);
    end
end

disp('-----------------------------------');

end

%------------- END CODE --------------