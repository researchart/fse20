function disp(obj)
% display - displays a Trajectory object
%
% Syntax:
%   display(obj)
%
% Inputs:
%   obj - Trajectory object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      15-November-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

disp('-----------------------------------');

% display type and properties
disp('type: Trajectory');
%disp(['current time: ',num2str(obj.time(1))]);
%disp(['number of samples: ',num2str(numel(obj.time))]);

disp('-----------------------------------');

end

%------------- END CODE --------------