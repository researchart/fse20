function [transition_okay, options] = transition_check(options, old_cost,new_cost)
%transition_check Check if we can take the transition.

if new_cost < old_cost
    transition_okay = true;
else
    p = exp(-(new_cost-old_cost)/(options.K*options.T));
    if rand() < p
        options.T = options.T/options.alpha;
        options.nFail = 0;
        transition_okay = true;
    else
        if options.nFail > options.nFail_max
            options.T = options.T * options.alpha;
            options.nFail = 0;
        else
            options.nFail = options.nFail + 1;
        end
        transition_okay = false;
    end
end

end
