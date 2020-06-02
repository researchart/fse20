function combined_system = create_combined_parallel_system(argv)
% NAME
% 
%     create_combined_parallel_system - create a parallel interconnection of two systems
% 
% SYNOPSIS
% 
%     combined_system = create_combined_parallel_system(argv)
% 
% DESCRIPTION
% 
%     create a parallel interconnection of two systems, and supply simulator
%     for the interconnection
%     
%   Inputs
% 
%     argv
%         A struct with the following fields
%         
%         model 
%             first system to connect, herein called a 'Model'
%             
%         implementation
%             second system to connect, herein called an 'Implementation'
%             
%         init       
%             Optional - initial conditions for the system. Struct with fields cube and 
%             loc, where cube is an n-by-2 array of lower and upper bounds on the continuous
%             variables, and loc is a vector of initial locations.
%             If omitted, init is taken from Model if it has one, else it is empty.        
% 
%         simulator_output
%             Optional - string name of desired simulator of this interconnection.
%             Default is 'simulator_parallel'.
%             You can choose from: 'parallel_trajectories', 'location_difference',  'x_difference',
%             'chronometers', 'shifted_x_difference', 'relative_error'                         
%                     
%   Outputs
%     
%     combined_system
%         A struct describing the interconnection, with fields 
%         
%         model
%             same as argv.model
%        
%         implementation
%             same as argv.implementation
%             
%         type
%             value 'interconnection'
%             
%         adjList, guards
%             both empty
%             
%         init
%             a struct - see above help for 'init'
%             
%         simulator
%             a function handle which simulates the combined system:
%             @(system,h0,simtime,solver,opts) [hs, locHis, rc] = simulator(system,h0,simtime,solver,opts)
%             where system is the system (yes, redundant, WIP...), h0 = initial condition, simtime = trajectory duration,
%                 solver = Matlab ode solver, opts = array of scalar options - see hasimulator for details.
%             hs is the output trajectory, with each row corresponding to a time instant and equal to
%                 row = [location   time_instant  continuous_state]
%             locHis = location history = hs(:,1) (yep, redundant)
%             rc = return code. Generally, anything not 0 is worthy of your attention.
%             
%             Some simulator will take additional arguments indirectly, e.g. 'relative_error'. See the help for each for
%             details.             
%     
% 
% EXAMPLES
% 
%         % Two simulink models
%         ATModel = 'AbstractFuelControlNoLUTs';
%         ATImplementation = 'AbstractFuelControl';
%         cs = create_combined_parallel_system(struct('model', Model, 'implementation', Implementation, 'simulator_output', 'location_difference'));
%         
%         % Two hybrid automata
%         init.loc = 13;
%         init.cube = [0.2 0.8; 3.2 3.8; -0.4 0.4; -0.4 0.4];
%         A = [4 2 3 4; 3 6 5 6; 1 2 3 6; 2 2 1 1];
%         Av = [-1.2000    0.1000;     0.1000   -1.2000];
%         Bv = Av;
%         Model = navbench_hautomaton(plotit,init,A, [], Av, Bv);
%         Av2 = Av+0.1; init.cube(end,:) = [-0.2 0.2];
%         Implementation = navbench_hautomaton(plotit,init,A, [], Av2, Bv);
% 
%       
% AUTHOR(S)
% 
%        Written by Houssam Abbas - Arizona State University 
% 
% See also - systemsimulator, navbench_hautomaton

        
    
combined_system.model = argv.model;
combined_system.implementation = argv.implementation;
combined_system.type = 'interconnection';
combined_system.adjList = []; % location graph
combined_system.guards = []; % the transition guards
if isfield(argv, 'init')
    combined_system.init = combined_system.model.init;
elseif isa(argv.model, 'hautomaton')
    combined_system.init = argv.model.init;
elseif isa(argv.implementation, 'hautomaton')
    combined_system.init = argv.implementation.init;
else
    combined_system.init = struct('loc',nan, 'cube',[]);
end

if ~isfield(argv, 'simulator_output')
    simulator_output = 'parallel_simulator';
else
    simulator_output = argv.simulator_output;
