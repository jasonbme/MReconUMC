function CheckConflicts( MR )
% Check input for conflicts

% Notification
fprintf('Checking for parameter conflicts..................  ');tic;

if strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'yes') && strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon')
        fprintf('\nWarning: mrecon nufft doesnt have an adjoint operator, cant perform iterative recon.\n')
    return
end

if ~strcmpi(MR.UMCParameters.SystemCorrections.GradientDelayCorrection,'no') && strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon')
            fprintf('\nWarning: Trajectory correction is not supported for the mrecon gridder.\n')
    return
end

if strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'yes') && ~strcmpi(MR.UMCParameters.IterativeReconstruction.TVtype,'Temporal') && MR.UMCParameters.IterativeReconstruction.Potential_function==1
               fprintf('\nWarning: Nonlinear conjugate gradient is not compatible with spatial TV atm.\n')
    return
end

if strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'yes') && ~strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'fessler') 
               fprintf('\nWarning: Iterative reconstruction only works with Fessler gridder.\n')
    return
end

% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end
