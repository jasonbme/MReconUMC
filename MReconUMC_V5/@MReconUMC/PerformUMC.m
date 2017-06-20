function PerformUMC( MR )
%Main execution script that sequentially performs all functions from the
% directory @MReconUMC. Individual reconstructions classes like respiratory
% data sorting could easily be integrated here.
%
% 20170717 - T.Bruijnen

%% PerformUMC
MR.FillParameters;
MR.ReadAndCorrect;
MR.CheckConflicts;
MR.SortData;
MR.ParallelComputing;
MR.CalculateTrajectoryAndDensity;
MR.SystemCorrections;
MR.CoilSensitivityMaps;
MR.AdjointReconstruction;
MR.IterativeReconstruction;
MR.CombineCoils; 
MR.GeometryCorrection;
%MR.RemoveOversampling;

%% Display
% Notification
fprintf('Reconstruction completed\n')

% END
end