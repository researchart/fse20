classdef (Abstract) Shape < matlab.mixin.Heterogeneous & handle
    % Shape - abstract class for describing 2D shapes
    % (Inherits from matlab.mixin.Heterogeneous to combine instances of the
    % subclasses into heterogeneous arrays)
    %
    % Syntax:
    %   no object constructor
    %
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: none
    
    % Author:       Markus Koschi
    % Written:      08-February-2017
    % Last update:  25-August-2017
    %
    % Last revision:---
    
    %------------- BEGIN CODE --------------
    
    properties (SetAccess = protected, GetAccess = public)
    end
    
    methods (Abstract)
        % visualization methods
        disp(obj)
        plot(varargin)
    end
    
end

%------------- END CODE --------------