function [nextIndex] = getNextIndex(vertices, currentIndex, direction, distances)
% getNextIndex - returns the next index in the specified direction while
% omitting vertices with zero distance
%
% Syntax:
%   [nextIndex] = getNextIndex(vertices, currentIndex, direction, distances)
%
% Inputs:
%   vertices - 2D array of vertices describing the polyline
%   currentIndex - index in respect to the vertices array
%   direction - direction of next: 'forward' or 'backward'
%   distances - optional: distances between vertices
%
% Outputs:
%   nextIndex - index of the next vertex
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

% Author:       Markus Koschi
% Written:      03-August-2017
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

% define epsilon for distance check
epsilon = 10e-6;

% input handling
if nargin < 3 || nargin > 4
    error('Wrong input.')
end
if nargin < 4
    distances = geometry.calcPathDistances(vertices(1,:), vertices(2,:));
end

% find next vertex in the specified direction
if strcmp(direction,'backward')
    if currentIndex == 1
        nextIndex = currentIndex;
    else
        k = currentIndex - 1;
        while distances(k+1) <= epsilon && k > 1
            k = k - 1;
        end
        nextIndex = k;
    end
elseif strcmp(direction,'forward')
    if currentIndex == size(vertices,2)
        nextIndex = currentIndex;
    else
        k = currentIndex + 1;
        while distances(k) <= epsilon && k < size(vertices,2)
            k = k + 1;
        end
        nextIndex = k;
    end
else
    error('Wrong input.')
end
end

%------------- END CODE --------------