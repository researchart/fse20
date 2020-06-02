% This is a demo to monitor longitudinal and lateral safety of CommonRoad
% trajectories without intersection.
%
% Authors:
% Mohammad Hekmatnejad  e-mail: mhekmatn@asu.edu
% Adel Dokhanchi        e-mail: adokhanc@asu.edu
% 
% Last Update:      
% June 2019
% 
% References:
%
% [1] S. Shalev-Shwartz, S. Shammah, and A. Shashua, “On a formal model
% of safe and scalable self-driving cars,” arXiv:1708.06374v6, 2018.
%
% [2] M. Althoff, M. Koschi, and S. Manzinger, “Commonroad: Composable
% benchmarks for motion planning on roads,” in 2017 IEEE Intelligent
% Vehicles Symposium (IV). IEEE, 2017, pp. 719–726.

clear all;
close all;
warning off;
distError=2e-15;


%based on RSS paper
global A_MAX_BRAKE;
global A_MAX_ACCEL;
global A_LAT_MAX_ACCEL;
global A_MIN_BRAKE;
global A_LAT_MIN_BRAKE;
global A_MIN_BRAKE_CORRECT;
global RHO;
global MU;
    
A_MAX_BRAKE=10;
A_MAX_ACCEL=5.5;
A_LAT_MAX_ACCEL=3;%For the MEMOCODE paper we used 0.5
A_MIN_BRAKE=4.0;
A_LAT_MIN_BRAKE=3;%For the MEMOCODE paper we used 0.5
A_MIN_BRAKE_CORRECT=4.0;
RHO=0.5;
MU=0.4;

global SHOW_PLOTS;
SHOW_PLOTS = false;%true if you want to see figures
global cutLineErrorAcceptance;
cutLineErrorAcceptance = 2;%the size of the sections to be check for cutting 
% through border lines
RUN_EXPERIMENTS = true;%true if all tests should be running
global RUN_TEST_MODE;
RUN_TEST_MODE = false;%true for test purposes
cut_from_end_of_trajectory = 0;%the distance from the end of lanes for which if 
% the trajectories end there, then we ignore them for the sake of simple figures
start_loop = 0;%starting test number 0
end_loop = 28;%maximum number of traffic scenarios 28

if true(~RUN_EXPERIMENTS)
    input_scenario_num = input('Enter the scenario number, a value between 0~28:');
    start_loop = input_scenario_num;
    end_loop = input_scenario_num;
end
%needed for experiment statistics
all_lon_violated_pred = cell(end_loop+1,1);
all_lat_violated_pred = cell(end_loop+1,1);
all_lat_long_violated_pred = cell(end_loop+1,1);
total_moni_time = 0;
total_prep_time = 0;
total_dp_taliro_call_neg_res = 0;
total_dp_taliro_call = 0;
car_statistics = [];
compute_Phi_not_lat_not_long_safety = true;
compute_Phi_lat_safety = true;
compute_Phi_long_safety = true;
compute_Phi_lat_long_safety = false;%not used 

for iteration_case_study=start_loop:end_loop
%%clear all;
clearvars -except start_loop end_loop iteration_case_study SHOW_PLOTS ...
    cutLineErrorAcceptance cut_from_end_of_trajectory RUN_TEST_MODE...
    total_moni_time total_prep_time total_dp_taliro_call_neg_res all_lon_violated_pred...
    all_lat_violated_pred all_lat_long_violated_pred total_dp_taliro_call car_statistics...
    compute_Phi_not_lat_not_long_safety compute_Phi_lat_long_safety...
    compute_Phi_lat_safety compute_Phi_long_safety ...
    A_MAX_BRAKE A_MAX_ACCEL A_LAT_MAX_ACCEL A_MIN_BRAKE...
    A_LAT_MIN_BRAKE A_MIN_BRAKE_CORRECT RHO MU

close all;
fprintf(['\n\n\n']);
iteration_case_study
inputFile = ['commonroad2017a/scenarios/NGSIM/US101/NGSIM_US101_',num2str(iteration_case_study),'.xml'];% 

tic %start preprocessing 

%===================================================================================
[samples, dt_prediction, egoFrontCar, egoLeftCar, egoRightCar,...
    obstacleLane, obstacleSamples, obstacleIDs, distancReflection] = ...
    prepareDataFromCommonRoad(inputFile, cut_from_end_of_trajectory);
%===================================================================================

prep_time = toc; %end of preprocessing
disp(['>>>Pre-processing time: ', num2str(prep_time)]);
total_prep_time = total_prep_time + prep_time;

tic %start of monitoring


%===================================================================================
% NOTE: in order to use the specification formulas with non-strict release
% operators (Rns rather than R) you must have the updated dp_taliro code (in the same
% folder as this script file).
% Another way to use the strict release operator is to replace all the
% release subformulas (a Rns_I b) with (a R_I (a \/ b)). The same formula in the second 
% format is represented as a commented section after the specification. 
%===================================================================================
% Longitudinal safety requirement for the ego vehicle with respect to the
% other vehicle (front,left,right)
lon_ant = '(  !safe_lat_ant /\ safe_long_ant /\ X (!safe_long_ant /\ !safe_lat_ant) )';
P_lon_conseq = ['( (( (safe_long_ant \/ safe_lat_ant) Rns_[0,',num2str(RHO),') (a_ego_lt_max_acc /\ a_front_max_brake)) ) /\ (( (safe_long_ant \/ safe_lat_ant) Rns_[', num2str(RHO),', inf)(a_ego_gt_min_brake /\ a_front_max_brake)) ) )'];
Phi_long_safety = ['[](',lon_ant,' -> X ( ',P_lon_conseq,' ))'];  

