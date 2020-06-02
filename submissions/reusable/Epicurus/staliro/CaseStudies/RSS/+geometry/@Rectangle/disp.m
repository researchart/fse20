function disp(obj)
% display - displays a Rectangle object
%
% Syntax:
%   display(obj)
%
% Inputs:
%   obj - Rectangle object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      08-February-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

disp('-----------------------------------');

% display type
disp('type: Rectangle');

% display properties
disp(['width: ' num2str(obj.width)]);
disp(['length: ' num2str(obj.length)]);
if ~isempty(obj.position)
    disp(['position: [' num2str(obj.position(1)) '; ' num2str(obj.position(2)) ']']);
end
if ~isempty(obj.orientation)
disp(['orientation: ' num2str(obj.orientation)]);
end

disp('-----------------------------------');

end

%------------- END CODE --------------