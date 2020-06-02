function d = angled_distance(x1,x2)
%ANGLED_DISTANCE Summary of this function goes here
%   Detailed explanation goes here

x2 = reshape(x2, 3, []);
opposites = sign(abs(x1(3, :)) - pi/2) .* sign(abs(x2(3, :)) - pi/2);
opposites = opposites < 0;
angfactor = opposites * 100000;
d = colnorm( bsxfun(@minus, x1(1:2, :), x2(1:2, :)) );
d= d + angfactor;
end

