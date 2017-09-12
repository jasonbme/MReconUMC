
%% Setup path and select root of data
clear all;clc;clear classes;close all;restoredefaultpath
addpath(genpath(pwd))
root='/werkplaats/tmp/TomBruijnen/ARD/';
%root='/local_scratch/tbruijne/WorkingData/UTE/';
scan=9;

%%
clear MR
MR=MReconUMC(root,scan);
%MR.UMCParameters.Operators.Niter=20;
%MR.Parameter.Encoding.NrDyn=1;
MR.UMCParameters.AdjointReconstruction.PrototypeMode=5;
%MR.UMCParameters.SystemCorrections.NoisePreWhitening='yes';
%MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='walsh';
%MR.UMCParameters.AdjointReconstruction.LoadCoilSensitivityMaps='yes';
%MR.UMCParameters.IterativeReconstruction.PotentialFunction=2;
MR.Parameter.Recon.ArrayCompression='yes';
MR.Parameter.Recon.ACNrVirtualChannels=4;
%MR.UMCParameters.IterativeReconstruction.WaveletDimension=2;
%MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
%MR.UMCParameters.IterativeReconstruction.TVDimension={[3 3 0 0 1 0 0]};
%MR.UMCParameters.IterativeReconstruction.TVLambda={[50 50 0 0 50 0 0]};
MR.UMCParameters.IterativeReconstruction.SplitDimension=5;
%MR.UMCParameters.IterativeReconstruction.WaveletLambda={50,50};
MR.UMCParameters.AdjointReconstruction.NufftSoftware='greengard';
%MR.UMCParameters.AdjointReconstruction.SpatialResolution=3;
%MR.UMCParameters.AdjointReconstruction.NufftType='3D';
%MR.UMCParameters.AdjointReconstruction.CoilMapEchoNumber=2;
%MR.UMCParameters.AdjointReconstruction.R=9.8;
%MR.UMCParameters.GeneralComputing.ParallelComputing='yes';
%MR.UMCParameters.SystemCorrections.PhaseCorrection='girf';
%MR.UMCParameters.AdjointReconstruction.SpatialResolution=1;
%MR.UMCParameters.AdjointReconstruction.IterativeDensityEstimation='yes';
MR.UMCParameters.SystemCorrections.Girf='yes';
%MR.UMCParameters.SystemCorrections.GirfNominalTrajectory='yes';
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;

MR.Data=fftshift(MR.Data,1);