% Fro each run, how many implementations did it falsify?
function conf_report_results_guardseeking(myresults, simtime)

nbruns = length(myresults.run);
falsi_per_run = zeros(1,nbruns);
zeno_impl_per_run = zeros(1,nbruns);
nbimpls = length(myresults.run(1).time_rob_of_bestSample);
impldata = zeros(2,nbimpls);%row1: nb falsifying runs, row 2=nb runs that revealed it zeno
corresponding_srob_isn=0;
for r=1:nbruns
    thisrun = myresults.run(r);
    x0 = thisrun.bestSample;
    for t=1:length(thisrun.time_rob_of_bestSample)
        tr = thisrun.time_rob_of_bestSample{1,t};
        if tr.pt <= 0 || tr.ft <= 0
            falsi_per_run(r) = falsi_per_run(r)+1;
            impldata(1,t) = impldata(1,t)+1;
            if thisrun.bestRob <= 0
                corresponding_srob_isn=corresponding_srob_isn+1;
            end
            if tr.pt == -100*simtime && tr.ft == -100*simtime
                zeno_impl_per_run(r) = zeno_impl_per_run(r)+1;
                impldata(2,t) = impldata(2,t)+1;
            end
        end
    end
    %ldisp(['Run ' , num2str(r), ' falsified ', num2str(falsi_per_run(r)), '/ ', num2str(nbimpls), ' implementations.']);
end

ldisp('Implementations')
ldisp(num2str(1:nbimpls))
ldisp(['Nb falsifying runs (out of ', num2str(nbruns), ').'])
ldisp(num2str(impldata(1,:)))
ldisp(['Nb Zeno-revealing runs (out of ', num2str(nbruns), ').'])
ldisp(num2str(impldata(2,:)))

total_falsi = sum(falsi_per_run(:));
ldisp([num2str(corresponding_srob_isn), '/', num2str(total_falsi),' falsified impls have a non-positive corresponding spatial rob.']);

alo = length(find(falsi_per_run));
ldisp([num2str(alo), ' runs falsified at least one implementation.']);

total_zeno = sum(zeno_impl_per_run(:))';
ldisp([num2str(total_zeno), ' Zeno implementations revealed by bestSample']);
pzf = 100*total_zeno/total_falsi;
pzi = 100*total_zeno/(nbimpls*nbruns);
ldisp(['     that is ', num2str(pzf),'% of falsified impls, and ', num2str(pzi),'% of tested impls.']);

end

function ldisp(msg)
eol = '\\';
disp([msg, eol]);
end 
