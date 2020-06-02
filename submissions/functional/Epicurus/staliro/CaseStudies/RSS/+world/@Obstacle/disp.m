function disp(obj)
% display - displays an Obstacle object
%
% Syntax:
%   display(obj)
%
% Inputs:
%   obj - Obstacle object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      26-Oktober-2016
% Last update:  08-February-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

disp('-----------------------------------');

% display type
disp('type: Obstacle');

% display properties
disp(['id: ' num2str(obj.id)]);
if size(obj.position,1) == 2
    disp(['position: [' num2str(obj.position(1)) '; ' num2str(obj.position(2)) ']']);
else
    disp(['position: ' num2str(obj.position)]);
end
disp(['orientation: ' num2str(obj.orientation)]);
if ~isempty(obj.inLane)
disp(['inLaneId: ' num2str(obj.inLane.id)]);
end

disp('Shape:');
disp(obj.shape);

disp('Occupancy:');
disp(obj.occupancy);

disp('-----------------------------------');

% %display number of states, inputs and parameters
% disp(['nr of states: ',num2str(obj.dim)]);
% disp(['nr of inputs: ',num2str(obj.nrOfInputs)]);
% disp(['nr of parameters: ',num2str(obj.nrOfParam)]);
%
% %display state space equations
% %create symbolic variables
% [x,u,dx,du,p]=symVariables(obj);
%
% %insert symbolic variables into the system equations
% t=0;
% f=obj.mFile(t,x,u,p);
% disp('state space equations:')
% for i=1:length(f)
%     disp(['f(',num2str(i),') = ',char(f(i))]);
% end

%     function disp(obj)
%         disp(['Simulator (current time: ' num2str(obj.time_idx) ')'])
%         disp(['  number of static obstacles: ' num2str(numel(obj.map.lane_boundary_rect))])
%         disp(['  number of dynamic obstacles: ' num2str(size(obj.obstacles,2))])
%         for i = 1:numel(obj.obstacles)
%             disp(['  --obstacle ' num2str(i) ': position (' num2str(obj.obstacles{i}.position(1), '%0.2f') '/' ...
%                 num2str(obj.obstacles{i}.position(2),'%0.2f') ') trajectory (' num2str(obj.obstacles{i}.time_idx) ' in ' ...
%                 num2str(obj.obstacles{i}.trajectory.t0) '-' num2str(obj.obstacles{i}.trajectory.t0+obj.obstacles{i}.trajectory.getLength()-1) ')']);
%         end
%     end
end

%------------- END CODE --------------