% function laneBasedPoints - Creates lane-based coordination trajectory:
% longitudinal distance / lateral distance 
% Based on global coordination trajectory of X / Y
% 
% USAGE  
%        [px,py,longDist,lattDist] = laneBasedPoints(x,y,centerLine,index,segmentDist)
% 
% INPUTS:
%
%        x - The X coordinate of the vehicle trajectory in the global system
%        
%        y - The Y coordinate of the vehicle trajectory in the global system
%        
%        centerLine - Cell array of the lanes containing the center points (x,y) 
%        of the lanes. Center of the lanes are based on global coordination
%        
%        index - The index of the lane which the lane-based coordination
%        will be computed.
%        
%        segmentDist - Each road segment has a distance from the beginning 
%        of the lane. This segmentDist is used to compute longitudianl
%        distance 
%
%
% OUTPUTS:
%        px - the X coordinate of the projection of the vehicle trajectory
%        with respect to lane (index)
%
%        py - the Y coordinate of the projection of the vehicle trajectory 
%        with respect to lane (index)
%
%        longDist - Array contains the longitudinal distances of vehicle 
%        trajectory on lane (index)
%
%        lattDist - Array contains the lateral distances of vehicle trajectory
%        on lane (index)
%
%
function [px,py,longDist,lattDist] = laneBasedPoints(x,y,centerLine,index,segmentDist)
global RUN_TEST_MODE;
if true(RUN_TEST_MODE)
SHOW_PLOTS = false;
else
global SHOW_PLOTS;
end

    distError=2e-14;
    px=[];
    py=[];
    longDist=[];
    lattDist=[];
    for j=1:length(x)
        %if j==78%debug
        %    j;
        %end
        tempDist=[];
%         j
%         index
        for k=1:length(centerLine{index})
