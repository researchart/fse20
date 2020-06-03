% funciton that decised whether the analyzed requests are of type drug or
% ambulance.

function [all_good, drug_requests, ambulance_requests]=pick_type_of_requests(num_requests,type_of_requests)

out=distribute(type_of_requests,num_requests);

all_good=out(1);
drug_requests=out(2);
ambulance_requests=out(3);

end

