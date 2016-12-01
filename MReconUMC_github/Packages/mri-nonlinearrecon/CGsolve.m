function [x,cn,NLR] = CGsolve(x0,NLR)
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
maxlsiter = 3 ;
gradToll = 1e-3 ;
NLR.l1Smooth = 1e-15;	
NLR.L1SSmooth = 1e-15;
alpha = 0.01;  
beta = NLR.beta;
t0 = 1 ; 
k = 0;

% compute g0  = grad(f(x))

% backtracking line-search	
lsiter = 0;
cn=0;
[f0,L20,L1T0] = objective(x,zeros(size(x)),0,NLR); 

[g0,NLR,L2grad,L1gradT] = grad(x,NLR);
maxX=max(abs(x(:)));
maxL1grad=max(abs(L1gradT(:)));
maxL2grad=max(abs(L2grad(:)));

if k==0 && NLR.adjustT==0 && NLR.lambdaT~=0
    NLR.lambdaT=NLR.lambdaT/(maxL1grad/maxL2grad);
    NLR.adjustT=1;
    f0=L1T0*NLR.lambdaT+L20;
    g0=L2grad+NLR.lambdaT*L1gradT;
end

cn=cn+3;
dx = -g0;
fprintf('Ite=%d, nls=%d, C=%8.2E, CL2=%8.2E, CL1T=%8.2E, maxX=%8.2E, GL2=%8.2E, GL1=%8.2E\n',k,lsiter,f0,L20,NLR.lambdaT*L1T0,maxX,maxL2grad,maxL1grad*NLR.lambdaT)
while(1)
	lsiter = 0;
    if k==0;[f0,L20,L1T0] = objective(x,zeros(size(x)),0,NLR);cn=cn+1;else f0=f1;L1T0=L1T;L20=L2;end
	t = (0.1*t0*(abs(maxX(:))/abs(max(dx(:)))))/(NLR.n+1);
    [f1,L2,L1T] = objective(x,dx,t,NLR);cn=cn+1;
	while (f1 > f0 - alpha*t*abs(g0(:)'*dx(:)))^2 & (lsiter<maxlsiter)
		lsiter = lsiter + 1;
		t = t * beta;
		[f1,L2,L1T] = objective(x,dx,t,NLR);cn=cn+1;
	end

	if lsiter == maxlsiter
		disp('Reboot algorithm ...');
		break;
	end

	% control the number of line searches by adapting the initial step search
	if lsiter > 2, t0 = t0 * beta;end 
	if lsiter<1, t0 = t0 / beta; end

    % update x
	x = (x + t*dx);

    %conjugate gradient calculation
	[g1,NLR,L2grad,L1gradT] = grad(x,NLR);cn=cn+2;
    
    % Get max val in x to compare gradient with
    maxX=max(abs(x(:)));
    maxL1grad=max(abs(L1gradT(:)));
    maxL2grad=max(abs(L2grad(:)));
    
    % print some numbers
    fprintf('Ite=%d, nls=%d, C=%8.2E, CL2=%8.2E, CL1T=%8.2E, maxX=%8.2E, GL2=%8.2E, GL1=%8.2E\n',k+1,lsiter,f1,L2,NLR.lambdaT*L1T,maxX,maxL2grad,maxL1grad*NLR.lambdaT)
    
	%bk = g1(:)'*g1(:)/(g0(:)'*g0(:)+eps);
    yk=g1-g0;
    bk=abs((permute(yk(:)-2*dx(:)*((yk(:)'*yk(:))/(dx(:)'*yk(:))),[2 1 3]))*(g1(:)/(dx(:)'*yk(:)))); % New GC update step
	g0 = g1;
	dx =  - g1 + bk* dx;
	k = k + 1;

	% Save cost on every iteration
	%cost=[cost [k L2 L1T*NLR.lambdaT]];
	
	% stopping criteria (to be improved)
	if ((k > NLR.nite) || ((abs(f1-f0) <= NLR.stopcrit*f0) && abs(L2-L20)<= NLR.stopcrit*L20 &&  abs(L1T-L1T0)<= NLR.stopcrit*L1T0))
   	%if (k > NLR.nite) || (norm(dx(:)) < gradToll), 
        if k<1
            NLR.quit=1;
        end
        NLR.stopcrit=NLR.stopcrit/2;
        break;
    end


end

return;
end

function [res,L2Obj,L1TObj] = objective(x,dx,t,NLR) 

% L2 norm part
w=NLR.W*(NLR.NUFFT*(NLR.S'*(x+t*dx)))-NLR.y;
L2Obj=w(:)'*w(:);

 % L1-norm part
if NLR.lambdaT
    w = NLR.TVT*(x+t*dx);
    L1TObj = sum((conj(w(:)).*w(:)+NLR.l1Smooth).^(1/2));
else
    L1TObj=0;
end

% objective function
res=L2Obj+NLR.lambdaT*L1TObj;
end

function [g,NLR,L2Grad,L1GradT] = grad(x,NLR)

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

end


