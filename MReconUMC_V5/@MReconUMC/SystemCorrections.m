function SystemCorrections( MR )
% Gradient and phase corrections

% If simulation mode is activated this is not required
if strcmpi(MR.UMCParameters.Simulation.Simulation,'yes')
    return;
end

% Notification
fprintf('Applying system corrections ......................  \n');tic

% Load gradient waveform to generate nominal trajecory and process with GIRF if required
GradientImpulseResponseFunction(MR);

% Perform noise prewhitening
noise_prewhitening(MR);

% Radial Phase correction on the most center point of k-space 
radial_phasecorrection(MR);

% Save raw data if iterative reconstruction is selected for data consistency step
if strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'yes')
    MR.UMCParameters.IterativeReconstruction.RawData=MR.Data;
end

%END
end
