classdef AcceptAllNovelty < handle
    %RelativeStateBasedNovelty Class for computing novelty.
    
    properties
        rel_states
        novelty_history
        num_novelty
        avg_novelty
        max_rejections = 5
        num_rejections
    end
    
    methods
        function obj = AcceptAllNovelty(ego_vehicles,agent_vehicles)
            %RelativeStateBasedNovelty Construct an instance of this class
            % Inits the novelty data (relative states) to an empty cell array.
            obj.rel_states = cell(length(ego_vehicles), length(agent_vehicles));
            obj.num_novelty = 0;
            obj.novelty_history = zeros(1,1000);
            obj.avg_novelty = 0;
            obj.num_rejections = 0;
        end
        
        function [is_novel, novelty, all_novelty] = compute_novelty(obj,ego_vehicles,agent_vehicles)
            %compute_novelty Computes novelty for the given vehicles.
            all_novelty = zeros(length(ego_vehicles),length(agent_vehicles));
            novelty = max(all_novelty(:));
            is_novel = true;
        end
        
    end
end

