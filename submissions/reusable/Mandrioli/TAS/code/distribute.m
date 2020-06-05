% utility function for splitting a number of requests to different service
% providers according to a given probability vector
%
%INPUTS:
%   - probabilities = is a vector of discrete probabilities. They should 
%                     sum to one. His length is also used to define the
%                     number of services involved.
%   - number        = number of requests to be distributed among the
%                     different service providers. The output vector should
%                     sum to this number.
%OUTPUTS:
%   - out           = vector with the number of requests assigned to each
%                     service provider
%

function out = distribute(probabilities, number)
out=zeros(length(probabilities),1);
cs=cumsum(probabilities);
for i=1:number
    tmp= sum(rand>cs)+1;
    out(tmp)=out(tmp)+1;
end

end