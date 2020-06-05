function setObstacles(obj, obstacles)
% setObstacles - adds the given array of obstacles to the map object
%
% Syntax:
%   setObstacles(obj, obstacles)
%
% Inputs: (state variables must be row vectors with the same length)
%   obj - Trajectory object
%   obstacles - obstacles array
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Mohammad Hekmatnejad
% Written:      06-June-2019
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------
obj.obstacles = obstacles;
end

%------------- END CODE --------------