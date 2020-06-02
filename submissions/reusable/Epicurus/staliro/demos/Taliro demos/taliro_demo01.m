% dp and fw taliro demo on discrete-time real valued signals.
%
% This is the same demo as taliro_demo00 with the difference that the
% atomic propositions map to polytopes rather than halfspaces.
% Using general polytopes produces better approximations to the temporal
% logic robustness, but the computation time increases due to the calls to
% quadratic programming solvers.

% G. Fainekos: Last update 2013.01.27

clear

phi = '<>_[0,1.5] []!a /\ []!d /\ (!e) U c';

i=1;
Pred(i).str = 'a';
Pred(i).A = [1 0; -1 0; 0 1; 0 -1];
Pred(i).b = [0.8; -0.2; 3.8; -3.2];

i=i+1;
Pred(i).str = 'c';
Pred(i).A = [1 0; -1 0; 0 1; 0 -1];
Pred(i).b = [3.8; -3.2; 1.8; -1.2];

i=i+1;
Pred(i).str = 'd';
Pred(i).A = [0 1; 1 0];
Pred(i).b = [1; 2];

i=i+1;
Pred(i).str = 'e';
Pred(i).A = [1 0; -1 0; 0 1; 0 -1];
Pred(i).b = [3.8; -3.2; 0.8; -0.2];

cd('..');
cd('SystemModelsAndData');
load('hybrid_signals');

disp(' ');
disp(' Running specification ')
disp(phi)
disp([' On a 2D trace with ',num2str(length(hh1)),' samples.'])

% hh1(:,3:4) contains the state trace (trajectory)
% hh1(:,2) contains the time stamps (sampling times)
disp(' ')
disp('Running dp_taliro ... ')
tic
rob_dp = dp_taliro(phi,Pred,hh1(:,3:4),hh1(:,2))
toc
disp(' ')
disp('Running fw_taliro ... ')
tic
rob_fw = fw_taliro(phi,Pred,hh1(:,3:4),hh1(:,2))
toc

cd('..');
cd('Taliro demos');



