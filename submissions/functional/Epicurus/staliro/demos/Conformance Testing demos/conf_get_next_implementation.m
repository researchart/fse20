function [s, Implementation] = conf_get_next_implementation(argv, implAv, implBv)
% the implAv adn implBv couldn't be made part of the struct argv because
% they caused it to act crazy; namely every field in it got replicated n times, 
% where n is the number of elements in implAv. so we pass them separately.

A = argv.common_elts.A;
init = argv.common_elts.init;
horiz_shift = argv.variable_elts.horiz_shift;
verti_shift = argv.variable_elts.verti_shift;

nb_flow_changes = length(implAv);
nb_horiz_guard_changes = length(horiz_shift);
nb_verti_guard_changes = length(verti_shift);
nb_impls = nb_flow_changes + nb_horiz_guard_changes + nb_verti_guard_changes;

%% Special mode: get info
% get_info is a special function of this iterator, it does it only and
% returns. 
if isfield(argv, 'get_info')
    if strcmp(argv.get_info, 'nb_implementations')
        s = nb_impls;
        if nargout == 2
            Implementation = [];
        end
    end
    return;
end            

%% Regular mode: get next implementation
global nb_implementation_iterator_calls;
nb_implementation_iterator_calls = nb_implementation_iterator_calls + 1;

if nb_implementation_iterator_calls > nb_impls
    %     display('Resetting implementation iterator')
    %     nb_calls = 0;
    display('[conf_get_next_implementation] Exceeded iterator end');
    s = 0;
    Implementation = [];
    return;
end
s= 1;

% nb_implementation_iterator_calls
if nb_implementation_iterator_calls <= nb_flow_changes
    % Flow difference
    Implementation = navbench_hautomaton(0,init,A, [], implAv{nb_implementation_iterator_calls}, implBv{nb_implementation_iterator_calls});
elseif nb_implementation_iterator_calls <= nb_flow_changes + nb_horiz_guard_changes
    % horizontal guard difference
    h=horiz_shift(nb_implementation_iterator_calls-nb_flow_changes);
    Implementation = navbench_hautomaton(0,init,A);
    for i=1:12
        Implementation.guards(i,i+4).b = Implementation.guards(i,i+4).b + h;
    end
elseif nb_implementation_iterator_calls <= nb_flow_changes + nb_horiz_guard_changes + nb_verti_guard_changes
    % vertical guard difference
    v=verti_shift(nb_implementation_iterator_calls-nb_flow_changes - nb_horiz_guard_changes);
    Implementation = navbench_hautomaton(0,init,A);
    for i=[1:3 5:7 9:11 13:15]
        Implementation.guards(i,i+1).b = Implementation.guards(i,i+1).b + v;
    end
end




end