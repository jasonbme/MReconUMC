function [x,cost] = CGsolve(x0,NLR)
% 
% 20160615 - Non linear conjugate gradient solver, based on Ricardo Ortazos
% code. I made modifications on the setting of lambda, i.e. expressed
% lambda is a ratio between the L1 & L2 gradient. Changed the CG update parameter (bk),
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
clear x0

% line search parameters
maxlsiter = 15 ;
gradToll = 1e-3 ;
NLR.l1Smooth = 1e-15;	
NLR.L1SSmooth = 1e-15;
alpha = 0.01;  
beta = NLR.beta;
t0 = 1 ; 
k = 0;
cost=[];

% compute g0  = grad(f(x))
%[g0, NLR] = grad(x,NLR);
%dx = -g0;

% iterations

while(1)

    % backtracking line-search
    [f0,L20,L1T0] = objective(x,zeros(size(x)),0,NLR);    
    if k==0 && NLR.adjustT==0 && NLR.lambdaT~=0
        NLR.lambdaT=NLR.lambdaT/(L1T0/L20);
        NLR.adjustT=1;
        f0=L20+NLR.lambdaT*L1T0;
        g0=grad(x,NLR);
        dx=-g0;
    end
	t = t0;

    [f1,L2,L1T] = objective(x,dx,t,NLR);
	lsiter = 0;
	while (f1 > f0 - alpha*t*abs(g0(:)'*dx(:)))^2 & (lsiter<maxlsiter)
		lsiter = lsiter + 1;
		t = t * beta;
		[f1,L2,L1T] = objective(x,dx,t,NLR);
        fprintf('lsiter=%d, f1=%8.2Ef, f0-blabla=%8.2E\n',lsiter,f1,f0 - alpha*t*abs(g0(:)'*dx(:)))
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
    fprintf('Iteration=%d, lsiter=%d, Cost=%.2f, L2=%.2f, L1T=%.5f\n',k,lsiter,f1,L2,NLR.lambdaT*l1)
    
    %conjugate gradient calculation
	g1 = grad(x,NLR);
	bk = g1(:)'*g1(:)/(g0(:)'*g0(:)+eps);
    %yk=g1-g0;
    %bk=abs((permute(yk(:)-2*dx(:)*((yk(:)'*yk(:))/(dx(:)'*yk(:))),[2 1 3]))*(g1(:)/(dx(:)'*yk(:)))); % New GC update step
	g0 = g1;
	dx =  - g1 + bk* dx;
	k = k + 1;
	
	% Save cost on every iteration
	cost=[cost [k;L2;L1T*NLR.lambdaT]];
	
	% stopping criteria (to be improved)
	if ((k > NLR.nite) || ((abs(f1-f0) <= 0.025*f0) && abs(L2-L20)<= 0.025*L20 &&  abs(L1T-L1T0)<= 0.025*L1T0))
   	%if (k > NLR.nite) || (norm(dx(:)) < gradToll), 
        
        break;
    end


end

return;

function [res,L2Obj,L1TObj] = objective(x,dx,t,NLR) %**********************************

% L2 norm part
w=NLR.W*(NLR.NUFFT*(NLR.S'*(x+t*dx)))-NLR.y;
L2Obj=w(:)'*w(:);

 % L1-norm part
if NLR.lambdaT
    w = NLR.TVT*(x+t*dx);
    L1TObj = sum((conj(w(:)).*w(:)+NLR.l1Smooth)).^(1/2);
else
    L1TObj=0;
end

% objective function
res=L2Obj+NLR.lambdaT*L1TObj;

function [g, NLR] = grad(x,NLR)%***********************************************

% L2-norm part
L2Grad = 2.*(NLR.S*(NLR.NUFFT'*(NLR.W*(NLR.W*(NLR.NUFFT*(NLR.S'*x))-NLR.y))));

% L1-norm part
if NLR.lambdaT
    w = NLR.TVT*x;
    L1GradT = NLR.TVT'*(w.*(w.*conj(w)+NLR.l1Smooth).^(-0.5));
else
    L1GradT=0;
    NLR.lambdaT=0;
end

% composite gradient
g=L2Grad+NLR.lambdaT*L1GradT;

