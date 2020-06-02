function [alpha, beta] = calcVectorIntersectionPoint(a, b, c, d)
% calcVectorIntersectionPoint - calculate the parameters alpha and beta
% such that the two lines intersect: a + alpha*b = c + beta*d
% (lines are give in vector equation: r = OA + lamda*AB)
%
% Syntax:
%   [alpha, beta] = calcVectorIntersectionPoint(a, b, c, d)
%
% Inputs: (in column vectors)
%   a - vector OA of line 1
%   b - vector AB of line 1
%   c - vector OA of line 2
%   d - vector AB of line 2
%
% Outputs:
%   beta - parameter of line 2 to insect with line 1
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: ---

% Author:       Markus Koschi
% Written:      13-Oktober-2016
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

% analytical solution of above vector equation system
beta = ( a(1) * b(2) - a(2) * b(1) - c(1) * b(2) + c(2) * b(1) ) / ...
    ( d(1) * b(2) - d(2) * b(1) );

alpha = (c(1) + beta * d(1) - a(1)) / b(1);

end

%------------- END CODE --------------