% Lateral safety requirement for the ego vehicle with respect to the
% other vehicle (front,left,right)
lat_ant = '( !safe_long_ant /\ safe_lat_ant /\ X (!safe_lat_ant /\ !safe_long_ant) )';
P_lat = ['( ( (safe_long_ant \/ safe_lat_ant) Rns_[0,',num2str(RHO),')(a_ego_lat_lt_max_acc /\ a_right_lat_max_acc)) )'];
P_lat11 = ['( (((safe_long_ant \/ safe_lat_ant) \/ stopped_ego_lat) Rns_[',num2str(RHO),', inf) a_ego_lat_lt_min_brake) )'];
P_lat12 = ['( (((safe_long_ant \/ safe_lat_ant) \/ stopped_right_lat) Rns_[',num2str(RHO),', inf) a_right_lat_min_brake ) )'];
P_lat21 = ['( ((safe_long_ant \/ safe_lat_ant) Rns_[',num2str(RHO),', inf) (stopped_ego_lat_ant -> X [](ego_lat_velocity_neg))  ) )'];
P_lat22 = ['( ((safe_long_ant \/ safe_lat_ant) Rns_[',num2str(RHO),', inf) (stopped_right_lat_ant -> X [] (right_lat_velocity_pos))  ) )'];
P_lat_conseq = [P_lat,' /\ ',P_lat11,' /\ ',P_lat12,' /\ ',P_lat21,' /\ ',P_lat22];
Phi_lat_safety = ['[](',lat_ant,' -> X ( ',P_lat_conseq,') )'];

% Longitudinal and Lateral safety requirement for the ego vehicle with respect to the
% other vehicle (front,left,right)
Phi_lon_lat_ant_org = '( safe_lat_ant /\ safe_long_ant /\ X (!safe_lat_ant /\ !safe_long_ant ) )';
Phi_lat_long_safety_org = ['[](' , Phi_lon_lat_ant_org , ' -> X ( ' , '(', P_lat_conseq ,')' , ' \/ ' , '(' , P_lon_conseq, ')' , ') )'];
%OR
%Phi_lat_long_safety_org = ['[](' , Phi_lon_lat_ant_org , ' -> X ( ' , '(', P_lat_conseq ,')' , ' /\ ' , '(' , P_lon_conseq, ')' , ') )'];

% Special case: when in the beginning the situation is unsafe
Phi_not_lat_not_long_safety = ['( ( !safe_lat_ant /\ !safe_long_ant ) -> X ( ' , '(', P_lat_conseq ,')' , ' \/ ' , '(' , P_lon_conseq, ')' ,') )'];
%OR
%Phi_not_lat_not_long_safety = ['( ( !safe_lat_ant /\ !safe_long_ant ) -> X ( ' , '(', P_lat_conseq ,')' , ' /\ ' , '(' , P_lon_conseq, ')' ,') )'];
Phi_lat_long_safety_updated = Phi_not_lat_not_long_safety;
%OR
%Phi_lat_long_safety_updated = [Phi_lat_long_safety_org,' /\ ',Phi_not_lat_not_long_safety];

