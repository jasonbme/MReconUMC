function MR = generate_simulation_data(MR)
% Function to load in simulation data and the following parameters:
% - Data
% - Ispacesize
% - Kspacesize
% - Output matrix size
% - MR.Parameter.Scan.ScanMode
% - Reconflags
% - MR.UMCParameters.AdjointReconstruction.NUFFTMethod
% - MR.UMCParameters.ReconFlags.nufft_csmapping=0
% - MR.UMCParameters.AdjointReconstruction.CombineCoilsOperator
% - MR.Parameter.Recon.CoilCombination

% Go to directory and load data
cd(MR.UMCParameters.GeneralComputing.TemporateWorkingDirectory)
load kdata.mat
MR.Data={kdata};clear kdata

% Assign parameters
MR.UMCParameters.AdjointReconstruction.IspaceSize{1}=[256 256 1 4 10 1 1 1 1 1 1 1];
MR.UMCParameters.AdjointReconstruction.KspaceSize{1}=[256 256 1 4 10 1 1 1 1 1 1 1];
MR.Parameter.Encoding.NrDyn=10;
MR.Parameter.Gridder.OutputMatrixSize{1}=round(MR.UMCParameters.AdjointReconstruction.IspaceSize{1}(1:2)*1.26);
MR.Parameter.Scan.ScanMode='2D';
MR.Parameter.Scan.AcqMode='Radial';
MR.Parameter.Scan.UTE='no';
MR.UMCParameters.AdjointReconstruction.Goldenangle=1;
MR.UMCParameters.SystemCorrections.GradientDelayCorrection='no';
MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio=1;


% Assign general parameters
MR.Parameter.ReconFlags.isread=1;
MR.Parameter.ReconFlags.issorted=1;
MR.Parameter.ReconFlags.isoversampled=[1,1,0];

% END
end