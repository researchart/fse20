function [obj] = manageConstraints(obj, obstacle)
% manageConstraints - verify the restrictions of all constraints by
% checking whether their limitation has been violated. If the actual
% property is higher than the constraint, it gets increased.
%
% Syntax:
%   [obj] = manageConstraints(obj, obstacle)
%
% Inputs:
%   obj - Occupancy object (property of obstacle)
%   obstacle - Obstacle object
%
% Outputs:
%   obj - Occupancy object
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: Althoff and Magdici, 2016, Set-Based Prediction of Traffic
% Participants on Arbitrary Road Networks, IV. Occupancy Prediction

% Author:       Markus Koschi
% Written:      16-November-2016
% Last update:  28-August-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

% constraints C1-C5 are only applicable for dynamic obstacles
if isa(obstacle, 'world.DynamicObstacle')
    
    % manage constraint C1 (maximum speed of obstacle):
    % if speed of obstacle is higher than its v_max, set v_max to infinity
    if obstacle.velocity > obstacle.v_max
        warning(['The speed of obstacle %d (v = %f) is higher than its ' ...
            'parameterized maximum speed (v_max = %f).'], obstacle.id, ...
            obstacle.velocity, obstacle.v_max)
        obstacle.set('v_max', inf);
    end
    % if speed of obstacle is higher than the speed limit * speeding
    % factor, increase speeding factor
    if ~isempty(obstacle.inLane)
        if obstacle.velocity > (max(obstacle.inLane(1).speedLimit) * (1 + obstacle.speedingFactor))
            warning(['The speed of obstacle %d (v = %f) is above the speed' ...
                ' limit (v = %f) by %d%%.'], obstacle.id, obstacle.velocity, ...
                max(obstacle.inLane(1).speedLimit), round(obstacle.speedingFactor * 100))
            speedingFactor_currently = (obstacle.velocity / max(obstacle.inLane(1).speedLimit)) - 1;
            obstacle.set('speedingFactor', (speedingFactor_currently + obj.INITIAL_SPEEDING_FACTOR));
        end
    else
        warning('Obstacle %d is not in a Lane.', obstacle.id)
    end
    
    % manage constraint C2 (modeling maximum engine power), which is only
    % applicable for vehicles
    if isa(obstacle, 'world.Vehicle') && ~isempty(obstacle.acceleration)
        % if acceleration is higher than by formula (a = a_max * v_s/v)
        % for speeds above v_s, set v_s to infinity
        if obstacle.velocity < obstacle.v_max && obstacle.velocity > obstacle.v_s && ...
                obstacle.acceleration > (obstacle.a_max * (obstacle.v_s / obstacle.velocity))
            warning(['The acceleration of obstacle %d (a = %f) is higher' ...
                ' than its modelled maximum acceleration (a = a_max * v_s/v'...
                ' = %f) for the switching velocity (v_s = %f).'], ...
                obstacle.id, obstacle.acceleration, ...
                (obstacle.a_max * (obstacle.v_s / obstacle.velocity)), ...
                obstacle.v_s)
            obstacle.set('v_s', inf);
        end
    end
    
    % manage constraint C3 (not allowing backward driving):
    % if speed of obstacle is negative, backward driving must be considered
    if obstacle.constraint3 && obstacle.velocity < 0
        warning(['The speed of obstacle %d (v = %f) is negative, although' ...
            ' constraint 3 was true.'], obstacle.id, obstacle.velocity)
        obstacle.set('constraint3', false);
        % elseif ~obstacle.constraint3 && obstacle.velocity > 0
        %     % elseif constraint 3 was false and speed is positive, set
        %     % constraint 3 true again
        %     obstacle.set('constraint3', true);
    end
    
    % manage constraint C4 (maximum absolute acceleration of obstacle)
    % since this is a physical constraint, it cannot be violated
    %     % if acceleration of obstacle is higher than its a_max, increase a_max
    %     % by the double difference of a and a_max
    %     if obstacle.acceleration > obstacle.a_max
    %          warning(['The acceleration of obstacle %d (a = %f) is higher than its ' ...
    %             'maximum allowed acceleration (a_max = %f).'], obstacle.id, ...
    %             obstacle.acceleration, obstacle.a_max)
    %         obstacle.set('a_max', obstacle.a_max + ...
    %             (2 * (obstacle.acceleration - obstacle.a_max)));
    %     end
    
    % manage constraint C5 (lane crossing)
    % detect if obstacle is driving on lane with opposing traffic
    % this check is done when updating the inLane property in the method
    % world.DynamicObstacle.update()
    
    % ego vehicle can go anywhere
    if isa(obstacle, 'world.EgoVehicle')
        obstacle.set('constraint5', false);
    end
    
end

end

%------------- END CODE --------------