
%% Recon head-and-neck over the weekend
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/global_scratch/Tom/Internal_data/20170619_Philips_EC_data/';
scan=19;

%%
clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.Operators.Niter=15;
MR.UMCParameters.AdjointReconstruction.PrototypeMode=1;
%MR.UMCParameters.SystemCorrections.NoisePreWhitening='yes';
MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='walsh';
MR.UMCParameters.AdjointReconstruction.LoadCoilSensitivityMaps='yes';
MR.UMCParameters.IterativeReconstruction.PotentialFunction=1;
%MR.UMCParameters.IterativeReconstruction.WaveletDimension=2;
MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
MR.UMCParameters.IterativeReconstruction.TVDimension={[3 3 0 0 0 0 0],[3 3 0 0 0 0 1]};
MR.UMCParameters.IterativeReconstruction.TVLambda={[5 5 0 0 0 0 0],[5 5 0 0 0 0 15]};
MR.UMCParameters.IterativeReconstruction.SplitDimension=3;
%MR.UMCParameters.IterativeReconstruction.WaveletLambda={5};
MR.UMCParameters.AdjointReconstruction.NufftSoftware='greengard';
%MR.UMCParameters.AdjointReconstruction.NufftType='3D';
MR.UMCParameters.AdjointReconstruction.CoilMapEchoNumber=2;
MR.UMCParameters.AdjointReconstruction.R=25;
MR.UMCParameters.GeneralComputing.ParallelComputing='yes';
%MR.UMCParameters.SystemCorrections.PhaseCorrection='model';
%MR.UMCParameters.SystemCorrections.Girf='yes';
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;

