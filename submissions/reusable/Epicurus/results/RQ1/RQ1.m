disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('RQ1 (Effectiveness and Efficency)');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
% Copyright by University of Luxembourg 2019-2020. Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg.
% Copyright by University of Luxembourg 2019-2020. Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg.
% Copyright by University of Luxembourg 2019-2020. Developed by Shiva Nejati,shiva.nejati@uni.lu University of Luxembourg.
% Copyright by University of Luxembourg 2019-2020. Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg.


clear
close all
runs=1:1:50;

models=["twotank" "regulators" "tustin" "regulators" "tustin" "regulators" "fsm"];

requirementspermodels={{"R1" "R2" "R3" "R4" "R6" "R7" "R8"},{"R1" "R3" "R4"},{"R1" "R2"},{"R1" "R3" "R4" "R5" "R7" "R8"},{"R1" "R2"}, {"R5" "R7" "R8"},{"R2","R3","R4"}};
prefixes=["IP" "IP" "IP" "IP1" "IP1" "IP2" "IP2"];
algorithms=["IFBT_UR" "UR"];



total=0;

totalRequirementsSize = cellfun(@numel, requirementspermodels);

reqrsults=zeros(1,sum(totalRequirementsSize));
reqrsults2=zeros(1,sum(totalRequirementsSize));
valid=zeros(1,sum(totalRequirementsSize));
avg_time=zeros(1,sum(totalRequirementsSize));

maxexecutiontime=3600;

results=[0 0];
totalresults=[0 0];
falseresults=[0 0];
time=[0 0];


for algindex=1:size(algorithms,2)
    rind=0;
    algorithm=algorithms(algindex)
    numberofchecks=0;
    reIndex=0;
    index=0;
    model_ind=0;

    for model=models
        model_ind=model_ind+1;
        disp(model)
        index=index+1;
        allrequirements=requirementspermodels{model_ind};
        for reqindex=1:size(allrequirements,2)
            reIndex=reIndex+1;
            requirement=allrequirements{reqindex};
            rind=rind+1;
            for run1=1:size(runs,2)
                numberofchecks=numberofchecks+1;
                totaltime=0;
                found=false;
                for run2=1:size(runs,2)
                    prefix=prefixes(index);
                    algorithmid=1;
                    run=1+mod(run1+run2,size(runs,2));
                    fidtime = fopen(strcat(prefix,filesep,model,filesep,requirement,filesep,algorithm,filesep,"Run",num2str(run),filesep,"totaltime.txt"),'r');
                    runtime=fscanf(fidtime,'%f');
                    fclose(fidtime);
                    totaltime=totaltime+runtime;
                    fid = fopen(strcat(prefix,filesep,model,filesep,requirement,filesep,algorithm,filesep,"Run",num2str(run),filesep,"result.txt"),'r');
                    runresult=fscanf(fid,'%d');
                    fclose(fid);
                    if runresult==1 && totaltime<maxexecutiontime && found==false
                        if algindex==1
                            reqrsults(rind)=reqrsults(rind)+1;
                        end
                        if algindex==2
                            reqrsults2(rind)=reqrsults2(rind)+1;
                        end
                        totalresults(algindex)=totalresults(algindex)+1;
                        found=true;
                        time(algindex)=time(algindex)+runtime;
                    end
                end
                if totaltime<maxexecutiontime && found==false
                    falseresults(algindex)=falseresults(algindex)+1;
                end
            end
        end
    end
    results(algindex)=totalresults(algindex)/numberofchecks;
    time(algindex)=time(algindex)/numberofchecks;
end

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('Percentage of reequirements in which IFBT-UR and UR identify a v-safe assumption respectively is: ');
disp(results*100);
disp(['IFBT-UR outperforms UR by learning av-safe assumption for: ',num2str( (results(1,1)-results(1,2))* 100),' % more requirements']);

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('The time required for IFBT-UR and UR to identify a v-safe assumption respectively is (seconds):');
disp(time)
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
