function tr = conf_evaluate_time_robustness_of_sample(phi, combined_system, h0, simtime, gs_opt, preds)


display(['Evaluating time robustness of guard seeking bestSample for formula:']);
disp(phi);
% Simulate Implementation with the result
if strcmp(gs_opt.ode_solver,'default')
    ode_solver = 'ode45';
else
    ode_solver = gs_opt.ode_solver;
end
[hs, ~, rc] = combined_system.simulator(combined_system, h0, simtime, ode_solver, gs_opt.hasim_params);
if rc.rci == -2 && rc.rcm ~= -2
    %If only Implementation traj is Zeno, then we have succeeded in
    %showing non-conformance under any reasonable criterion
    tr.pt = -100*simtime; tr.ft = -100*simtime;
elseif rc.rcm == -2
    % If Model traj is Zeno, conformance to it, it seems, is
    % not well defined, so it is assumed to hold. Arguable...
    tr.pt = 100*simtime; tr.ft = 100*simtime;
else
    tr = dp_t_taliro(phi, preds, hs(:,3:end), hs(:,2)); %#ok<*NOPTS>
end

end