function PerformUMC( MR )
% 20160615 - Main execution script for the reconstruction. Some RECONFRMAE functions
% have been overloaded (e.g. GridderCalculateTrajectory). 

MR.ReadSortCorrect; 
MR.GridderCalculateTrajectory; 
MR.RadialPhaseCorrection;
MR.GetCoilMaps;
MR.NUFFT;
MR.NonLinearReconstruction;

% Last step
MR.RemoveOversampling;

% Notification
fprintf('Reconstruction completed\n')

% END
end