% ToDo Lukas
function update(varargin)
if nargin == 3
    obj = varargin{1};
    t = varargin{2};
    map = varargin{3};
end

if ~isempty(obj.trajectory)
    if obj.trajectory.timeInterval.ts == obj.trajectory.timeInterval.tf
        update@world.Vehicle(obj, obj.trajectory.timeInterval.ts, map);
    end
else
    update@world.Vehicle(obj, t, map);
end

end