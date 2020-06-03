% function that implements the services dynamics, it should implement both
% the requests handling and the service dynamics (servers that might go 
% down and similar). It outputs the number of requests that each service
% managed and/or failed to handle at this time step: this is needed because
% the controller will need it.
%
%INPUTS
%   - services
%OUTPUTS
%   - success
%   - fail
%   - services

function [success, fail, services]=service_dynamics(services)

%initialize output
success=zeros(length(services),1);
fail=success;

%iterate over all the services
for i=1:length(services)

%% provider working
if ~services(i).state %server was up at previous time step
    if rand<services(i).down_prob %provider goes down
        %disp(['server ',int2str(i),' down'])
        services(i).state=services(i).recover_time; %update state
        fail(i)=sum(services(i).processing>0)+services(i).incoming; %fail all the requests currently being processed
        services(i).processing(services(i).processing>0)=0; %reset the processing vector
        services(i).incoming=0; %reset incoming requests
    else %provider is working
        for ii=1:services(i).max_capacity %loop over requests being handled
            switch services(i).processing(ii)
                case 0 %new request can be taken
                    if services(i).incoming>0
                        services(i).processing(ii)=services(i).execution_time; %start procssing a new request
                        services(i).incoming=services(i).incoming-1; %decrement incoming requests
                    end
                case 1 %request is done
                    services(i).processing(ii)=0;
                    if rand>services(i).fail_prob %check if request fails because of provider internal error
                    	success(i)=success(i)+1;
                    else
                        fail(i)=fail(i)+1;
                    end
                    % if there are still requests in the queue re-assign the resource
                    % otherwise requests would take execution_time+1 to be processed
                    if services(i).incoming>0 
                        services(i).processing(ii)=services(i).execution_time; %start procssing a new request
                        services(i).incoming=services(i).incoming-1; %decrement incoming requests
                    end
                otherwise %request is being processed
                    services(i).processing(ii)=services(i).processing(ii)-1;
            end %switch
        end %loop over requests being handled
        
        %some requests might still not have been handled here, they are
        %kept in the queue
    end
else % else the provider is not working
%% provider down
    services(i).state=services(i).state-1; %one step less to recover
    fail(i)=services(i).incoming; %all incoming requests are failed 
    services(i).incoming=0;
end %end if provider working

end %end providers loop

end


