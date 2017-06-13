
%% Recon head-and-neck over the weekend
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/local_scratch/tbruijne/WorkingData/UTE/';
scan=3;

%%
clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.SystemCorrections.GIRF='yes';
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;
figure,imshow(abs(MR.Data),[])

