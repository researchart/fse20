classdef TimeInterval < globalPck.Dynamic
    % TimeInterval - class to describe a time interval
    %
    % Syntax:
    %   object constructor:
    %
    % Inputs:
    %   ts - starting time in s
    %   dt - time step size in s
    %   tf - ending in time in s
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
        
        ts = [];
        dt = [];
        tf = [];
    end
    
    methods
        % class constructor
        function obj = TimeInterval(ts, dt, tf, time)
            if nargin >= 3
                obj.ts = ts;
                
                if dt ~= 0
                    obj.dt = dt;
                else
                    obj.dt = 0.1; %default value
                end
                
                obj.tf = tf;
            end
            if nargin == 4
                obj.time = time;
            end
        end
        
        % set method
        function setTimeInterval(obj, ts, dt, tf)
            obj.ts = ts;
            obj.dt = dt;
            obj.tf = tf;
        end
        
        % get method
        function [ts, dt, tf] = getTimeInterval(obj)
            ts = obj.ts;
            dt = obj.dt;
            tf = obj.tf;
        end
        
        % Dynamic class methods
        function step(obj)
            obj.ts = obj.ts + obj.dt;
            obj.tf = obj.tf + obj.dt;
            obj.time = obj.time + obj.dt;
        end
        
        %ToDo: check interval boundaries
        function [idx_start, idx_end] = getIndex(obj, ts, tf)
            if nargin == 2
                % Get index of specific point in time
                idx_end = [];
            elseif nargin == 3
                % Get start index and final index of timeinterval [ts,tf]
                idx_end = round((tf - obj.ts)/obj.dt) + 1;
            end
            idx_start = round((ts - obj.ts)/obj.dt) + 1;
            
            % catch invalid index and return 0
            if idx_start < 0 || isnan(idx_start)
                idx_start = 0;
            end
        end
        
        function [cnt] = getNumberOfSamples(obj)
            cnt = round((obj.tf - obj.ts)/obj.dt) + 1;
        end
        
        % methods in seperate files
        update(varargin)
        disp(obj)
        plot(varargin) % argin: obj, timeInterval
    end
end

%------------- END CODE --------------