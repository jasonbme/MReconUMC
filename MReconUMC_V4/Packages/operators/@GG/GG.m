function  gg = GG(k,Id,Kd,varargin)
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
gg.num_data=numel(k); % Number of data chunks
gg.adjoint=1; % 1 = inverse NUFFT, -1 = forward NUFFT
gg.k=cellfun(@(x) x*2*pi,k,'UniformOutput',false);
gg.precision=1e-01; % range: 1e-1 - 1e-15
for n=1:gg.num_data;gg.nj{n}=numel(k{n}(:,:,1));end
gg.Id=Id;
gg.Kd=Kd;
for n=1:gg.num_data;gg.k{n}=reshape(gg.k{n},[gg.Kd{n}(1)*gg.Kd{n}(2) 1]);end
gg=class(gg,'GG');

%END
end
