function [longSafety, latSafety, lat_longSafety] = ...
    computeRSSrobustnessForTrajectories(samples, dt_prediction, egoCar,...
    obstacleLane, obstacleSamples, distancReflection,...
    Phi_long_safety, Phi_lat_safety, Phi_lat_long_safety,...
    preds_long, preds_lat, preds_lat_long, compute_Phi_long_safety,...
    compute_Phi_lat_safety, compute_Phi_not_lat_not_long_safety, sideIndex)

global A_MAX_BRAKE;
global A_MAX_ACCEL;
global A_LAT_MAX_ACCEL;
global A_MIN_BRAKE;
global A_LAT_MIN_BRAKE;
global A_MIN_BRAKE_CORRECT;
global RHO;
global MU;

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
totalTimeSteps = samples;
szf=size(egoCar);

for i = 1:szf(1)
    %check for multiple cross along lanes%added by Mohammad: begin
    repeatition = find(egoCar(1:i,1)==egoCar(i,1) & ...
        egoCar(1:i,2)==egoCar(i,2) & egoCar(1:i,3)==egoCar(i,3));
    cutMask = ones(1,totalTimeSteps);
    if length(repeatition) > 1
        repeatCount = length(repeatition);
        repeatCountIndex = find(obstacleLane{egoCar(i,2)}(:,1)==egoCar(i,1));
        szObss = size(obstacleSamples);
        stCut = obstacleLane{egoCar(i,2)}(repeatCountIndex(repeatCount),2);
        edCut = obstacleLane{egoCar(i,2)}(repeatCountIndex(repeatCount),3);
        cutMask = zeros(1,totalTimeSteps);
        cutMask(1,stCut:edCut) = 1;
    end%end of change
    
    direction=[];
    mask=obstacleSamples(egoCar(i,3),:,egoCar(i,1) + sideIndex) & obstacleSamples(egoCar(i,2),:,egoCar(i,1));
    mask = mask & cutMask;%added by Mohammad
    nonzeros=find(mask==1);
    if ~isempty(nonzeros)
       unsafe_begin_time = (nonzeros(1)-1)*dt_prediction; 
    else
        continue;
    end

    frontLong=distancReflection{egoCar(i,3),egoCar(i,1)}(3,nonzeros);
    rearLong=distancReflection{egoCar(i,2),egoCar(i,1)}(3,nonzeros);
    startPrefix = nonzeros(1)-1;

    mask_NaN = ~isnan(frontLong) & ~isnan(rearLong);
    nonzeros=find(mask_NaN==1);
    if isempty(nonzeros)
        continue;
    end
    nonzeros = nonzeros + startPrefix;
    %sync the beginning and end (this must be done before!)
    frontLong=distancReflection{egoCar(i,3),egoCar(i,1)}(3,nonzeros);
    rearLong=distancReflection{egoCar(i,2),egoCar(i,1)}(3,nonzeros);
    if length(frontLong) > 1
        stoppedFront = diff(frontLong(:));
        stoppedRear = diff(rearLong(:));
        stoppedFront = [stoppedFront;stoppedFront(end)];
        stoppedRear = [stoppedRear;stoppedRear(end)];
        nonzeros = find(stoppedFront>0 & stoppedRear > 0);
        zerosindex = find(diff(nonzeros) ~= 1);
        if isempty(nonzeros)
            continue;
        end
        unsafe_begin_time = unsafe_begin_time + (nonzeros(1)-1)*dt_prediction; 
        nonzeros = nonzeros + startPrefix;
    end
    frontLong=distancReflection{egoCar(i,3),egoCar(i,1)}(3,nonzeros);
    rightLat=distancReflection{egoCar(i,3),egoCar(i,1)}(4,nonzeros);
    rearLong=distancReflection{egoCar(i,2),egoCar(i,1)}(3,nonzeros);
    leftLat=distancReflection{egoCar(i,2),egoCar(i,1)}(4,nonzeros);
    frontSpeed=diff(frontLong(:))./dt_prediction;
    rearSpeed=diff(rearLong(:))./dt_prediction;
    rightLatSpeed=diff(rightLat(:))./dt_prediction;
    leftLatSpeed=diff(leftLat(:))./dt_prediction;
    szSpeed=size(frontSpeed);
    safeDist=zeros(szSpeed(1),1);
    safeLatDist=zeros(szSpeed(1),1);
    if szSpeed(1) > 1

        trj_len = length(leftLat);
        err_marj = 0.1;
        %compute mu-lateral-velocity for left trajectory
        leftMuLatSpeed = zeros(trj_len-1,1);
        for cnt1=1:trj_len-1
            cur_lat = leftLat(cnt1);
            meets_half_mu = true;
            meets_cur_lat_before = false;
            lat_is_cur_lat = find(leftLat(cnt1+1:end)>=(cur_lat-err_marj) & leftLat(cnt1+1:end)<=(cur_lat+err_marj));
            lat_is_in_cur_lat_half_mu = find(leftLat(cnt1+1:end)>=(cur_lat-MU/2+err_marj) & leftLat(cnt1+1:end)<=(cur_lat+MU/2-err_marj));
            
            if length(lat_is_in_cur_lat_half_mu)==(trj_len-cnt1) | (trj_len-cnt1)==0
                meets_half_mu = false;
            else
                lat_is_out_cur_lat_half_mu = find(leftLat(cnt1+1:end)<=(cur_lat-MU/2-err_marj) | leftLat(cnt1+1:end)>=(cur_lat+MU/2+err_marj));
                if ~isempty(lat_is_cur_lat) && ~isempty(lat_is_out_cur_lat_half_mu)
                    if lat_is_cur_lat(1) < lat_is_out_cur_lat_half_mu(1)
                        meets_cur_lat_before = true;
                    else
                        leftMuLatSpeed(cnt1,1) = (leftLat(lat_is_out_cur_lat_half_mu(1))-cur_lat)/((lat_is_out_cur_lat_half_mu(1)-1)*dt_prediction);
                    end
                end
            end
            
            if (~isempty(lat_is_cur_lat) && ~meets_half_mu) | (meets_half_mu && meets_cur_lat_before)
                leftMuLatSpeed(cnt1,1) = 0;
            else
            end
        end
        %compute mu-lateral-velocity for right trajectory
        rightMuLatSpeed = zeros(trj_len-1,1);
        for cnt1=1:trj_len-1
            cur_lat = rightLat(cnt1);
            meets_half_mu = true;
            meets_cur_lat_before = false;
            lat_is_cur_lat = find(rightLat(cnt1+1:end)>=(cur_lat-err_marj) & rightLat(cnt1+1:end)<=(cur_lat+err_marj));
            lat_is_in_cur_lat_half_mu = find(rightLat(cnt1+1:end)>=(cur_lat-MU/2+err_marj) & rightLat(cnt1+1:end)<=(cur_lat+MU/2-err_marj));
            
            if length(lat_is_in_cur_lat_half_mu)==(trj_len-cnt1) | (trj_len-cnt1)==0
                meets_half_mu = false;
            else
                lat_is_out_cur_lat_half_mu = find(rightLat(cnt1+1:end)<=(cur_lat-MU/2-err_marj) | rightLat(cnt1+1:end)>=(cur_lat+MU/2+err_marj));
                if ~isempty(lat_is_cur_lat) && ~isempty(lat_is_out_cur_lat_half_mu)
                    if lat_is_cur_lat(1) < lat_is_out_cur_lat_half_mu(1)
                        meets_cur_lat_before = true;
                    else
                        rightMuLatSpeed(cnt1,1) = (rightLat(lat_is_out_cur_lat_half_mu(1))-cur_lat)/((lat_is_out_cur_lat_half_mu(1)-1)*dt_prediction);
                    end
                end
            end
            
            if (~isempty(lat_is_cur_lat) && ~meets_half_mu) | (meets_half_mu && meets_cur_lat_before)
                rightMuLatSpeed(cnt1,1) = 0;
            else
            end
        end

        
        for j=1:szSpeed(1)
           
        min_long_dist = rearSpeed(j)*RHO+0.5*A_MAX_ACCEL*(RHO^2) + ...
            (0.5*(rearSpeed(j)+RHO*A_MAX_ACCEL)^2)/A_MIN_BRAKE - ...
            0.5*(frontSpeed(j)^2)/A_MAX_BRAKE;
        min_long_dist = max(0, min_long_dist);
        safeDist(j)=frontLong(j)-rearLong(j)-min_long_dist;
        frontAccel=[diff(frontSpeed(:))./dt_prediction];
        frontAccel = [frontAccel;frontAccel(end)];
        rearAccel=[diff(rearSpeed(:))./dt_prediction];
        rearAccel = [rearAccel;rearAccel(end)];
        rightLatAccel=[diff(rightLatSpeed(:))./dt_prediction];
        rightLatAccel = [rightLatAccel;rightLatAccel(end)];
        leftLatAccel=[diff(leftLatSpeed(:))./dt_prediction];
        leftLatAccel = [leftLatAccel;leftLatAccel(end)];

        Data_long=[];
        Data_lat=[];
        if  leftLat(j)<rightLat(j) % Ego car is on the left
            vr_lat_rho = leftLatSpeed(j)+RHO*A_LAT_MAX_ACCEL;
            vf_lat_rho = rightLatSpeed(j)-RHO*A_LAT_MAX_ACCEL;
            d1=(leftLatSpeed(j)+vr_lat_rho)*RHO*0.5;
            d2=0.5*(vr_lat_rho^2)/A_LAT_MIN_BRAKE;
            d3=(rightLatSpeed(j)+vf_lat_rho)*RHO*0.5;
            d4=0.5*(vf_lat_rho^2)/A_LAT_MIN_BRAKE;
            minLatDist = MU + max(0, d1+d2-d3+d4);
            safeLatDist(j) = abs(rightLat(j)-leftLat(j))-minLatDist;
            Data_lat = [safeDist, safeLatDist, leftLatAccel, rightLatAccel, leftMuLatSpeed, rightMuLatSpeed];
        else    
            vr_lat_rho = leftLatSpeed(j)-RHO*A_LAT_MAX_ACCEL;
            vf_lat_rho = rightLatSpeed(j)+RHO*A_LAT_MAX_ACCEL;
            d1=(rightLatSpeed(j)+vf_lat_rho)*RHO*0.5;
            d2=0.5*(vf_lat_rho^2)/A_LAT_MIN_BRAKE;
            d3=(leftLatSpeed(j)+vr_lat_rho)*RHO*0.5;
            d4=0.5*(vr_lat_rho^2)/A_LAT_MIN_BRAKE;
            minLatDist = MU + max(0, d1+d2-d3+d4);
            safeLatDist(j) = abs(rightLat(j)-leftLat(j))-minLatDist;
            Data_lat = [safeDist, safeLatDist, rightLatAccel, leftLatAccel, rightMuLatSpeed, leftMuLatSpeed];

        end
    end

    Data_long = [safeDist, safeLatDist, rearAccel, frontAccel, safeDist*1000, safeLatDist*1000];
    
    time=zeros(szSpeed(1),1);
    for j=2:szSpeed(1)
        time(j)=(j-1)*dt_prediction;
    end
    if isempty(time)==0
        
        if true(compute_Phi_long_safety)
        [rob, aux]=dp_taliro(Phi_long_safety, preds_long, Data_long, time);
        t_blame = -1;
        i_blame = -1;
        if rob < 0
            tmpSafeDist = zeros(length(safeDist),1);
            indexNotSafe = find(safeDist < 0);
            if ~isempty(indexNotSafe)
                tmpSafeDist(indexNotSafe) = -1;
                Data_long = [safeDist, safeLatDist, rearAccel, frontAccel, tmpSafeDist, safeLatDist*1000];
                [tmpRob, tmpAux]=dp_taliro(Phi_long_safety, preds_long, Data_long, time);
                t_blame = (tmpAux.i)*dt_prediction + unsafe_begin_time;
                i_blame = tmpAux.i;
            end
        end
        longSafety=[longSafety;struct('egoID',egoCar(i,2),'frontID',...
        egoCar(i,3),'robustness',rob,'aux',aux,'t_blame',t_blame,...
        'i_blame',i_blame,'safeDist',safeDist,'safeLatDist',safeLatDist)];
