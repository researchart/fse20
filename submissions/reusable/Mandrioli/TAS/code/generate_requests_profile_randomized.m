%function to generate a partially randomized request profile.
% the idea is to have an underlying deterministic trend to ensure
% appropriate triggering of the adaptation strategy added to a randomized
% component that makes the tests different form one another

function requests_profile=generate_requests_profile_randomized()

one=40*ones(50,1)+floor((rand(50,1)-0.5)*30); %constant request arrival rate
two=linspace(50,200,11)'+floor((rand(11,1)-0.5)*40); %ramp input
three=3*ones(39,1)+floor((rand(39,1))*70);

requests_profile=[one; two; three];

%add zeros requests at the end for avoiding that requests are still in
%processing at the end of the simulation (needed for comparison consistency 
%between the different tests)
requests_profile=[requests_profile;zeros(50,1)];
end