%Phi_lat_long_safety = Phi_lat_long_safety_org;
%OR
Phi_lat_long_safety = Phi_lat_long_safety_updated;
%===================================================================================

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
% Alternative specification formula with strict release operator
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%
% 
% % Longitudinal safety requirement for the ego vehicle with respect to the
% % other vehicle (front,left,right)
% lon_ant = '(  !safe_lat_ant /\ safe_long_ant /\ X (!safe_long_ant /\ !safe_lat_ant) )';
% P_lon_conseq = ['( (( (safe_long_ant \/ safe_lat_ant) R_[0,',num2str(RHO),') ((a_ego_lt_max_acc /\ a_front_max_brake)\/(safe_long_ant \/ safe_lat_ant))) ) /\ (( (safe_long_ant \/ safe_lat_ant) R_[', num2str(RHO),', inf)((a_ego_gt_min_brake /\ a_front_max_brake)\/(safe_long_ant \/ safe_lat_ant))) ) )'];
% Phi_long_safety = ['[](',lon_ant,' -> X ( ',P_lon_conseq,' ))'];  
% 
% % Lateral safety requirement for the ego vehicle with respect to the
% % other vehicle (front,left,right)
% lat_ant = '( !safe_long_ant /\ safe_lat_ant /\ X (!safe_lat_ant /\ !safe_long_ant) )';
% P_lat = ['( ( (safe_long_ant \/ safe_lat_ant) R_[0,',num2str(RHO),')((a_ego_lat_lt_max_acc /\ a_right_lat_max_acc)\/(safe_long_ant \/ safe_lat_ant))) )'];
% P_lat11 = ['( (((safe_long_ant \/ safe_lat_ant) \/ stopped_ego_lat) R_[',num2str(RHO),', inf)(a_ego_lat_lt_min_brake \/(safe_long_ant \/ safe_lat_ant \/ stopped_ego_lat) )) )'];
% P_lat12 = ['( (((safe_long_ant \/ safe_lat_ant) \/ stopped_right_lat) R_[',num2str(RHO),', inf)(a_right_lat_min_brake \/(safe_long_ant \/ safe_lat_ant \/ stopped_right_lat) )) )'];
% P_lat21 = ['( ((safe_long_ant \/ safe_lat_ant) R_[',num2str(RHO),', inf) ((stopped_ego_lat_ant -> X [](ego_lat_velocity_neg))\/(safe_long_ant \/ safe_lat_ant))  ) )'];
% P_lat22 = ['( ((safe_long_ant \/ safe_lat_ant) R_[',num2str(RHO),', inf) ((stopped_right_lat_ant -> X [] (right_lat_velocity_pos))\/(safe_long_ant \/ safe_lat_ant))  ) )'];
% P_lat_conseq = [P_lat,' /\ ',P_lat11,' /\ ',P_lat12,' /\ ',P_lat21,' /\ ',P_lat22];
% Phi_lat_safety = ['[](',lat_ant,' -> X ( ',P_lat_conseq,') )'];
% 
% % Longitudinal and Lateral safety requirement for the ego vehicle with respect to the
% % other vehicle (front,left,right)
% Phi_lon_lat_ant_org = '( safe_lat_ant /\ safe_long_ant /\ X (!safe_lat_ant /\ !safe_long_ant ) )';
% Phi_lat_long_safety_org = ['[](' , Phi_lon_lat_ant_org , ' -> X ( ' , '(', P_lat_conseq ,')' , ' \/ ' , '(' , P_lon_conseq, ')' , ') )'];
% %OR
% %Phi_lat_long_safety_org = ['[](' , Phi_lon_lat_ant_org , ' -> X ( ' , '(', P_lat_conseq ,')' , ' /\ ' , '(' , P_lon_conseq, ')' , ') )'];
% 
% % Special case: when in the beginning the situation is unsafe
% Phi_not_lat_not_long_safety = ['( ( !safe_lat_ant /\ !safe_long_ant ) -> X ( ' , '(', P_lat_conseq ,')' , ' \/ ' , '(' , P_lon_conseq, ')' ,') )'];
% %OR
% %Phi_not_lat_not_long_safety = ['( ( !safe_lat_ant /\ !safe_long_ant ) -> X ( ' , '(', P_lat_conseq ,')' , ' /\ ' , '(' , P_lon_conseq, ')' ,') )'];
% Phi_lat_long_safety_updated = Phi_not_lat_not_long_safety;
% %OR
% %Phi_lat_long_safety_updated = [Phi_lat_long_safety_org,' /\ ',Phi_not_lat_not_long_safety];
% 
% %Phi_lat_long_safety = Phi_lat_long_safety_org;
% %OR
% Phi_lat_long_safety = Phi_lat_long_safety_updated;
%--------------------------------------------------------------------------%



%Monitoring begins here
%Data indexes of the simulation
LONG_SAFE_DIST = 1;
LONG_LAT_SAFE_DIST = 2;
LONG_REAR_A = 3;
LONG_FRONT_BRAKE = 4;
LONG_SAFE_DIST_BIG = 5;
LONG_LAT_SAFE_DIST_BIG = 6;

%----Longitudinal
ii = 1;
preds_long(ii).str = 'safe_long';
preds_long(ii).proj = LONG_SAFE_DIST;
preds_long(ii).A = -1;
preds_long(ii).b = 0.0;

ii = ii+1;%2
preds_long(ii).str = 'safe_lat';
preds_long(ii).proj = LONG_LAT_SAFE_DIST;
preds_long(ii).A = -1;
preds_long(ii).b = 0.0;

ii = ii+1;%3
preds_long(ii).str = 'a_ego_lt_max_acc';
preds_long(ii).proj = LONG_REAR_A;
preds_long(ii).A = 1;
preds_long(ii).b = A_MAX_ACCEL;

 ii = ii+1;%4
 preds_long(ii).str = 'a_ego_gt_min_brake';
 preds_long(ii).proj = LONG_REAR_A;
 preds_long(ii).A = 1;
 preds_long(ii).b = -A_MIN_BRAKE;

ii = ii+1;%5
preds_long(ii).str = 'a_front_max_brake';
preds_long(ii).proj = LONG_FRONT_BRAKE;
preds_long(ii).A = -1;
preds_long(ii).b = A_MAX_BRAKE;

ii = ii+1;%6
preds_long(ii).str = 'safe_long_ant';
preds_long(ii).proj = LONG_SAFE_DIST_BIG;
preds_long(ii).A = -1;
preds_long(ii).b = 0.0;

ii = ii+1;%7
preds_long(ii).str = 'safe_lat_ant';
preds_long(ii).proj = LONG_LAT_SAFE_DIST_BIG;
preds_long(ii).A = -1;
preds_long(ii).b = 0.0;

%------Lateral
%Data indexes of the simulation
LAT_LONG_SAFE_DIST = 1;
LAT_LAT_SAFE_DIST = 2;
LAT_ACCEL_L = 3;
LAT_ACCEL_R = 4;
MU_LAT_VELOCITY_L = 5;
MU_LAT_VELOCITY_R = 6;
LAT_LONG_SAFE_DIST_BIG = 7;
LAT_LAT_SAFE_DIST_BIG = 8;

ii = 1;
preds_lat(ii).str = 'safe_long';
preds_lat(ii).proj = LAT_LONG_SAFE_DIST;
preds_lat(ii).A = -1;
preds_lat(ii).b = 0.0;