end
switch simulator_output
    case 'parallel_trajectories'
        combined_system.simulator = @parallel_simulator;
    case 'location_difference'
        combined_system.simulator = @parallel_simulator_location_difference;
    case 'x_difference'
        combined_system.simulator = @parallel_simulator_x_difference;
    case 'chronometers'
        combined_system.simulator = @parallel_simulator_chronometers;
    case 'shifted_x_difference'
        if ~isfield(argv, 'tau') || ~isfield(argv,'sp')
            error('When requesting parallel_simulator_shifted_x_difference, you must supply fields tau (allowed time difference) and sp (sampling period) to the argv');
        end
        if argv.sp <= 0
            error('The sampling period s must be positive');
        end
        if argv.tau < 0
            error('The allowed time difference tau must be non-negative')
        end
        if isfield(argv,'filler')
            combined_system.simulator = @(system,h0,u0,simtime,input_bounds, nb_control_pnts) parallel_simulator_shifted_x_difference(system,h0,u0,simtime,input_bounds, nb_control_pnts,argv.tau, argv.sp, argv.filler);
        else
            combined_system.simulator = @(system,h0,u0,simtime,input_bounds, nb_control_pnts) parallel_simulator_shifted_x_difference(system,h0,u0,simtime,input_bounds, nb_control_pnts,argv.tau, argv.sp);
        end
    case 'relative_error'
        if isfield(argv,'filler')
            combined_system.simulator = @(system,h0,u0,simtime,input_bounds, nb_control_pnts)       parallel_simulator_relative_error(system,h0,u0,simtime,input_bounds, nb_control_pnts,argv.tau, argv.sp, argv.filler);
        else
            combined_system.simulator = @(system,h0,u0,simtime,input_bounds, nb_control_pnts)       parallel_simulator_relative_error(system,h0,u0,simtime,input_bounds, nb_control_pnts,argv.tau, argv.sp);
        end
    otherwise
        error(['[conf_create_combined_parallel_system] Invalid simulator_output argument: ', simulator_output,'.']);
