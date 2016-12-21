
%% MRECONUMC
%% Initialize and generate path
clear all;clc;clear classes
curdir=which('MRECON.m');
cd(curdir(1:end-8))
addpath(genpath(pwd))
%root=[pwd,'/Data/'];
root='/home/tbruijne/Documents/WorkingData/20161220_4DGA_volunteer/';
scan=1;

%% Linear Recon 2D Golden angle data 

clear MR
MR=MReconUMC(root,scan);
%MR.Parameter.Recon.ArrayCompression='yes';
%MR.UMCParameters.LinearReconstruction.PrototypeMode=10;
%MR.UMCParameters.GeneralComputing.ParallelComputing='no';
%MR.Parameter.Gridder.AlternatingRadial='no';
MR.UMCParameters.LinearReconstruction.CoilSensitivityMaps='openadapt';
MR.UMCParameters.LinearReconstruction.LoadCoilSensitivityMaps='yes';
%MR.Parameter.Recon.ACNrVirtualChannels = 12;
%MR.Parameter.Recon.ArrayCompression = 'yes';
%MR.UMCParameters.SystemCorrections.PhaseCorrection='fit';
%MR.UMCParameters.NonlinearReconstruction.NonlinearReconstruction='yes';
%MR.UMCParameters.NonlinearReconstruction.TVtype='temporal';
%MR.UMCParameters.NonlinearReconstruction.CGLambda=10;
%MR.UMCParameters.LinearReconstruction.R=6.2;
%MR.UMCParameters.LinearReconstruction.SpatialResolution=1.875;
%MR.UMCParameters.RadialDataCorrection.PhaseCorrection='fit';
MR.UMCParameters.LinearReconstruction.NUFFTMethod='greengard';
%MR.UMCParameters.LinearReconstruction.CombineCoils='no';
%MR.UMCParameters.GeneralComputing.NumberOfCPUs=2;
MR.PerformUMC;