%************************************************
%*** the below block is used for chart generation in the paper
%************************************************
         if false && egoCar(i,2)==48 && egoCar(i,3)==31% 28 24 scn 9 % 26 23 scn 9 % 21 11 scn 10
             stSignalData = struct('safeDist',safeDist,'safeLatDist',...
                 safeLatDist,'rearAccel',rearAccel,'frontAccel',...
                 frontAccel, 'unsafe_begin_time', unsafe_begin_time);
             stSignalBounds = struct('MIN_SAFE_DIST',0,'A_MAX_BRAKE',...
                 A_MAX_BRAKE,'A_MAX_ACCEL',A_MAX_ACCEL,'A_MIN_BRAKE',A_MIN_BRAKE);
             create_acc_dist_charts(stSignalData, stSignalBounds, preds_long, time);
             create_acc_dist_charts_new(stSignalData, stSignalBounds, preds_long, time);
         end
        end%compute_Phi_long_safety
        
        Data_lat_org = Data_lat;
        %test
        Data_lat = [Data_lat, safeDist*1000, safeLatDist*1000];
        
        if true(compute_Phi_lat_safety)
        [rob, aux]=dp_taliro(Phi_lat_safety, preds_lat, Data_lat, time);
        t_blame = -1;
        i_blame = -1;
        if rob < 0
            tmpSafeDist = zeros(length(safeDist),1);
            indexNotSafe = find(safeDist < 0);
            if ~isempty(indexNotSafe)
                tmpSafeDist(indexNotSafe) = -1;
                Data_long = [safeDist, safeLatDist, rearAccel, frontAccel, tmpSafeDist, safeLatDist*1000];
                [tmpRob, tmpAux]=dp_taliro(Phi_lat_safety, preds_lat, Data_lat, time);
                t_blame = (tmpAux.i)*dt_prediction + unsafe_begin_time;
                i_blame = tmpAux.i;
            end
        end
        latSafety=[latSafety;struct('egoID',egoCar(i,2),'frontID',...
        egoCar(i,3),'robustness',rob,'aux',aux,'t_blame',t_blame,...
        'i_blame',i_blame,'safeDist',safeDist,'safeLatDist',safeLatDist)];
    
    %************************************************
    %*** the below block is used for chart generation in the paper
    %************************************************
         if false && egoCar(i,2)==28 && egoCar(i,3)==24% 28 24 scn 9 % 26 23 scn 9 % 21 11 scn 10
             stSignalData = struct('safeDist',safeDist,'safeLatDist',...
                 safeLatDist,'rightLatAccel',rightLatAccel,'leftLatAccel',...
                 leftLatAccel,'rightMuLatSpeed',rightMuLatSpeed,'leftMuLatSpeed',...
                 leftMuLatSpeed, 'unsafe_begin_time', unsafe_begin_time);
             stSignalBounds = struct('MIN_SAFE_DIST',0,'A_MAX_BRAKE',...
                 A_MAX_BRAKE,'A_MAX_ACCEL',A_MAX_ACCEL,'A_MIN_BRAKE',A_MIN_BRAKE);
             create_acc_dist_charts_lat(stSignalData, stSignalBounds, preds_lat, time);
             create_acc_dist_charts_lat_new(stSignalData, stSignalBounds, preds_lat, time);
         end
        end%compute_Phi_not_lat_safety
        if true(compute_Phi_not_lat_not_long_safety)
        Data_lat_lon = [Data_lat, rearAccel, frontAccel];
        [rob, aux]=dp_taliro(Phi_lat_long_safety, preds_lat_long, Data_lat_lon, time);
        t_blame = -1;
        i_blame = -1;
        if rob < 0
            tmpSafeDist = zeros(length(safeDist),1);
            tmpSafeLatDist = zeros(length(safeLatDist),1);
            indexNotSafe = find(safeDist < 0);
            if ~isempty(indexNotSafe)
                tmpSafeDist(indexNotSafe) = -1;
                indexNotSafe = find(safeLatDist < 0);
                tmpSafeLatDist(indexNotSafe) = -1;
                Data_lat_lon = [Data_lat_org,tmpSafeDist,tmpSafeLatDist, rearAccel, frontAccel];
                [tmpRob, tmpAux]=dp_taliro(Phi_lat_long_safety, preds_lat_long, Data_lat_lon, time);
                t_blame = (tmpAux.i)*dt_prediction + unsafe_begin_time;
                i_blame = tmpAux.i;
            end
        end
        lat_longSafety=[lat_longSafety;struct('egoID',egoCar(i,2),'frontID',...
        egoCar(i,3),'robustness',rob,'aux',aux,'t_blame',t_blame,...
        'i_blame',i_blame,'safeDist',safeDist,'safeLatDist',safeLatDist)];
    
        %************************************************
        %*** the below block is used for chart generation in the paper
        %************************************************
         if false && egoCar(i,2)==28 && egoCar(i,3)==24% 28 24 scn 9 % 26 23 scn 9 % 21 11 scn 10
             stSignalData = struct('safeDist',safeDist,'safeLatDist',...
                 safeLatDist,'rightLatAccel',rightLatAccel,'leftLatAccel',...
                 leftLatAccel,'rightMuLatSpeed',rightMuLatSpeed,'leftMuLatSpeed',...
                 leftMuLatSpeed, 'unsafe_begin_time', unsafe_begin_time);
             stSignalBounds = struct('MIN_SAFE_DIST',0,'A_MAX_BRAKE',...
                 A_MAX_BRAKE,'A_MAX_ACCEL',A_MAX_ACCEL,'A_MIN_BRAKE',A_MIN_BRAKE);
             create_acc_dist_charts_lat(stSignalData, stSignalBounds, preds_lat, time);
             create_acc_dist_charts_lat_new(stSignalData, stSignalBounds, preds_lat, time);
         end
        end%compute_Phi_not_lat_not_long_safety
    end
    end
end

end

