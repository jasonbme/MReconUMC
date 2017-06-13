
%% Recon head-and-neck over the weekend
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/local_scratch/tbruijne/WorkingData/UTE/';
scan=4;

%%
clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.SystemCorrections.GIRF='yes';
MR.UMCParameters.AdjointReconstruction.NUFFTtype='3D';
%MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;

