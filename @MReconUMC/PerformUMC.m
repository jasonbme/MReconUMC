function PerformUMC( MR )
%% Main execution script

MR.ReadSortCorrect; 
MR.GridderCalculateTrajectory; 
MR.RadialPhaseCorrection;
MR.CoilSensitivityMaps;
MR.NUFFT;
MR.NonLinearReconstruction;

% Last step
MR.RemoveOversampling;

% Notification
fprintf('Reconstruction completed\n')

% END
end