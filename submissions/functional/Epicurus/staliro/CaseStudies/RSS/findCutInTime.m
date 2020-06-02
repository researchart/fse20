% function findCutInTime - Return the samples when the vehicle changes lane
%
% USAGE  
%        [lineChange] = findCutInTime(borderLine,LR,x,y)
% 
% INPUTS:
%
%        borderLine - Array of the X/Y trajectory of lane border in global
%        coordination system
%
%        LR - 0 when the vehicle turns right
%             1 when the vehicle turns left
%
%        x - The X coordinate of the vehicle trajectory in the global system
%        
%        y - The Y coordinate of the vehicle trajectory in the global system
%
% OUTPUTS:
%        lineChange - Contains the last sample of the previous lane and the
%        first sample of the next lane.
%

function [lineChange] = findCutInTime(borderLine,LR,x,y)
global RUN_TEST_MODE;
if true(RUN_TEST_MODE)
SHOW_PLOTS = false;
else
global SHOW_PLOTS;
end
%global cutLineErrorAcceptance;
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%
    if true(SHOW_PLOTS)

    if  LR==1
        plot(borderLine(1,:),borderLine(2,:),'b');
    else
        plot(borderLine(1,:),borderLine(2,:),'b');
    end
    end
    k=length(borderLine);
    j=1;
    while j<=k-1
        % Removing the border lines that are the same in a sequence
        if borderLine(1,j)==borderLine(1,j+1) && borderLine(2,j)==borderLine(2,j+1)
            borderLine(:,j+1)=[];
            k=length(borderLine);
        end
        j=j+1;
    end
    distError=2e-15;  
    leftRight=zeros(length(x),1);
    for j=1:length(x)
        tempDist=[];
        for k=1:length(borderLine)
            tempDist(k)=sqrt((borderLine(1,k)-x(j))^2+(borderLine(2,k)-y(j))^2);
        end
        [M,IM]=find(tempDist==min(tempDist));
        if isscalar(IM)==0 && length(IM)==2
            if IM(1)<IM(2)
                l2r=leftRightLane(borderLine(:,IM(1)),borderLine(:,IM(2)),[x(j),y(j)]);
            elseif IM(1)>IM(2)
                l2r=leftRightLane(borderLine(:,IM(2)),borderLine(:,IM(1)),[x(j),y(j)]);
            else
                l2r=leftRightLane(borderLine(:,IM(1)),borderLine(:,IM(1)+1),[x(j),y(j)]);
            end
            if l2r<0 % Right
                leftRight(j)=1;
            else % Left
                leftRight(j)=-1;
            end
        elseif IM~=1 && IM~=length(borderLine)
            l2r=leftRightLane(borderLine(:,IM-1),borderLine(:,IM),[x(j),y(j)]);
            l2r2=leftRightLane(borderLine(:,IM),borderLine(:,IM+1),[x(j),y(j)]);
            if l2r<0 && l2r2<0 % Right
                leftRight(j)=1;               
            elseif l2r>0 && l2r2>0  % Left
                leftRight(j)=-1;
            else 
                [pxPre,pyPre]=findProjection(borderLine(:,IM),borderLine(:,IM-1),[x(j) y(j)]);
                [pxNex,pyNex]=findProjection(borderLine(:,IM),borderLine(:,IM+1),[x(j) y(j)]);
                distPrev=sqrt((borderLine(1,IM)-borderLine(1,IM-1))^2+(borderLine(2,IM)-borderLine(2,IM-1))^2);
                distPrev1=sqrt((borderLine(1,IM)-pxPre)^2+(borderLine(2,IM)-pyPre)^2);
                distPrev2=sqrt((borderLine(1,IM-1)-pxPre)^2+(borderLine(2,IM-1)-pyPre)^2);
                distNext=sqrt((borderLine(1,IM)-borderLine(1,IM+1))^2+(borderLine(2,IM)-borderLine(2,IM+1))^2);
                distNext1=sqrt((borderLine(1,IM)-pxNex)^2+(borderLine(2,IM)-pyNex)^2);
                distNext2=sqrt((borderLine(1,IM+1)-pxNex)^2+(borderLine(2,IM+1)-pyNex)^2);
                if distNext+distError<distNext1+distNext2 
                    if l2r<0 % Right
                        leftRight(j)=1;
                    else % Left
                        leftRight(j)=-1;
                    end
                elseif distPrev+distError<distPrev1+distPrev2 
                    if l2r2<0 % Right
                        leftRight(j)=1;
                    else % Left
                        leftRight(j)=-1;
                    end 
                else
                    error('left or right error');
                end
            end
        elseif IM==1
            l2r=leftRightLane(borderLine(:,1),borderLine(:,2),[x(j),y(j)]);
            if l2r<0 % Right
                leftRight(j)=1;
            else % Left
                leftRight(j)=-1;
            end
        elseif IM==length(borderLine)
            ll=length(borderLine);
            l2r=leftRightLane(borderLine(:,ll-1),borderLine(:,ll),[x(j),y(j)]);
            if l2r<0 % Right
                leftRight(j)=1;
            else % Left
                leftRight(j)=-1;
            end
        end
    end
    %commented by Mohammad
    %index=find(leftRight==leftRight(1));
    %lineChange=index(end);
    %if lineChange==length(x)
    %    lineChange=[];
    %    return;
    %end
    %index=find(leftRight~=leftRight(1));
    %lineChange=[lineChange,index(1)];
    %added by Mohammad
    startIndex = 1;
    oldValue = leftRight(1);
    lineChange = [];
    while startIndex < length(leftRight)
        oldValue = leftRight(startIndex);
        index=find(leftRight(startIndex:end)~=oldValue);
        if isempty(index)
            if isempty(lineChange)
                lineChange=[length(leftRight)-1,length(leftRight)];           
            end
            return;
        end
        startIndex = index(1)+startIndex-1;
        if startIndex >= length(leftRight)%todo: test
            display('check findCutInTime!');
        end
        lineChange = [lineChange,startIndex-1,startIndex];
        %TODO: quick fix for now to only have one cut in a new lane not
        %more, but in future this part of the code must be commented in
        %order to find all the cuts
        %if length(lineChange) == 2
        %    return;
        %end
    end
    %for now this function cannot detect if the obstacle's trajectory is
    %out of the neighbore's lane. The assumption is that the trajectory 
    %does not get outside of the assumed lane
end

