function CheckConflicts( MR )
% Check whether certain input parameters have conflicts with each other. 
% For example iterative reconstruction is not possible when no coil
% sensitivity maps are provided. Furthermore it gives a warning when the
% amount of memory required to perform the randomphasecorrection is too
% large. Sometimes it will change the input and continue the
% reconstruction. 
%
% 20170717 - T.Bruijnen

%% Logic & display
% Notification
fprintf('Checking for parameter conflicts..................  ');tic;

%% CheckConflicts
if strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'yes') && strcmpi(MR.UMCParameters.AdjointReconstruction.NufftSoftware,'mrecon')
	fprintf('\n>>>>>>>>>> Warning: mrecon nufft doesnt have a forward operator, cant perform iterative recon. <<<<<<<<<<\n')
	fprintf('>>>>>>>>>>                          Change: Set nufft type to fessler.                         <<<<<<<<<<\n')
	MR.UMCParameters.AdjointReconstruction.NufftSoftware='fessler';
end

if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'3D') && strcmpi(MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps,'espirit')
	fprintf('\n>>>>>>>>>> Warning: ESPIRiT is not implemented for 3D reconstructions. <<<<<<<<<<\n')
	fprintf('>>>>>>>>>> Change: CSM method changed to Walsh.                        <<<<<<<<<<\n')
	MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='walsh';
end

if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'3D') && strcmpi(MR.UMCParameters.SystemCorrections.Girf,'no')
	fprintf('\n>>>>>>>>>> Warning: Analytical trajectory for 3D acquisitions is not implemented. <<<<<<<<<<\n')
	fprintf('>>>>>>>>>> Change: Trajectory is derived from the GIRFs and waveforms.            <<<<<<<<<<\n')
    MR.UMCParameters.SystemCorrections.Girf='yes';
end

if strcmpi(MR.Parameter.Scan.UTE,'yes') && strcmpi(MR.UMCParameters.SystemCorrections.Girf,'no')
	fprintf('\n>>>>>>>>>> Warning: Girf corrections are required for UTE!                <<<<<<<<<<\n')
	fprintf('>>>>>>>>>> Change: Trajectory is derived from the GIRFs and waveforms.    <<<<<<<<<<\n')
    MR.UMCParameters.SystemCorrections.Girf='yes';
end

if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'3D') && ~isempty(regexp(MR.UMCParameters.SystemCorrections.PhaseCorrection,'zero*')) 
    fprintf('\n>>>>>>>>>> Warning: 3D radial acquisitions dont work with the zero phase correction method. <<<<<<<<<<\n')
	fprintf('\n>>>>>>>>>> Change: Model based phase correction is applied.                                 <<<<<<<<<<\n')
    MR.UMCParameters.SystemCorrections.PhaseCorrection='model';
end

if strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'yes') && strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'3D') && MR.UMCParameters.IterativeReconstruction.SplitDimension < 5
    fprintf('\n>>>>>>>>>> Warning: Reconstruction can not be split in dimensions < 5.                <<<<<<<<<<\n')
	fprintf('>>>>>>>>>> Change: MR.UMCParameters.IterativeReconstruction.SplitDimension = 12.       <<<<<<<<<<\n')
    MR.UMCParameters.IterativeReconstruction.SplitDimension=12;
end

if strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'yes') && strcmpi(MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps,'no')
   fprintf('\n>>>>>>>>>> Warning: Cant perform iterative reconstruction without coil maps.           <<<<<<<<<<\n')
   fprintf('>>>>>>>>>> Change: CSM method changed to Walsh.                                        <<<<<<<<<<\n')
   MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='walsh';
end

if strcmpi(MR.Parameter.Scan.UTE,'yes') && ~isempty(regexp(MR.UMCParameters.SystemCorrections.PhaseCorrection,'zero*')) && ~strcmpi(MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps,'no') && MR.Parameter.Encoding.NrEchoes>1
	fprintf('\n>>>>>>>>>> Warning: Multi echo UTE data must have model-based phase correction if csm maps are used <<<<<<<<<<\n')
	fprintf('>>>>>>>>>> Change: Model based phase correction is applied.                                         <<<<<<<<<<\n')
	MR.UMCParameters.SystemCorrections.PhaseCorrection='model';
end

% Check if enough memory is available to reconstruct
[MemoryNeeded, MemoryAvailable, ~] = MR.GetMemoryInformation;
if MemoryNeeded > MemoryAvailable
    fprintf('\n>>>>>>>>>> Warning: Reconstruction will require more memory then you have available. <<<<<<<<<<\n')
end

%% Display
% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end