%             k
            tempDist(k)=sqrt((centerLine{index}(1,k)-x(j))^2+(centerLine{index}(2,k)-y(j))^2);
        end
        [M,IM]=find(tempDist==min(tempDist));
        if isscalar(IM)==0 && length(IM)==2
            [px(j),py(j)]=findProjection(centerLine{index}(:,IM(1)),centerLine{index}(:,IM(2)),[x(j) y(j)]);
    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%
    if true(SHOW_PLOTS)
            plot(px(j),py(j),'y.');
    end
            longDist(j)=segmentDist{index}(IM(1))+sqrt((centerLine{index}(1,IM(1))-px(j))^2+(centerLine{index}(2,IM(1))-py(j))^2);
            if IM(1)<IM(2)
                l2r=leftRightLane(centerLine{index}(:,IM(1)),centerLine{index}(:,IM(2)),[x(j),y(j)]);
            elseif IM(1)>IM(2)
                l2r=leftRightLane(centerLine{index}(:,IM(2)),centerLine{index}(:,IM(1)),[x(j),y(j)]);
            else
                l2r=leftRightLane(centerLine{index}(:,IM(1)),centerLine{index}(:,IM(1)+1),[x(j),y(j)]);
            end
            if l2r<0 % Right
                lattDist(j)=sqrt((x(j)-px(j))^2+(y(j)-py(j))^2);
            else % Left
                lattDist(j)=-sqrt((x(j)-px(j))^2+(y(j)-py(j))^2);
            end
        elseif IM~=1 && IM~=length(centerLine{index})
            [pxPre,pyPre]=findProjection(centerLine{index}(:,IM),centerLine{index}(:,IM-1),[x(j) y(j)]);
            [pxNex,pyNex]=findProjection(centerLine{index}(:,IM),centerLine{index}(:,IM+1),[x(j) y(j)]);
            distPrev=sqrt((centerLine{index}(1,IM)-centerLine{index}(1,IM-1))^2+(centerLine{index}(2,IM)-centerLine{index}(2,IM-1))^2);
            distPrev1=sqrt((centerLine{index}(1,IM)-pxPre)^2+(centerLine{index}(2,IM)-pyPre)^2);
            distPrev2=sqrt((centerLine{index}(1,IM-1)-pxPre)^2+(centerLine{index}(2,IM-1)-pyPre)^2);
            distNext=sqrt((centerLine{index}(1,IM)-centerLine{index}(1,IM+1))^2+(centerLine{index}(2,IM)-centerLine{index}(2,IM+1))^2);
            distNext1=sqrt((centerLine{index}(1,IM)-pxNex)^2+(centerLine{index}(2,IM)-pyNex)^2);
            distNext2=sqrt((centerLine{index}(1,IM+1)-pxNex)^2+(centerLine{index}(2,IM+1)-pyNex)^2);
            if distNext+distError<distNext1+distNext2 
    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%
    if true(SHOW_PLOTS)
                plot(pxPre,pyPre,'y.');
    end
                px(j)=pxPre;
                py(j)=pyPre;
                longDist(j)=segmentDist{index}(IM-1)+sqrt((centerLine{index}(1,IM-1)-px(j))^2+(centerLine{index}(2,IM-1)-py(j))^2);
                l2r=leftRightLane(centerLine{index}(:,IM-1),centerLine{index}(:,IM),[x(j),y(j)]);
                if l2r<0 % Right
                    lattDist(j)=sqrt((x(j)-px(j))^2+(y(j)-py(j))^2);
                else % Left
                    lattDist(j)=-sqrt((x(j)-px(j))^2+(y(j)-py(j))^2);
                end
            elseif distPrev+distError<distPrev1+distPrev2 
    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%
    if true(SHOW_PLOTS)
                plot(pxNex,pyNex,'y.');
    end
                px(j)=pxNex;
                py(j)=pyNex;
                longDist(j)=segmentDist{index}(IM)+sqrt((centerLine{index}(1,IM)-px(j))^2+(centerLine{index}(2,IM)-py(j))^2);
                l2r=leftRightLane(centerLine{index}(:,IM),centerLine{index}(:,IM+1),[x(j),y(j)]);
                if l2r<0 % Right
                    lattDist(j)=sqrt((x(j)-px(j))^2+(y(j)-py(j))^2);
                else % Left
                    lattDist(j)=-sqrt((x(j)-px(j))^2+(y(j)-py(j))^2);
                end
            else
                px(j)=centerLine{index}(1,IM);
                py(j)=centerLine{index}(2,IM);
    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%
    if true(SHOW_PLOTS)
                plot(px(j),py(j),'y.');
    end
                longDist(j)=segmentDist{index}(IM);
                l2r=leftRightLane(centerLine{index}(:,IM-1),centerLine{index}(:,IM),[x(j),y(j)]);
                if l2r<0 % Right
                    lattDist(j)=sqrt((x(j)-px(j))^2+(y(j)-py(j))^2);
                else % Left
                    lattDist(j)=-sqrt((x(j)-px(j))^2+(y(j)-py(j))^2);
                end
            end
        elseif IM==1
            [px(j),py(j)]=findProjection(centerLine{index}(:,1),centerLine{index}(:,2),[x(j) y(j)]);
    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%
    if true(SHOW_PLOTS)
            plot(px(j),py(j),'y.');
    end            
            distNext=sqrt((centerLine{index}(1,IM)-centerLine{index}(1,IM+1))^2+(centerLine{index}(2,IM)-centerLine{index}(2,IM+1))^2);
            distNext1=sqrt((centerLine{index}(1,IM)-px(j))^2+(centerLine{index}(2,IM)-py(j))^2);
            distNext2=sqrt((centerLine{index}(1,IM+1)-px(j))^2+(centerLine{index}(2,IM+1)-py(j))^2);
            if distNext+distError<distNext1+distNext2 
                longDist(j)=-sqrt((centerLine{index}(1,IM)-px(j))^2+(centerLine{index}(2,IM)-py(j))^2);
            else
                longDist(j)=sqrt((centerLine{index}(1,IM)-px(j))^2+(centerLine{index}(2,IM)-py(j))^2);
            end
            l2r=leftRightLane(centerLine{index}(:,1),centerLine{index}(:,2),[x(j),y(j)]);
            if l2r<0 % Right
                lattDist(j)=sqrt((x(j)-px(j))^2+(y(j)-py(j))^2);
            else % Left
                lattDist(j)=-sqrt((x(j)-px(j))^2+(y(j)-py(j))^2);
            end
        elseif IM==length(centerLine{index})
            ll=length(centerLine{index});
            [px(j),py(j)]=findProjection(centerLine{index}(:,ll-1),centerLine{index}(:,ll),[x(j) y(j)]);
    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%
    if true(SHOW_PLOTS)
            plot(px(j),py(j),'y.');
    end
            longDist(j)=segmentDist{index}(ll-1)+sqrt((centerLine{index}(1,ll-1)-px(j))^2+(centerLine{index}(2,ll-1)-py(j))^2);
            l2r=leftRightLane(centerLine{index}(:,ll-1),centerLine{index}(:,ll),[x(j),y(j)]);
            if l2r<0 % Right
                lattDist(j)=sqrt((x(j)-px(j))^2+(y(j)-py(j))^2);
            else % Left
                lattDist(j)=-sqrt((x(j)-px(j))^2+(y(j)-py(j))^2);
            end
        end             
    end
end