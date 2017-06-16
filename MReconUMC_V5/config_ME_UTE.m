
%% Recon head-and-neck over the weekend
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/local_scratch/tbruijne/WorkingData/UTE/';
scan=5;

%%
clear MR
MR=MReconUMC(root,scan);
%MR.UMCParameters.SystemCorrections.GIRF='yes';
MR.UMCParameters.GeneralComputing.ParallelComputing='yes';
MR.UMCParameters.AdjointReconstruction.NUFFTMethod='greengard';
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;

%%
clear MR
MR=MReconUMC(root,scan);
%MR.UMCParameters.SystemCorrections.GIRF='yes';
MR.UMCParameters.AdjointReconstruction.PrototypeMode=1;
%MR.UMCParameters.GeneralComputing.ParallelComputing='yes';
MR.UMCParameters.AdjointReconstruction.NUFFTMethod='fessler';
MR.UMCParameters.AdjointReconstruction.NUFFTtype='3D';
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;


%%
clear MR
MR=MReconUMC(root,scan);
%MR.UMCParameters.SystemCorrections.GIRF='yes';
MR.UMCParameters.AdjointReconstruction.PrototypeMode=1;
MR.UMCParameters.GeneralComputing.ParallelComputing='yes';
MR.UMCParameters.AdjointReconstruction.NUFFTMethod='greengard';
%MR.UMCParameters.AdjointReconstruction.NUFFTtype='3D';
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;


%%
clear MR
MR=MReconUMC(root,scan);
%MR.UMCParameters.SystemCorrections.GIRF='yes';
MR.UMCParameters.AdjointReconstruction.PrototypeMode=1;
%MR.UMCParameters.GeneralComputing.ParallelComputing='yes';
MR.UMCParameters.AdjointReconstruction.NUFFTMethod='greengard';
MR.UMCParameters.AdjointReconstruction.NUFFTtype='3D';
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;