ii = ii+1;%2
preds_lat(ii).str = 'safe_lat';
preds_lat(ii).proj = LAT_LAT_SAFE_DIST;
preds_lat(ii).A = -1;
preds_lat(ii).b = 0.0;

ii = ii+1;%3
preds_lat(ii).str = 'a_ego_lat_lt_max_acc';
preds_lat(ii).proj = LAT_ACCEL_L;
preds_lat(ii).A = [1;-1];
preds_lat(ii).b = [A_LAT_MAX_ACCEL;A_LAT_MAX_ACCEL];

ii = ii+1;%4
preds_lat(ii).str = 'a_ego_lat_lt_min_brake';
preds_lat(ii).proj = LAT_ACCEL_L;
preds_lat(ii).A = 1;
preds_lat(ii).b = -A_LAT_MIN_BRAKE;

ii = ii+1;%5
preds_lat(ii).str = 'a_right_lat_max_acc';
preds_lat(ii).proj = LAT_ACCEL_R;
preds_lat(ii).A = [1;-1];
preds_lat(ii).b = [A_LAT_MAX_ACCEL;A_LAT_MAX_ACCEL];

ii = ii+1;%6
preds_lat(ii).str = 'a_right_lat_min_brake';
preds_lat(ii).proj = LAT_ACCEL_R;
preds_lat(ii).A = -1;
preds_lat(ii).b = -A_LAT_MIN_BRAKE;

ii = ii+1;%7
preds_lat(ii).str = 'stopped_ego_lat';
preds_lat(ii).proj = MU_LAT_VELOCITY_L;
preds_lat(ii).A = [1;-1];
preds_lat(ii).b = [0.01;0.01];

ii = ii+1;%8
preds_lat(ii).str = 'stopped_right_lat';
preds_lat(ii).proj = MU_LAT_VELOCITY_R;
preds_lat(ii).A = [1;-1];
preds_lat(ii).b = [0.01;0.01];

ii = ii+1;%9
preds_lat(ii).str = 'ego_lat_velocity_neg';
preds_lat(ii).proj = MU_LAT_VELOCITY_L;
preds_lat(ii).A = 1;
preds_lat(ii).b = 0;

ii = ii+1;%10
preds_lat(ii).str = 'right_lat_velocity_pos';
preds_lat(ii).proj = MU_LAT_VELOCITY_R;
preds_lat(ii).A = -1;
preds_lat(ii).b = 0;

ii = ii+1;%11
preds_lat(ii).str = 'stopped_ego_lat_ant';
preds_lat(ii).proj = MU_LAT_VELOCITY_L;
preds_lat(ii).A = [1;-1];
preds_lat(ii).b = [0.01;0.01];

ii = ii+1;%12
preds_lat(ii).str = 'stopped_right_lat_ant';
preds_lat(ii).proj = MU_LAT_VELOCITY_R;
preds_lat(ii).A = [1;-1];
preds_lat(ii).b = [0.01;0.01];

ii = ii+1;%13
preds_lat(ii).str = 'safe_long_ant';
preds_lat(ii).proj = LAT_LONG_SAFE_DIST_BIG;
preds_lat(ii).A = -1;
preds_lat(ii).b = 0.0;

ii = ii+1;%14
preds_lat(ii).str = 'safe_lat_ant';
preds_lat(ii).proj = LAT_LAT_SAFE_DIST_BIG;
preds_lat(ii).A = -1;
preds_lat(ii).b = 0.0;

%------Lateral and Longitidinal
%Data indexes of the simulation
LAT_LONG_SAFE_DIST_ = 1;
LAT_LAT_SAFE_DIST_ = 2;
LAT_ACCEL_L_ = 3;
LAT_ACCEL_R_ = 4;
MU_LAT_VELOCITY_L_ = 5;
MU_LAT_VELOCITY_R_ = 6;
LAT_LONG_SAFE_DIST_BIG_ = 7;
LAT_LAT_SAFE_DIST_BIG_ = 8;
LONG_REAR_A_ = 9;
LONG_FRONT_BRAKE_ = 10;

ii = 1;
preds_lat_long(ii).str = 'safe_long';
preds_lat_long(ii).proj = LAT_LONG_SAFE_DIST_;
preds_lat_long(ii).A = -1;
preds_lat_long(ii).b = 0.0;

ii = ii+1;%2
preds_lat_long(ii).str = 'safe_lat';
preds_lat_long(ii).proj = LAT_LAT_SAFE_DIST_;
preds_lat_long(ii).A = -1;
preds_lat_long(ii).b = 0.0;

ii = ii+1;%3
preds_lat_long(ii).str = 'a_ego_lat_lt_max_acc';
preds_lat_long(ii).proj = LAT_ACCEL_L_;
preds_lat_long(ii).A = [1;-1];
preds_lat_long(ii).b = [A_LAT_MAX_ACCEL;A_LAT_MAX_ACCEL];

ii = ii+1;%4
preds_lat_long(ii).str = 'a_ego_lat_lt_min_brake';
preds_lat_long(ii).proj = LAT_ACCEL_L_;
preds_lat_long(ii).A = 1;
preds_lat_long(ii).b = -A_LAT_MIN_BRAKE;

ii = ii+1;%5
preds_lat_long(ii).str = 'a_right_lat_max_acc';
preds_lat_long(ii).proj = LAT_ACCEL_R_;
preds_lat_long(ii).A = [1;-1];
preds_lat_long(ii).b = [A_LAT_MAX_ACCEL;A_LAT_MAX_ACCEL];

