function PerformUMC( MR )

% Main execution script
MR.FillParameters;
MR.ReadAndCorrect;
MR.CheckConflicts;
MR.SortData;
MR.ParallelComputing;
MR.CalculateTrajectory;
MR.SystemCorrections;
%MR.EPIPhaseCorrection;
MR.CoilSensitivityMaps;
MR.AdjointReconstruction;
MR.IterativeReconstruction;
MR.CombineCoils; % Does cell2mat
MR.GeometryCorrection;
MR.RemoveOversampling;

% Notification
fprintf('Reconstruction completed\n')

% END
end