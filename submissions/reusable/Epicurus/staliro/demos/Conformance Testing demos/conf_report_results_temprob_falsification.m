function conf_report_results_temprob_falsification(collected_results)

%for each formula and implementation
%   how many runs falsfified the formula
%   how many tests were required to falsify (min, avg, max) over runs
%   runtime of falsifying runs (min, avg, max) over runs
%   the rob reached (min, avg,max) over runs
% How many implementations were falsified (by any run)


nbphis = size(collected_results, 1);
nbimpls = size(collected_results,2);

for ixphi=1:nbphis
    nb_fimpls = 0;
    monster = zeros(10,nbimpls);
    for ixI = 1:nbimpls
        myresults = collected_results{ixphi,ixI};
        nbruns = length(myresults.run);
        nb_fruns = 0;
        nb_ftests = [];
        ftime = [];
        rob = [];
        for r =1:nbruns
            if myresults.run(r).falsified
                nb_fruns = nb_fruns + 1;
                nb_ftests = [nb_ftests myresults.run(r).nTests]; %#ok<AGROW>
                ftime = [ftime  myresults.run(r).time]; %#ok<AGROW>
            end
        end
        if nb_fruns > 0 
            nb_fimpls = nb_fimpls+1; 
        end
        stFtests = [min(nb_ftests), mean(nb_ftests), max(nb_ftests)];
        stFtime = [min(ftime), mean(ftime), max(ftime)];
        stRob = [min(rob), mean(rob), max(rob)];
        monster(1,ixI) = nb_fruns;
        monster(2:4, ixI) = stFtests';
        monster(5:7, ixI) = stFtime';
        monster(8:10, ixI) = stRob';
    end
    
    disp('')
    ldisp(['FORMULA ',num2str(ixphi)])
    ldisp([num2str(nbruns), ' falsified ', num2str(nb_fimpls),'/',num2str(nbimpls),' impls'])
    ldisp(['Impls: ', num2str(1:nbimpls)])
    ldisp(['nfruns: ', num2str(monster(1,:))])
    ldisp(['nb ftests min: ', num2str(monster(2,:))])
    ldisp(['nb ftests avg: ', num2str(monster(3,:))])
    ldisp(['nb ftests max: ', num2str(monster(4,:))])
    ldisp(['nb ftime min: ', num2str(monster(5,:))])
    ldisp(['nb ftime avg: ', num2str(monster(6,:))])
    ldisp(['nb ftime max: ', num2str(monster(7,:))])
    ldisp(['rob min: ', num2str(monster(8,:))])
    ldisp(['rob avg: ', num2str(monster(9,:))])
    ldisp(['rob max: ', num2str(monster(10,:))])
    
    disp('')
end

end

function ldisp(msg)
eol = '\\';
disp([msg, eol]);
end
