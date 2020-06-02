function setTrajectory(obj, t, x, y, theta, v, a)
% setTrajectory - adds the given array of states to the trajectory object
%
% Syntax:
%   setTrajectory(obj, t, x, y, theta, v, a)
%
% Inputs: (state variables must be row vectors with the same length)
%   obj - Trajectory object
%   t - time array
%   x - array of the x-coordinates of the position
%   y - array of the y-coordinates of the position
%   theta - orientation array
%   v - velocity array
%   a - acceleration array
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      15-November-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------
%added by Mohammad
if length(t) >= 3
obj.timeInterval = globalPck.TimeInterval(t(1), t(2)-t(1), t(end));
else
    obj.timeInterval = [];
end
obj.position = [x;y];
obj.orientation = theta;
obj.velocity = v;
obj.acceleration = a;

end

%------------- END CODE --------------