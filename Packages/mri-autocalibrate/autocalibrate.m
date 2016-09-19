function csm = autocalibrate(img,varargin)
%% Function to use the eigenanalysis from Uecker et al. to derive coil
% sensitivity maps from the calibration matrix.
% Input requires a 4D matrix of [x y z coils].
%
% Tom Bruijnen - University Medical Center Utrecht - 201609

%% Handle inputs
% set default values
coff1=0.02;
coff2=0.97;
nlines=24;
kernelsize=[6, 6];

% handle varargin
if nargin > 1
    coff1=varargin{1};
end
    
if nargin > 2
    coff2=varargin{2};
end

if nargin > 3
    nlines=varargin{3};
end

if nargin > 4
    kernelsize=[varargin{4} varargin{4}];
end
  
% Get image dimensions
[nx ny nz nc]=size(img);

%% CSM reconstruction
% Select center part 
kimg=fft2c(img);
AC=crop(kimg,nlines);

% Loop over all z slices, so only works for multislice and not 3D
for z=1:nz
    % Compute GRAPPA matrix A
    A=CalibrationMatrix(AC(:,:,z,:),kernelsize);
    
    % Do a SVD to get V and the eigenvalues in the diagonal
    [~,EV,V]=svd(A,'econ');
    EV=diag(EV);EV=EV(:);
    
    % Get rid of null-space
    idx=max(find(EV>=EV(1)*coff1));
    
    % Reshape V to analyze patches
    V=reshape(V,[kernelsize nc size(V,2)]);
    [M,W]=EigenPatches(V(:,:,:,1:idx),[nx,ny]);
    
    % Only select largest eigenvalue and normalize
    tcsm=M(:,:,:,end).*repmat(W(:,:,end)>coff2,[1,1,nc]);
    tcsm=tcsm/max(abs(tcsm(:)));
    
    % Make non calibration areas noise like
    for p=1:nx*ny*nc;if tcsm(p)==0;tcsm(p)=rand();end;end; 
    
    % Assign to slice
    csm(:,:,z,:)=tcsm;
end

% END
end
