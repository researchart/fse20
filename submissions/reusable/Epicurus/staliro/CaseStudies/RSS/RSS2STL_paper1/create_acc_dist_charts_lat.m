
%    stSignalData = struct('safeDist',safeDist,'safeLatDist',
%       safeLatDist,'rearAccel',rearAccel,'frontAccel', 
%       frontAccel, 'unsafe_begin_time', unsafe_begin_time);
%    stSignalBounds = struct('MIN_SAFE_DIST',0,'A_MAX_BRAKE',
%       A_MAX_BRAKE,'A_MAX_ACCEL',A_MAX_ACCEL,'A_MIN_BRAKE',A_MIN_BRAKE);


function create_acc_dist_charts(stSignalData, stSignalBounds, preds_lat, time)

    safeDist = stSignalData.safeDist;
    safeLatDist = stSignalData.safeLatDist;
    rightLatAccel = stSignalData.rightLatAccel;
    leftLatAccel = stSignalData.leftLatAccel;
    rightMuLatSpeed = stSignalData.rightMuLatSpeed;
    leftMuLatSpeed = stSignalData.leftMuLatSpeed;
    unsafe_begin_time = stSignalData.unsafe_begin_time;

    MIN_SAFE_DIST = stSignalBounds.MIN_SAFE_DIST;
    A_MAX_BRAKE = stSignalBounds.A_MAX_BRAKE;
    A_MAX_ACCEL = stSignalBounds.A_MAX_ACCEL;
    A_MIN_BRAKE = stSignalBounds.A_MIN_BRAKE;

    %Data_long = [safeDist, safeLatDist, rearAccel, frontAccel, safeDist*1000, safeLatDist*1000];
    Data_lat = [safeDist, safeLatDist, rightLatAccel, leftLatAccel, rightMuLatSpeed, leftMuLatSpeed, safeDist*1000, safeLatDist*1000];

    psi1 = '( !safe_long_ant /\ safe_lat_ant /\ X (!safe_lat_ant /\ !safe_long_ant) )';
    r_psi1 = zeros(length(time),1); 
    for ii = 1:length(time)
        r_psi1(ii) = dp_taliro(psi1,preds_lat,Data_lat(ii:end,:),time(ii:end))>0;
    end

    psi2 = ['(safe_long_ant \/ safe_lat_ant) R_[0,0.5) ((a_ego_lat_lt_max_acc /\ a_right_lat_max_acc)\/(safe_long_ant \/ safe_lat_ant))'];
    r_psi2 = zeros(length(time),1); 
    for ii = 1:length(r_psi1)
        r_psi2(ii) = dp_taliro(psi2,preds_lat,Data_lat(ii:end,:),time(ii:end))>0;
    end

    %psi3 = ['(safe_long_ant \/ safe_lat_ant \/ stopped_ego_lat) R_[0.5, inf) (a_ego_lat_lt_min_brake \/ (safe_long_ant \/ safe_lat_ant \/ stopped_ego_lat))'];
    psi3 = ['(safe_long_ant \/ safe_lat_ant)'];
    r_psi3 = zeros(length(time),1); 
    for ii = 1:length(r_psi3)
        r_psi3(ii) = dp_taliro(psi3,preds_lat,Data_lat(ii:end,:),time(ii:end))>0;
    end

    %psi4 = ['(safe_long_ant \/ safe_lat_ant \/ stopped_right_lat) R_[0.5, inf) (a_right_lat_min_brake \/(safe_long_ant \/ safe_lat_ant \/ stopped_right_lat)) '];
    psi4 = ['(a_ego_lat_lt_max_acc /\ a_right_lat_max_acc)\/(safe_long_ant \/ safe_lat_ant)'];
    r_psi4 = zeros(length(time),1); 
    for ii = 1:length(time)
        r_psi4(ii) = dp_taliro(psi4,preds_lat,Data_lat(ii:end,:),time(ii:end))>0;
    end
    updatedTime = time + unsafe_begin_time;

    psi5 = ['(safe_long_ant \/ safe_lat_ant) R_[0.5, inf) ((stopped_ego_lat_ant -> X [](ego_lat_velocity_neg)) \/ (safe_long_ant \/ safe_lat_ant) ) '];
    %psi5 = [P_lat,' /\ ',P_lat11,' /\ ',P_lat12,' /\ ',P_lat21,' /\ ',P_lat22];
    r_psi5 = zeros(length(time),1); 
    for ii = 1:length(r_psi1)
        r_psi5(ii) = dp_taliro(psi5,preds_lat,Data_lat(ii:end,:),time(ii:end))>0;
    end
    
    psi6 = ['(safe_long_ant \/ safe_lat_ant) R_[0.5, inf) ((stopped_right_lat_ant -> X [] (right_lat_velocity_pos)) \/ (safe_long_ant \/ safe_lat_ant) ) '];
    %psi6 = ['[](',lat_ant,' -> X ( ',P_lat_conseq,') )'];    
    r_psi6 = zeros(length(time),1); 
    for ii = 1:length(r_psi1)
        r_psi6(ii) = dp_taliro(psi6,preds_lat,Data_lat(ii:end,:),time(ii:end))>0;
    end
    
    %TEST PURPOSES: floating point error
    for ii = 1:length(time)
        jj = find( (time(ii:end)-time(ii))>=0.1);
        jjBd{ii} = intersect(jj,find( (time(ii:end)-time(ii))<0.2));
    end
    
    figure;
    axis equal;
    hold on;
    sf1 = subplot(6,1,1);
    plot(updatedTime,r_psi1)
    sf2 = subplot(6,1,2);
    plot(updatedTime,r_psi2)
    sf3 = subplot(6,1,3);
    plot(updatedTime,r_psi3)
    sf4 = subplot(6,1,4);
    plot(updatedTime,r_psi4)
    sf5 = subplot(6,1,5);
    plot(updatedTime,r_psi5)
    sf6 = subplot(6,1,6);
    plot(updatedTime,r_psi6)
    title1 = psi1;%'$$ \neg S_{l,r}^{lat} \wedge S_{b,f}^{lon} \wedge \bigcirc (\neg{S_{l,r}^{lat}} \wedge \neg{S_{b,f}^{lon}})$$';%'Antecedent in $$\varphi^{lon}$$ in Lemma 3.3';
    title2 = psi2;%'$$ S_{b,f}^{lon}  \overline{\mathcal{R}}_{[0,\rho)}( A_{r,maxAcc}^{lon} \wedge A_{f,maxBr}^{lon})$$';%'First release formula in the consequent in Lemma 3.3';
    title3 = psi3;%'$$ S_{b,f}^{lon}  \overline{\mathcal{R}}_{[\rho,+\infty)} (A_{r,minBr}^{lon} \wedge A_{f,maxBr}^{lon})$$';%'Second release formula in the consequent in Lemma 3.3';
    title4 = psi4;%'$$ \bigl(\neg S_{l,r}^{lat} \wedge S_{b,f}^{lon} \wedge \bigcirc (\neg{S_{l,r}^{lat}} \wedge \neg{S_{b,f}^{lon}})\bigr ) \rightarrow\bigcirc P^{lon}$$';%'$\varphi^{lon}$ in Lemma 3.3';
    title5 = psi5;%'$$ F_{[0,0.1)} (S_{b,f}^{lon} \vee S_{l,r}^{lat}) $$';%'$\varphi^{lon}$ in Lemma 3.3';
    title6 = psi6;%'$$ F_{[0.5,0.6)} (S_{b,f}^{lon} \vee S_{l,r}^{lat})$$';%'$\varphi^{lon}$ in Lemma 3.3';
    title(sf1,title1,'Interpreter','latex')
    title(sf2,title2,'Interpreter','latex')
    title(sf3,title3,'Interpreter','latex')
    title(sf4,title4,'Interpreter','latex')
    title(sf5,title5,'Interpreter','latex')
    title(sf6,title6,'Interpreter','latex')
    hold off;
    
