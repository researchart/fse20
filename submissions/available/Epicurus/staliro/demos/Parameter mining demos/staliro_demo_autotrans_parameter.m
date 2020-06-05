% This is a demo for using S-TALIRO with the Automatic Transimssion
% Simulink Demo for parameter estimation for results generated for the 
% ICTSS 2012 paper: 
% Hengyi Yang, Bardh Hoxha, and Georgios Fainekos. "Querying 
% parametric temporal logic properties on embedded systems." Testing 
% Software and Systems. Springer Berlin Heidelberg, 2012. 136-151.

clear

cd('..')
cd('SystemModelsAndData')

model = 'sldemo_autotrans_mod01';

init_cond = []
input_range = [0 100]
cp_array = 1

phi = '([]_[0,t1] !r2)' 

% -w<=-4500 => w>=4500
ii = 1;
preds(ii).str='r2';
preds(ii).A = [0 -1];
preds(ii).b = -4500;
preds(ii).loc = [1:7];

ii = ii+1;
preds(ii).par = 't1';
preds(ii).value = 30;
preds(ii).range = [0 30];

time = 30
opt = staliro_options()
opt.interpolationtype={'const'};
opt.runs = 1;
opt.optim_params.n_tests = 500;
opt.optimization_solver = 'SA_Taliro';
opt.taliro = 'dp_taliro';
opt.falsification = 0;
opt.parameterEstimation = 1;

tic
[results,history] = staliro(model,init_cond,input_range,cp_array,phi,preds,time,opt);
toc

figure
[T1,XT1,YT1,IT1] = SimSimulinkMdl(model,init_cond,input_range,cp_array,results.run(results.optParamValIndex).bestSample,time,opt);
subplot(3,1,1)
plot(IT1(:,1),IT1(:,2))
title('Throttle')
subplot(3,1,2)
plot(T1,YT1(:,2))
hold on 
plot([0 30],[4500 4500],'r');
title('RPM')
subplot(3,1,3)
plot(T1,YT1(:,1))
hold on 
plot([0 30],[120 120],'r');
title('Speed')


% Verify

disp(' ')
disp(' 1.Yes')
disp(' 2.No')
form_id_1 = input('Would you like to verify the results:');

if (form_id_1 == 1)
    preds(2).value = results.run(results.optParamValIndex).paramVal;
    samples = 1:100;
    samples = samples';
    robval = zeros(length(samples),1);
    for jj = 1:length(samples)
        [T1,XT1,YT1,IT1] = SimSimulinkMdl(model,init_cond,input_range,cp_array,samples(jj,:),time,opt);
        robval(jj) = dp_taliro(phi,preds,YT1,T1);
    end
    figure
    plot(samples,robval)
    hold on;
    plot([0 100], [0 0],'r')
    if any(robval<0)       
        title(['Fig. 1 Guaranteed falsification for specification: []\_[0,',num2str(preds(2).value),'] !r2'])
    else
        title(['Fig. 1 Not guaranteed falsification for specification: []\_[0,',num2str(preds(2).value),'] !r2'])    
    end
    xlabel('u')
    ylabel('Robustenss')
    grid on
    
    preds(2).value = results.run(results.optParamValIndex).paramVal-1;
    samples = 1:100;
    samples = samples';
    robval = zeros(length(samples),1);
    for jj = 1:length(samples)
        [T1,XT1,YT1,IT1] = SimSimulinkMdl(model,init_cond,input_range,cp_array,samples(jj,:),time,opt);
        robval(jj) = dp_taliro(phi,preds,YT1,T1);
    end
    figure
    plot(samples,robval)
    hold on;
    plot([0 100], [0 0],'r')
    if any(robval<0)       
        title(['Fig. 2 Guaranteed falsification for specification: []\_[0,',num2str(preds(2).value -1),'] !r2'])
    else
        title(['Fig. 2 Not guaranteed falsification for specification: []\_[0,',num2str(preds(2).value -1),'] !r2'])    
    end    
    xlabel('u')
    ylabel('Robustenss')
    grid on
    
    preds(2).value = results.run(results.optParamValIndex).paramVal+1;
    samples = 1:100;
    samples = samples';
    robval = zeros(length(samples),1);
    for jj = 1:length(samples)
        [T1,XT1,YT1,IT1] = SimSimulinkMdl(model,init_cond,input_range,cp_array,samples(jj,:),time,opt);
        robval(jj) = dp_taliro(phi,preds,YT1,T1);
    end
    figure
    plot(samples,robval)
    hold on;
    plot([0 100], [0 0],'r')
    if any(robval<0)       
        title(['Fig. 3 Guaranteed falsification for specification: []\_[0,',num2str(preds(2).value + 1),'] !r2'])
    else
        title(['Fig. 3 Not guaranteed falsification for specification: []\_[0,',num2str(preds(2).value + 1),'] !r2'])    
    end    
    xlabel('u')
    ylabel('Robustenss')
    grid on
end

cd('..')
cd('Parameter mining demos')
