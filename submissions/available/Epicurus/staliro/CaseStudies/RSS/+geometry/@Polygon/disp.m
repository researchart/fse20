function disp(obj)
% display - displays a Polygon object
%
% Syntax:
%   display(obj)
%
% Inputs:
%   obj - Polygon object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      08-February-2017
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

disp('-----------------------------------');

% display type
disp('type: Polygon');

% display properties
disp(['number of vertices: ' num2str(size(obj.vertices,2))]);

disp('-----------------------------------');

end

%------------- END CODE --------------