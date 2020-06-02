% function leftRightLane - 
%   returns positive if the point C is at the left side of vector A->B
%   returns negative if the point C is at the right side of vector A->B
function [cross_product] = leftRightLane(A,B,C)
delta_B=[B(1)-A(1),B(2)-A(2)];
delta_P=[C(1)-A(1),C(2)-A(2)];
cross_product=delta_B(1)*delta_P(2)-delta_B(2)*delta_P(1);
end

