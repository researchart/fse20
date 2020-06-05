function [ pt_proj, dist, rd ] = project_point_line_segment( line_pt_a, line_pt_b, pt )
%PROJECT_POINT_LINE_SEGMENT Returns closest point on the line segment
%   pt_proj closest point on line segment
%   dist    distance pt to closest point on line segment
%   rd      distance from line_pt_a along line segment to closest point

d = line_pt_b-line_pt_a;
v = pt-line_pt_a;
c = (d'*v)/(d'*d)*d;

rd = (d'*v)/norm(d);
if rd<0
    % line_pt_a is the closest point on the segment
    rd = 0;
    pt_proj = line_pt_a;
    dist = norm(line_pt_a-pt);
elseif rd>norm(d)
    % line_pt_b is the closest point on the segment
    rd = norm(d);
    pt_proj = line_pt_b;
    dist = norm(line_pt_b-pt);
else
    % project v onto the segment
    dist = norm(v-c);
    pt_proj = line_pt_a+c;
end

end

