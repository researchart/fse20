function [pt_out, dist, idx] = closestPointOnLaneBorderInTrun(obj, pt, border)
% closestPointOnLaneBorderInTrun - %give closest point on lane border in
% case of sharp turn allow multiple projection on same point 
%
% Syntax:
%   [pt_out, dist, road_distance, idx] = closestPointOnLaneBorderInTrun(obj, pt)
%
% Inputs:
%   %TODO
%
% Outputs:
%   %TODO
%
% Other m-files required: %TODO
% Subfunctions: none
% MAT-files required: none
%
% Author:       Rajat Koner
% Written:      27-Feb-2017
% Last update:
%
% Last revision:---

%------------- BEGIN CODE --------------

road_distance = -1;
idx = knnsearch(border(1:2,:)', pt');
dist = 0;
pt_out = [];
if idx>1
    [pt_out, dist, rd] = geometry.project_point_line_segment(border(1:2,idx-1), border(1:2,idx), pt);
    if isnan(pt_out)
        pt_out = border(1:2,idx);
    end
end
if idx<size(border,2)
    [pt2_out, dist2, rd2] = geometry.project_point_line_segment(border(1:2,idx), border(1:2,idx+1), pt);
    if dist > dist2 || idx == 1
        dist = dist2;
        pt_out = pt2_out;
    end
    % if nan project previous point
    if isnan(pt2_out)
        pt2_out = border(1:2,idx+1);
        pt_out = pt2_out;
    end
end

end

%------------- END CODE --------------