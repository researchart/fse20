% function that implements the adaptation algorithm for the choice of the
% providers for the different services

function new_controller_state=adaptation(success ,fail ,controller_state, gain, advanced)

%% if advanced controller enabled reset the weight to one
if advanced
    for iii=1:length(success)     
        if success(iii)==0 && fail(iii)>0 %attempt to recognize very weak providers and down providers
            new_controller_state(iii)=1;
        else
            new_controller_state(iii)=controller_state(iii)+gain*success(iii)-gain*fail(iii);
        end
    end    
end

%% control action computation
new_controller_state=controller_state+gain*success-gain*fail;

%% saturation
new_controller_state=min(max(new_controller_state,1),1000); 

end
