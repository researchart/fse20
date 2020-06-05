function setTrajectory( obj, trajectory )
% set - sets the property trajectory of a DynamicObstacle object
%
% Syntax:
%   set(obj, trajectory)
%
% Inputs:
%   obj - DynamicObstacle object
%   trajectory - Trajectory object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Lukas Braunstorfer
% Written:      25-Dezember-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

if(isa(trajectory,'globalPck.Trajectory'))
    obj.trajectory = trajectory;
else
    warning('trajectory not of class globalPck.Trajectory');
end

end