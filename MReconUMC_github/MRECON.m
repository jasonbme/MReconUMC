%% MRECONUMC
%% Initialize and generate path
clear all;clc;clear classes
curdir=which('MRECON.m');
cd(curdir(1:end-8))
addpath(genpath(pwd))
%root=[pwd,'/Data/'];
root='/global_scratch/Tom/Scan_Results/20161005_GA_Patient1/';
scan=3;

%% Linear Recon 2D Golden angle data 

clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.LinearReconstruction.PrototypeMode=5;
%MR.UMCParameters.GeneralComputing.ParallelComputing='no';
%MR.Parameter.Gridder.AlternatingRadial='no';
%MR.UMCParameters.LinearReconstruction.Autocalibrate='yes';
%MR.UMCParameters.LinearReconstruction.AutocalibrateLoad='yes';
%MR.UMCParameters.LinearReconstruction.CoilReferenceScan='yes';
%MR.UMCParameters.LinearReconstruction.CoilReferenceScanLoad='yes';
%MR.UMCParameters.NonlinearReconstruction.NonlinearReconstruction='yes';
%MR.UMCParameters.LinearReconstruction.R=9.8;
MR.UMCParameters.RadialDataCorrection.GradientDelayCorrection='yes';
%MR.UMCParameters.LinearReconstruction.SpatialResolution=1.46;
%MR.UMCParameters.RadialDataCorrection.PhaseCorrection='fit';
%MR.UMCParameters.LinearReconstruction.NUFFTMethod='mrecon';
%MR.UMCParameters.LinearReconstruction.CombineCoils='no';
MR.PerformUMC;


