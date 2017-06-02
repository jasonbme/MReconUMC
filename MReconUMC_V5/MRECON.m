
%% MRECONUMC
%% Initialize and generate path
clear all;clc;clear classes;close all
cd('/nfs/rtsan02/userdata/home/tbruijne/MReconUMC/MReconUMC/MReconUMC_V5/')
addpath(genpath('/nfs/rtsan02/userdata/home/tbruijne/MReconUMC/MReconUMC/MReconUMC_V5/'))
root='/nfs/rtsan02/userdata/home/tbruijne/Documents/WorkingData/MRF/';
%root='/home/tbruijne/Documents/WorkingData/4DGA/';
%root='/global_scratch/Tom/Internal_data/20170327_Lowpass_UTE_EPI/';
scan=1;

%% recon

clear MR
MR=MReconUMC(root,scan);
%MR.UMCParameters.SystemCorrections.GIRF_nominaltraj='yes';
%MR.UMCParameters.SystemCorrections.GIRF='yes';
%MR.UMCParameters.ReconFlags.Verbose=1;
%MR.Parameter.Parameter2Read.chan=10;
%MR.Parameter.Parameter2Read.echo=0;
%MR.UMCParameters.SystemCorrections.NoisePreWhitening='yes';
%MR.Parameter.Recon.ArrayCompression='yes';
MR.UMCParameters.AdjointReconstruction.PrototypeMode=50;
%MR.UMCParameters.GeneralComputing.ParallelComputing='yes';
%MR.UMCParameters.AdjointReconstruction.NUFFTtype='3D';
%MR.UMCParameters.Simulation.Simulation='yes';
%MR.Parameter.Gridder.AlternatingRadial='no';
%MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='walsh';
%MR.UMCParameters.AdjointReconstruction.LoadCoilSensitivityMaps='yes';
MR.UMCParameters.IterativeReconstruction.JointReconstruction=5;
%MR.Parameter.Recon.ACNrVirtualChannels=4;
%MR.Parameter.Recon.ArrayCompression='yes';
%MR.Parameter.Recon.CoilCombination='no';
%MR.UMCParameters.SystemCorrections.PhaseCorrection='zero';
%MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
%MR.UMCParameters.Operators.N_iter=5;
%MR.UMCParameters.IterativeReconstruction.TVtype='temporal';
%MR.UMCParameters.IterativeReconstruction.Lambda={10};
MR.UMCParameters.AdjointReconstruction.R=3;
%MR.UMCParameters.AdjointReconstruction.SpatialResolution=5;
%MR.UMCParameters.SystemCorrections.PhaseCorrection='model';
%MR.UMCParameters.AdjointReconstruction.NUFFTMethod='fessler';
%MR.Parameter.Recon.CoilCombination='no';
%MR.UMCParameters.GeneralComputing.NumberOfCPUs=2;
MR.PerformUMC;



