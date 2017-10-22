function [res,cost] = configure_tgv(params)
% Configures the structure to send to the tgv code

% Total generalized variation
[res,cost]=tgv_noncartesian(params.y,params.N,params.W,params.Niter);

% Append resvec if it converges reached prior to N_iter
cost=cost(1,:);if size(cost,1)<params.Niter;cost(end+1:params.Niter)=0;end

% END
end