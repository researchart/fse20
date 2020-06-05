function [ ttc, v_coll ] = compute_TTC( p1, p2, v1, v2, allow_negative )
%compute_TTC Computes time-to-collision between 2 points.
if nargin < 5
    allow_negative = false;
end
%epsilon = 0.000001;
INFTY = 10000;

d = sqrt((p1-p2)'*(p1-p2));
d_dot = -((p1-p2)'*(v1-v2))/d;
%d_2dot = ((v1-v2)'*(v1-v2) - d_dot^2)/d;
if d_dot ~= 0.0 %abs(d_dot) > epsilon
    T1 = d/d_dot;
else
    T1 = INFTY;
end
ttc = T1;
if nargout > 1
    v_coll = d_dot;
end

if ttc < 0 && ~allow_negative
    ttc = INFTY;
end
end

