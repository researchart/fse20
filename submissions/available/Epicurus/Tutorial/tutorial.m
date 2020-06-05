% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

disp('##################################################');
disp(' Tutorial: Running EPIcuRus on the model demo.slx')
disp('##################################################');

setenv('PATH', '/Library/Frameworks/Python.framework/Versions/3.7/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/TeX/texbin:/opt/X11/bin')
close all;
clear;
% Generates the paths 
cd ..;
curPath=fileparts(which('epicurus.m')); 
addpath(genpath(curPath));

% Defines a variable that contains the name of the model
model='demo';
% Defines a variable that contains the name of the requirement of interest
property='R';
% Defines a variable that contains a cell array of the inputs names
input_names={'rollCmd_','yawCmd', 'beta_deg', 'vtas_kts'};
% If categorical inputs exist, specify the inputs indexes (i.e. [1 3])
categorical=[];
% Defines a variable that contains the ranges for each input
input_range=[0 50;0 50;0 10;0 10];
% The test case generation policy
policy='IFBT_UR';
% Considers the default initial conditions of the model
init_cond = [];
% Sets the simulation Time
sim_time=1;

% Defines of the requirement of interest.

phi='<>_[0,100](p1)';

preds(1).str='p1';
preds(1).A=[1 0];
preds(1).b=50;

cmd = load('-mat', 'demo.mat');
vars = fieldnames(cmd);
for i = 1:length(vars)
    assignin('base', vars{i}, cmd.(vars{i}));
end                                      

% Creates the options of EPIcuRus. Further details are described under
% epicurus_options.m
epicurus_opt=epicurus_options();
epicurus_opt.SampTime=0.01; 
epicurus_opt.assumeIterations= 2;
epicurus_opt.assumeRuns=1;
epicurus_opt.writeInternalAssumptions=1;
epicurus_opt.testSuiteSize=30;
epicurus_opt.iteration1Size=30;
epicurus_opt.nbrControlPoints=1;
epicurus_opt.policy=policy;
epicurus_opt.desiredFitness=0;
epicurus_opt.exploit=0; 
epicurus_opt.qvtraceenabled=false;

% Prepares the results folders
resultfilename=strcat(model,property,policy);
scriptname=[model,property];
modelFolder=['result',filesep,model];
if ~exist(modelFolder, 'dir')
    mkdir(modelFolder);
end
propertyFolder=strcat('result',filesep,model,filesep,property);
if ~exist(propertyFolder, 'dir')
    mkdir(propertyFolder);
end
policyFolder=strcat('result',filesep,model,filesep,property,filesep,policy);
if ~exist(policyFolder, 'dir')
    mkdir(policyFolder);
end

% Loading the model in QVtrace if enabled
% Make sure to write 'Matlab' into the turn.txt
% cd ..;
if  epicurus_opt.qvtraceenabled==1
    modelPath=fullfile(fileparts(which([model,'qv.mdl'])),[model,'qv.mdl']);
    matPath=fullfile(fileparts(which([model,'.mat'])),[model,'.mat']);
    copyfile(modelPath,'./model.mdl');
    copyfile(matPath,'./model.mat');
    turn='LoadModel';
    turnfile=fopen('turn.txt', 'w'); 
    fprintf(turnfile,turn); 
    fclose(turnfile);
    disp('Waiting that QVtrace loads the model');
    while(~strcmp(turn,'Matlab'))
        pause(1)
        turnfile=fopen('turn.txt', 'r'); 
        turn=fgetl(turnfile); 
        fclose(turnfile);
    end
    disp('Model loaded');
end
% Run epicurus
epicurus(model,property,init_cond, phi, preds, sim_time,input_names,categorical,input_range,epicurus_opt,scriptname,resultfilename,policyFolder)

disp('############################################################################');
disp(['EPIcuRus finishes running and results are saved under: ',policyFolder]);
disp('############################################################################');
