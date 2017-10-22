function [res,cost] = configure_compressed_sensing(params)
%Configures the structure to send to the nonlinear conjugate gradient
%solver (nlcg).

% Nonlinear conjugate gradient
x0=params.S*(params.N'*(params.W*params.y));
[res,cost]=nlcg(x0,params);

% Append resvec if it converges reached prior to N_iter
cost=cost(1,:);
if size(cost,1)<params.Niter;cost(end+1:params.Niter)=0;end

% END
end