ii = ii+1;%6
preds_lat_long(ii).str = 'a_right_lat_min_brake';
preds_lat_long(ii).proj = LAT_ACCEL_R_;
preds_lat_long(ii).A = -1;
preds_lat_long(ii).b = -A_LAT_MIN_BRAKE;

ii = ii+1;%7
preds_lat_long(ii).str = 'stopped_ego_lat';
preds_lat_long(ii).proj = MU_LAT_VELOCITY_L_;
preds_lat_long(ii).A = [1;-1];
preds_lat_long(ii).b = [0.01;0.01];

ii = ii+1;%8
preds_lat_long(ii).str = 'stopped_right_lat';
preds_lat_long(ii).proj = MU_LAT_VELOCITY_R_;
preds_lat_long(ii).A = [1;-1];
preds_lat_long(ii).b = [0.01;0.01];

ii = ii+1;%9
preds_lat_long(ii).str = 'ego_lat_velocity_neg';
preds_lat_long(ii).proj = MU_LAT_VELOCITY_L_;
preds_lat_long(ii).A = 1;
preds_lat_long(ii).b = 0;

ii = ii+1;%10
preds_lat_long(ii).str = 'right_lat_velocity_pos';
preds_lat_long(ii).proj = MU_LAT_VELOCITY_R_;
preds_lat_long(ii).A = -1;
preds_lat_long(ii).b = 0;

ii = ii+1;%11
preds_lat_long(ii).str = 'a_ego_lt_max_acc';
preds_lat_long(ii).proj = LONG_REAR_A_;
preds_lat_long(ii).A = 1;
preds_lat_long(ii).b = A_MAX_ACCEL;

ii = ii+1;%12
preds_lat_long(ii).str = 'a_ego_gt_min_brake';
preds_lat_long(ii).proj = LONG_REAR_A_;
preds_lat_long(ii).A = 1;
preds_lat_long(ii).b = -A_MIN_BRAKE;

ii = ii+1;%13
preds_lat_long(ii).str = 'a_front_max_brake';
preds_lat_long(ii).proj = LONG_FRONT_BRAKE_;
preds_lat_long(ii).A = -1;
preds_lat_long(ii).b = A_MAX_BRAKE;

ii = ii+1;%14
preds_lat_long(ii).str = 'stopped_ego_lat_ant';
preds_lat_long(ii).proj = MU_LAT_VELOCITY_L_;
preds_lat_long(ii).A = [1;-1];
preds_lat_long(ii).b = [0.01;0.01];

ii = ii+1;%15
preds_lat_long(ii).str = 'stopped_right_lat_ant';
preds_lat_long(ii).proj = MU_LAT_VELOCITY_R_;
preds_lat_long(ii).A = [1;-1];
preds_lat_long(ii).b = [0.01;0.01];

ii = ii+1;%16
preds_lat_long(ii).str = 'safe_long_ant';
preds_lat_long(ii).proj = LAT_LONG_SAFE_DIST_BIG_;
preds_lat_long(ii).A = -1;
preds_lat_long(ii).b = 0.0;

ii = ii+1;%17
preds_lat_long(ii).str = 'safe_lat_ant';
preds_lat_long(ii).proj = LAT_LAT_SAFE_DIST_BIG_;
preds_lat_long(ii).A = -1;
preds_lat_long(ii).b = 0.0;

% Containing the Robustness of the longitudinal safety of ego vehicle (egoID) with
% respect to the front car (frontID)
longSafety=[];

% Containing the Robustness of the lateral safety of ego vehicle (egoID) with 
% respect to the front car (frontID)
latSafety=[];

% Containing the Robustness of the longitudinal safety of ego vehicle (egoID)
%  with respect to the left car (leftID)
longSafetyLeft=[];

% Containing the Robustness of the longitudinal safety of ego vehicle (egoID)
% with respect to the right car (rightID)
longSafetyRight=[];

% Containing the Robustness of the lateral safety of ego vehicle (egoID) 
% with respect to the left car (leftID)
latSafetyLeft=[];

% Containing the Robustness of the lateral safety of ego vehicle (egoID) 
% with respect to the right car (rightID)
latSafetyRight=[];

%added for preds_lat_long and formula Phi_not_lon_not_lat_safety
lat_longSafety=[];
lat_longSafetyLeft=[];
lat_longSafetyRight=[];

unsafe_begin_time = 0;
%szf=size(egoFrontCar);
tic
%totalTimeSteps = samples;

%**************************************************************************
%>>>> longSafety & latSafety
[longSafety, latSafety, lat_longSafety] = ...
    computeRSSrobustnessForTrajectories(samples, dt_prediction, egoFrontCar,...
    obstacleLane, obstacleSamples, distancReflection,...
    Phi_long_safety, Phi_lat_safety, Phi_lat_long_safety,...
    preds_long, preds_lat, preds_lat_long, compute_Phi_long_safety,...
    compute_Phi_lat_safety, compute_Phi_not_lat_not_long_safety, 0);
%**************************************************************************

%**************************************************************************
%>>>> longSafetyLeft & latSafetyLeft
[longSafetyLeft, latSafetyLeft, lat_longSafetyLeft] = ...
    computeRSSrobustnessForTrajectories(samples, dt_prediction, egoLeftCar,...
    obstacleLane, obstacleSamples, distancReflection,...
    Phi_long_safety, Phi_lat_safety, Phi_lat_long_safety,...
    preds_long, preds_lat, preds_lat_long, compute_Phi_long_safety,...
    compute_Phi_lat_safety, compute_Phi_not_lat_not_long_safety, -1);
