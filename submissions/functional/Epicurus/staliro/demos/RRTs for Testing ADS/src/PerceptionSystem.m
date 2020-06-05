classdef PerceptionSystem < handle
    %PERCEPTIONSYSTEM Contains the sensors and simulates a perception
    %system for a vehicle.
    
    properties
        sensors
        max_delay
        vhc_type
        vhc_id
    end
    
    methods
        function p = PerceptionSystem(vhc_type,vhc_id)
            %PERCEPTIONSYSTEM Construct an instance of this class
            %   Detailed explanation goes here
            p.sensors = [];
            p.max_delay = 0;
            p.vhc_type = vhc_type;
            p.vhc_id = vhc_id;
        end
        
        function p = add_sensor(p, s)
            %ADD_SENSOR Add a sensor object to the perception system
            p.sensors = [p.sensors, s];
            if s.time_delay > p.max_delay
                p.max_delay = s.time_delay;
            end
        end
        
        function detections = get_all_detections(p,sim_env)
            %GET_ALL_DETECTIONS Extract all sensor detections from the
            %given simulation environment.
            detections = [];
            sim_items = sim_env.get_sim_items(p.vhc_type,p.vhc_id,p.max_delay);
            for s_i = 1:length(p.sensors)
                detections = [detections, p.sensors(s_i).detect(sim_items,sim_items.cur_time)]; %#ok<AGROW>
            end
        end
        
    end
end

