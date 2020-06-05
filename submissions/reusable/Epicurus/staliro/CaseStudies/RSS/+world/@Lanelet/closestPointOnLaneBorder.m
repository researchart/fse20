function [pt_out, dist, idx] = closestPointOnLaneBorder(obj, pt, border)
% closestPointOnLaneBorder - %TODO
% %TODO: Rajat: function needs revision
%
% Syntax:
%   [pt_out, dist, road_distance, idx] = closestPointOnLaneBorder(obj, pt)
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
% See also: Althoff and Magdici, 2016, Set-Based Prediction of Traffic Participants on
% Arbitrary Road Networks, III. A. Road Network Representation

% Author:       Rajat Koner
% Written:      08-November-2016
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
end
if idx<size(border,2)
    [pt2_out, dist2, rd2] = geometry.project_point_line_segment(border(1:2,idx), border(1:2,idx+1), pt);
    if dist > dist2 || idx == 1
        dist = dist2;
        pt_out = pt2_out;
    end
end
end

%------------- END CODE --------------