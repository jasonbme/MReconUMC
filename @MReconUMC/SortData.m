function SortData( MR )
% 20160615 - Run the conventional MR.SortData + remove calibration spokes
% from the data + reorder the ensemble into dynamics + startup parallel
% pool + check for conflicts.

SortData@MRecon(MR);

% Add additional gradient delay for experiments
if MR.ParUMC.MimicGradientDelay>0
    dims=size(MR.Data);
    destruction_M=repmat(exp(-2*1i*(polyval([-1*MR.ParUMC.MimicGradientDelay*2*pi/dims(1) 0],-dims(1)/2+1:dims(1)/2)/2)'),[1 dims(2) dims(3) dims(4)]);
    MR.Data=ifft(ifftshift(fftshift(fft(MR.Data)).*destruction_M));
end

% Remove calibration spokes from data
if MR.ParUMC.NumCalibrationSpokes>0
    ncs=MR.ParUMC.NumCalibrationSpokes;
    MR.ParUMC.CalibrationData=permute(MR.Data(:,1:ncs,:,:),[1 2 3 4 5]); 
    MR.Data=MR.Data(:,ncs+1:end,:,:,:);
end

% Reorder dynamic golden radial MRI to dynamics
if strcmpi(MR.ParUMC.ProfileSpacing,'golden')
    % Initialize handling parameters
    dims=size(MR.Data);
    
    if MR.ParUMC.NumberOfSpokes > 0
        ndyn=floor(dims(2)/MR.ParUMC.NumberOfSpokes);
        MR.Parameter.Encoding.NrDyn=ndyn;
    else
        ndyn=MR.Parameter.Encoding.NrDyn; % number of dynamics
    end
   
    % Discard obselete spokes
    ns=floor(dims(2)/ndyn); % number of spokes per dynamic
    MR.Data=MR.Data(:,1:ndyn*ns,:,:,:);

    % Sort data in dynamics
    MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[dims(1) dims(3) dims(4) ns ndyn]),[1 4 2 3 5]);
    
end

% Deal with different sizes when you set an arbitrary resolution. 0 ==
% equal to acquisition voxel size
if ~isempty(MR.ParUMC.SpatialResolution)
   if MR.ParUMC.SpatialResolution==0
       MR.ParUMC.ReconRatio=min(MR.Parameter.Scan.AcqVoxelSize)/min(MR.Parameter.Scan.RecVoxelSize);
       MR.Parameter.Encoding.XRes=round(1/MR.ParUMC.ReconRatio*MR.Parameter.Encoding.XRes);
       MR.Parameter.Encoding.XReconRes=round(1/MR.ParUMC.ReconRatio*MR.Parameter.Encoding.XReconRes);
       MR.Parameter.Encoding.YRes=round(1/MR.ParUMC.ReconRatio*MR.Parameter.Encoding.YRes);
       MR.Parameter.Encoding.YReconRes=round(1/MR.ParUMC.ReconRatio*MR.Parameter.Encoding.YReconRes);
       MR.Parameter.Scan.RecVoxelSize=MR.Parameter.Scan.AcqVoxelSize;
       MR.ParUMC.ReconRatio=1;
   else   
       MR.ParUMC.ReconRatio=MR.ParUMC.SpatialResolution/min(MR.Parameter.Scan.RecVoxelSize);
       MR.Parameter.Encoding.XRes=round(1/MR.ParUMC.ReconRatio*MR.Parameter.Encoding.XRes);
       MR.Parameter.Encoding.YRes=round(1/MR.ParUMC.ReconRatio*MR.Parameter.Encoding.YRes);
       MR.Parameter.Encoding.XReconRes=round(1/MR.ParUMC.ReconRatio*MR.Parameter.Encoding.XReconRes);
       MR.Parameter.Encoding.YReconRes=round(1/MR.ParUMC.ReconRatio*MR.Parameter.Encoding.YReconRes);
       [tmp_z,idx]=max(MR.Parameter.Scan.RecVoxelSize);
       MR.Parameter.Scan.RecVoxelSize=repmat(MR.ParUMC.SpatialResolution,[3 1]);
       MR.Parameter.Scan.RecVoxelSize(idx)=tmp_z;
       MR.ParUMC.ReconRatio=min(MR.Parameter.Scan.RecVoxelSize)/min(MR.Parameter.Scan.AcqVoxelSize);
   end
else
   MR.ParUMC.ReconRatio=min(MR.Parameter.Scan.RecVoxelSize)/min(MR.Parameter.Scan.AcqVoxelSize);
end

if strcmpi(MR.ParUMC.ProfileSpacing,'golden')
    % Set reconstruction parameters accordingly
    MR.Parameter.Scan.Samples(2)=size(MR.Data,2);
    MR.Parameter.Parameter2Read.ky=(0:size(MR.Data,2)-1)';
    MR.Parameter.Encoding.KyRange=[0 size(MR.Data,2)-1];
    MR.ParUMC.Kdims=size(MR.Data);
    MR.ParUMC.Rdims=[MR.Parameter.Encoding.XRes,MR.Parameter.Encoding.YRes,MR.Parameter.Encoding.ZRes,dims(4),ndyn];
end

% Startup parallel computing
if strcmpi(MR.ParUMC.ParallelComputing,'yes')
    p=gcp('nocreate');
    if isempty(p)
        parpool(MR.ParUMC.NumCores);
    end
    pctRunOnAll warning off
end

% Check for conflicts
if strcmpi(MR.ParUMC.CustomRec,'no') && ~strcmpi(MR.ParUMC.Gridder,'mrecon')
    fprintf('\nWarning: no phase correction will be applied.\n')
end

if strcmpi(MR.ParUMC.GetCoilMaps,'no') && strcmpi(MR.ParUMC.CS,'yes')
    fprintf('\nWarning: no sensitivity maps are estimaed for compressed sensing.\n')
end

if strcmpi(MR.ParUMC.ProfileSpacing,'uniform')
    MR.ParUMC.CustomRec='no';
    MR.ParUMC.Gridder='mrecon';
    MR.ParUMC.GetCoilMaps='no';
end

% END
end

