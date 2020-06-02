function update( varargin )
% update - updates the properties of a Vehicle object by the values
% of the trajectory at the specified time
%
% Syntax:
%   update(obj, t)
%
% Inputs:
%   obj - Vehicle object
%   t - current time of the object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Stefanie Manzinger
% Written:      29-Nomvember-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

if nargin == 3
    obj = varargin{1};
    t = varargin{2};
    map = varargin{3};
    
    update@world.DynamicObstacle(obj, t, map);
end

%------------- END CODE --------------
