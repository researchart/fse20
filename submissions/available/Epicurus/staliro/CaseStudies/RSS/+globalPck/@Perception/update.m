function update(varargin)
% update - updates the properties of a Perception object
%
% Syntax:
%   update(obj, t)
%
% Inputs:
%   obj - Perception object
%   t - current time of the object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      27-January-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

    if nargin == 2
        obj = varargin{1};
        t = varargin{2};
    end

    obj.map.update(t);
    obj.time = t;
end

%------------- END CODE --------------