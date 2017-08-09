
%% Recon head-and-neck over the weekend
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/local_scratch/tbruijne/WorkingData/4DGA/';
%root='/global_scratch/Tom/Internal_data/20170808_UTE_ME_GA_MR21/';
scan=2;

%%
clear MR
MR=MReconUMC(root,scan);
%MR.UMCParameters.Operators.Niter=12;
%MR.UMCParameters.AdjointReconstruction.PrototypeMode=5;
%MR.UMCParameters.SystemCorrections.NoisePreWhitening='yes';
%MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='walsh';
%MR.UMCParameters.AdjointReconstruction.LoadCoilSensitivityMaps='yes';
%MR.UMCParameters.IterativeReconstruction.PotentialFunction=1;
%MR.UMCParameters.IterativeReconstruction.WaveletDimension=2;
%MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
%MR.UMCParameters.IterativeReconstruction.TVDimension={[3 3 0 0 0 0 0],[3 3 0 0 0 0 0]};
%MR.UMCParameters.IterativeReconstruction.TVLambda={[5 5 0 0 0 0 0],[5 5 0 0 0 0 0]};
%MR.UMCParameters.IterativeReconstruction.SplitDimension=5;
%MR.UMCParameters.IterativeReconstruction.WaveletLambda={5,5};
%MR.UMCParameters.AdjointReconstruction.NufftSoftware='greengard';
%MR.UMCParameters.AdjointReconstruction.SpatialResolution=3;
MR.UMCParameters.AdjointReconstruction.NufftType='3D';
%MR.UMCParameters.AdjointReconstruction.CoilMapEchoNumber=2;
%MR.UMCParameters.AdjointReconstruction.R=5;
%MR.UMCParameters.GeneralComputing.ParallelComputing='yes';
MR.UMCParameters.SystemCorrections.PhaseCorrection='model';
%MR.UMCParameters.AdjointReconstruction.SpatialResolution=1;
MR.UMCParameters.SystemCorrections.Girf='yes';
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;

