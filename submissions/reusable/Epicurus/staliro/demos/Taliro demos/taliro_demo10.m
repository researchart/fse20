% dp and fw taliro demo on hybrid system signals.
% The distance metric that does not include distance to guards.

% G. Fainekos: Last update 2013.01.27

clear;

phi = '(<>_[0,1.5] []!(a1 /\ a2 /\ a3 /\ a4)) /\ []!(d1 /\ d2) /\ ((!(e1 /\ e2 /\ e3 /\ e4)) U (c1 /\ c2 /\ c3 /\ c4))';

i=1;
Pred(i).str = 'a1';
Pred(i).A = [1 0];
Pred(i).b = [0.8];
Pred(i).loc = 13;

i=i+1;
Pred(i).str = 'a2';
Pred(i).A = [-1 0];
Pred(i).b = [-0.2];
Pred(i).loc = 13;

i=i+1;
Pred(i).str = 'a3';
Pred(i).A = [0 1];
Pred(i).b = [3.8];
Pred(i).loc = 13;

i=i+1;
Pred(i).str = 'a4';
Pred(i).A = [0 -1];
Pred(i).b = [-3.2];
Pred(i).loc = 13;

i=i+1;
Pred(i).str = 'c1';
Pred(i).A = [1 0];
Pred(i).b = [3.8];
Pred(i).loc = 8;

i=i+1;
Pred(i).str = 'c2';
Pred(i).A = [ -1 0];
Pred(i).b = [ -3.2];
Pred(i).loc = 8;

i=i+1;
Pred(i).str = 'c3';
Pred(i).A = [0 1];
Pred(i).b = [ 1.8];
Pred(i).loc = 8;

i=i+1;
Pred(i).str = 'c4';
Pred(i).A = [0 -1];
Pred(i).b = [-1.2];
Pred(i).loc = 8;

i=i+1;
Pred(i).str = 'd1';
Pred(i).A = [0 1];
Pred(i).b = [1];
Pred(i).loc = [1,2];

i=i+1;
Pred(i).str = 'd2';
Pred(i).A = [1 0];
Pred(i).b = [2];
Pred(i).loc = [1,2];

i=i+1;
Pred(i).str = 'e1';
Pred(i).A = [1 0];
Pred(i).b = [3.8];
Pred(i).loc = 4;

i=i+1;
Pred(i).str = 'e2';
Pred(i).A = [ -1 0];
Pred(i).b = [-3.2];
Pred(i).loc = 4;

i=i+1;
Pred(i).str = 'e3';
Pred(i).A = [0 1];
Pred(i).b = [ 0.8];
Pred(i).loc = 4;

i=i+1;
Pred(i).str = 'e4';
Pred(i).A = [0 -1];
Pred(i).b = [-0.2];
Pred(i).loc = 4;

cd('..');
cd('SystemModelsAndData');
load('hybrid_signals');

disp(' ');
disp(' Running specification ')
disp(phi)
disp([' On a hybrid 2D trace with ',num2str(length(hh1)),' samples.'])

% hh1(:,3:4) contains the state trace (trajectory)
% hh1(:,2) contains the time stamps (sampling times)
% hh1(:,1) contains the location trace (trajectory)
% CLG contains the adjacency graph of the control locations
disp(' ')
disp('Running dp_taliro ... ')
tic
rob_dp  = dp_taliro(phi,Pred,hh1(:,3:4),hh1(:,2),hh1(:,1),CLG)
toc
disp(' ')
disp('Running fw_taliro ... ')
tic
rob_fw = fw_taliro(phi,Pred,hh1(:,3:4),hh1(:,2),hh1(:,1),CLG)
toc

cd('..');
cd('Taliro demos');





