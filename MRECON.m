%% MRECONUMC
%% Initialize and generate path
clear all;clc;close all;clear classes
curdir=which('MRECON.m');
cd(curdir(1:end-8))
addpath(genpath(pwd))
%root=[pwd,'/Data/'];
root='/global_scratch/Tom/Scan_Results/20160914_GA_HN_matteo/';
scan=3;
% General NOTE: You have to set three parameters from the acquisition code.
% Go to the file @MReconUMC/FillParameters.m and set MR.ParUMC.Goldenangle,
% MR.ParUMC.ProfileSpacing and MR.ParUMC.NumCalibrationSpokes.

%% Linear Recon 2D Golden angle data 

clear MR
MR=MReconUMC(root,scan);
%MR.UMCParameters.GeneralComputing.ParallelComputing='no';
%MR.Parameter.Gridder.AlternatingRadial='no';
MR.UMCParameters.LinearReconstruction.Autocalibrate='yes';
MR.UMCParameters.NonlinearReconstruction.NonlinearReconstruction='yes';
MR.UMCParameters.LinearReconstruction.R=7;
MR.UMCParameters.RadialDataCorrection.GradientDelayCorrection='yes';
%MR.UMCParameters.RadialDataCorrection.PhaseCorrection='zero';
%MR.UMCParameters.LinearReconstruction.NUFFTMethod='mrecon';
MR.PerformUMC;


