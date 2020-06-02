% This demo runs five on-line monitors for five MTL formulas
% 
clear all;

ii = 1;
preds(ii).str = 'p1';
preds(ii).A = [1];
preds(ii).b = [0.25];

ii = 2;
preds(ii).str = 'p2';
preds(ii).A = [-1];
preds(ii).b = [0.25];


%  Always in the past the signal value should be between -0.25 and 0.25 
Phi_1='[.]( p1 /\ p2) ';
%  Always in the past from 0 to 10 samples the signal value should be 
%  between -0.25 and 0.25 
Phi_2='[.]_[0,10]( p1 /\ p2 ) ';
%  At some point in the last 20 samples, when the signal value is out of 
%  -0.25~0.25 bounds then within the next 10 samples, the signal will be in
%  the -0.25~0.25 bounds and stay there for 10 samples.
Phi_3='[.]_[0,20]( !( p1 /\ p2) -> <>_[0,10] []_[0,10]( p1 /\ p2) )';
%  Always in the past between, when the signal value is out of -0.25~0.25 
%  bounds then within the next 10 samples, the signal will be in the 
%  -0.25~0.25 bounds and stay there for 10 samples.
Phi_4='[.]( !( p1 /\ p2) -> <>_[0,10] []_[0,10]( p1 /\ p2) )';
%  Eventually in the past from 0 to 10 samples the signal value should be 
%  between -0.25 and 0.25.
Phi_5='<.>_[0,10]( p1 /\ p2) ';
assignin('base','Preds',preds);
assignin('base','InputDimension',1);
sim('Multiple_Monitors');
