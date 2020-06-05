% function findLane - Returns the lane index of the vehicle, given X/Y 
% coordinates of the vehicle and center points of the lane (X/Y).
% 
% USAGE  
%        [line] = findLane(centerLine,szLane,x,y)
% 
% INPUTS:
%
%        centerLine - Cell array of the lanes containing the center points (x,y) 
%        of the lanes. Center of the lanes are based on global coordination
%
%        szLane - Size of the lane arrays. It contains the total number of
%        the lanes.
%
%        x - The X coordinate of the vehicle trajectory in the global system
%        
%        y - The Y coordinate of the vehicle trajectory in the global system
%        
%
% OUTPUTS:
%        line - The line index which the vehicle's trajectory is inside it.
%             line is scalar when the vehicle does not change lane
%             line is array when the vehicle changes lane
%        

function [line] = findLane(centerLine,szLane,x,y)
    dist2lane=zeros(szLane);
    for k=1:szLane(1)
        tempDistS=[];
        for j=1:length(centerLine{k})
            tempDistS(j)=sqrt((centerLine{k}(1,j)-x(1))^2+(centerLine{k}(2,j)-y(1))^2);
        end
        tempDistE=[];
        for j=1:length(centerLine{k})
            tempDistE(j)=sqrt((centerLine{k}(1,j)-x(end))^2+(centerLine{k}(2,j)-y(end))^2);
        end
        [MS,MIS]=min(tempDistS);
        [ME,MIE]=min(tempDistE);
        if MIS>1 &&  MIS<length(centerLine{k})
            [pxl,pyl]=findProjection([centerLine{k}(1,MIS),centerLine{k}(2,MIS)],[centerLine{k}(1,MIS-1),centerLine{k}(2,MIS-1)],[x(1),y(1)]);
            [pxr,pyr]=findProjection([centerLine{k}(1,MIS),centerLine{k}(2,MIS)],[centerLine{k}(1,MIS+1),centerLine{k}(2,MIS+1)],[x(1),y(1)]);
            distL=sqrt((pxl-x(1))^2+(pyl-y(1))^2);
            distR=sqrt((pxr-x(1))^2+(pyr-y(1))^2);
            dist2lane(k,1)=min(distL,distR);
        elseif MIS==1
            [pxr,pyr]=findProjection([centerLine{k}(1,1),centerLine{k}(2,1)],[centerLine{k}(1,2),centerLine{k}(2,2)],[x(1),y(1)]);
            dist2lane(k,1)=sqrt((pxr-x(1))^2+(pyr-y(1))^2);
        elseif MIS==length(centerLine{k})
            [pxl,pyl]=findProjection([centerLine{k}(1,MIS),centerLine{k}(2,MIS)],[centerLine{k}(1,MIS-1),centerLine{k}(2,MIS-1)],[x(1),y(1)]);
            dist2lane(k,1)=sqrt((pxl-x(1))^2+(pyl-y(1))^2);
        end
        if MIE>1 &&  MIE<length(centerLine{k})
            [pxl,pyl]=findProjection([centerLine{k}(1,MIE),centerLine{k}(2,MIE)],[centerLine{k}(1,MIE-1),centerLine{k}(2,MIE-1)],[x(end),y(end)]);
            [pxr,pyr]=findProjection([centerLine{k}(1,MIE),centerLine{k}(2,MIE)],[centerLine{k}(1,MIE+1),centerLine{k}(2,MIE+1)],[x(end),y(end)]);
            distL=sqrt((pxl-x(end))^2+(pyl-y(end))^2);
            distR=sqrt((pxr-x(end))^2+(pyr-y(end))^2);
            dist2lane(k,2)=min(distL,distR);
        elseif MIE==1
            [pxr,pyr]=findProjection([centerLine{k}(1,1),centerLine{k}(2,1)],[centerLine{k}(1,2),centerLine{k}(2,2)],[x(end),y(end)]);
            dist2lane(k,2)=sqrt((pxr-x(end))^2+(pyr-y(end))^2);
        elseif MIE==length(centerLine{k})
            [pxl,pyl]=findProjection([centerLine{k}(1,MIE),centerLine{k}(2,MIE)],[centerLine{k}(1,MIE-1),centerLine{k}(2,MIE-1)],[x(end),y(end)]);
            dist2lane(k,2)=sqrt((pxl-x(end))^2+(pyl-y(end))^2);
        end
    end
    [MS,IS] = min(dist2lane(:,1)); 
    [ME,IE] = min(dist2lane(:,2)); 
    if IS==IE
        line=IS;
    else
        line=[IS,IE];
    end
end

