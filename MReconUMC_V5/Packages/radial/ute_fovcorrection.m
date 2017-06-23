function ute_fovcorrection(MR)
%Reconframe doesnt perform adequate AQ`base correction for UTE echos, so
% this still has to be done. Only works for axial oriented scans so far!!
%
% T.Bruijnen 20170620

%% Logic & display 
if ~(strcmpi(MR.Parameter.Scan.UTE,'yes')) 
    return;end

% Notification
fprintf('     UTE field of view correction.................  ');tic;


%% UTE field of view correction
% Get resolution and offcenter in mm
res=MR.Parameter.Scan.AcqVoxelSize;
fov_offcenter=MR.Parameter.Scan.MPSOffcentresMM;

% Number of cycles to ramp per direction
nramps=fov_offcenter./res;

% Get dimensionality
Kd=MR.UMCParameters.AdjointReconstruction.KspaceSize{1};

% Case Stack-of-stars 
if strcmpi(MR.Parameter.Scan.KooshBall,'no')
    
    % Apply Z shift first
    %pcmtx=repmat(permute(nramps(3)*2*pi/Kd(3)*(1:Kd(3)),[3 1 2]),[Kd(1:2) 1 Kd(4:end)]);
    %MR.Data{1}=MR.Data{1}.*exp(-1j.*pcmtx);

    if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftSoftware,'fessler') || ( strcmpi(MR.UMCParameters.AdjointReconstruction.NufftSoftware,'greengard') &&  strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'3D'))
        nramps=nramps*-1;end
    
    % In-plane shifts interpolate them from cartesian one
    [x,y]=meshgrid(0:0.01:1,0:0.01:1);
    pcgrid=nramps(1)*(2*pi/1)*(0:0.01:1)'*ones(1,101)...
        +ones(101,1)*nramps(2)*(2*pi/1)*(0:0.01:1);
    kx=squeeze(MR.Parameter.Gridder.Kpos{1}(1,:,:,1,:,:,:,:,:,:,:,:));kx=(kx/max(abs(kx(:)))/2)+.5;
    ky=squeeze(MR.Parameter.Gridder.Kpos{1}(2,:,:,1,:,:,:,:,:,:,:,:)+.5);ky=(ky/max(abs(ky(:)))/2)+.5;
    pcmtx=interp2(x,y,pcgrid,kx,ky);
    pcmtx=repmat(pcmtx,[1 1 Kd(3:end)]);
    MR.Data{1}=MR.Data{1}.*exp(1j.*pcmtx);
    
end

% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end