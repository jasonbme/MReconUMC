%% MRECONUMC
%% Initialize and generate path
clear all;clc;close all
curdir=which('MRECON.m');
cd(curdir(1:end-8))
addpath(genpath(pwd))
%root=[pwd,'/Data/'];
root='/home/tbruijne/Documents/Scan_Results/20160628/';
scan=11; % 7 = abdominal 3T data / 8 = headneck 1.5T data

% General NOTE: You have to set three parameters from the acquisition code.
% Go to the file @MReconUMC/FillParameters.m and set MR.ParUMC.Goldenangle,
% MR.ParUMC.ProfileSpacing and MR.ParUMC.NumCalibrationSpokes.

%% Linear Recon 2D Golden angle data 
% Takes around 50 seconds with 4 CPUs for current settings (abdominal data)
% Getting coil maps from espirit takes half of the time.
clear MR
MR=MReconUMC(root,scan);
%MR.ParUMC.GradDelayCorrMethod='sweep';
%MR.ParUMC.GetCoilMaps='espirit';
%MR.ParUMC.SpatialResolution=2.5;
MR.ParUMC.PhaseHardSet='yes';
MR.ParUMC.ParallelComputing='no';
MR.PerformUMC;


% Possible options
%MR.ParUMC.GradDelayCorrMethod='sweep'; % Default is smagdc
%MR.ParUMC.GetCoilMaps='no'; % or 'mrsense' or 'espirit' or 'no'
%MR.ParUMC.DCF='ram-lak'; % standard is 'ram-lak adaptive'
%MR.ParUMC.Gridder='fessler'; % standard -->'greengard'/'fessler'/'mrecon'
%MR.ParUMC.NumberOfSpokes=100; % Number of spokes per dynamic
%MR.Parameter.Encoding.NrDyn=50; % Number of dynamics. NumberOfSpokes
% overrules number of dynamics.


%% Nonlinear Recon 2D Golden angle data
% For current settings it takes around ~ 40 min with 4 CPUs (abdominal data)
clear MR
MR=MReconUMC(root,scan);
MR.ParUMC.GetCoilMaps='yes'; 
MR.ParUMC.CS='yes';
MR.ParUMC.NumberOfSpokes=55; 
MR.PerformUMC;

% Possible options
%MR.ParUMC.lambda=[20,30,40]; % Multiple or 1 lambdas (regularization)
%MR.ParUMC.NumCores=6; % Set as high as you can, linearly increases recon
%speed. Default value is 6 cores.

% Notes:
% CS data will be in the parameter MR.ParUMC.CSData.
% Linear reconstructed data will be in MR.Data.
% Coil maps will be in MR.Parameter.Recon.Sensitivities