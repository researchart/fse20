% This is a demo for the Case Study presented in the MEMOCODE 2016
% conference paper:
% 
% Dokhanchi, et al. "An Efficient Algorithm for Monitoring Practical TPTL 
% Specifications", MEMOCODE 2016
%
% We present the Automatic Transmission Benchmark with TPTL specifications 
% in the Case Study (Section V.B) of MEMOCODE 2016 paper.
%
% (C) Adel Dokhanchi, 2017, Arizona State University

clear;
cd('..')
cd('SystemModelsAndData')

%% Display and user feedback
disp(' ')
disp('This is a demo for the Case Study presented in the MEMOCODE 2016 ')
disp('conference paper.')
disp(' ')
disp('Press any key to continue')

pause


nform  = 1;
phi_nat{nform} = ['Always if shift from gear one to gear two happens, then shift from gear two to gear three should happen and',char(10),...
      '          then shift from gear three to gear four should happen in future, and the duration between the first shift and',char(10),...
      '          the third shift should be equal or more than 8 seconds'];
phi{nform} = '[] @ Var_z ( ( gear1 /\ X gear2 ) -> [] ( ( gear2 /\ X gear3 )  -> [] ( ( gear3 /\ X gear4 ) -> { Var_z >= 8 }  ) ) )';

nform  = nform+1;
phi_nat{nform} = ['Always if shift from gear one to gear two happens, then shift from gear two to gear three should happen and',char(10),...
      '          then shift from gear three to gear four should happen in future, and the duration between the first shift and',char(10),...
      '          the third shift should be equal or less than 12 seconds'];
phi{nform} = '[] @ Var_z ( ( gear1 /\ X gear2 ) -> <> ( ( gear2 /\ X gear3 )  /\ <> ( ( gear3 /\ X gear4 ) /\ { Var_z <= 12 }  ) ) )';

disp('The set of specifications for the Automatic Transmission model:')
for j = 1:nform
    disp(['   ',num2str(j),'. NL: ',phi_nat{j}])
    disp(' ')
    disp(['      TPTL: ',phi{j}])
    disp(' ')
    disp(' ')
end
form_id_1 = input('Choose a specification to falsify:');
disp(' ')


opt = staliro_options();
opt.runs = 1;
opt.spec_space = 'Y';
opt.map2line = 0;
opt.n_workers = 1;
opt.optimization_solver = 'SA_Taliro';
opt.optim_params.n_tests = 2000;

init_cond = [];

    
    disp(' ')
    disp('Remark: These benchmarks utilize the hybrid_inf metric. ')
    disp('        In general, it is recommended to use the hybrid distance metric in')
    disp('        cases where the guards for the transitions between locations is known.')
    disp(' ')
    disp('Press any key to continue')
    
    pause
    
    input_range = [0 100;0 500];
    model = @BlackBoxAutotrans04;
    
    cp_array = [7,3];
    
    opt.loc_traj = 'end';
    opt.taliro_metric = 'hybrid_inf';
    opt.taliro = 'tp_taliro';
    opt.black_box = 1;
    opt.interpolationtype = {'pchip'};
    if form_id_1==1
        opt.seed = 1;
    else
        opt.seed = 0;
    end
    
    %predicate definitions
    ii = 1;
    preds(ii).str = 'gear1';
    preds(ii).A = [];
    preds(ii).b = [];
    preds(ii).loc = 1;
    
    ii = ii+1;
    preds(ii).str = 'gear2';
    preds(ii).A = [];
    preds(ii).b = [];
    preds(ii).loc = 2;
    
    ii = ii+1;
    preds(ii).str = 'gear3';
    preds(ii).A = [];
    preds(ii).b = [];
    preds(ii).loc = 3;
    
    ii = ii+1;
    preds(ii).str = 'gear4';
    preds(ii).A = [];
    preds(ii).b = [];
    preds(ii).loc = 4;
    
    
    disp(' ')
    disp('Total Simulation time:')
    time = 30 %#ok<*NOPTS>
    

[results,history] = staliro(model,init_cond,input_range,cp_array,phi{form_id_1},preds,time,opt);

disp(' ')
disp(' See results for for the output of the robustness values of each run')
disp(' See history for the information on all the tests for each run')

%% plot the inputs/outputs for which the system does not satisfy the spec.
warning off %#ok<*WNOFF>    
    [T1,XT1,YT1,IT1,LT1,CLG,GRD] = SimBlackBoxMdl(model,init_cond,input_range,cp_array,results.run(results.optRobIndex).bestSample,time,opt);
    figure
    
    subplot(5,1,1)
    plot(IT1(:,1),IT1(:,2))
    axis([0 30 0 100])
    title('Throttle')
    
    subplot(5,1,2)
    plot(IT1(:,1),IT1(:,3))
    title('Break')
    axis([0 30 0 500])
    
    subplot(5,1,3)
    plot(T1,YT1(:,2))
    hold on
    title('RPM')
    axis([0 30 0 6000])
    
    subplot(5,1,4)
    plot(T1,YT1(:,1))
    hold on

    title('Speed')
    axis([0 30 0 200])
    
    subplot(5,1,5)
    plot(T1,LT1)
    hold on
    title('Gear')
    axis([0 30 0 4])

cd('..')
cd('TPTL demos')