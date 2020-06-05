% function to initialize the services of a generic type.
%INPUTS:
%   - number   = number of services to be initialized
%OUTPUTS:
%   - services = vector of initialized services

%Each service is initialized as a structure defining its state with the
%following fields:
%   * incoming       = number of new incoming requests
%   * processing     = vector of requests currently being processed
%   * state          = state of the service: 0 if working fine, a integer if
%                      not working, the integer represents the number of time 
%                      steps before the service is up again
%   * max_capacity   = maximum number of requests the provider is able to handle
%   * fail_prob      = probability of a request failing
%   * down_prob      = probability of the server going down at every time step
%   * recover_time   = time it takes for the server to start working again
%                      when went down
%   * execution_time = time to process one request

function services = initialize_services(number)

max_capacity=5;
failure_probabilities=[0.5,0.5,0.5,0.1,0.1,0.1,0.05,0.02,0.02,0.01];
down_probabilities=[0.05,0.05,0.01,0.01,0.001];
execution_time=[4];

for i=1:number
    services(i)=struct('incoming',0,...                       %states
                       'processing',zeros(max_capacity,1),...
                       'state',0,...
                       'max_capacity',max_capacity,...        %parameters
                       'fail_prob',datasample(failure_probabilities,1),...
                       'down_prob',datasample(down_probabilities,1),...
                       'recover_time',30, ...
                       'execution_time',datasample(execution_time,1) ...
                       );
end

end

