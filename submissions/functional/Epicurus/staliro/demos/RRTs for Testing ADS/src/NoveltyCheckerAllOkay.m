classdef NoveltyCheckerAllOkay < handle
    %NoveltyCheckerAllOkay Class for computing novelty.
    
    properties
        rel_states
        novelty_history
        num_novelty
        avg_novelty
    end
    
    methods
        function obj = NoveltyCheckerAllOkay(ego_vehicles,agent_vehicles)
            %NoveltyCheckerAllOkay Construct an instance of this class
            % Inits the novelty data (relative states) to an empty cell array.
            obj.rel_states = cell(length(ego_vehicles), length(agent_vehicles));
            obj.num_novelty = 0;
            obj.novelty_history = zeros(1,1000);
            obj.avg_novelty = 0;
        end
        
        function [is_novel, novelty, all_novelty] = compute_novelty(obj,ego_vehicles,agent_vehicles)
            %compute_novelty Computes novelty for the given vehicles.
            all_novelty = zeros(length(ego_vehicles),length(agent_vehicles));
            novelty = 0.0;
            is_novel = true;
        end
        
    end
    
    methods(Static)
        function novelty = compute_novelty_from_data(old_data,new_data)
            %compute_novelty_from_data Novelty is the maximum of the 
            % sparseness of points in new_data wrt old_data.
            novelty = 0;
        end
    end
end

