function CheckConflicts( MR )
% Check input for conflicts

% Notification
fprintf('Checking for parameter conflicts..................  ');tic;

if strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'yes') && strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon')
        fprintf('\nWarning: mrecon nufft doesnt have an adjoint operator, cant perform iterative recon.\n')
end

if (~strcmpi(MR.UMCParameters.SystemCorrections.GradientDelayCorrection,'no') || strcmpi(MR.UMCParameters.SystemCorrections.GIRF,'yes')) && strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon')
            fprintf('\nWarning: Trajectory correction is not supported for the mrecon gridder.\n')
end

if strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'yes') && ~strcmpi(MR.UMCParameters.IterativeReconstruction.TVtype,'Temporal') && MR.UMCParameters.IterativeReconstruction.Potential_function==1
               fprintf('\nWarning: Nonlinear conjugate gradient is not compatible with spatial TV atm.\n')
end

if strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'yes') && ~strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'fessler') 
               fprintf('\nWarning: Iterative reconstruction only works with Fessler gridder.\n')
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
