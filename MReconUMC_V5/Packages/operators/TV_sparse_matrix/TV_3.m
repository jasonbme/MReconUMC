function T = TV_3(dims,order)
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

N=dims(1);
M=dims(2);
Z=dims(3);
Nt=dims(5);

switch order
    case 1
        Dz = spdiags([-ones(Z,1) ones(Z,1)],[0 1],Z,Z);
        Dz(Z,:) = 0;
    case 2
        Dz = spdiags([-2*ones(Z,1) ones(Z,1) ones(Z,1)],[0 1 -1],Z,Z);
        Dz([1,Z],:) = 0;
end
T = kron(speye(Nt),kron(Dz,speye(N*M)));