
% Main script for running the simulation of the Tele-Assistance Service 
% presented at ESEC/FSE 2020 in the paper "Testing Self-Adaptive Software 
% with Probabilistic Guarantees on Performance Metrics"

clear all
close all
random_seed=98766867; %store for repeatibility
rng(random_seed)

%% testing parameters
% Number of tests in a single testset
num_tests=500;
% Number of Testsets:
% do more than one for evaluating stability of results (only one testset in 
% the ESEC/FSE paper)
num_testset=1;

%% testing conditions (the ones that are the same in all the tests)
num_providers=[60,20,15]; % number of [analysis, drug, ambulance] providers
adaptation_gain=50;
advanced=false;

%% initialize variables for storage
total_requests=zeros(num_tests,1); 
service_rate=zeros(num_tests,num_testset);
total_num_fails=zeros(num_tests,num_testset);
avg_num_attempts=zeros(num_tests,num_testset);

max_avg_num_attempts=zeros(num_tests+1,num_testset);
max_fails=zeros(num_tests+1,num_testset);

%% run tests
disp(['-------------- STARTING EXECUTION OF TESTS --------------'])
%testset loop
for jj=1:num_testset
%tests loop
for j=1:num_tests
  %GENERATE RANDOMIZED TESTING CONDITIONS FOR EACH TEST
    %generate request profile
    requests_profile=generate_requests_profile_randomized();
    total_requests(j)=sum(requests_profile);
    %probabilities of a request being respectively all_good, drug or ambulance
    drug_prob=0.20+rand*(0.40-0.20);
    ambulance_prob=0.15+rand*(0.30-0.15);
    type_of_requests=[1-ambulance_prob-drug_prob,drug_prob,ambulance_prob];    
  %RUN TAS
    res=run_TAS(requests_profile,type_of_requests,num_providers,adaptation_gain,advanced);
  %STORE TEST OUTCOME
    total_num_fails(j,jj)=res.fail; %number of times a service has failed a request
    avg_num_attempts(j,jj)=(sum(requests_profile)+total_num_fails(j))/sum(requests_profile);
    max_avg_num_attempts(j+1,jj)=max(avg_num_attempts(j,jj),max_avg_num_attempts(j,jj));
    max_fails(j+1,jj)=max(total_num_fails(j,jj),max_fails(j,jj));
    
    % if performing only one testset disply a progress update 
    if num_testset==1 && (mod(j,100)==0)
        disp(['I have executed ', int2str(j),' tests'])
    end
end %main test loop
if num_testset>1
    disp(['I have executed test set number:',int2str(jj)])
end
end %testset loop

disp(['-------------- FINISHED EXECUTION OF TESTS --------------'])

%% generate .csv for plotting
maxima_growth=[1,avg_num_attempts(1)];
for k=2:length(avg_num_attempts)
    if maxima_growth(end)<avg_num_attempts(k)
        maxima_growth=[maxima_growth;
                       k, avg_num_attempts(k)];
    end
end
%this final addition is only for estetics in the tikz plot ()
maxima_growth=[maxima_growth;
               k+2, maxima_growth(end)+3];
csvwrite('../fig/maxima_growth_plot.csv',maxima_growth);

%% analysis and plotting for only one test set
if num_testset==1
    
    disp(['ST : The worst case average number of attempts is:',num2str(max(avg_num_attempts))])
    disp(['MC : The sampled mean of the average number of attempts is:',num2str(mean(avg_num_attempts))])
    disp(['MC : The std of the sampled mean average number of attempts is:',num2str(sqrt(var(avg_num_attempts)/num_tests))])

    figure
    histogram(avg_num_attempts,40)
    title('distribution of average number of attempts')

    
    %EXTREME VALUE ANALYSIS
    ordered = sort(avg_num_attempts);                           % order results
    number_datapoints=floor(length(avg_num_attempts)*(90)/100); % number of maxima (arbitrary chosen to be the top 10%)
    maxima=ordered(number_datapoints:end);                      % pick maxima
    excedances=maxima-ordered(number_datapoints-1);             % compute excedances
    [paramhat,paramci] = gpfit(excedances);                     % gpd fitting

    figure
    histogram(excedances,20)
    xgrid = linspace(0,max(excedances),1000);
    line(xgrid,1*gppdf(xgrid,paramhat(1),paramhat(2),excedances(1)));
    title('EVD fitting based on highest 10% of the tests')
    grid
    %compute probability of the maximum observed actually being the maximum
    evt_max_prob=(1-cdf('Generalized Pareto',max(excedances),paramhat(1),paramhat(2),excedances(2))) ...
                *(length(excedances)/num_tests);
    disp(['EVT: probability of a future worst case ', ...
          'worse than what observed so far:',num2str(evt_max_prob)])

end

%% ploting for many testset
if num_testset>1
    figure
    title('growth over the tests of maximum total number of failed requests')
    hold on
    for jj=1:num_testset
        plot(max_fails(:,jj))
    end
end
if num_testset>1
    figure
    title('growth over the tests of maximum total number of failed requests')
    hold on
    for jj=1:num_testset
        plot(max_avg_num_attempts(:,jj))
    end
end