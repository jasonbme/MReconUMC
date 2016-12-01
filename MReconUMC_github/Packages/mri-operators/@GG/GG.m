function  gg = GG(k,Rdims,varargin)
% Greengard Gaussian gridding for 5 dimensional matrices.
% Generalized data structure of [x y z coils dynamics].
% Rdims contains the image domain dimensions
%
% Tom Bruijnen - University Medical Center Utrecht - 201609 

% Parallelization
if nargin<3
    gg.parfor=0;
else
    gg.parfor=varargin{1};
end

% Set parameters
gg.adjoint=1; % 1 = inverse NUFFT, -1 = forward NUFFT
gg.k=k*2*pi;
gg.precision=1e-01; % range: 1e-1 - 1e-15
gg.nj=numel(k(:,:,1));
if numel(Rdims)<5
    Rdims(5)=1;
    Rdims(Rdims==0)=1;
end
gg.Rdims=round(Rdims);
gg.Kdims(1:numel(size(k)))=size(k);
gg.Kdims(3:5)=gg.Rdims(3:5);
gg.k=reshape(gg.k,[gg.Kdims(1)*gg.Kdims(2),gg.Kdims(3)*gg.Kdims(5)]);
gg=class(gg,'GG');

%END
end
