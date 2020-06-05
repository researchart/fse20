function setLanelets(obj, lanelets)
% setLanelets - adds the given array of lanelets to the map object
%
% Syntax:
%   setLanelets(obj, lanelets)
%
% Inputs: (state variables must be row vectors with the same length)
%   obj - Trajectory object
%   lanelets - lanelets array
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
obj.lanelets = lanelets;
end

