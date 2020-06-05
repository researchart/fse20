classdef RelativeStateBasedNovelty < handle
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
        function obj = RelativeStateBasedNovelty(ego_vehicles,agent_vehicles)
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
            for e_i = 1:length(ego_vehicles)
                for a_i = 1:length(agent_vehicles)
                    % Relative states of the ego vehicle wrt the agent:
                    recent_rel_states = ego_vehicles(e_i).veh.x_hist(:,1:4) - ...
                        agent_vehicles(a_i).veh.x_hist;
                    % The relative states shifted by one step
                    delayed_rel_states = [ego_vehicles(e_i).veh.x0(1:4)' - ...
                        agent_vehicles(a_i).veh.x0'; ...
                        recent_rel_states(1:end-1,:)];
                    % Relative states and 'change in relative states' merged
                    new_data = [recent_rel_states, ...
                        recent_rel_states - delayed_rel_states];
                    all_novelty(e_i,a_i) = ...
                        obj.compute_novelty_from_data(...
                            obj.rel_states{e_i, a_i}, ...
                            new_data(end,:));
                    obj.rel_states{e_i, a_i} = [obj.rel_states{e_i, a_i};...
                        new_data];
                end
            end
            novelty = max(all_novelty(:));
            is_novel = obj.num_rejections >= obj.max_rejections || ...
                obj.num_novelty < 10 || ...
                novelty >= mean(obj.novelty_history(obj.num_novelty-9:obj.num_novelty));
            obj.avg_novelty = (obj.avg_novelty*obj.num_novelty + novelty)/(obj.num_novelty+1);
            obj.num_novelty = obj.num_novelty + 1;
            if obj.num_novelty > length(obj.novelty_history)
                obj.novelty_history = [obj.novelty_history, zeros(1, length(obj.novelty_history))];
            end
            obj.novelty_history(obj.num_novelty) = novelty;
            if ~is_novel
                obj.num_rejections = obj.num_rejections + 1;
            else
                obj.num_rejections = 0;
            end
        end
        
    end
    
    methods(Static)
        function novelty = compute_novelty_from_data(old_data,new_data)
            %compute_novelty_from_data Novelty is the maximum of the 
            % sparseness of points in new_data wrt old_data.
            if isempty(old_data)
                novelty = 0;
            else
                [~,dists] = knnsearch(old_data,new_data,'K',10,...
                    'Distance','mahalanobis');
                novelty = max(sum(dists,2)/size(dists,1));
            end
        end
    end
end

