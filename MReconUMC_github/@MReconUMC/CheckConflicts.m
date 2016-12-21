function CheckConflicts( MR )
% Check input for conflicts

% Notification
fprintf('Checking for parameter conflicts..................  ');tic;

if (strcmpi(MR.UMCParameters.NonlinearReconstruction.NonlinearReconstruction,'yes') && strcmpi(MR.UMCParameters.LinearReconstruction.NUFFTMethod,'mrecon'))
        fprintf('\nWarning: mrecon nufft doesnt have an adjoint operator, cant perform nonlinear recon.\n')
    return
end

% Notification
fprintf('Finished [%.2f sec]\n',toc')


% END
end
