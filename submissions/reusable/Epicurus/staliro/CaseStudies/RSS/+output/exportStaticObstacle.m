function [obstacleNode] = exportStaticObstacle (doc,obstacle,shape)
% exportStaticObstacle - returns obstacle information as a DOM tree node
%
% Syntax:
%   exportStaticObstacle(doc,obstacle,shape)
%
% Inputs:
%   doc - DOM tree 
%   obstacle - obstacle object to be exported
%   shape - shape of obstacle
%
%
% Outputs:
%   obstacleNode - DOM tree node containing all information about the
%   obstacle
%    
%
% Other m-files required: exportShape.m
% Subfunctions: none


% Author:       Lukas Willinger
% Written:      10 April 2017
% Last update:
%
% Last revision:---
%
%------------- BEGIN CODE --------------   

    % create obstacle node
    obstacleNode = doc.createElement('obstacle');
    obstacleNode.setAttribute('id',num2str(abs(obstacle.id)));
    
    % create role and type nodes
    role = doc.createElement('role');
    obstacleNode.appendChild(role);
    type = doc.createElement('type');   
    obstacleNode.appendChild(type);

    % ToDo:
    % role and type are set statically, 
    % dynamic initialization when parameter is implemented for objects
    role.appendChild(doc.createTextNode('static'));
    type.appendChild(doc.createTextNode('parkedVehicle'));

    obstacleNode.appendChild(output.exportShape(doc,shape,obstacle.orientation,...
        obstacle.position(1),obstacle.position(2)));
    
end