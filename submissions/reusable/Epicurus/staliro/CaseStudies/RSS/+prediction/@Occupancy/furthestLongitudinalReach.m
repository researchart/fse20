function [xi] = furthestLongitudinalReach(t, v0, v_s, v_max, a_max)
% furthestLongitudinalReach - compute the furthest possible travelled
% distance along the path in time t
%
% Syntax:
%   [xi] = furthestLongitudinalReach(t, v0, v_s, v_max, a_max)
%
% Inputs:
%   t - length of the time interval in seconds
%   v0 - initial velocity in longitudinal direction
%   v_s - switching velocity to model limited engine power (constraint2)
%   a_max - maximum absolute acceleration (unequal zero)
%
% Outputs:
%   xi - furthest possible travelled distance in path coordinates
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: Althoff and Magdici, 2016, Set-Based Prediction of Traffic
% Participants on Arbitrary Road Networks, III. Mathematical Modeling, B.
% Model of Other Traffic Participants AND
%   E. Weiﬂ, 2015, Set-based prediction of interacting road vehicles,
% Bachelor thesis, chapter 5

% Author:       Markus Koschi
% Written:      23-September-2016
% Last update:  15-May-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

% To find the furthest reach, the vehicle performs full acceleration. Hence,
%     { a_max           if v < v_s && v < v_max  --> time interval 1 (t1)
% a = { a_max * v_s/v   if v_s <= v < v_max        --> time interval 2 (t2)
%     { 0               if v >= v_max             --> time interval 3 (t3)
% (Althoff, p. 5)
% Note, that v_s might be set to infinity as a fallback solution. Also
% v_max and a_max can be set much higher to allow for dropping the
% corresponding constraint.

% compute the relevant time intervals (t = t1 + t2 + t3)
% time interval 1: accelerate from v0 to v_s with a = a_max
if (v0 < v_s && v0 < v_max)
    % (v_s - v0)/a_max refers to the time needed to reach v = v_s
    t1 = min( (v_s - v0)/a_max, t );
else
    t1 = 0;
end
v1 = a_max * t1 + v0;

% time interval 2: accelerate from v_s to v_max with a = a_max * v_s/v
if (v1 >= v_s && v1 < v_max) % (and if also t1 ~= 0, then v1 == v_s)
    % (v_max^2 - v1^2)/(2 * a_max * v_s) refers to the time needed to
    % reach v = v_max (Weiﬂ, (5.9))
    t2 = min( (v_max^2 - v1^2)/(2 * a_max * v_s), (t - t1) );
else
    t2 = 0;
end

% time interval 3: constant velocity (a = 0)
% t3 is the remaining time
t3 = t - t1 - t2;

% compute the travelled distance in each time interval
xi1 = (1/2 * a_max * t1^2) + (v0 * t1);
if t2 > 0
    xi2 = (((2 * a_max * v_s * t2) + v1^2)^(3/2) - v1^3) / (3 * a_max * v_s); %(Weiﬂ, (5.8))
else
    xi2 = 0;
end
xi3 = v_max * t3;

% sum of travelled distances
xi = xi1 + xi2 + xi3;
end

%------------- END CODE --------------