%     figure;
%     axis equal;
%     hold on;
%     sff1 = subplot(2,1,1);
%     plot(updatedTime,safeDist,':')
%     hold on;
%     plot(updatedTime,safeLatDist,':')
%     hold on;
%     plot(updatedTime,zeros(length(updatedTime),1))
% 
%     hold off;
%     lgd = legend({'safe long dist','safe lat dist', 'min safe dist'},'Location','southeast','Orientation','vertical');
%     lgd.NumColumns = 2;
% 
%     sff2 = subplot(2,1,2);
%     plot(updatedTime,rearAccel,':')
%     hold on;
%     plot(updatedTime,frontAccel,':')
%     hold on;
%     plot(updatedTime,ones(length(updatedTime),1)*A_MAX_BRAKE*-1)
%     hold on;
%     plot(updatedTime,ones(length(updatedTime),1)*A_MIN_BRAKE*-1)
%     hold on;
%     plot(updatedTime,ones(length(updatedTime),1)*A_MAX_ACCEL)
%     title1 = 'safe distances';
%     title2 = 'accelarations';
%     title(sff1,title1)
%     title(sff2,title2)
%     hold off;
%     lgd = legend({'ego car accel','front car accel', 'max brake', 'min brake', 'max accel'},'Location','southeast','Orientation','vertical');
%     lgd.NumColumns = 3;
end