%**************************************************************************

%**************************************************************************
%>>>> longSafetyRight & latSafetyRight
[longSafetyRight, latSafetyRight, lat_longSafetyRight] = ...
    computeRSSrobustnessForTrajectories(samples, dt_prediction, egoRightCar,...
    obstacleLane, obstacleSamples, distancReflection,...
    Phi_long_safety, Phi_lat_safety, Phi_lat_long_safety,...
    preds_long, preds_lat, preds_lat_long, compute_Phi_long_safety,...
    compute_Phi_lat_safety, compute_Phi_not_lat_not_long_safety, +1);
%**************************************************************************

disp('Monitoring time: ');
moni_time = toc; %end of preprocessing
disp(['>>>Monitoring time: ', num2str(moni_time)]);
total_moni_time = total_moni_time + moni_time;

min_Lon_Rob = NaN(1);
if ~isempty(longSafety)
    min_Lon_Rob = longSafety(1).robustness;
    car1 = longSafety(1).egoID;
    car2 = longSafety(1).frontID;
end
min_index = 0;
min_indexFront = 0;
min_indexLeft = 0;
min_indexRight = 0;
min_safety_struct = 'none';
total_lon_unsafe_left = 0;
total_lon_unsafe_right = 0;
total_lon_unsafe_front = 0;
lon_violated_pred = zeros(length(preds_long),1);
lat_violated_pred = zeros(length(preds_lat),1);
lat_long_violated_pred = zeros(length(preds_lat_long),1);

for i=1:length(longSafety)
    if(min_Lon_Rob > longSafety(i).robustness)
        car1 = longSafety(i).egoID;
        car2 = longSafety(i).frontID;
        min_index = i;
        min_safety_struct = 'long-front';
    end
    min_Lon_Rob=min(min_Lon_Rob,longSafety(i).robustness);
    if(longSafety(i).robustness < 0)
        total_lon_unsafe_front = total_lon_unsafe_front + 1;
        lon_violated_pred(longSafety(i).aux.pred) = lon_violated_pred(longSafety(i).aux.pred)+1;
    end
end
min_indexFront = min_index;
for i=1:length(longSafetyLeft)
    if(min_Lon_Rob > longSafetyLeft(i).robustness)
        car1 = longSafetyLeft(i).egoID;
        car2 = longSafetyLeft(i).frontID;
        min_index = i;
        min_safety_struct = 'long-left';
    end
    min_Lon_Rob=min(min_Lon_Rob,longSafetyLeft(i).robustness);
    if(longSafetyLeft(i).robustness < 0)
        total_lon_unsafe_left = total_lon_unsafe_left + 1;
        lon_violated_pred(longSafetyLeft(i).aux.pred) = lon_violated_pred(longSafetyLeft(i).aux.pred)+1;
    end
end
min_indexLeft = min_index;
for i=1:length(longSafetyRight)
    if(min_Lon_Rob > longSafetyRight(i).robustness)
        car1 = longSafetyRight(i).egoID;
        car2 = longSafetyRight(i).frontID;
        min_index = i;
        min_safety_struct = 'long-right';
    end
    min_Lon_Rob=min(min_Lon_Rob,longSafetyRight(i).robustness);
    if(longSafetyRight(i).robustness < 0)
        total_lon_unsafe_right = total_lon_unsafe_right + 1;
        lon_violated_pred(longSafetyRight(i).aux.pred) = lon_violated_pred(longSafetyRight(i).aux.pred)+1;
    end
end
min_indexRight = min_index;

lon_safety_statistics=['min_lon_rob = ',num2str(min_Lon_Rob) ...
    ,' front_unsafe/total_front = ',num2str(total_lon_unsafe_front),'/',num2str(length(longSafety))...
    ,' right_unsafe/total_right = ',num2str(total_lon_unsafe_right),'/',num2str(length(longSafetyRight))...
    ,' left_unsafe/total_left = ',num2str(total_lon_unsafe_left),'/',num2str(length(longSafetyLeft))];
disp(lon_safety_statistics);

    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%
    if true(SHOW_PLOTS)

if globalPck.PlotProperties.SHOW_INITAL_CONFIGURATION
    figure('Name','Least Longitudinal Safe Monuver')
    idSet = [obstacleIDs(car1);obstacleIDs(car2)];
    perception.plot(idSet);
end
    end

min_Lat_Rob = NaN(1);
if ~isempty(latSafety)
    min_Lat_Rob = latSafety(1).robustness;
    car1 = latSafety(1).egoID;
    car2 = latSafety(1).frontID;
end
min_index_lat = 0;
min_safety_struct_lat = 'none';
total_lat_unsafe_left = 0;
total_lat_unsafe_right = 0;
total_lat_unsafe_front = 0;

for i=1:length(latSafety)
    if(min_Lat_Rob > latSafety(i).robustness)
        car1 = latSafety(i).egoID;
        car2 = latSafety(i).frontID;
        min_index_lat = i;
        min_safety_struct_lat = 'lat-front';
    end
    min_Lat_Rob=min(min_Lat_Rob,latSafety(i).robustness);
    if(latSafety(i).robustness < 0)
        total_lat_unsafe_front = total_lat_unsafe_front + 1;
        lat_violated_pred(latSafety(i).aux.pred) = lat_violated_pred(latSafety(i).aux.pred)+1;
    end
