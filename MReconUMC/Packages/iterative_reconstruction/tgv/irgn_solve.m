function  [us,nr] = irgn_solve(data,F,FT,params)
%IRGN_SOLVE     Iteratively regularized Gauss-Newton method.
%   US = IRGN_SOLVE(DATA,F,MAXIT) reconstructs subsampled PMRI data using
%   iteratively regularized Gauss-Newton with variational penalties.
%
%   Input
%    DATA:     3D array of coil images (in k-space)
%    F,FT:     subsampling Fourier transform operator, adjoint (handle)
%    PARAMS:   parameters for IRGN (structure, see code for contents
%
%   Output
%    US:       scaled reconstructed image

% July 2011,
% Christian Clason (christian.clason@uni-graz.at)

%% set up parameters and operators

alpha0    = params.alpha0;      % initial penalty alpha_0 (L2, sensitivites)
beta0     = params.beta0;       % initial penalty beta_0 (T(G)V, image)
qa        = params.alpha_q;		% reduction factor for alpha
qb        = params.beta_q;		% reduction factor for beta
alpha_min = params.alpha_min;	% final value of alpha
beta_min  = params.beta_min;	% final value of beta
maxit     = params.maxit;    	% maximum number of IRGN iterations

tvtype = params.tvtype;         % type of penalty for image (1=TV, 2=TGV)
tvits  = params.tvits;          % initial number of gradient steps
tvmax  = 1000;                  % upper bound on number of gradient steps

[ns,nl,nc] = size(data);
nx=params.N;

% centered FFT, IFFT: for preweighted sensitivities
cfft  = @(x) fftshift(fft2(fftshift(x)))./sqrt(ns.*nl);
cifft = @(x) fftshift(ifft2(fftshift(x))).*sqrt(ns.*nl);

% High frequency penalty (inverse) for sensitivities
[xi,eta] = meshgrid(linspace(-.5,.5,nx));
w    = (1+220*(xi.^2+eta.^2)).^(-8);
wbar = conj(w);
W    = @(x) cifft(w.*x);
WH   = @(x) wbar.*cfft(x);

% normalize data
dscale = 100/norm(abs(data(:)));
data = data * dscale;

%% Gauss-Newton iteration

% initial guess
u = ones(nx,nx); u0 = 0*u;
c = zeros(nx,nx,nc);

% preallocate arrays
cw  = zeros(nx,nx,nc);
res = zeros(ns,nl,nc);
nr  = zeros(maxit,1);

alpha = alpha0;
beta  = beta0;

for k = 1:maxit
    % apply inverse weight to sensitivity iterates
    for i = 1:nc
        cw(:,:,i) = W(c(:,:,i));
    end
    
    % precompute complex conjugates
    cwbar = conj(cw);
    ubar  = conj(u);
    
    % adjoint derivative
    DFH = @(x) applyDFH(FT,WH,cw,cwbar,ubar,x);
    
    % compute residual
    for i=1:nc
        %res(:,:,i) = F(u.*cw(:,:,i))-data(:,:,i);
        res(:,:,i) = cell2mat(F(u.*cw(:,:,i)))-data(:,:,i);
    end
    
    nr(k) = norm(res(:));
    fprintf('Iteration %d: alpha = %0.1e, beta = %0.1e, residual norm = %g\n',...
        k,alpha,beta,nr(k));
    
    % gradient: (F')^T(residual)
    rhs = DFH(res);
    
    % Hessian: F'^T*F'
    M = @(du,dc) applyM(F,FT,W,WH,cw,cwbar,u,ubar,du,dc);
    
    % solve using projected extragradient method
    switch tvtype
        case 0
            [du,dc] = l2solve(u,c,rhs,u0,M,tvits,alpha,beta);
        case 1
            [du,dc] = tvsolve(u,c,rhs,u0,M,tvits,alpha,beta);
        case 2
            [du,dc] = tgvsolve(u,c,rhs,u0,M,tvits,alpha,beta);
        otherwise
            error('Only tvtype = 0 (L2), 1 (TV) or 2 (TGV) are implemented.');
    end
    u  = u + du;
    c  = c + dc;
    
    % Visualize if verbose
    if params.verbose && k>1   
       if k==2;figure(211);close(211);hfig=figure(211);end
       vis(:,:,k-1)=abs(u)/max(abs(u(:)));
       scrsz=get(0,'ScreenSize');
       imshow3(vis,[],[1 size(vis,3)]);title(['Image estimate iter=',num2str(k-1)]);
       set(hfig,'position',scrsz);pause(.1);drawnow

    end
    
    % reduce parameter
    alpha = max(alpha_min, alpha * qa);
    beta  = max(beta_min, beta  * qb);
    tvits = min(tvmax, tvits * 2);
    
end

%% postprocess: multiply by SOS of sensitivities
cscale = 0;
for i = 1:nc
    cscale = cscale+abs(W(c(:,:,i))).^2;
end
cscale = sqrt(cscale);
us = dscale * u.*cscale;

% end main function

%% Derivative evaluation

function y = applyDFH(FH,WH,c,cconj,uconj,dx)
[nx,ny,nc] = size(c);

y   = zeros(nx,ny,nc+1);
tmp = zeros(nx,ny);
for i = 1:nc
    %fdy = FH(dx(:,:,i));
    fdy = cell2mat(FH(dx(:,:,i)));
    tmp = tmp + fdy.*cconj(:,:,i);
    y(:,:,i+1) = WH(fdy.*uconj);
end
y(:,:,1) = tmp;
% end function applyDFH

function [gu,gc] = applyM(F,FH,W,WH,c,cconj,u,uconj,du,dc)
[nx,ny,nc] = size(c);

gc = zeros(nx,ny,nc);
gu = zeros(nx,ny);
for i = 1:nc
    %fdy = FH(F(u.*W(dc(:,:,i)) + c(:,:,i).*du));
    fdy = cell2mat(FH(cell2mat(F(u.*W(dc(:,:,i)) + c(:,:,i).*du))));
    gu  = gu + fdy.*cconj(:,:,i);
    gc(:,:,i) = WH(fdy.*uconj);
end
% end function applyM
