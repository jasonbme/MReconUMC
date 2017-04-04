
%% MRECONUMC
%% Initialize and generate path
clear all;clc;clear classes;close all
curdir=which('MRECON.m');
cd(curdir(1:end-8))
addpath(genpath(pwd))
addpath('/nfs/rtsan02/userdata/home/tbruijne/Documents/MATLAB/MReconUMC_V4/')

%root=[pwd,'/Data/'];
root='/global_scratch/Tom/Internal_data/20161209_4DGA_Bjorn/';
scan=2;

%% Linear Recon 2D Golden angle data 

clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.SystemCorrections.GIRF='yes';
MR.UMCParameters.ReconFlags.Verbose=1;
%MR.UMCParameters.SystemCorrections.NoisePreWhitening='no';
%MR.Parameter.Recon.ArrayCompression='yes';
%MR.UMCParameters.AdjointReconstruction.PrototypeMode=[1:400];
%MR.UMCParameters.GeneralComputing.ParallelComputing='no';
%MR.Parameter.Gridder.AlternatingRadial='no';
%MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='openadapt';
%MR.UMCParameters.AdjointReconstruction.LoadCoilSensitivityMaps='yes';
%MR.Parameter.Recon.ACNrVirtualChannels = 5;
%MR.Parameter.Recon.ArrayCompression = 'yes';
%MR.UMCParameters.SystemCorrections.PhaseCorrection='zero';
%MR.UMCParameters.NonlinearReconstruction.NonlinearReconstruction='yes';
%MR.UMCParameters.NonlinearReconstruction.TVtype='spatial';
%MR.UMCParameters.NonlinearReconstruction.CGLambda=20;
%MR.UMCParameters.LinearReconstruction.R=7;
%MR.UMCParameters.AdjointReconstruction.SpatialResolution=3;
%MR.UMCParameters.SystemCorrections.PhaseCorrection='model';
%MR.UMCParameters.AdjointReconstruction.NUFFTMethod='mrecon';
%MR.Parameter.Recon.CoilCombination='no';
%MR.UMCParameters.GeneralComputing.NumberOfCPUs=2;
MR.PerformUMC;


