function [notParallel,distanceLK,distanceRK] = checkLaneletAdjacency(l_k,r_k,j1,j2,totalWidth)
% checklaneletAdjacency - calculate two lanelets adjacency by checking
% start and end point distance,if its lower than thresold then calculate 
% centriod of the two line and comapre its value with avg lane width
%
% Syntax:
%   [notParallel,distanceLK,distanceRK] =
%   checkLaneletAdjacency(l_k,r_k,j1,j2,length,widthK,widthJ);
%
% Inputs:
%   l_k -left border of K
%   r_k - right border of k
%   j1 and j2 - left and roght border of J based on direction
%   totalWidth - total width of lane K and J
%
% Outputs:
%   notParallel - if lanes are not parallel
%   distanceLK and distanceRK - distance from the left and right border of K
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Rajat Koner
% Written:      22 JAN 2017
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

epsilion =0.27;  %thresold value of parallel lanelet

%initialize variable
notParallel = 0;
%distance between left & right border of K and border of J
distanceLKJ1 =0;distanceRKJ2=0;

distanceLK=0;distanceRK=0;

for t= 1:2
    if(t==1)
        %1st of left border of K and right or left border of J based on direction
        distanceLKJ1(t)=sqrt((l_k(1,t) - j1(1,t))^2 + ...
            (l_k(2,t) - j1(2,t))^2);
        %1st of right border of K and left or right border of J based on direction
        distanceRKJ2(t)=sqrt((r_k(1,t) - j2(1,t))^2 + ...
            (r_k(2,t) - j2(2,t))^2);
    else
        distanceLKJ1(t)=sqrt((l_k(1,end) - j1(1,end))^2 + ...
            (l_k(2,end) - j1(2,end))^2);
        %end of right border of K and left or right border of J based on direction
        distanceRKJ2(t)=sqrt((r_k(1,end) - j2(1,end))^2 + ...
            (r_k(2,end) - j2(2,end))^2);
    end
end  %end of for loop

%check devation with 1st and last, shouldn't be more than 0.5m of border distance
if (abs(distanceLKJ1(1) -distanceLKJ1(2)) > epsilion) && (abs(distanceRKJ2(1) -distanceRKJ2(2))> epsilion)
    notParallel=1;
end


if notParallel == 0
    %create polygon and calculate centroid
    %for lane k
    xk = [l_k(1,:),fliplr(r_k(1,:)),l_k(1,1)];
    yk = [l_k(2,:),fliplr(r_k(2,:)),l_k(2,1)];
    [xk_cen,yk_cen] = geometry.calcPolygonCentroid(xk,yk);
    %     DEBUG plot
    %     patch(xk,yk,'red');
    %     hold on
    %     plot(xk_cen,yk_cen,'bo')
    xj = [j1(1,:),fliplr(j2(1,:)),j1(1,1)];
    yj = [j1(2,:),fliplr(j2(2,:)),j1(2,1)];
    
    [xj_cen,yj_cen] = geometry.calcPolygonCentroid(xj,yj);
    %     DEBUG plot
    %     patch(xj,yj,'green');
    %     hold on
    %     plot(xj_cen,yj_cen,'ro');
    
    %calculate distance among centroid and check deviation of 0.5m
    cntrDistance = sqrt((xk_cen - xj_cen)^2 + (yk_cen - yj_cen)^2);
    if cntrDistance > totalWidth%/2 + 0.5 || cntrDistance < totalWidth/2 - 0.5
        notParallel =1;
    end
end

%taking the average border distance of lane k and J
distanceRK = ((distanceRKJ2(1)+distanceRKJ2(2)/2))/totalWidth;
distanceLK = ((distanceLKJ1(1)+distanceLKJ1(2))/2)/totalWidth;

end
%------------- END CODE --------------