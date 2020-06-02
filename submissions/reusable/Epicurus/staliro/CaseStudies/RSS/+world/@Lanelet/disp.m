function disp(obj)
% display - displays a Lanelet object
%
% Syntax:
%   display(obj)
%
% Inputs:
%   obj - Lanelet object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      07-Dezember-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

for i = 1:numel(obj)
    disp('-----------------------------------');
    
    % display type
    disp('type: Lanelet');
    
    % display properties
    if ~isempty(obj(i))
        disp(['id: ' num2str(obj(i).id)])
        disp(['number of vertices: ' num2str(size(obj(i).leftBorderVertices,2))]);
        disp(['speed limit: ' num2str(obj(i).speedLimit)]);
        
        disp(['number of predecessor lanelets: ' num2str(numel(obj(i).predecessorLanelets))]);
        for j = 1:numel(obj(i).predecessorLanelets)
            disp(['id of predecessor lanelet ' num2str(j) ': ' num2str(obj(i).predecessorLanelets(j).id)]);
        end
        disp(['number of successor lanelets: ' num2str(numel(obj(i).successorLanelets))]);
        for j = 1:numel(obj(i).successorLanelets)
            disp(['id of successor lanelet ' num2str(j) ': ' num2str(obj(i).successorLanelets(j).id)]);
        end
        
        if ~isempty(obj(i).adjacentLeft)
            disp(['id of left adjacent lanelet: ' num2str((obj(i).adjacentLeft.lanelet.id))]);
            disp(['driving direction of left adjacent lanelet: ' (obj(i).adjacentLeft.driving)]);
        end
        if ~isempty(obj(i).adjacentRight)
            disp(['id of right adjacent lanelet: ' num2str((obj(i).adjacentRight.lanelet.id))]);
            disp(['driving direction of right adjacent lanelet: ' (obj(i).adjacentRight.driving)]);
        end
    end
    
    disp('-----------------------------------');
end

end

%------------- END CODE --------------