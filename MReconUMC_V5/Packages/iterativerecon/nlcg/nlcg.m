function [x,cost] = nlcg(x0,params)
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
x=cell2mat(x0);
clear x0 % saves memory

% line search parameters
maxlsiter=3;
gradToll=1e-8;
alpha=0.01;  
beta=params.Beta;
t0=1 ; 
k=0;
cost=[];

% Verbose
if params.Verbose;
    figure(211);close(211);figure(211);subplot(221);
    imshow(abs(x(:,:,round(size(x,3)/2),1,1,1,1,1,1,1,1,1)),[]);title('Gridding recon')
    %pause();
end
    
% compute g0  = grad(f(x))
g0 = grad(x,params);
dx = -g0;

while(1)
    
    % backtracking line-search
	lsiter=0;
    t=t0;
    f0=objective(x,dx,0,params);
    [f1,l1,l2] = objective(x,dx,t,params);

	while (f1 > f0 - alpha*t*abs(g0(:)'*dx(:)))^2 & (lsiter<maxlsiter)
		lsiter=lsiter + 1;
		t=t*beta;
		[f1,l1,l2]=objective(x,dx,t,params);
	end

% 	if lsiter == maxlsiter
% 		disp('Reboot algorithm ...');
% 		break;
% 	end

	% control the number of line searches by adapting the initial step search
	if lsiter > 2, t0 = t0 * beta;end 
	if lsiter<1, t0 = t0 / beta; end

    % update x
	x=(x+t*dx);

    % Report cost function
    cost(:,k+1)=[f1;l1;l2]; 
    fprintf('Iter=%d | Cost=%6.1e | L1=%6.1e | L2=%6.1e | nrls=%d\n',k,f1,l1,l2,lsiter);    
    
    % Verbose
    if params.Verbose
        subplot(222);imshow(abs(x(:,:,round(size(x,3)/2),1,1,1,1,1,1,1,1)),[]);title(['Iteration: ',num2str(k)]), drawnow;
        %subplot(223);scatter(k+1,cost(1,k+1)/cost(1,1),'k');hold all;scatter(k+1,cost(2,k+1)/cost(2,1),'b');scatter(k+1,cost(3,k+1)/cost(3,1),'r');[h, ~] = legend('show');title('Convergence rate');box on;grid on;set(gca,'LineWidth',3,'FontSize',12), drawnow;
        subplot(223);semilogy(1:k+1,cost(1,:),'k');hold all;semilogy(1:k+1,cost(2,:),'b');semilogy(1:k+1,cost(3,:),'r');
        title('Cost function convergence');legend('L1+L2','L1','L2');box on;grid on;set(gca,'LineWidth',3,'FontSize',12), drawnow;
        subplot(224);imshow(abs(dx(:,:,round(size(x,3)/2),1,1,1,1,1,1,1,1)),[]);title(['Gradient: ',num2str(k)]), drawnow;


    end

    % stopping criteria (to be improved)
    k = k + 1;
	if (k > params.N_iter) || (norm(dx(:)) < gradToll), break; end
    
    %conjugate gradient calculation
	g1=grad(x,params);
	bk = g1(:)'*g1(:)/(g0(:)'*g0(:)+eps);
    %yk=g1-g0;
    %bk=abs((permute(yk(:)-2*dx(:)*((yk(:)'*yk(:))/(dx(:)'*yk(:))),[2 1 3]))*(g1(:)/(dx(:)'*yk(:)))); % New GC update step
	g0 = g1;
	dx =  - g1 + bk* dx;

end

return;
end

function [res,L1obj,L2obj] = objective(x,dx,t,params) 

% L2 norm part
w=cell2mat(params.W*(params.N*(params.S'*(x+t*dx))))-params.y;
L2obj=w(:)'*w(:);

 % TV part or tikhonov part
l1smooth=1e-15;
w=reshape(params.TV*(matrix_to_vec(x+t*dx)),[params.Id(1:3) 1 params.Id(5:end)]);
TVobj=sum((conj(w(:)).*w(:)+l1smooth).^(1/2));

% Wavelet part
if ~isempty(params.Wavelet)
    l1smooth=1e-15;
    w=params.Wavelet*(x+t*dx);
    Wobj=sum((conj(w(:)).*w(:)+l1smooth).^(1/2));
else
    Wobj=0;
end

% objective function
L1obj=TVobj+params.Wavelet_lambda*Wobj; % TV lambda is already in the matrix T
res=L2obj+L1obj;

end

function g = grad(x,params)

% L2-norm part
L2Grad = 2.*cell2mat(params.S*(params.N'*(params.W*(cell2mat(params.W*(params.N*(params.S'*x)))-params.y))));

% TV part
l1smooth=1e-15;
w = reshape(params.TV*x(:),[params.Id(1:3) 1 params.Id(5:end)]);
TVGrad = reshape(params.TV'*(matrix_to_vec(w.*(w.*conj(w)+l1smooth).^(-0.5))),[params.Id(1:3) 1 params.Id(5:end)]);

% Wavelet part
if ~isempty(params.Wavelet)
    l1smooth=1e-15;
    w=params.Wavelet*x;
    WGrad=params.Wavelet'*(w.*(w.*conj(w)+l1smooth).^(-0.5));
else
    WGrad=0;
end

% composite gradient
g=L2Grad+TVGrad+params.Wavelet_lambda*WGrad;

end


