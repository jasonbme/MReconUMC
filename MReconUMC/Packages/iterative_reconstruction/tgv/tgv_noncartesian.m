function [recon,res] = tgv_noncartesian(kdata,F,W,niter,N,vis)
% Faciliate easy call to TU Graz IRN-TGV reconstruction code for single 2D
% All credits go to Florian Knoll and Christian Clason
% I only made some minor modifications to their matlab package
%
% Some personal experiences:
%  - Anything less then 6 iterations does not give good results (the more
%  the better)
%
% Input:
%  - kdata is k-space data with [ns,nl,nc] matrix, type complex doubles
%  - F is the fourier operator
%  - W is the density operator (if not provided make ones)
%  - niter is number of iterations 
%
% Output:
%  - res is [X,Y] image
%
% t.bruijnen@umcutrecht.nl - version 2017-10-23

%% Check input
if numel(size(kdata))>3
    disp('Error in tgv_noncartesian.m, kdata has more then 3 dimensions. Breaking function ');return;end
    
% Reconstruction parameters
params.maxit     = niter;  % maximum number of IRGN iterations
params.tvtype    = 2;      % regularization term: 0: L2, 1: TV, 2: TGV
params.beta_min  = 5e-3;   % final value of beta: 0: no T(G)V effect, >0: effect
params.alpha0    = 1;      % initial penalty alpha_0 (L2, sensitivites)
params.beta0     = 2;      % initial penalty beta_0 (TV, image)
params.alpha_min = 0;      % final value of alpha
params.alpha_q   = 1/10;   % reduction factor for alpha
params.beta_q 	 = 1/10;   % reduction factor for beta
params.tvits     = 20;     % initial number of gradient steps
params.N         = N;      % Matris size image space
params.verbose   = vis;    % 1 or 0 to visualize iters
% Generate Fourier function handles (with or without dcf)
nft  = @(x) F*x;
if isempty(W)
    inft = @(x) F'*x;
else
    inft = @(x) F'*(W*x);
end

% Perform the reconstruction
[recon,res] = irgn_solve(kdata,nft,inft,params);

% END