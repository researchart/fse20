classdef (Abstract) Dynamic < handle
    % Dynamic - abstract class that defines objects which act over time
    %
    % Syntax:
    %   no object constructor
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
        time = 0; % current time of the object
    end
    
    methods (Abstract)
        % Dynamic class methods
        step(obj) % for simulation
        update(varargin) % to update from sensor data
        
        % visualization methods
        disp(obj)
        plot(varargin)
    end
end

%------------- END CODE --------------