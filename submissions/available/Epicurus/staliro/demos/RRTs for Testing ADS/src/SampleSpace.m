classdef SampleSpace < handle
    %SampleSpace Describes a sample space.
    
    properties
        x_s
        sampler
        mapper
    end
    
    methods
        function obj = SampleSpace(x_s)
            %SampleSpace Construct an instance of this class
            %   x_s should be nx2 as min,max value for n parameters.
            obj.x_s = x_s;
            obj.sampler = @ur_sample_from_space;
            obj.mapper = @one_to_one_map;
        end
        
        function set_mapper(obj, mapper)
            obj.mapper = mapper;
        end
        
        function set_sampler(obj, sampler)
            obj.sampler = sampler;
        end
        
        function x = get_new_sample(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            temp_x = obj.sample_without_mapping();
            x = obj.map_sample(temp_x);
        end
        
        function x = sample_without_mapping(obj, x_s)
            if nargin < 2
                x_s = obj.x_s;
            end
            x = obj.sampler(x_s);
        end
        
        function mapped_x = map_sample(obj, org_x)
            mapped_x = obj.mapper(org_x);
        end
    end
end

function mapped_x = one_to_one_map(org_x)
    mapped_x = org_x;
end

