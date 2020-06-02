function [distance, nLamda] = calcProjectedDistance(i, bound, position)
% calcProjectedDistance - project the position on the bound such that it is
% perpendicular to the pseudo tanget and calculate the distance of the
% projection point to vertice i
%
% Syntax:
%   [distance] = calcProjectedDistance(i, bound, position)
%
% Inputs:
%   i - vertice index of the bound which is closest to the object's position
%   bound - lane border
%   position - coordinates of the object
%
% Outputs:
%   distance - L2 norm from pLamda to vi
%   nLamda - vector perpendicular to the pseudo tanget and pointing to the
%               given position 
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: Bender et al., 2014, Lanelets: Efficient Map Representation for
% Autonomous Driving, III. Lanelts, D. Calculation and measures
%
% References in this function refer to this paper.

% Author:       Markus Koschi
% Written:      20-Oktober-2016
% Last update:  23-August-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

% vertice_i of inner bound
vi = bound.vertices(:,i);

% find the previous and next vertices on the lane bound:
% (note that these vertices might not be the on the inner bound)
if i == 1 && i == size(bound.vertices,2)
    error(['Lane %i is too short to properly calculate the projection of'...
            ' the object on the lane border'], bound.id(1));
end
% set v(i-2) and v(i-1)
iminus1 = geometry.getNextIndex(bound.vertices, i, 'backward', bound.distances);
viminus1 = bound.vertices(:,iminus1);
viminus2 = bound.vertices(:,geometry.getNextIndex(bound.vertices, iminus1, 'backward', bound.distances));
% set v(i+1) and v(i+2)
iplus1 = geometry.getNextIndex(bound.vertices, i, 'forward', bound.distances);
viplus1 = bound.vertices(:,iplus1);        
viplus2 = bound.vertices(:,geometry.getNextIndex(bound.vertices, iplus1, 'forward', bound.distances));

% choose the segment in which the object's position is projected in:
% calculate the angle between the points (vi, p, vi-1) and (vi, p, vi+1)
a = vi - position;
b = viminus1 - position;
beta_iminus1 = atan2(a(1)*b(2) - a(2)*b(1), a(1)*b(1) + a(2)*b(2));
b = viplus1 - position;
beta_iplus1 = atan2(a(1)*b(2) - a(2)*b(1), a(1)*b(1) + a(2)*b(2));
% set the flag:
% if position is between vertices v(i-1) and v(i) -> flag = 1
% if position is between vertices v(i) and v(i+1) -> flag = 0
flag_segement = abs(beta_iminus1) > abs(beta_iplus1);

% construct the points (p) and tangents (t) of the base and the tip of the
% segment
ti = viplus1 - viminus1;
if flag_segement % v(i-1) -> v(i)
    pBase = viminus1;
    tBase = vi - viminus2; % timinus1
    pTip = vi;
    tTip = ti;
else % ~flag: v(i) -> v(i+1)
    pBase = vi;
    tBase = ti;
    pTip = viplus1;
    tTip = viplus2 - vi; % tiplus1
end

% transform the coordinate system:
% translate by -pBase, such that pBase == 0
% rotate by theta, such that pTip(2) == 0
% (note that atan() does not work for all cases)
theta = atan2( -(pTip(2) - pBase(2)), (pTip(1) - pBase(1)) );

% points p:
% pBase = [0; 0]
% pTip = [l; 0]
l = norm(pTip - pBase);
% pTip_x = l = (pTip(1) - pBase(1))*cos(theta) - (pTip(2) - pBase(2))*sin(theta)
% pTip_y = 0 = (pTip(1) - pBase(1))*sin(theta) + (pTip(2) - pBase(2))*cos(theta)

% transform the tangent vectors into new coordinate system,
% i.e. rotate with theta
tBase_Rot(1) = tBase(1) * cos(theta) -  tBase(2) * sin(theta);
tBase_Rot(2) = tBase(1) * sin(theta) +  tBase(2) * cos(theta);
tTip_Rot(1) = tTip(1) * cos(theta) -  tTip(2) * sin(theta);
tTip_Rot(2) = tTip(1) * sin(theta) +  tTip(2) * cos(theta);

% transform the tangents such that t = [1; m], i.e. slopes m = ty / tx
% tBase = [1; mBase]
mBase = tBase_Rot(2) / tBase_Rot(1);
% tTip = [1; mTip]
mTip = tTip_Rot(2) / tTip_Rot(1);

% transform the position of the object = [x, y] in new coordinate system:
% translate
x_Trans = position(1) - pBase(1);
y_Trans = position(2) - pBase(2);
% rotate
x = x_Trans * cos(theta) -  y_Trans * sin(theta);
y = x_Trans * sin(theta) +  y_Trans * cos(theta);

% solve equations (1) - (4) for parameter lamda (equation (5))
lamda = (x + y * mBase) / (l - y * (mTip - mBase));

% distance from pLamda to vi (distance is equal in both coordinate systems)
if flag_segement % (vi == pTip)
    % i.e. distance from pLamda to pTip
    distance = (1 - lamda) * l; %previous verified version
else % (vi == pBase)
    % i.e. distance from pLamda to pBase
    distance = - lamda * l;
end

% projection vector nLamda (connecting pLamda perpendicular with position)
pLamda = lamda * pTip + (1-lamda) * pBase; % (equation (2))
nLamda = position - pLamda;

% % figure in global coordinate frame
% plot(vi(1), vi(2), 'ks')
% plot(viminus1(1), viminus1(2), 'ko')
% plot(viplus1(1), viplus1(2), 'ko')
% plot(pBase(1), pBase(2), 'k.')
% plot(pTip(1), pTip(2), 'k.')
% plot(pLamda(1), pLamda(2), 'r.')
% alpha = 0:0.1:1;
% plot(pBase(1)+alpha*tBase(1), pBase(2)+alpha*tBase(2), 'g-')
% plot(pLamda(1)+alpha*nLamda(1), pLamda(2)+alpha*nLamda(2), 'g--')

% % figure in transformed coordinates (X_)
% figure()
% plot(0,0,'k.') %pBase
% hold on
% plot(l,0,'k.') %pTip
% plot(x,y,'r.') %x
% plot(lamda*l, 0, 'rx') %pLamda
% alpha = 0:0.1:1;
% pBase_ = [0; 0];
% pTip_ = [l; 0];
% tBase_ = [1; mBase];
% tTip_ = [1; mTip];
% plot(pBase_(1)+alpha*tBase_(1), pBase_(2)+alpha*tBase_(2), 'g-')
% plot(pTip_(1)+alpha*tTip_(1), pTip_(2)+alpha*tTip_(2), 'g--')

%------------- END CODE --------------

end