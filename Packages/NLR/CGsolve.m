function [x,f1,NLR] = CGsolve(x0,NLR)
% 
% 20160615 - Non linear conjugate gradient solver, based on Ricardo Ortazos
% code. I made modifications on the setting of lambda, i.e. expressed
% lambda is a ratio between L1 & L2. Changed the CG update parameter (bk),
% according to considerations in : Hager, W. W., & Zhang, H. (2006). 
% A Survey of Nonlinear Conjugate Gradient Methods. Stopping criteria are
% now set to equal < 5 % change in L1 && L2 && L1+L2 in cost function. The
% function is compatible with both fessler/greengard gridders.
%
% Given the acquisition model y = E*x, and the sparsifying transform W, 
% the pogram finds the x that minimizes the following objective function:
%
% f(x) = ||E*x - y||^2 + lambda * ||W*x||_1 
%

% starting point
x=x0;

% line search parameters
maxlsiter = 25 ;
gradToll = 1e-3 ;
NLR.l1Smooth = 1e-15;	
alpha = 0.01;  
beta = NLR.beta;
t0 = 1 ; 
k = 0;

% compute g0  = grad(f(x))
g0 = grad(x,NLR);
dx = -g0;

% iterations

while(1)

    % backtracking line-search
    [f0,a0,b0] = objective(x,dx,0,NLR);
    if k==0 && NLR.adjust==0 && NLR.lambda~=0
        NLR.lambda=NLR.lambda/(b0/a0);
        NLR.adjust=1;
        [f0,a0,b0] = objective(x,dx,0,NLR);
        g0 = grad(x,NLR);
        dx = -g0;
        fprintf('\n Iteration=%d, Cost=%.2f, L2=%.2f, L1=%.2f \n',k,f0,a0,b0*NLR.lambda);
    end
    
    if k==0
        f1_prev=[a0,b0];
    else
        f1_prev=[a,b];
    end
    
	t = t0;

    [f1,a,b] = objective(x,dx,t,NLR);
	lsiter = 0;
	while (f1 > f0 - alpha*t*abs(g0(:)'*dx(:)))^2 & (lsiter<maxlsiter)
		lsiter = lsiter + 1;
		t = t * beta;
		[f1,a,b] = objective(x,dx,t,NLR);
	end

	if lsiter == maxlsiter
		disp('Error - line search ...');
		return;
	end

	% control the number of line searches by adapting the initial step search
	if lsiter > 2, t0 = t0 * beta;end 
	if lsiter<1, t0 = t0 / beta; end

    % update x
	x = (x + t*dx);
    
	% print some numbers	
    fprintf('Iteration=%d, NumLineSearch=%d, Cost=%.2f, L2=%.2f, L1=%.2f \n',k,lsiter,f1,a,b*NLR.lambda);
    
    %conjugate gradient calculation
	g1 = grad(x,NLR);
	%bk = g1(:)'*g1(:)/(g0(:)'*g0(:)+eps);
    yk=g1-g0;
    bk=abs((permute(yk(:)-2*dx(:)*((yk(:)'*yk(:))/(dx(:)'*yk(:))),[2 1 3]))*(g1(:)/(dx(:)'*yk(:)))); % New GC update step
	g0 = g1;
	dx =  - g1 + bk* dx;
	k = k + 1;
	
	% stopping criteria (to be improved)
	if (k > NLR.nite) || ((abs(f1_prev(2)-b) <= 0.05*f1_prev(2)) && (abs(f1_prev(1)-a) <= 0.05*f1_prev(1))), break;end

end
return;

function [res,L2Obj,L1Obj] = objective(x,dx,t,NLR) %**********************************
switch NLR.gridder
    case 'fessler'
        % L2-norm part
        w=NLR.NUFFT*(x+t*dx)-NLR.y;
        L2Obj=w(:)'*w(:);
        
        % L1-norm part
        if NLR.lambda
            w = NLR.TV*(x+t*dx);
            L1Obj = sum((conj(w(:)).*w(:)+NLR.l1Smooth).^(1/2));
        else
            L1Obj=0;
        end
    case 'greengard'
        w=(NLR.W*(NLR.NUFFT*(NLR.S'*(x+t*dx))))-NLR.y;
        L2Obj=w(:)'*w(:);
        
         % L1-norm part
        if NLR.lambda
            w = NLR.TV*(x+t*dx);
            L1Obj = sum((conj(w(:)).*w(:)+NLR.l1Smooth).^(1/2));
        else
            L1Obj=0;
        end
end

% objective function
res=L2Obj+NLR.lambda*L1Obj;

function g = grad(x,NLR)%***********************************************
switch NLR.gridder
    case 'fessler'
        % L2-norm part
        L2Grad = 2.*(NLR.NUFFT'*(NLR.NUFFT*x-NLR.y));
        
        % L1-norm part
        if NLR.lambda
            w = NLR.TV*x;
            L1Grad = NLR.TV'*(w.*(w.*conj(w)+NLR.l1Smooth).^(-0.5));
        else
            L1Grad=0;
        end
    case 'greengard'
        % L2-norm part
        L2Grad = 2*(NLR.S*(NLR.NUFFT'*(NLR.W*(NLR.W*(NLR.NUFFT*(NLR.S'*x))-NLR.y))));
        
        % L1-norm part
        if NLR.lambda
            w = NLR.TV*x;
            L1Grad = NLR.TV'*(w.*(w.*conj(w)+NLR.l1Smooth).^(-0.5));
        else
            L1Grad=0;
        end
end

% composite gradient
g=L2Grad+NLR.lambda*L1Grad;

