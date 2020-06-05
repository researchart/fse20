function [T, XT, YT, LT, clg, grd] = BlackBoxHA3(X0,simT,TU,U)

LT = [];

clg=cell(1,1);
grd=cell(1,1);
 for i=1:1
     
    clg{i} = {2;1};
    guards = [];
    guards(1,2).A={[1 0 0 0 0 0 0 0 0] ...
                    [0 -1 0 0 0 0 0 0 0] ...
                    [0 0 1 0 0 0 0 0 0] ...
                    [0 0 0 -1 0 0 0 0 0] ...
                    [0 0 0 0 1 0 0 0 0]...
                    [0 0 0 0 0 -1 0 0 0] ...
                    [0 0 0 0 0 0 1 0 0]...
                    [0 0 0 0 0 0 0 -1 0]};
    guards(1,2).b={ 90 -10 90 -10 90 -10 90 -10};
    guards(2,1).A=[-1 0 0 0 0 0 0 0 0;
                    0 1 0 0 0 0 0 0 0;
                    0 0 -1 0 0 0 0 0 0;
                    0 0 0 1 0 0 0 0 0;
                    0 0 0 0 -1 0 0 0 0;
                    0 0 0 0 0 1 0 0 0;
                    0 0 0 0 0 0 -1 0 0;
                    0 0 0 0 0 0 0 1 0];
    guards(2,1).b=[-90; 10; -90; 10; -90; 10; -90; 10];
    grd{i} = guards;
end



model = 'HA1_model';
slCharacterEncoding('Shift_JIS');
warning off
simopt = simget('HA3_model');
simopt = simset(simopt,'SaveFormat','Array'); % Replace input outputs with structures
% Run the model 
 [T, XT, YT] = sim(model,[0 simT],simopt,[TU U]);
 
  LT = YT(:,[10]);
 YT(:,[10]) = [];
 
end
