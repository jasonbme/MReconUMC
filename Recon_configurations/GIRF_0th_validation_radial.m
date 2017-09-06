
%% Setup path and select root of data
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/nfs/bsc01/researchData/USER/tbruijne/Research_data/MR21/20170830_GIRF_MR21/';
scan=13;

%%
clear MR
MR=MReconUMC(root,scan);
%MR.UMCParameters.Operators.Niter=12;
%MR.UMCParameters.AdjointReconstruction.PrototypeMode=500;
%MR.UMCParameters.SystemCorrections.NoisePreWhitening='yes';
%MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='espirit';
%MR.UMCParameters.AdjointReconstruction.LoadCoilSensitivityMaps='yes';
%MR.UMCParameters.IterativeReconstruction.PotentialFunction=1;
%MR.Parameter.Recon.ArrayCompression='yes';
%MR.Parameter.Recon.ACNrVirtualChannels=4;
%MR.UMCParameters.IterativeReconstruction.WaveletDimension=2;
%MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
%MR.UMCParameters.IterativeReconstruction.TVDimension={[3 3 0 0 0 0 0]};
%MR.UMCParameters.IterativeReconstruction.TVLambda={[150 150 0 0 0 0 0]};
MR.UMCParameters.IterativeReconstruction.SplitDimension=5;
%MR.UMCParameters.IterativeReconstruction.WaveletLambda={5,5};
%MR.UMCParameters.AdjointReconstruction.NufftSoftware='fessler';
%MR.UMCParameters.AdjointReconstruction.SpatialResolution=3;
%MR.UMCParameters.AdjointReconstruction.NufftType='3D';
%MR.UMCParameters.AdjointReconstruction.CoilMapEchoNumber=2;
%MR.UMCParameters.AdjointReconstruction.R=8;
%MR.UMCParameters.GeneralComputing.ParallelComputing='yes';
MR.UMCParameters.SystemCorrections.PhaseCorrection='girf';
%MR.UMCParameters.AdjointReconstruction.SpatialResolution=1;
MR.UMCParameters.SystemCorrections.Girf='yes';
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;

