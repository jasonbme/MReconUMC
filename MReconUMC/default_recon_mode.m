
%% Setup path and select root of data
clear all;clc;clear classes;close all;restoredefaultpath
addpath(genpath(pwd))
%root='/global_scratch/Tom/Internal_data/ARD/';
root='/local_scratch/tbruijne/WorkingData/2DGA/';
scan=2;

%%
clear MR
MR=MReconUMC(root,scan);
%MR.UMCParameters.Operators.Niter=20;
MR.UMCParameters.AdjointReconstruction.PrototypeMode=2;
%MR.UMCParameters.SystemCorrections.NoisePreWhitening='yes';
%MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='espirit';
%MR.UMCParameters.AdjointReconstruction.LoadCoilSensitivityMaps='yes';
%MR.UMCParameters.IterativeReconstruction.PotentialFunction=1;
MR.Parameter.Recon.ArrayCompression='yes';
MR.Parameter.Recon.ACNrVirtualChannels=4;
%MR.UMCParameters.IterativeReconstruction.WaveletDimension=2;
%MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
%MR.UMCParameters.IterativeReconstruction.TVDimension={[3 3 0 0 1 0 0]};
%MR.UMCParameters.IterativeReconstruction.TVLambda={[50 50 0 0 50 0 0]};
%MR.UMCParameters.IterativeReconstruction.SplitDimension=5;
%MR.UMCParameters.IterativeReconstruction.WaveletLambda={50,50};
%MR.UMCParameters.AdjointReconstruction.NufftSoftware='fessler';
%MR.UMCParameters.AdjointReconstruction.SpatialResolution=3;
%MR.UMCParameters.AdjointReconstruction.NufftType='3D';
%MR.UMCParameters.AdjointReconstruction.CoilMapEchoNumber=2;
%MR.UMCParameters.AdjointReconstruction.R=9.8;
%MR.UMCParameters.GeneralComputing.ParallelComputing='yes';
%MR.UMCParameters.SystemCorrections.PhaseCorrection='girf';
%MR.UMCParameters.AdjointReconstruction.SpatialResolution=1;
MR.UMCParameters.SystemCorrections.Girf='yes';
%MR.UMCParameters.SystemCorrections.GirfNominalTrajectory='yes';
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;
