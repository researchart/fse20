% This m-file is benchmarking the S-Taliro on-line monitor.
%
% It will collect statistics for 30 different formulas by running 2 tests 
% for each formula (nTest=2). 
% 
% It does not return the robustness values computed.
%
% Interface:
% [stats,runtime] = benchmarking_autotrans_monitoring
%
% stats - 30x5 array where each column contains
%   1 : formula number
%   2 : min runtime
%   3 : max runtime
%   4 : mean runtime
%   5 : variance of runtime
%
% runtime - the runtime for each formula

function  [stats,runtime] = benchmarking_autotrans_monitoring()
clear all;
% Specify the number of runs/tests to create the statstics of runtime
% execution.
nTest = 2;

%--------- FORMULAS -----------
%--- Eventually Formulas (E) --
iform = 1;
formula{iform} = 'p1 -> <>_[0,1000] p2';
iform = iform+1;
formula{iform} = 'p1 -> <>_[0,2000] p2';
iform = iform+1;
formula{iform} = 'p1 -> <>_[0,10000] p2';
iform = iform+1;
formula{iform}= 'p1 -> <>_[0,333] ( p2 /\ <>_[0,333] ( p1 /\ <>_[0,334] p2 ) )';
iform = iform+1;
formula{iform} = 'p1 -> <>_[0,666] ( p2 /\ <>_[0,667] ( p1 /\ <>_[0,667] p2 ) )';
iform = iform+1;
formula{iform} = 'p1 -> <>_[0,3333] ( p2 /\ <>_[0,3333] ( p1 /\ <>_[0,3334] p2 ) )';
iform = iform+1;
formula{iform} = 'p1 -> <>_[0,200] ( p2 /\ <>_[0,200] ( p1 /\ <>_[0,200] ( p2 /\ <>_[0,200] ( p1 /\ <>_[0,200] p2 ) ) ) )';
iform = iform+1;
formula{iform} = 'p1 -> <>_[0,400] ( p2 /\ <>_[0,400] ( p1 /\ <>_[0,400] ( p2 /\ <>_[0,400] ( p1 /\ <>_[0,400] p2 ) ) ) )';
iform = iform+1;
formula{iform} = 'p1 -> <>_[0,2000] ( p2 /\ <>_[0,2000] ( p1 /\ <>_[0,2000] ( p2 /\ <>_[0,2000] ( p1 /\ <>_[0,2000] p2 ) ) ) )';
iform = iform+1;
formula{iform}  = 'p1 -> <>_[0,142] ( p2 /\ <>_[0,143] ( p1 /\ <>_[0,143] ( p2 /\ <>_[0,143] ( p1 /\ <>_[0,143] ( p2 /\ <>_[0,143] ( p1 /\ <>_[0,143] p2 ) ) ) ) ) )';
iform = iform+1;
formula{iform}  = 'p1 -> <>_[0,285] ( p2 /\ <>_[0,285] ( p1 /\ <>_[0,286] ( p2 /\ <>_[0,286] ( p1 /\ <>_[0,286] ( p2 /\ <>_[0,286] ( p1 /\ <>_[0,286] p2 ) ) ) ) ) )';
iform = iform+1;
formula{iform}  = 'p1 -> <>_[0,1428] ( p2 /\ <>_[0,1428] ( p1 /\ <>_[0,1428] ( p2 /\ <>_[0,1429] ( p1 /\ <>_[0,1429] ( p2 /\ <>_[0,1429] ( p1 /\ <>_[0,1429] p2 ) ) ) ) ) )';
iform = iform+1;
formula{iform}  = 'p1 -> <>_[0,111] ( p2 /\ <>_[0,111] ( p1 /\ <>_[0,111] ( p2 /\ <>_[0,111] ( p1 /\ <>_[0,111] ( p2 /\ <>_[0,111] ( p1 /\ <>_[0,111] ( p2 /\ <>_[0,111] ( p1 /\ <>_[0,112] p2 ) ) ) ) ) ) ) )';
iform = iform+1;
formula{iform}  = 'p1 -> <>_[0,222] ( p2 /\ <>_[0,222] ( p1 /\ <>_[0,222] ( p2 /\ <>_[0,222] ( p1 /\ <>_[0,222] ( p2 /\ <>_[0,222] ( p1 /\ <>_[0,222] ( p2 /\ <>_[0,223] ( p1 /\ <>_[0,223] p2 ) ) ) ) ) ) ) )';
iform = iform+1;
formula{iform}  = 'p1 -> <>_[0,1111] ( p2 /\ <>_[0,1111] ( p1 /\ <>_[0,1111] ( p2 /\ <>_[0,1111] ( p1 /\ <>_[0,1111] ( p2 /\ <>_[0,1111] ( p1 /\ <>_[0,1111] ( p2 /\ <>_[0,1111] ( p1 /\ <>_[0,1112] p2 ) ) ) ) ) ) ) )';
%--- Until Formulas (U) --
iform = iform+1;
formula{iform}  = 'p2 -> (p3 U_[0,1000] p1)';
iform = iform+1;
formula{iform}  = 'p2 -> (p3 U_[0,2000] p1)';
iform = iform+1;
formula{iform}  = 'p2 -> (p3 U_[0,10000] p1)';
iform = iform+1;
formula{iform}  = 'p2 -> ( p3 U_[0,333] ( p1 /\ p4 U_[0,333] ( p2 /\ p3 U_[0,334] p1 ) ) )';
iform = iform+1;
formula{iform}  = 'p2 -> ( p3 U_[0,666] ( p1 /\ p4 U_[0,667] ( p2 /\ p3 U_[0,667] p1 ) ) )';
iform = iform+1;
formula{iform}  = 'p2 -> ( p3 U_[0,3333] ( p1 /\ p4 U_[0,3333] ( p2 /\ p3 U_[0,3334] p1 ) ) )';
iform = iform+1;
formula{iform}  = 'p2 -> ( p3 U_[0,200] ( p1 /\ p4 U_[0,200] ( p2 /\ p3 U_[0,200] ( p1 /\ p4 U_[0,200] ( p2 /\ p3 U_[0,200] p1 ) ) ) ) )';
iform = iform+1;
formula{iform}  = 'p2 -> ( p3 U_[0,400] ( p1 /\ p4 U_[0,400] ( p2 /\ p3 U_[0,400] ( p1 /\ p4 U_[0,400] ( p2 /\ p3 U_[0,400] p1 ) ) ) ) )';
iform = iform+1;
formula{iform}  = 'p2 -> ( p3 U_[0,2000] ( p1 /\ p4 U_[0,2000] ( p2 /\ p3 U_[0,2000] ( p1 /\ p4 U_[0,2000] ( p2 /\ p3 U_[0,2000] p1 ) ) ) ) )';
iform = iform+1;
formula{iform}  = 'p2 -> ( p3 U_[0,142] ( p1 /\ p4 U_[0,143] ( p2 /\ p3 U_[0,143] ( p1 /\ p4 U_[0,143] ( p2 /\ p3 U_[0,143] ( p1 /\ p4 U_[0,143] ( p2 /\ p3 U_[0,143] p1 ) ) ) ) ) ) )';
iform = iform+1;
formula{iform}  = 'p2 -> ( p3 U_[0,285] ( p1 /\ p4 U_[0,285] ( p2 /\ p3 U_[0,286] ( p1 /\ p4 U_[0,286] ( p2 /\ p3 U_[0,286] ( p1 /\ p4 U_[0,286] ( p2 /\ p3 U_[0,286] p1 ) ) ) ) ) ) )';
iform = iform+1;
formula{iform}  = 'p2 -> ( p3 U_[0,1428] ( p1 /\ p4 U_[0,1428] ( p2 /\ p3 U_[0,1428] ( p1 /\ p4 U_[0,1429] ( p2 /\ p3 U_[0,1429] ( p1 /\ p4 U_[0,1429] ( p2 /\ p3 U_[0,1429] p1 ) ) ) ) ) ) )';
iform = iform+1;
formula{iform}  = 'p2 -> ( p3 U_[0,111] ( p1 /\ p4 U_[0,111] ( p2 /\ p3 U_[0,111] ( p1 /\ p4 U_[0,111] ( p2 /\ p3 U_[0,111] ( p1 /\ p4 U_[0,111] ( p2 /\ p3 U_[0,111] ( p1 /\ p4 U_[0,111] ( p2 /\ p3 U_[0,112] p1 ) ) ) ) ) ) ) ) )';
iform = iform+1;
formula{iform}  = 'p2 -> ( p3 U_[0,222] ( p1 /\ p4 U_[0,222] ( p2 /\ p3 U_[0,222] ( p1 /\ p4 U_[0,222] ( p2 /\ p3 U_[0,222] ( p1 /\ p4 U_[0,222] ( p2 /\ p3 U_[0,222] ( p1 /\ p4 U_[0,223] ( p2 /\ p3 U_[0,223] p1 ) ) ) ) ) ) ) ) )';
iform = iform+1;
formula{iform}  = 'p2 -> ( p3 U_[0,1111] ( p1 /\ p4 U_[0,1111] ( p2 /\ p3 U_[0,1111] ( p1 /\ p4 U_[0,1111] ( p2 /\ p3 U_[0,1111] ( p1 /\ p4 U_[0,1111] ( p2 /\ p3 U_[0,1111] ( p1 /\ p4 U_[0,1111] ( p2 /\ p3 U_[0,1112] p1 ) ) ) ) ) ) ) ) )';

%-------- PREDICATES ------
ii = 1;
Pred(ii).str = 'p1';
Pred(ii).A = [0 -1];
Pred(ii).b = -4500;

ii = ii+1;
Pred(ii).str = 'p2';
Pred(ii).A = [0 1];
Pred(ii).b = 1500;

ii = ii+1;
Pred(ii).str = 'p3';
Pred(ii).A = [-1 0];
Pred(ii).b = -40;

ii = ii+1;
Pred(ii).str = 'p4';
Pred(ii).A = [1 0];
Pred(ii).b = 120;

runtime = zeros(iform,nTest);
output = zeros(iform,5);
assignin('base','Preds',Pred);
assignin('base','SystemDimension',2);
for i = 1:iform
    for j = 1:nTest
        assignin('base', 'Formula', formula{i});
        tic;
        sim('demo_autotrans_monitoring');
        runtime(i,j) = toc;
        disp(runtime(i,j));
    end
    output(i,1) = i;
    output(i,2) = min(runtime(i,:));
    output(i,3) = max(runtime(i,:));
    output(i,4) = mean(runtime(i,:));
    output(i,5) = var(runtime(i,:));
end
   
stats=output;
end

