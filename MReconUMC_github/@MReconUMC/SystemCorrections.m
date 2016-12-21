function SystemCorrections( MR )
% Gradient and phase corrections

% Notification
fprintf('Applying system corrections ......................  ');tic

% Phase correction
radialphasecorrection( MR );

% Save raw data for nonlinear reconstructions & scale 
if strcmpi(MR.UMCParameters.NonlinearReconstruction.NonlinearReconstruction,'yes')
    % Scale to make max of rawdata
    MR.Data=0.001*MR.Data/max(abs(MR.Data(:)));
    MR.UMCParameters.NonlinearReconstruction.RawData=single(MR.Data);
end

% Notification    
fprintf('Finished [%.2f sec] \n',toc')

%END
end
