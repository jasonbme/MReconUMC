function PerformUMC( MR )
% Main execution script
        
MR.FillParameters;
MR.ReadAndCorrect;
MR.CheckConflicts;
MR.SortData;
MR.ParallelComputing;
MR.CalculateTrajectory;
MR.SystemCorrections;
MR.CoilSensitivityMaps;
MR.LinearReconstruction;
MR.CombineCoils;
MR.NonLinearReconstruction;
%MR.GeometryCorrection;

%MR.RemoveOversampling;
% Notification
fprintf('Reconstruction completed\n')

% END
end