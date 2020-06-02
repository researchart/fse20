function disp(obj)
% display - displays an Occupancy object
%
% Syntax:
%   display(obj)
%
% Inputs:
%   obj - Occupancy object
%
% Outputs:
%   none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      27-Oktober-2016
% Last update:  08-June-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

disp('-----------------------------------');

%display type
disp('type: Occupancy');

% display properties
disp(['number of lanes: ' num2str(size(obj, 1))])
disp(['number of time intervals: ' num2str(size(obj, 2))])

if ~isempty(obj) && ~isempty(obj(1,1))
    % display valid abstraction
    disp('Occupancy is composed of: ')
    if obj(1,1).COMPUTE_OCC_M1
        disp('acceleration-based occupancy (abstraction M1)')
    end
    if obj(1,1).COMPUTE_OCC_M2
        disp('lane-following occupancy (abstraction M2)')
    end
end

disp('-----------------------------------');

end

%------------- END CODE --------------