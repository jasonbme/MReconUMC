function T = TV_2(N,M,Z,Nt,order)
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
        Dx = spdiags([-ones(M,1) ones(M,1)],[0 1],M,M);
        Dx(M,:) = [];
    case 2
        Dx = spdiags([-2*ones(M,1) ones(M,1) ones(M,1)],[0 1 -1],M,M);
        Dx([1,M],:) = [];
end
T = kron(speye(Z*Nt),kron(Dx,speye(N)));