classdef TreeNodeData < handle
    %TreeNodeData Data kept on the Tree nodes
    
    properties
        x
        x_hist
        u_hist
        target_path
        cur_time
        controller_state
        ttc_list
    end
    
    methods
        function obj = TreeNodeData(x)
            %TreeNodeData Construct an instance of TreeNodeData
            if nargin > 0
                obj.x = x;
            else
                obj.x = [];
            end
            obj.x_hist = [];
            obj.u_hist = [];
            obj.target_path = [];
            obj.cur_time = 0;
            obj.controller_state = [];
            obj.ttc_list = [];
        end
    end
end

