% S-Taliro script for the Heat Benchmark from the HSCC 04 paper by Fehnker & Ivancic

clear 

cd('..')
cd('SystemModelsAndData')

model = 'heat25830_staliro_02';
load heat30;
time = 24;
cp_array = [4 1];
input_range = [1 2; 0.8 1.2];
X0 = [17*ones(10,1) 18*ones(10,1)];
phi = '[]p';
pred.str = 'p';
pred.A = -eye(10);
pred.b = -[14.50; 14.50; 13.50; 14.00; 13.00; 14.00; 14.00; 13.00; 13.50; 14.00];

opt = staliro_options();
opt.runs = 1;
opt.optim_params.n_tests = 100;
opt.interpolationtype = {'pchip', 'const'};

results = staliro(model,X0,input_range,cp_array,phi,pred,time,opt);

figure(1)
clf
[T1,XT1,YT1,IT1] = SimSimulinkMdl(model,X0,input_range,cp_array,results.run(1).bestSample,time,opt);
subplot(2,1,1)
plot(T1,XT1)
title('State trajectories')
subplot(2,1,2)
plot(IT1(:,1),IT1(:,2))
title('Input Signal')

cd('..')
cd('Falsification demos')

