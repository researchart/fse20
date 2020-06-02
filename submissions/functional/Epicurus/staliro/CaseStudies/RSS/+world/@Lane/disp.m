function disp(obj)
% display - displays a Lane object
%
% Syntax:
%   display(obj)
%
% Inputs:
%   obj - Lane object
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

for i = 1:numel(obj)
disp('-----------------------------------');

% display type
disp('type: Lane');

% display properties
if ~isempty(obj(i))
    disp(['id: ' num2str(obj(i).id)])
    disp(['number of vertices: ',num2str(size(obj(i).leftBorder.vertices,2))]);
    disp(['number of lanelets: ',num2str(numel(obj(i).lanelets))]);
    if ~isempty(obj(i).adjacentLeft)
        disp(['id of left adjacent lane: ',num2str((obj(i).adjacentLeft.lane.id))]);
    end
    if ~isempty(obj(i).adjacentRight)
        disp(['id of right adjacent lane: ',num2str((obj(i).adjacentRight.lane.id))]);
    end
end

disp('-----------------------------------');
end

end

%------------- END CODE --------------