end
for i=1:length(latSafetyLeft)
    if(min_Lat_Rob > latSafetyLeft(i).robustness)
        car1 = latSafetyLeft(i).egoID;
        car2 = latSafetyLeft(i).frontID;
        min_index_lat = i;
        min_safety_struct_lat = 'lat-left';
    end
    min_Lat_Rob=min(min_Lat_Rob,latSafetyLeft(i).robustness);
    if(latSafetyLeft(i).robustness < 0)
        total_lat_unsafe_left = total_lat_unsafe_left + 1;
        lat_violated_pred(latSafetyLeft(i).aux.pred) = lat_violated_pred(latSafetyLeft(i).aux.pred)+1;
    end
end
for i=1:length(latSafetyRight)
    if(min_Lat_Rob > latSafetyRight(i).robustness)
        car1 = latSafetyRight(i).egoID;
        car2 = latSafetyRight(i).frontID;
        min_index_lat = i;
        min_safety_struct_lat = 'lat-right';
    end
    min_Lat_Rob=min(min_Lat_Rob,latSafetyRight(i).robustness);
    if(latSafetyRight(i).robustness < 0)
        total_lat_unsafe_right = total_lat_unsafe_right + 1;
        lat_violated_pred(latSafetyRight(i).aux.pred) = lat_violated_pred(latSafetyRight(i).aux.pred)+1;
    end
end

lat_safety_statistics=['min_lat_rob = ',num2str(min_Lat_Rob) ...
    ,' front_unsafe/total_front = ',num2str(total_lat_unsafe_front),'/',num2str(length(latSafety))...
    ,' right_unsafe/total_right = ',num2str(total_lat_unsafe_right),'/',num2str(length(latSafetyRight))...
    ,' left_unsafe/total_left = ',num2str(total_lat_unsafe_left),'/',num2str(length(latSafetyLeft))];
disp(lat_safety_statistics);

    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%
    if true(SHOW_PLOTS)

if globalPck.PlotProperties.SHOW_INITAL_CONFIGURATION
    figure('Name','Least Lateral Safe Monuver')
    idSet = [obstacleIDs(car1);obstacleIDs(car2)];
    perception.plot(idSet);
end
    end
    

min_Lat_Long_Rob = NaN(1);
if ~isempty(lat_longSafety)
    min_Lat_Long_Rob = lat_longSafety(1).robustness;
    car1 = lat_longSafety(1).egoID;
    car2 = lat_longSafety(1).frontID;
end
min_index_lat_long = 0;
min_safety_struct_lat_long = 'none';
total_lat_long_unsafe_left = 0;
total_lat_long_unsafe_right = 0;
total_lat_long_unsafe_front = 0;

for i=1:length(lat_longSafety)
    if(min_Lat_Long_Rob > lat_longSafety(i).robustness)
        car1 = lat_longSafety(i).egoID;
        car2 = lat_longSafety(i).frontID;
        min_index_lat_long = i;
        min_safety_struct_lat_long = 'lat-long-front';
    end
    min_Lat_Long_Rob=min(min_Lat_Long_Rob,lat_longSafety(i).robustness);
    if(lat_longSafety(i).robustness < 0)
        total_lat_long_unsafe_front = total_lat_long_unsafe_front + 1;
        lat_long_violated_pred(lat_longSafety(i).aux.pred) = lat_long_violated_pred(lat_longSafety(i).aux.pred)+1;
    end
end
for i=1:length(lat_longSafetyLeft)
    if(min_Lat_Long_Rob > lat_longSafetyLeft(i).robustness)
        car1 = lat_longSafetyLeft(i).egoID;
        car2 = lat_longSafetyLeft(i).frontID;
        min_index_lat_long = i;
        min_safety_struct_lat_long = 'lat-long-left';
    end
    min_Lat_Long_Rob=min(min_Lat_Long_Rob,lat_longSafetyLeft(i).robustness);
    if(lat_longSafetyLeft(i).robustness < 0)
        total_lat_long_unsafe_left = total_lat_long_unsafe_left + 1;
        lat_long_violated_pred(lat_longSafetyLeft(i).aux.pred) = lat_long_violated_pred(lat_longSafetyLeft(i).aux.pred)+1;
    end
end
for i=1:length(lat_longSafetyRight)
    if(min_Lat_Long_Rob > lat_longSafetyRight(i).robustness)
        car1 = lat_longSafetyRight(i).egoID;
        car2 = lat_longSafetyRight(i).frontID;
        min_index_lat_long = i;
        min_safety_struct_lat_long = 'lat-long-right';
    end
    min_Lat_Long_Rob=min(min_Lat_Long_Rob,lat_longSafetyRight(i).robustness);
    if(lat_longSafetyRight(i).robustness < 0)
        total_lat_long_unsafe_right = total_lat_long_unsafe_right + 1;
        lat_long_violated_pred(lat_longSafetyRight(i).aux.pred) = lat_long_violated_pred(lat_longSafetyRight(i).aux.pred)+1;
    end
end

lat_long_safety_statistics=['min_lat_long_rob = ',num2str(min_Lat_Long_Rob) ...
    ,' front_unsafe/total_front = ',num2str(total_lat_long_unsafe_front),'/',num2str(length(lat_longSafety))...
    ,' right_unsafe/total_right = ',num2str(total_lat_long_unsafe_right),'/',num2str(length(lat_longSafetyRight))...
    ,' left_unsafe/total_left = ',num2str(total_lat_long_unsafe_left),'/',num2str(length(lat_longSafetyLeft))];
