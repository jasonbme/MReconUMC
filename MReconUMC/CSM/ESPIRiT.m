function ESPIRiT( MR )
% 20160616 - Estimate coil sensitivity maps by reconstructing a single
% dynamics from all the data, for simplicity this is always done by the 
% mrecon gridder. Subsequentially applying ESPIRiT to acquire the coil
% maps. Alternatively estimate the maps via sense ref scans

% Notification
fprintf('Estimate coil maps from data (ESPIRiT)............  ');tic;

% Save raw data to re-assign to MR.Data after ESPIRiT
data=MR.Data;

% Save number of dynamics to restore after reconstruction
ndyn=MR.Parameter.Encoding.NrDyn;
MR.Parameter.Encoding.NrDyn=1;

% Use MRecon gridder to reconstruct coil images, just for coding simplicity.
method=MR.ParUMC.Gridder;
MR.ParUMC.Gridder='mrecon';

% Deal with the combinecoils option
cc=MR.ParUMC.EnableCombineCoils;
MR.ParUMC.EnableCombineCoils='no';

% Reconstruct one dynamic per coil using all spokes
dims=size(MR.Data);dims(5)=size(MR.Data,5);

% Change dimensions of data to [nsamples nspokes*ndyn z ncoils 1]
MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[dims(1) dims(3) dims(4) dims(2)*dims(5) 1]),[1 4 2 3 5]);

% Set reconstruction parameters accordingly
MR.Parameter.Scan.Samples(2)=size(MR.Data,2);
MR.Parameter.Parameter2Read.ky=(0:size(MR.Data,2)-1)';
MR.Parameter.Encoding.KyRange=[0 size(MR.Data,2)-1];

% Do the conventional gridding pipeline
MR.GridData;
MR.RingingFilter;
MR.ZeroFill;
MR.K2I;
MR.GridderNormalization;
MR.GeometryCorrection;

% Go to k space
MR.I2K;
kdata=squeeze(MR.Data);
dims=size(kdata);

% Start auto-calibration of SENSE maps
% Choose size of calibration kernel and area
ncalib=24; % 24 calibration lines
ksize=[6,6]; % kernel size

% Preset thresholds for eigen vectors
eigThresh_1=0.02;
eigThresh_2=0.95;

% Crop the center out of the multicoil data for calibration
calib=crop(kdata,[ncalib,ncalib,dims(3)]);

% Compute the GRAPPA calibration matrix A
%[k,S]=dat2Kernel(calib,ksize);
A=CalibrationMatrix(calib,ksize);

% Do a SVD to get the right handed vectors, which are a basis for the
% rows of A. Also the eigenvalues are important for the thresholding.
[~,S,V]=svd(A,'econ');
S = diag(S);S = S(:); % Diagonal vector with eigenvalues anyway

% Reshape V back to the individual kernels
V=reshape(V,ksize(1),ksize(2),dims(3),size(V,2));

% Select top eigenvalues using threshold 1 (Get rid off nullspace)
idx=max(find(S >= S(1)*eigThresh_1));

% Analyse matrix V
[M,W]=EigenPatches(V(:,:,:,1:idx),[dims(1),dims(2)]);

% Only select largest eigenvectors to contribute to the csm
csm=M(:,:,:,end).*repmat(W(:,:,end)>eigThresh_2,[1,1,dims(3)]);

% Normalize sense maps
csm=csm/max(abs(csm(:)));
csm(csm==0)=0.5;
if numel(size(csm))==3
    csm=permute(csm,[1 2 4 3]);
end

% Get Body counters to make background sensitivities noise like
if strcmp(MR.ParUMC.Mask,'yes')
    MR.K2I;MR.ParUMC.EnableCombineCoils='yes';
    MR.Parameter.ReconFlags.iscombined=0;
    MR.CombineCoils; % high quality image to select background from
    csm=ConnectComponents(MR.Data,csm);
end

% Save in operator and for combine coils
MR.Parameter.Recon.Sensitivities=csm; % The actual sense maps
MR.ParUMC.Sense=SENSE(csm); % The sense operator

% Restore number of dynamics
MR.Parameter.Encoding.NrDyn=ndyn;

% Restore combinecoil
MR.ParUMC.EnableCombineCoils=cc;

% Restore gridder
MR.ParUMC.Gridder=method;

% Restore ReconFlags
MR=SetGriddingFlags(MR,0);

% Restore reconstruction information
MR.Data=data;
MR.Parameter.Scan.Samples(2)=size(MR.Data,2);
MR.Parameter.Parameter2Read.ky=(0:size(MR.Data,2)-1)';
MR.Parameter.Encoding.KyRange=[0 size(MR.Data,2)-1];
    
% Notification
fprintf('Finished [%.2f sec] \n',toc')

% END
end