function [trajectoryNode] = exportTrajectory (doc,trajectory,indexStart,indexFinish)
% exportTrajectory - returns trajectory information as a DOM tree node
%
% Syntax:
%   exportTrajecotry(doc,trajectory,indexStart,indexFinish)
%
% Inputs:
%   doc - DOM tree 
%   trajectory - trajectory to be exported
%   indexStart - first index of trajectory to be exported
%   indesFinish - last index of trajectory to be exported
%
%
% Outputs:
%   trajectoryNode - DOM tree node containing all information about the
%   trajectory consisting of state elements for each time step
%
% Other m-files required: exportState.m
% Subfunctions: none
% MAT-files required: none

% Author:       Lukas Willinger
% Written:      5 April 2017
% Last update:
%
% Last revision:---
%
%------------- BEGIN CODE --------------

    % create trajectory node 
    trajectoryNode = doc.createElement('trajectory');
    
    % create state nodes for each time step 
    for i = indexStart:indexFinish
        [tS,dt,~] = trajectory.timeInterval.getTimeInterval();
        time = tS + (i-1)*dt;
        trajectoryNode.appendChild(output.exportState(doc,trajectory,i,time));
    end
end

%------------- END CODE ------------------