disp(lat_long_safety_statistics);

    %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%
    if true(SHOW_PLOTS)

if globalPck.PlotProperties.SHOW_INITAL_CONFIGURATION
    figure('Name','Least Lateral and Longitudinal Safe Monuver')
    idSet = [obstacleIDs(car1);obstacleIDs(car2)];
    perception.plot(idSet);
end
    end
    
disp(['total samples: ',num2str(length(longSafety)+length(longSafetyLeft)+length(longSafetyRight))]);
    
disp('lon_violated_pred = ');
disp(lon_violated_pred');
disp('lat_violated_pred = ');
disp(lat_violated_pred');
disp('lat_long_violated_pred = ');
disp(lat_long_violated_pred');


disp('-----------------LONGITUDINAL---------------')
for i=1:length(lon_violated_pred)
    predicate_violation_statistics = [preds_long(i).str,' violated ',num2str(lon_violated_pred(i)),' times'];
    disp(predicate_violation_statistics);
end
disp('-----------------LATERAL---------------');
for i=1:length(lat_violated_pred)
    predicate_violation_statistics = [preds_lat(i).str,' violated ',num2str(lat_violated_pred(i)),' times'];
    disp(predicate_violation_statistics);
end
disp('-----------------LONGITUDINAL & LATERAL---------------')
for i=1:length(lat_long_violated_pred)
    predicate_violation_statistics = [preds_lat_long(i).str,' violated ',num2str(lat_long_violated_pred(i)),' times'];
    disp(predicate_violation_statistics);
end

all_lon_violated_pred{iteration_case_study+1} = lon_violated_pred;
all_lat_violated_pred{iteration_case_study+1} = lat_violated_pred;
all_lat_long_violated_pred{iteration_case_study+1} = lat_long_violated_pred;
total_calls = length(longSafety)+...
    length(latSafety) + length(longSafetyLeft) + length(latSafetyLeft) +...
    length(latSafetyRight) + length(longSafetyRight) + length(lat_longSafety) +...
    length(lat_longSafetyLeft) + length(lat_longSafetyRight);
total_dp_taliro_call = total_dp_taliro_call + total_calls;
sum_viol  = sum(lon_violated_pred) + sum(lat_violated_pred) + sum(lat_long_violated_pred);
car_statistics = [car_statistics, struct('scn',iteration_case_study,...
    'total_cars',length(obstacleIDs),'total_violation', sum_viol, ...
    'prep_time', prep_time, 'moni_time', moni_time, 'total_calls',total_calls,...
    'longSafety',longSafety,...
    'latSafety',latSafety,...
    'longSafetyLeft',longSafetyLeft,...
    'latSafetyLeft',latSafetyLeft,...
    'longSafetyRight',longSafetyRight,...
    'latSafetyRight',latSafetyRight,...
    'lat_longSafety',lat_longSafety,...
    'lat_longSafetyLeft',lat_longSafetyLeft,...
    'lat_longSafetyRight',lat_longSafetyRight)];
end



disp('=======================================================');
disp('END OF EXPERIMENT EXECUTION');
disp('=======================================================');
all_preds_long = zeros(length(preds_long),1);
all_preds_lat = zeros(length(preds_lat),1);
all_preds_lat_long = zeros(length(preds_lat_long),1);
for c=1:length(all_lon_violated_pred)
    for i=1:length(all_lon_violated_pred{c})
        all_preds_long(i) = all_preds_long(i) + all_lon_violated_pred{c}(i);
        total_dp_taliro_call_neg_res = total_dp_taliro_call_neg_res + all_lon_violated_pred{c}(i);
    end
end
for c=1:length(all_lat_violated_pred)
    for i=1:length(all_lat_violated_pred{c})
        all_preds_lat(i) = all_preds_lat(i) + all_lat_violated_pred{c}(i);
        total_dp_taliro_call_neg_res = total_dp_taliro_call_neg_res + all_lat_violated_pred{c}(i);
    end
end
for c=1:length(all_lat_long_violated_pred)
    for i=1:length(all_lat_long_violated_pred{c})
        all_preds_lat_long(i) = all_preds_lat_long(i) + all_lat_long_violated_pred{c}(i);
        total_dp_taliro_call_neg_res = total_dp_taliro_call_neg_res + all_lat_long_violated_pred{c}(i);
    end
end


disp('-----------------TOTAL LONGITUDINAL---------------')
for i=1:length(lon_violated_pred)
    predicate_violation_statistics = [preds_long(i).str,' violated ',num2str(all_preds_long(i)),' times'];
    disp(predicate_violation_statistics);
end
disp('-----------------TOTAL LATERAL---------------');
for i=1:length(lat_violated_pred)
    predicate_violation_statistics = [preds_lat(i).str,' violated ',num2str(all_preds_lat(i)),' times'];
    disp(predicate_violation_statistics);
end
disp('-----------------TOTAL LONGITUDINAL & LATERAL---------------')
for i=1:length(lat_long_violated_pred)
    predicate_violation_statistics = [preds_lat_long(i).str,' violated ',num2str(all_preds_lat_long(i)),' times'];
    disp(predicate_violation_statistics);
end
total_moni_time
total_prep_time
total_dp_taliro_call_neg_res
total_dp_taliro_call