end

    % rc
    function rc = setrc(rcm,rci)
        % See output 'us' of hasimulator for some rationale
        if rcm == -3 || rci == -3
            rc = -3;
        elseif rcm ==- 2 || rci == -2
            rc = -2;
        elseif rcm == -1 || rci == -1
            rc = -1;
        elseif rcm < 0 
            rc = rcm;
        elseif rci < 0
            rc = rci;
        else            
            % positive values could mean anything, so we can't assign
            % priorities. Just say 'simulation passed'
            rc = 0;
        end
    end

    function C = rowWiseNorm(A)
        % C(i) = norm of ith row of A
        n = size(A,1);
        C = zeros(n,1);
        for r=1:n
            C(r) = norm(A(r,:));
        end
    end

    % chronometers
    function [chronometers, locHis, rc] = parallel_simulator_chronometers(system,h0,simtime,solver,opts)
    % The output trajectory consists of 2+nbloc 'chronometers', where nbloc
    % is the number of locations in the hybrid automaton being simulated.
    % A chronometer measures the time spent by one system in the location
    % before the other system also enters that locations. Thus it gives the
    % time dealy between the two systems in entering the location.
    % It doesn't make a difference which system entered a given location
    % first, Model or Implementation.
    % The 2 additional entries are for location history (which is filled
    % wiht NaNs in this case since it's meaningless) and the time instants.
    
        [phs, ~, rcp] = parallel_simulator(system,h0,simtime,solver,opts);
        rc = rcp;
        hs1 = phs.model;
        hs2 = phs.implementation;
        b1 = behavior(hs1);
        b2 = behavior(hs2);
        en1 = b1.entry_events;
        en2 = b2.entry_events;
        t0 = min([en1(:,1);en2(:,1)]);
        tf = max([en1(:,1);en2(:,1)]);
        N = 50*max([size(hs1,1), size(hs2,1)]); % finer grid for chronometers
        t = linspace(t0,tf,N);
        nbloc = length(system.model.loc);
        chronometers = zeros(N,2+nbloc);
        chronometers(:,1) = NaN; % phony location, should never be used
        locHis = chronometers(:,1);
        chronometers(:,2) = t';
        
        for loc = 1:nbloc
            % Get entry times into loc for both systems
            a1 = find(en1(:,2) == loc); t1 = en1(a1,1); %#ok<*FNDSB>
            a2 = find(en2(:,2) == loc); t2 = en2(a2,1);
            %Order the entry times (while keeping track of Model and Imp
            %via the sorting index)
            [sortedT, ixSortedT] = sort([t1;t2]);
            sys1_below_me = length(t1);
            st = sortedT; ixSt = ixSortedT;
            % Scan (ordered) times from the left to the right
            i = 1;
            while ~isempty(st)
                % Start chronomoeter at first time encountered (whether model or Imp) unless the other system is already in that location
                %    (slope 1 if model, slope -1 if Imp)
                if ixSt(i) <= sys1_below_me
                    first_sys_in = 1;
                    ff = find(hs2(:,2) <= st(i));
                    lother = hs2(ff(end),1);
                else
                    first_sys_in = 2;
                    ff = find(hs1(:,2) <= st(i));
                    lother = hs1(ff(end),1);
                end
                if lother == loc
                    % if other system is already here, skip this entry time
                    st = [st(1:i-1) st(i+1:end)];
                    ixSt = [ixSt(1:i-1) ixSt(i+1:end)];
                    continue;
                end
                j = i+1;
                noj = 0; % set to 1 if no match is found in other system
                %    get first entry time of other system
                while j <= length(st) && (ixSt(j)<= sys1_below_me && first_sys_in == 1 || ixSt(j)> sys1_below_me && first_sys_in == 2 )
                    j = j+1;
                end
                if j > length(st)  %other sys never entered loc
                    noj = 1;
                    stoptime = tf;
                else
                    stoptime = st(j);
                end
                %     create chrono slope
                dt = stoptime - st(i);
                %     (a minimum of 1 pnt for the slope)
                nbticks = max([(N*dt)/(tf-t0), 1]);
                c = linspace(0,dt,nbticks);
                if first_sys_in == 2
                    c = -c;
                end
                %    find where to fit this slope in the chronometer. Where
                %    it fits is a question because chronometers was
                %    created with linspace, so it might not have an entry
                %    exactly equal to st(i). So must find next best value.
                %    note that this approximation is OK,
                %    so long as the y-values st(j) and st(i) are preserved,
                %    which they are.
                if ~(length(c)== 1 && c == 0)
                    a = find(t <= st(i));
                    % sanity check
                    if a(end)+length(c) > size(chronometers,1)
                        rc = -3;
                        error('Chronometer slope too long...')
                    end
                    chronometers(a(end):a(end)+length(c)-1, 2+loc) = c;
                end
                % Remove matched pair from list of ordered times
                st = [st(1:i-1) st(i+1:end)];
                ixSt = [ixSt(1:i-1) ixSt(i+1:end)];
                if ~noj
                    st = [st(1:j-1) st(j+1:end)];
                    ixSt = [ixSt(1:j-1) ixSt(j+1:end)];
                end
                
                
            end
            
        end % for loc
        
    end

    % parallel
    function [hs, locHis, rc] = parallel_simulator(system,h0,simtime,solver,opts)
        % OUTPUTS
        %   hs.model: hybrid trajectory generated by system.model
        %   hs.implementation: hybrid trajectory generated by
        %       system.implementation
        Model = system.model;
        Implementation = system.implementation;
        [hsm, ~, rcm] = hasimulator(Model, h0, simtime,solver,opts);
        [hsi, ~, rci] = hasimulator(Implementation, h0, simtime,solver,opts);
        hs.model = hsm;
        hs.implementation = hsi;
        rc = setrc(rcm,rci);
        locHis = [hsm(:,1), hsi(:,1)];
    end

    % synchronous parallel
    function [hs, locHis, rc] = synchronous_parallel_simulator(system,h0,simtime,solver,opts)
        % OUTPUTS
        % hs: nb of rows = nb of implementation trajectory time stamps
        %     column 1: time stamps
        %     columns 2,3: locations of model and implementation, resp.
        %     columns 4:end : continuous traj of model and impl, resp.
        % The Model trajecotry is interpolated at the timestamps if needed.
        Model = system.model;
        Implementation = system.implementation;
        [hsm, ~, rcm] = hasimulator(Model, h0, simtime,solver,opts);
        [hsi, ~, rci] = hasimulator(Implementation, h0, simtime,solver,opts);
        implTimeStamps = hsi(:,2);
        temp =  interpolate_at_timestamps(implTimeStamps, hsm);
        
        hs = zeros(length(implTimeStamps), 2*size(hsi,2));
        hs(:,1) = implTimeStamps;
        hs(:,2:3) = [temp(:,1) hsi(:,1)];
        locHis = hs(:,2:3);
        hs(:,4:end) = [temp(3:end) hsi(3:end)];
        rc = setrc(rcm,rci);
    end

    % loc difference
    function [hs, locHis, rc] = parallel_simulator_location_difference(system,h0,UPoint, simtime, inputBounds, nbControlPoints)
%     function [hs, locHis, rc] = parallel_simulator_location_difference(system,h0,simtime,solver,opts)
        % hs = trajectory of interconnection = difference in locations
        % locHis = vector of NaN, kept for interface compatibility but
        % shouldn't be used
        % rc = return code of hasimulator for the Implementation
        % trajectory. We are interested in it to check Zeno-ness.
        global staliro_opt;
        Model = system.model;
        Implementation = system.implementation;
        if ~isempty(UPoint) || ~isempty(nbControlPoints)
            error('UPoint must be empty, this is an autonomous system')
        end
        [hsm, ~, rcm] = hasimulator(Model, h0, simtime, 'ode45', staliro_opt.hasim_params);
        [hsi, ~, rci] = hasimulator(Implementation, h0, simtime, 'ode45', staliro_opt.hasim_params);
        ts = hsi(:,2);
        inthsm = interpolate_at_timestamps(ts, hsm);
        hs = zeros(length(ts), 3);
        hs(:,1) = nan;  % the locations of parallel system shouldn't be used anywhere
        hs(:,2) = ts;
        hs(:,3) = inthsm(:,1)-hsi(:,1);
        locHis = hs(:,1);
        rc = setrc(rcm,rci);
        
    end

    %function [hs, locHis, rc] = parallel_simulator_shifted_x_difference(system,h0,simtime,solver,opts,tau,s)
    function [hs, locHis, rc, frXm] = parallel_simulator_shifted_x_difference(system,h0, u0, simtime, input_bounds, nb_control_pnts, tau,s, varargin)
        % Additonal INPUTS (other than standard ones listed in file help):
        % tau = tau of taueps-closeness formula. Needed to compute number of sample shifts = offset below        
        % s = sampling period of trajectories. Ignored if trajectories
        %   already have the same sampling period, as in a simulink models
        % filler = what value to use to fill the spaces left open by
        % shifting. Default = constant interpolation.
        % OUTPUTS
        % hs = trajectory of interconnection, defined as a the norm difference between Model traj and shifted Impl trajectories, 
        %   and the norm difference between Impl traj and time-shifted
        %   Model trajectories. See paper.
        % locHis = vector of NaN, kept for interface compatibility but
        %   shouldn't be used
        % rc = return code of hasimulator for the Implementation
        % trajectory. We are interested in it to check Zeno-ness.        
        % frXm = Model trajectory
        Model = system.model;
        Implementation = system.implementation;
        %[hsm, ~, rcm] = hasimulator(Model, h0, simtime,solver,opts);
        %[hsi, ~, rci] = hasimulator(Implementation, h0, simtime,solver,opts);
        stype = determine_model_type(Model);
        if strcmp(stype,'simulink')
            if size(h0,2) > 2
                init_cond = h0(3:end);
            else
                init_cond = [];
            end
        elseif strcmp(stype, 'hautomaon')
            init_cond = h0;
        end            
        if length(varargin) >= 1
            usefiller = 1;
            filler = varargin{1};
        else
            usefiller = 0;
        end
        [hsm, rcm] = systemsimulator(Model, init_cond, u0, simtime, input_bounds, nb_control_pnts);
        [hsi, rci] = systemsimulator(Implementation, init_cond, u0, simtime, input_bounds, nb_control_pnts);
        if ~isempty(hsm.YT)
            Xm = hsm.YT;
            Xi = hsi.YT;
        else
            Xm = hsm.XT;
            Xi = hsm.XT;
        end
        T = hsm.T;
        % Same legnth + same time stamps + fixed sampling period (approximately) 
        tempD = T(2:end)-T(1:end-1);
        if length(T) == length(hsi.T) && isempty(find(T-hsi.T, 1)) && max(tempD) - min(tempD) <= 100*eps
            realSP = T(2)-T(1);
            if realSP ~= s
                msg = 'The Model and Implementation trajectories have the same fixed sampling period.\n';
                msg = [msg, 'The user-specified sampling period for (tau,epsilon)-closeness is different from the true sampling period calculated from the simulation.\n'];     
                msg = [msg, 'User-specified = ', num2str(s),', calculated = ', num2str(realSP),'.\n'];
                if realSP > s
                    msg = [msg, 'The auxiliary signals construction is too permissive and includes too many past and future samples during which to return to within epsilon.\n'];
                else
                    msg = [msg, 'The auxiliary signals construction is too restrictive and includes too few past and future samples during which to return to within epsilon.\n'];
                end
                msg = [msg, 'Please re-run while specifying a sampling period taueps_samplingPeriod equal to real period = ',num2str(realSP)];
                error('simulation:SamplingPeriodMismatch',msg);
            end
            s = T(2) - T(1); % override input sampling period
            ts = T;
            frXm = Xm;
            frXi = Xi;
        else        
            % Trajectories don't have same time stamps -> interpolate to
            % create the TSS
            ts = (T(1) + 0:s:(T(end)-T(1)))';        
            frXm = interp1(T, Xm, ts, 'linear');
            frXi = interp1(hsi.T, Xi, ts, 'linear');                       
        end
        nbsamples = size(frXm,1);      
        o = floor(tau/s); % offset left = offset right = o
        
        % Detecting location changes
        if (usefiller)
            locThreshold = 0.5;
            [locModel, startEndRunModel] = detect_location_changes(frXm, size(frXm,2), locThreshold);
            [locImpl, startEndRunImpl]   = detect_location_changes(frXi, size(frXi,2), locThreshold);
            tt=max(size(startEndRunModel,1),size(startEndRunImpl,1));
            blockSizesModel = [startEndRunModel(:,2) - startEndRunModel(:,1)+1;
                -inf*ones(tt-size(startEndRunModel,1),1)];
            blockSizesImpl = [startEndRunImpl(:,2) - startEndRunImpl(:,1)+1;
                -inf*ones(tt-size(startEndRunImpl,1),1)];
            blockSizes = max(blockSizesModel, blockSizesImpl);
        end
        % Creating the output trajectory
        % 2 shifted auxiliaries per signal: one to the past and one to the
        % future. Plus 1 for instantaneous difference
        y = zeros(nbsamples,1+4*o);
        %     Instantaneous difference
        y(:,1) = rowWiseNorm(frXm-frXi);
        %     Shifted differences = auxiliary signals
        for q=1:o
            if (usefiller)                
                [auxModelPast, auxModelFuture] = shift_trajectories(frXm, blockSizes, filler, q, startEndRunModel );
                [auxImplPast, auxImplFuture]   = shift_trajectories(frXi, blockSizes, filler, q, startEndRunImpl );
                
            else
                % m_q = ||xm(t+ms)-xi||
                auxModelPast = [repmat(frXm(1,:),q,1);
                    frXm(1:nbsamples-q,:)];
                auxModelFuture = [frXm(q+1:end,:);
                    repmat(frXm(end,:),q,1)];
                auxImplPast = [repmat(frXi(1,:),q,1);
                    frXi(1:nbsamples-q,:)];
                auxImplFuture = [frXi(q+1:end,:);
                    repmat(frXi(end,:),q,1)];
            end
            
            
            % Positions in y array.
            % 1 is added to pos to account for y(:,1) created above
            pos  = 1 + o - (q-1);     % pastModel - Impl
            posf = pos+q + (q-1);     % futureModel - Impl
            y(:,pos)  = rowWiseNorm(auxModelPast-frXi);
            y(:,posf) = rowWiseNorm(auxModelFuture-frXi);
            ipos  = pos + 2*o;       % pastImpl - Model
            iposf = posf + 2*o;      % futureImpl - Model
            y(:,ipos)  = rowWiseNorm(auxImplPast - frXm);
            y(:,iposf) = rowWiseNorm(auxImplFuture - frXm);            
        end        
        hs = zeros(nbsamples, 2+size(y,2));
        hs(:,1) = nan;  % the locations of parallel system shouldn't be used anywhere
        hs(:,2) = ts;
        hs(:,3:end) = y;
        locHis = hs(:,1);
        rc = setrc(rcm,rci);
        
    end

    function [hs, locHis, rc] = parallel_simulator_relative_error(system,h0, u0, simtime, input_bounds, nb_control_pnts, tau,s, varargin)        
        % INPUTS
        % Same inputs as parallel_simulator_shifted_x_difference.
        % OUTPUTS
        % hs : Relative difference between system.implementation and
        % system.model trajectories, relative to the model's
        if length(varargin) >= 1
            [hs, ~, rc, Xm] = parallel_simulator_shifted_x_difference(system,h0, u0, simtime, input_bounds, nb_control_pnts, tau,s, varargin);
        else
            [hs, ~, rc, Xm] = parallel_simulator_shifted_x_difference(system,h0, u0, simtime, input_bounds, nb_control_pnts, tau,s);
        end
        hs(:,3:end) = hs(:,3:end)./repmat(rowWiseNorm(Xm),1,size(hs,2)-2);
        locHis = nan(size(hs,1),1);
        
    end


    function [hs, locHis, rc] = parallel_simulator_x_difference(system,h0,simtime,solver,opts)
        % hs = trajectory of interconnection = difference in continuous
        % states
        % locHis = vector of NaN, kept for interface compatibility but
        % shouldn't be used
        % rc = return code of hasimulator for the Implementation
        % trajectory. We are interested in it to check Zeno-ness.
        Model = system.model;
        Implementation = system.implementation;
        [hsm, ~, rcm] = hasimulator(Model, h0, simtime,solver,opts);
        [hsi, ~, rci] = hasimulator(Implementation, h0, simtime,solver,opts);
        ts = hsi(:,2);
        inthsm = interpolate_at_timestamps(ts, hsm);
        
        hs = zeros(length(ts), 3);
        hs(:,1) = nan;  % the locations of parallel system shouldn't be used anywhere
        hs(:,2) = ts;
        hs(:,3) = rowWiseNorm(inthsm(:,3:end)-hsi(:,3:end));        
        locHis = hs(:,1);
        rc = setrc(rcm,rci);
        
    end

    function [auxPast, auxFuture] = shift_trajectories(X, blockSizes, filler, q, startEndRun )
                
        auxPast = zeros(size(X));
        auxFuture = zeros(size(X));
        n = size(X,2);
        nBlocks = length(blockSizes);
        
        pastFillers = [X(1,:);
            filler*ones(nBlocks-1,n)];
        futureFillers = [filler*ones(nBlocks-1,n);
            X(end,:)];
        
        for blockNb=1:size(startEndRun,1)
            start = startEndRun(blockNb,1);
            finish = startEndRun(blockNb,2);
            blockLength = finish-start+1;
            
            block = [X(start:finish,:);
                     repmat(futureFillers(blockNb,:),blockSizes(blockNb)-blockLength,1)];
        
            auxPastBlock = [repmat(pastFillers(blockNb,:),q,1);
                block(1:end-q,:)];
            auxFutureBlock = [block(1+q:end,:);
                repmat(futureFillers(blockNb,:),q,1)];
            
            auxPast(start:blockSizes(blockNb),:) = auxPastBlock;
            auxFuture(start:blockSizes(blockNb),:) = auxFutureBlock;
        end
        
        % sanity check
        assert(size(auxPast,1) == size(X,1));
        assert(size(auxFuture,1) == size(X,1));
                    
    end

    function [locSequence, blockStartEnd] = detect_location_changes(X, ix, threshold)
        % Detect when a specific dimension of X goes above or below a
        % threshold, and report the indices of these changes
        locSequence = X(:,ix) >= threshold;
        blockStartEnd=[1 size(X,1)];
        block=1;        
        for ss=2:length(locSequence)
            if locSequence(ss) ~= locSequence(ss-1)
                blockStartEnd(block,2) = ss-1;
                blockStartEnd(block+1,1) = ss;
                block = block+1;
            end
        end
    end

    function interp_sequence= interpolate_at_timestamps(tref,seq)
        % INPUTS:
        %   seq: hybrid trajectory to be interpolated, one row per timestamp,
        %        2nd col' is the time column
        %   tref: col' vector of timestamps at which to interpolate seq
        % DESCRIPTION:
        % Because a variable step-size solver was used, we need to 'interpolate'
        % the trajectories
        % (ode5, in auxiliary/ directory, is a fixed step-size solver, but it
        % doesn't compute events. Maybe in a better world, I would make it compute
        % events, but this isn't that world)
        % The final trajectory has the timestamps of the Implementation. That's
        % because we want the Implementation to simulate the Model, i.e. every
        % behavior of the former has a close relative in the Model. Otherwise the
        % Implementation is doing whatever it wants.
        % Given these time stamps, for location interpolation, we use
        % 'most recent neighbor' interpolation: if seq(some_time)
        % doesn't exist, we use for its location seq(largest time step smaller than some_time,1).
        interp_sequence = zeros(length(tref), size(seq,2));
        tm = seq(:,2);
        interp_sequence(:,2) = tref;
        n = size(seq,2) - 2; % dimension of continuous space
        v = [3:3+n-1];
        for i=1:length(tref)
            ix=find(tm <= tref(i));
            interp_sequence(i,1) = seq(ix(end),1); % interpolate locations
            interp_sequence(i,v) = seq(ix(end),v); % interpolate continuous states
        end
        
    end

end