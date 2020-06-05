function [xi] = closestLongitudinalReach(t, v0, a_max, constraint3)
% closestLongitudinalReach - compute the shortest possible travelled
% distance in time t
%
% Syntax:
%   [xi] = closestLongitudinalReach(t, v0, a_max, constraint3)
%
% Inputs:
%   t - time interval
%   v0 - initial velocity in longitudinal direction
%   a_max - maximum absolute acceleration
%   constraint3 - boolean, whether driving backwards is not allowed
%
% Outputs:
%   xi - travelled distance in path coordinates (negative distance conforms
%   to backward driving)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ---

% Author:       Markus Koschi
% Written:      22-September-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

% To find the closest reach, the vehicle performs full braking. Hence,
% a = - a_max.

% compute the relevant time
if constraint3
    % as constraint3 holds, the velocity must not be negative
    % v0/a_max refers to the time needed to reach v = 0    
    t1 = min(v0/a_max, t);
else % constraint3 = false
    % backward driving is allowed
    t1 = t;
end

% compute the traveled distance s = (1/2 * a * t^2) + (v0 * t) + (s0)
xi = (1/2 * - a_max * t1^2) + (v0 * t1);
end

%------------- END CODE --------------