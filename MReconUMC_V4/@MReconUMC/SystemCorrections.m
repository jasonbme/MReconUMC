function SystemCorrections( MR )
% Gradient and phase corrections

% Notification
fprintf('Applying system corrections ......................  ');tic

% Load gradient waveform to generate nominal trajecory and process with GIRF if required
GIRF( MR );

% Perform noise prewhitening
noise_prewhitening( MR );

% Radial Phase correction on the most center point of k-space 
radial_phasecorrection( MR );

% Save raw data if iterative reconstruction is selected for data consistency step
if strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'yes')
    MR.UMCParameters.IterativeReconstruction.RawData=single(MR.Data);
end

% Notification    
fprintf('Finished [%.2f sec] \n',toc')

%END
end
