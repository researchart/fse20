classdef Perception < globalPck.Dynamic
    % Perception - class to hold all object percepted by the ego car in
    % its environment
    %
    % Syntax:
    %   object constructor: obj = Perception(varargin)
    %
    % Inputs:
    %   varargin{1} - map object or XML file name
    %   time - current time in s
    %
    % Outputs:
    %   obj - generated object
    %
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: none
    
    % Author:       Markus Koschi
    % Written:      27-October-2016
    % Last update:
    %
    % Last revision:---
    
    %------------- BEGIN CODE --------------
    
    properties (SetAccess = protected, GetAccess = public)
        % inherited from abstract class Dynamic:
        % time = 0;
        
        map = world.Map.empty();
    end
    
    methods
        % class constructor
        function obj = Perception(varargin)
            if nargin >= 1
                % set property map
                if isa(varargin{1},'world.Map')
                    % save map object
                    obj.map = varargin{1};
                elseif ischar(varargin{1})
                    % create map object from file
                    obj.map = world.Map(varargin{1});
                else
                    error('No Map file found. Error in globalPck.Perception');
                end
            end
            
            % set property time and update all objects
            if nargin == 2 && ~isempty(varargin{2}) && isnumeric(varargin{2})
                obj.time = varargin{2};
                obj.update(obj.time);
            else
                % use time of map (objects are already updated)
                obj.time = obj.map.time;
            end
        end
        
        % % set functions
        % function setTimeIntervall(obj, ts, dt, tf)
        %     if ~isempty(obj.timeInterval)
        %         obj.timeInterval.setTimeInterval(ts, dt, tf)
        %     else
        %         obj.timeInterval = globalPck.TimeInterval(ts, dt, tf);
        %     end
        % end
        
        % methods in seperate files:
        % occupancy
        computeOccupancyGlobal(obj, timeInterval)
        adaptOccupancy(obj)
        % collision check
        [collision_flag, collision_time, collision_obstacle] = checkOccupancyCollision(obj)
        % PNR
        [position_PNR] = findPNR(obj)
        [position_SFH] = findSFH(obj)
        
        % Dynamic class methods
        step(obj)
        update(varargin)
        
        % visualization methods
        disp(obj)
        plot(varargin) % argin: obj, timeInterval
    end
end

%------------- END CODE --------------