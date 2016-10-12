function SortData( MR )
%% Sortdata,remove calibration,ensemble dynamics,startup parpool
SortData@MRecon(MR);

%% Remove calibration spokes from data
if MR.UMCParameters.RadialDataCorrection.NumberOfCalibrationSpokes>0
    ncs=MR.UMCParameters.RadialDataCorrection.NumberOfCalibrationSpokes;
    MR.UMCParameters.RadialDataCorrection.CalibrationData=permute(MR.Data(:,1:ncs,:,:),[1 2 3 4 5]); 
    MR.Data=MR.Data(:,ncs+1:end,:,:,:);
end

%% Reorder dynamic golden radial MRI to dynamics
% Initialize handling parameters
[ns,nl,nz,nc,ndyn]=size(MR.Data);
if strcmpi(MR.UMCParameters.LinearReconstruction.ProfileSpacing,'golden')
    % If you set a specific number of spokes per slice, enforce this into
    % the dynamics.
    if MR.UMCParameters.LinearReconstruction.R ~= 1
        ndyn=round(MR.Parameter.Encoding.NrDyn*MR.UMCParameters.LinearReconstruction.R);
        MR.Parameter.Encoding.NrDyn=ndyn;
    else
        ndyn=MR.Parameter.Encoding.NrDyn; 
    end
   
    % Discard obselete spokes
    nl=floor(nl/ndyn); % number of spokes per dynamic
    MR.Data=MR.Data(:,1:ndyn*nl,:,:,:);

    % Sort data in dynamics
    MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[ns nz nc nl ndyn]),[1 4 2 3 5]);
end


%% Prototype mode to reduce number of dynamics
if MR.UMCParameters.LinearReconstruction.PrototypeMode~=0
    MR.Data=MR.Data(:,:,:,:,1:MR.UMCParameters.LinearReconstruction.PrototypeMode);
    ndyn=MR.UMCParameters.LinearReconstruction.PrototypeMode;
    MR.Parameter.Encoding.NrDyn=MR.UMCParameters.LinearReconstruction.PrototypeMode;
end

%% Deal with spatial resolution
% If 2D fill in ZRes and ZReconRes
if strcmpi(MR.Parameter.Scan.ScanMode,'2D')
    MR.Parameter.Encoding.ZRes=1;
    MR.Parameter.Encoding.ZReconRes=1;
end

% Spatialresolution == 0 equals acquisition parameter reconstruction
if MR.UMCParameters.LinearReconstruction.SpatialResolution==0
   MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio=min(MR.Parameter.Scan.AcqVoxelSize)/min(MR.Parameter.Scan.RecVoxelSize);
   MR.Parameter.Encoding.XRes=round(1/MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.XRes);
   MR.Parameter.Encoding.XReconRes=round(1/MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.XReconRes);
   MR.Parameter.Encoding.YRes=round(1/MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.YRes);
   MR.Parameter.Encoding.YReconRes=round(1/MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.YReconRes);
   MR.Parameter.Scan.RecVoxelSize=MR.Parameter.Scan.AcqVoxelSize;
   MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio=1;
else   
   MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio=MR.UMCParameters.LinearReconstruction.SpatialResolution/min(MR.Parameter.Scan.RecVoxelSize);
   MR.Parameter.Encoding.XRes=round(1/MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.XRes);
   MR.Parameter.Encoding.YRes=round(1/MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.YRes);
   MR.Parameter.Encoding.XReconRes=round(1/MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.XReconRes);
   MR.Parameter.Encoding.YReconRes=round(1/MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio*MR.Parameter.Encoding.YReconRes);
   [tmp_z,idx]=max(MR.Parameter.Scan.RecVoxelSize);
   MR.Parameter.Scan.RecVoxelSize=repmat(MR.UMCParameters.LinearReconstruction.SpatialResolution,[3 1]);
   MR.Parameter.Scan.RecVoxelSize(idx)=tmp_z;
   MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio=min(MR.Parameter.Scan.RecVoxelSize)/min(MR.Parameter.Scan.AcqVoxelSize);
end


if strcmpi(MR.UMCParameters.LinearReconstruction.ProfileSpacing,'golden')
    % Set reconstruction parameters accordingly
    MR.Parameter.Scan.Samples(2)=size(MR.Data,2);
    MR.Parameter.Parameter2Read.ky=(0:size(MR.Data,2)-1)';
    MR.Parameter.Encoding.KyRange=[0 size(MR.Data,2)-1];
end

% Store k-space and image dimensions in struct
MR.UMCParameters.LinearReconstruction.KspaceSize=size(MR.Data);
MR.UMCParameters.LinearReconstruction.IspaceSize=[MR.Parameter.Encoding.XRes,MR.Parameter.Encoding.YRes,size(MR.Data,3),nc,ndyn];

%% Startup parallel computing
if strcmpi(MR.UMCParameters.GeneralComputing.ParallelComputing,'yes')
    p=gcp('nocreate');
    if isempty(p)
        evalc('parpool(MR.UMCParameters.GeneralComputing.NumberOfCPUs)');
    end
    pctRunOnAll warning off
else
    MR.UMCParameters.GeneralComputing.NumberOfCPUs=0;
end

%% Check for conflicts
if strcmpi(MR.UMCParameters.NonlinearReconstruction,'yes') && (strcmpi(MR.UMCParameters.LinearReconstruction.Autocalibrate,'no')...
        ||strcmpi(MR.UMCParameters.LinearReconstruction.ReferenceScan,'no'))
    fprintf('\nWarning: no sensitivity maps are estimated for the nonlinear reconstruction.\n')
    return
end

if strcmpi(MR.UMCParameters.NonlinearReconstruction,'yes') && strcmpi(MR.UMCParameters.LinearReconstruction.NUFFTMethod,'mrecon')
    fprintf('\nWarning: mrecon nufft doesnt have an adjoint operator, cant perform nonlinear recon.\n')
    return
end

% END
end

