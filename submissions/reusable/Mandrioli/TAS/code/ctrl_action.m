% function that distributes the received requests among the different
% services according to the provided weights

function assigned_requests = ctrl_action(incoming_requests,weights)
assigned_requests = distribute(weights./sum(weights),incoming_requests);
end