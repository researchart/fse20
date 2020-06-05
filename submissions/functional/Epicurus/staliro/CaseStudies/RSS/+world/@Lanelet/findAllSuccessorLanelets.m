function [successors] = findAllSuccessorLanelets(obj, successors)
% findAllSuccessorLanelets - returns all successor lanelets of the lanelet
% object
%
% Syntax:
%   [successors] = findAllSuccessorLanelets(obj, successors)
%
% Inputs:
%   obj - Lanelet object
%   successors - array of already found successor lanelets
%
% Outputs:
%   successors - array of found successor lanelets
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      05-January-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

for i = 1:numel(obj.successorLanelets)
    % add all successor lanelets of the obj
    successors(end+1) = obj.successorLanelets(i);
    
    % continue the search for all successors of the current successors
    successors = obj.successorLanelets(i).findAllSuccessorLanelets(successors);
end

end

%------------- END CODE --------------