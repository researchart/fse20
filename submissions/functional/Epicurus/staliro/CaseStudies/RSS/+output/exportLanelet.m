function laneletNode = exportLanelet(doc,lanelet)
% exportLanelet - returns Lanelet information as a DOM tree node
%
% Syntax:
%   exportLanelet(doc,lanelet)
%
% Inputs:
%   doc - DOM tree 
%   lanelet - lanelet object to be exported
%
%
% Outputs:
%   laneletNode - DOM tree node containing all information about the
%   lanelet
%
% Other m-files required: exportPoint.m

% Author:       Lukas Willinger
% Written:      05-April-2017
% Last update:  22-August-2017 Markus Koschi
%
% Last revision:---
%
%------------- BEGIN CODE --------------
    % create lanelet node
    laneletNode = doc.createElement('lanelet');
    laneletNode.setAttribute('id',num2str(abs(lanelet.id)));

    % -----leftBound
    leftBound = doc.createElement('leftBound');
    laneletNode.appendChild(leftBound);
    % append all nodes by traversing the border array
    for i = 1:max(size(lanelet.leftBorderVertices))
        pointElement = output.exportPoint(doc,lanelet.leftBorderVertices(1,i),...
            lanelet.leftBorderVertices(2,i));
        leftBound.appendChild(pointElement);
    end
    % ToDo:
    % LINE MARKING MISSING

    % -----rightBound
    rightBound = doc.createElement('rightBound');
    laneletNode.appendChild(rightBound);
    % append all nodes by traversing the border array
    for i = 1:max(size(lanelet.rightBorderVertices))
        pointElement = output.exportPoint(doc,lanelet.rightBorderVertices(1,i),...
           lanelet.rightBorderVertices(2,i));
        rightBound.appendChild(pointElement);
    end
    % ToDo:
    % LINE MARKING MISSING

    % -----adjacent lanelets

    %add predecessor lanlets
    for i = 1:numel(lanelet.predecessorLanelets)
        predecessor=doc.createElement('predecessor');
        predecessor.setAttribute('ref',num2str(abs(lanelet.predecessorLanelets(i).id)));
        laneletNode.appendChild(predecessor);
    end

    %Add successor lanelets
    for i = 1:numel(lanelet.successorLanelets)
        successor=doc.createElement('successor');
        successor.setAttribute('ref',num2str(abs(lanelet.successorLanelets(i).id)));
        laneletNode.appendChild(successor);
    end

    %Add adjacentLeft
    if isstruct(lanelet.adjacentLeft) 
        adjacentLeft=doc.createElement('adjacentLeft');
        adjacentLeft.setAttribute('ref',num2str(abs(lanelet.adjacentLeft.lanelet.id)));
        adjacentLeft.setAttribute('drivingDir',lanelet.adjacentLeft.driving);
        laneletNode.appendChild(adjacentLeft);
    end
    
    %Add adjacentRight
    if isstruct(lanelet.adjacentRight) 
        adjacentRight=doc.createElement('adjacentRight');
        adjacentRight.setAttribute('ref',num2str(abs(lanelet.adjacentRight.lanelet.id)));
        adjacentRight.setAttribute('drivingDir',lanelet.adjacentRight.driving);
        laneletNode.appendChild(adjacentRight);
    end
  
    % ToDo: 
    % Comment for optional part missing
     % -----speed limit
    if (lanelet.speedLimit ~= Inf)
        speedL = doc.createElement('speedLimit');
        speedL.appendChild(doc.createTextNode(num2str(lanelet.speedLimit)));
        laneletNode.appendChild(speedL);
    end   
    
    % ------ traffic sign
    % MISSING

end

%------------- END CODE ------------------