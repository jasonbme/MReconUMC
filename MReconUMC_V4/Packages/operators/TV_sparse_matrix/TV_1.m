function T = TV_1(N,M,Z,Nt,order)
% construct 1st or 2nd order difference operator for a N x M x Nt array along the
% third dimension. 
%
% The operator is stored as a sparse matrix T such that:
%
% order = 1: output has size N*M*(Nt-1)
% reshape(T*array,N,M,Nt-1) = diff(array,[],3);
% order = 2: output has size N*M*(Nt-2)
% reshape(T*array,N,M,Nt-2) = diff(array,2,3);

if nargin < 5
    order = 1; % default is 1st order
end

switch order
    case 1
        Dx = spdiags([-ones(N,1) ones(N,1)],[0 1],N,N);
        Dx(N,:) = [];
    case 2
        Dx = spdiags([-2*ones(N,1) ones(N,1) ones(N,1)],[0 1 -1],N,N);
        Dx([1,N],:) = [];
end
T = kron(speye(M*Z*Nt),Dx);