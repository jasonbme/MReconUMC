function CheckConflicts( MR )
% Check input for conflicts

% Notification
fprintf('Checking for parameter conflicts..................  ');tic;

%% Check settings and provide warnings and change settings
if strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'yes') && strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon')
        fprintf('\n>>>>>>>>>> Warning: mrecon nufft doesnt have an adjoint operator, cant perform iterative recon. <<<<<<<<<<\n')
        fprintf('\n>>>>>>>>>>                          Change: Set nufft type to fessler.                          <<<<<<<<<<\n')
        MR.UMCParameters.AdjointReconstruction.NUFFTMethod='fessler';
end

if (~strcmpi(MR.UMCParameters.SystemCorrections.GradientDelayCorrection,'no') || strcmpi(MR.UMCParameters.SystemCorrections.GIRF,'yes')) && strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon')
            fprintf('\n>>>>>>>>>> Warning: Trajectory correction is not supported for the mrecon gridder. <<<<<<<<<<\n')
            fprintf('\n>>>>>>>>>>                          Change: Set nufft type to fessler.             <<<<<<<<<<\n')
            MR.UMCParameters.AdjointReconstruction.NUFFTMethod='fessler';
end

if strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'yes') && ~strcmpi(MR.UMCParameters.IterativeReconstruction.TVtype,'Temporal') && MR.UMCParameters.IterativeReconstruction.Potential_function==1
               fprintf('\n>>>>>>>>>> Warning: Nonlinear conjugate gradient is not compatible with spatial TV atm. <<<<<<<<<<\n')
end

if strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'yes') && ~strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'fessler') 
               fprintf('\n>>>>>>>>>> Warning: Iterative reconstruction only works with Fessler gridder. <<<<<<<<<<\n')
end

if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTtype,'3D') && strcmpi(MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps,'espirit')
               fprintf('\n>>>>>>>>>> Warning: ESPIRiT is not implemented for 3D reconstructions. <<<<<<<<<<\n')
               fprintf('\n>>>>>>>>>> Change: CSM method changed to Walsh.                        <<<<<<<<<<\n')
               MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='walsh';
end

if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTtype,'3D') && strcmpi(MR.UMCParameters.SystemCorrections.GIRF,'no')
    MR.UMCParameters.SystemCorrections.GIRF='yes';
end

if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTtype,'3D') && ~isempty(regexp(MR.UMCParameters.SystemCorrections.PhaseCorrection,'zero*')) 
    MR.UMCParameters.SystemCorrections.PhaseCorrection='model';
end

% Check if enough memory is available to reconstruct
[MemoryNeeded, MemoryAvailable, ~] = MR.GetMemoryInformation;
if MemoryNeeded > MemoryAvailable
    fprintf('\nWarning: Reconstruction will require more memory then you have available.\n')
end

% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end
