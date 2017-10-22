function [du,dc] = tgvsolve(u,c,rhs,u0,M,maxits,alpha,beta)
%TGVSOLVE    Solve quadratic TGV-constrained IRGN-subproblem.
%   [DU,DC] = TGVSOLVE(U,C,RHS,U0,M,MAXITS,ALPHA,BETA) computes the updates
%   DU, DC for image and coil sensitivities in the IRGN method for given
%   iterates U,C, gradient RHS, initial guess U0, linear operator M with
%   MAXITS iterations and L2 penalty ALPHA for the sensitivities and TGV
%   penalty BETA for the image.
 
% July 2011,
% Christian Clason (christian.clason@uni-graz.at)
% Kristian Bredies (kristian.bredies@uni-graz.at)

[n,m,nc] = size(c);

gamma  = 2*beta;   % weight of symmetrized gradient
proj   = @(x1,x2) max(1,sqrt(x1.^2+x2.^2)/beta);  % projection on C_beta
proj2  = @(x1,x2,x3) max(1,sqrt(x1.^2+x2.^2+2*x3.^2)/gamma); % on C^2_gamma
dx     = @(x) [diff(x,1,2), x(:,1)-x(:,m)];       % discrete x-derivative
dy     = @(x) [diff(x,1,1); x(1,:)-x(n,:)];       % discrete y-derivative
dxt    = @(x) [x(:,m)-x(:,1), -diff(x,1,2)];      % transpose x-derivative
dyt    = @(x) [x(n,:)-x(1,:); -diff(x,1,1)];      % transpose y-derivative

% estimate operator norm using power iteration
x1  = rand(n,m); x2 = rand(n,m,nc);
[y1,y2] = M(x1,x2);
for i=1:10
    if norm(y1(:))~=0
        x1 = y1./norm(y1(:));
    else
        x1 = y1;
    end
    x2 = y2./norm(y2(:));
    [y1,y2] = M(x1,x2);
    l1 = y1(:)'*x1(:);
    l2 = y2(:)'*x2(:);
end
L = 2*max(abs(l1),abs(l2)); % Lipschitz constant estimate

sigma  = 1/sqrt(12+L);    % dual step size
tau    = 1/sqrt(12+L);    % primal step size

rhsu = rhs(:,:,1);
rhsc = rhs(:,:,2:end);

% initialize iterates p=(p1,p2), q=(q1,q2,q3); du, dc, v1, v2
p1 = zeros(n,m);
p2 = zeros(n,m);
q1 = zeros(n,m);
q2 = zeros(n,m);
q3 = zeros(n,m);

du = zeros(n,m);
dc = zeros(n,m,nc);
v1 = zeros(n,m);
v2 = zeros(n,m);

% initialize leading points  \bar du, \bar dc; \bar v = (vb1,vb2)
ub  = du; cb = dc;
vb1 = v1; vb2 = v2;

for iter = 1:maxits
    
    % update dual (p): (eta1,eta2) = nabla(u+du-u0)-v,
    ukp = ub + u - u0;
    eta1 = dx(ukp) - vb1;
    eta2 = dy(ukp) - vb2;
    y1 = p1 + sigma * eta1;
    y2 = p2 + sigma * eta2;
    my = proj(y1,y2);
    p1 = y1./my;
    p2 = y2./my;
    
    % update dual (q): (zeta1,zeta2,zeta3) = E(v); v: (zeta4,zeta5) = -p - div q
    zeta1 = dx(vb1);
    zeta2 = dy(vb2);
    zeta3 = (dy(vb1) + dx(vb2))/2;
    z1 = q1 + sigma * zeta1;
    z2 = q2 + sigma * zeta2;
    z3 = q3 + sigma * zeta3;
    mz = proj2(z1,z2,z3);
    q1 = z1./mz;
    q2 = z2./mz;
    q3 = z3./mz;
    
    % update primal (du,dc): F'*F du  + F(u) - div(p)
    [Mu,Mc] = M(ub,cb);
    eta3 = Mu + rhsu + dxt(p1)+dyt(p2); % primal variable: image
    eta4 = Mc + rhsc + alpha*(c+cb);    % primal variable: coils
    uold = du;
    cold = dc;
    du   = du - tau * eta3;
    dc   = dc - tau * eta4;
    
    % update primal (v): (zeta4,zeta5) = -p - div q
    zeta4 = dxt(q1) + dyt(q3) - p1;
    zeta5 = dxt(q3) + dyt(q2) - p2;
    v1old = v1;
    v2old = v2;
    v1 = v1 - tau * zeta4;
    v2 = v2 - tau * zeta5;
    
    % update primal leading points
    ub   = 2*du - uold;
    cb   = 2*dc - cold;
    vb1 = 2*v1 - v1old;
    vb2 = 2*v2 - v2old;
    
end

