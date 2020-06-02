function disp(obj)
% display - displays a Perception object
%
% Syntax:
%   display(obj)
%
% Inputs:
%   obj - Perception object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      28-Oktober-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

disp('-----------------------------------');

% display type
disp('type: Perception');

% display properties
disp(['time: ',num2str(obj.time)]);
disp('Map:');
disp(obj.map);

disp('-----------------------------------');

end

%------------- END CODE --------------