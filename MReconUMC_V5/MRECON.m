
%% Recon head-and-neck over the weekend
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/local_scratch/tbruijne/WorkingData/EPI/';
scan=1;

%%
clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.SystemCorrections.GIRF='yes';
%MR.UMCParameters.SystemCorrections.GIRF_nominaltraj='yes';
MR.UMCParameters.AdjointReconstruction.PrototypeMode=1;
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;
figure,imshow(abs(MR.Data),[])

