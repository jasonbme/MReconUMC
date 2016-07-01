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

% Reconstruct one dynamic per coil using all spokes
dims=size(MR.Data);dims(5)=size(MR.Data,5);

% Change dimensions of data to [nsamples nspokes*ndyn z ncoils 1]
MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[dims(1) dims(3) dims(4) dims(2)*dims(5) 1]),[1 4 2 3 5]);

% Use the greengard gridder to reconstruct coil images, just for coding simplicity.
method=MR.ParUMC.Gridder;
MR.ParUMC.Gridder='greengard';

% Deal with the combinecoils option
cc=MR.ParUMC.EnableCombineCoils;
MR.ParUMC.EnableCombineCoils='no';

% Perform NUFFT
GreengardNUFFT(MR);

%% Go to k space
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

% Preallocate csm matrix
csm=zeros(dims);

% Loop over all slices and do espirit
for slice=1:dims(3)
    % Crop the center out of the multicoil data for calibration
    calib=crop(squeeze(kdata(:,:,slice,:)),[ncalib,ncalib,dims(4)]);
    
    % Compute the GRAPPA calibration matrix A
    A=CalibrationMatrix(calib,ksize);
    
    % Do a SVD to get the right handed vectors, which are a basis for the
    % rows of A. Also the eigenvalues are important for the thresholding.
    [~,S,V]=svd(A,'econ');
    S = diag(S);S = S(:); % Diagonal vector with eigenvalues anyway
    
    % Reshape V back to the individual kernels
    V=reshape(V,ksize(1),ksize(2),dims(4),size(V,2));
    
    % Select top eigenvalues using threshold 1 (Get rid off nullspace)
    idx=max(find(S >= S(1)*eigThresh_1));
    tic
    % Analyse matrix V
    [M,W]=EigenPatches(V(:,:,:,1:idx),[dims(1),dims(2)]);

    % Only select largest eigenvectors to contribute to the csm
    s_csm=M(:,:,:,end).*repmat(W(:,:,end)>eigThresh_2,[1,1,dims(4)]);
    
    % Normalize sense maps
    s_csm=s_csm/max(abs(s_csm(:)));
    if numel(size(s_csm))==3
        s_csm=permute(s_csm,[1 2 4 3]);
    end
        % Save current csm
    csm(:,:,slice,:)=s_csm;
end

% Replace all 0s in the coil maps by random numbers
b=rand(size(csm));
csm(~logical(abs(csm)))=b(~logical(abs(csm)));

% Get Body counters to make background sensitivities noise like
if strcmp(MR.ParUMC.Mask,'yes')
    MR.K2I;MR.Data=fftshift(MR.Data,3);
    MR.ParUMC.EnableCombineCoils='yes';
    MR.Parameter.ReconFlags.iscombined=0;
    MR.CombineCoils; % high quality image to select background from
    csm=ConnectComponents(MR.Data,csm);
end
    
% Save in operator and for combine coils
MR.Parameter.Recon.Sensitivities=csm; % The actual sense maps
MR.ParUMC.Sense=SENSE(csm); % The sense operator

% Restore the data
MR.Data=data;

% Restore number of dynamics
MR.Parameter.Encoding.NrDyn=ndyn;

% Restore combinecoil
MR.ParUMC.EnableCombineCoils=cc;

% Restore gridder
MR.ParUMC.Gridder=method;

% Restore ReconFlags
MR=SetGriddingFlags(MR,0);

% Notification
fprintf('Finished [%.2f sec] \n',toc')

% END
end