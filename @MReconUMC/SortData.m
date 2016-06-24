function SortData( MR )
% 20160615 - Run the conventional MR.SortData + remove calibration spokes
% from the data + reorder the ensemble into dynamics + startup parallel
% pool + check for conflicts.

SortData@MRecon(MR);

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

% Control voxel size. Only works for 2D if slice thickness < resolution
if ~isempty(MR.ParUMC.SpatialResolution)
   if MR.ParUMC.SpatialResolution==0
       MR.ParUMC.ReconRatio=MR.Parameter.Scan.RecVoxelSize(1)/MR.Parameter.Scan.AcqVoxelSize(1);
       MR.Parameter.Encoding.XRes=MR.ParUMC.ReconRatio*MR.Parameter.Encoding.XRes;
       MR.Parameter.Encoding.XReconRes=MR.ParUMC.ReconRatio*MR.Parameter.Encoding.XReconRes;
       MR.Parameter.Encoding.YRes=MR.ParUMC.ReconRatio*MR.Parameter.Encoding.YRes;
       MR.Parameter.Encoding.YReconRes=MR.ParUMC.ReconRatio*MR.Parameter.Encoding.YReconRes;
       MR.Parameter.Scan.RecVoxelSize=MR.Parameter.Scan.AcqVoxelSize;
   else
       MR.ParUMC.ReconRatio=min(MR.Parameter.Scan.RecVoxelSize)/MR.ParUMC.SpatialResolution;
       MR.Parameter.Encoding.XRes=round(MR.ParUMC.ReconRatio*MR.Parameter.Encoding.XRes);
       MR.Parameter.Encoding.YRes=round(MR.ParUMC.ReconRatio*MR.Parameter.Encoding.YRes);
       MR.Parameter.Encoding.XReconRes=round(MR.ParUMC.ReconRatio*MR.Parameter.Encoding.XRes);
       MR.Parameter.Encoding.YReconRes=round(MR.ParUMC.ReconRatio*MR.Parameter.Encoding.YRes);
       %MR.Parameter.Scan.RecVoxelSize=[MR.ParUMC.ReconVoxelSize,MR.ParUMC.ReconVoxelSize,MR.Parameter.Scan.RecVoxelSize(3)];
       % still have to set line above to something usefull
   end
else
   MR.ParUMC.ReconRatio=1;
end

% Set reconstruction parameters accordingly
MR.Parameter.Scan.Samples(2)=size(MR.Data,2);
MR.Parameter.Parameter2Read.ky=(0:size(MR.Data,2)-1)';
MR.Parameter.Encoding.KyRange=[0 size(MR.Data,2)-1]; 
MR.ParUMC.Kdims=size(MR.Data);
MR.ParUMC.Rdims=[MR.Parameter.Encoding.XRes,MR.Parameter.Encoding.YRes,MR.Parameter.Encoding.ZRes,dims(4),ndyn];

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

