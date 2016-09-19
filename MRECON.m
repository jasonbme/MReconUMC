%% MRECONUMC
%% Initialize and generate path
clear all;clc;close all;clear classes
curdir=which('MRECON.m');
cd(curdir(1:end-8))
addpath(genpath(pwd))
%root=[pwd,'/Data/'];
root='/home/tbruijne/Documents/Scan_Results/20160914/';
scan=4;
% General NOTE: You have to set three parameters from the acquisition code.
% Go to the file @MReconUMC/FillParameters.m and set MR.ParUMC.Goldenangle,
% MR.ParUMC.ProfileSpacing and MR.ParUMC.NumCalibrationSpokes.

%% Linear Recon 2D Golden angle data 

clear MR
MR=MReconUMC(root,scan);

%MR.UMCParameters.LinearReconstruction.Autocalibrate='yes';
%MR.UMCParameters.RadialDataCorrection.GradientDelayCorrection='smagdc';
MR.UMCParameters.RadialDataCorrection.PhaseCorrection='zero';
%MR.UMCParameters.LinearReconstruction.NUFFTMethod='mrecon';
MR.PerformUMC;


