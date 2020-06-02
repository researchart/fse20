function disp(obj)
% display - displays a Map object
%
% Syntax:
%   display(obj)
%
% Inputs:
%   obj - Map object
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

disp('-----------------------------------');

% display type
disp('type: Map');

% display properties
if ~isempty(obj)
    disp(['number of lanes: ',num2str(numel(obj.lanes))]);
    disp(['number of obstacles: ',num2str(numel(obj.obstacles))]);
    disp(['number of ego vehicles: ',num2str(numel(obj.egoVehicle))]);
end

disp('-----------------------------------');

end

%------------- END CODE --------------