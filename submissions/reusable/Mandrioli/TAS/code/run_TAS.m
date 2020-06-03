% main function for simulation of Tele-Assistance-Service (TAS) based on time
%
%INPUTS:
%   - requests_profile = a vector defining the number of requests arriving 
%                        at each time step. If set to '0' then a random
%                        number of requests is generated at each time step.
%   - type_of_requests = a vector defining the probability of different
%                        types of request [none, drug, ambulance]
%   - num_providers    = a vector defining the number of provider per each
%                        service [analysis, drugs, ambulance]
%   - gain             = gain of the adaptation strategy, used for
%                        aggressive or soft adaptation strategy
%   - advanced         = boolean for using advanced adaptation strategy or
%                        not (active identification of unavailable 
%                        providers)
%   - [single_test]    = a (optional) boolean that should be true when only 
%                        one test (not testset!) is being executed. If true
%                        also the data about the load of the different 
%                        services are stored.
%OUTPUTS:
% 

function result = run_TAS(requests_profile,type_of_requests,num_providers,gain,advanced,single_test)

if ~exist('single_test') %check whether you will execute one or many tests
    single_test=false;
end

num_time_steps=length(requests_profile); %define number of time steps to be simulated

%% initialize services
analysis_providers=initialize_services(num_providers(1));     % analysis services
drug_providers=initialize_services(num_providers(2));         % drug services
ambulance_providers=initialize_services(num_providers(3));    % ambulance services

%% initialize controllers
analysis_adaptation=initialize_adaptation(num_providers(1));  % analysis services
drug_adaptation=initialize_adaptation(num_providers(2));      % drug services
ambulance_adaptation=initialize_adaptation(num_providers(3)); % ambulance services

%% initialize loop variables
drug_requests = zeros(num_providers(2),1);      %number of requests forwarded to drug services at each step
ambulance_requests = zeros(num_providers(3),1); %number of requests forwarded to ambulance services at each step

%storage for statistics
successfull_requests=0;
failed_requests=0;
%next ones are needed only if a single test is being performed
if single_test
    analysis_load_incoming=zeros(num_providers(1),num_time_steps);
    analysis_load_processing=zeros(num_providers(1),num_time_steps);
    drug_load_incoming=zeros(num_providers(2),num_time_steps);
    drug_load_processing=zeros(num_providers(2),num_time_steps);
    ambulance_load_incoming=zeros(num_providers(3),num_time_steps);
    ambulance_load_processing=zeros(num_providers(3),num_time_steps);
end

%% main loop over time
for i=1:num_time_steps
    
    %-------distribute new requests to analysis providers
    tmp=ctrl_action(requests_profile(i),analysis_adaptation);
    for ii=1:num_providers(1) %loop over analysis providers
        analysis_providers(ii).incoming=analysis_providers(ii).incoming+tmp(ii);
    end
    
    %-------run dynamics of the different providers (analysis-drugs-ambulance)
    [analysis_success, analysis_fail, analysis_providers]=service_dynamics(analysis_providers);
    [drug_success, drug_fail, drug_providers]=service_dynamics(drug_providers);
    [ambulance_success, ambulance_fail, ambulance_providers]=service_dynamics(ambulance_providers);
    
    %-------define types of requests
    [all_good, drug_requests, ambulance_requests]=pick_type_of_requests(sum(analysis_success),type_of_requests);
    
    %-------distribute requests to drugs and ambulance services
    tmp=ctrl_action(drug_requests,drug_adaptation);
    for ii=1:num_providers(2) %loop over drug providers
        drug_providers(ii).incoming=drug_providers(ii).incoming+tmp(ii);
    end
    tmp=ctrl_action(ambulance_requests,ambulance_adaptation);
    for ii=1:num_providers(3) %loop over ambulance providers
        ambulance_providers(ii).incoming=ambulance_providers(ii).incoming+tmp(ii);
    end
    
    %-------run adaptation algorithm
    analysis_adaptation=adaptation(analysis_success, analysis_fail,analysis_adaptation,gain,advanced); 
    drug_adaptation=adaptation(drug_success, drug_fail,drug_adaptation,gain,advanced); 
    ambulance_adaptation=adaptation(ambulance_success, ambulance_fail,ambulance_adaptation,gain,advanced);
    
    %-------re-distribute failed requests
    tmp=ctrl_action(sum(analysis_fail),analysis_adaptation);
    for ii=1:num_providers(1) %loop over analysis providers
        analysis_providers(ii).incoming=analysis_providers(ii).incoming+tmp(ii);
    end
    tmp=ctrl_action(sum(drug_fail),drug_adaptation);
    for ii=1:num_providers(2) %loop over drug providers
        drug_providers(ii).incoming=drug_providers(ii).incoming+tmp(ii);
    end
    tmp=ctrl_action(sum(ambulance_fail),ambulance_adaptation);
    for ii=1:num_providers(3) %loop over ambulance providers
        ambulance_providers(ii).incoming=ambulance_providers(ii).incoming+tmp(ii);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %store data for statistics%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    successfull_requests=successfull_requests+all_good+sum(drug_success)+sum(ambulance_success);
    failed_requests=failed_requests+sum(analysis_fail)+sum(drug_fail)+sum(ambulance_fail);
    %next ones are needed only if a single test is being performed
    if (single_test)
        %store data about different services
        for ii=1:num_providers(1) %loop over analysis providers
            analysis_load_incoming(ii,i)=analysis_providers(ii).incoming;
            if ~analysis_providers(ii).state
                analysis_load_processing(ii,i)=sum(analysis_providers(ii).processing>0);
            else
                analysis_load_processing(ii,i)=-1;
            end
        end
        for ii=1:num_providers(2) %loop over drug providers
            drug_load_incoming(ii,i)=drug_providers(ii).incoming;
            if ~drug_providers(ii).state
                drug_load_processing(ii,i)=sum(drug_providers(ii).processing>0);
            else
                drug_load_processing(ii,i)=-1;
            end
        end
        for ii=1:num_providers(3) %loop over ambulance providers
            ambulance_load_incoming(ii,i)=ambulance_providers(ii).incoming;
            if ~ambulance_providers(ii).state
                ambulance_load_processing(ii,i)=sum(ambulance_providers(ii).processing>0);
            else
                ambulance_load_processing(ii,i)=-1;
            end
        end
    end % end if single test

end %end main loop

%% extract relevant statistics
result.success=successfull_requests;
result.fail=failed_requests;
%next ones are needed only if a single test is being performed
if (single_test)
    result.analysis_load_incoming=analysis_load_incoming;
    result.analysis_load_processing=analysis_load_processing;
    result.drug_load_incoming=drug_load_incoming;
    result.drug_load_processing=drug_load_processing;
    result.ambulance_load_incoming=ambulance_load_incoming;
    result.ambulance_load_processing=ambulance_load_processing;
end

end %end function