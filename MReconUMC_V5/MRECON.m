
%% Recon head-and-neck over the weekend
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='C:\Users\s116555\Documents\Programming\Github_repositories\MReconUMC\MReconUMC_V5\Packages\simulations\Phantom\';
scan=1;

%%
clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.Operators.Niter=1;
MR.UMCParameters.AdjointReconstruction.PrototypeMode=1;
%MR.UMCParameters.SystemCorrections.NoisePreWhitening='yes';
%MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='walsh';
%MR.UMCParameters.AdjointReconstruction.LoadCoilSensitivityMaps='yes';
%MR.UMCParameters.IterativeReconstruction.PotentialFunction=1;
%MR.UMCParameters.IterativeReconstruction.WaveletDimension=2;
%MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
%MR.UMCParameters.IterativeReconstruction.TVDimension=[0 0 0 0 0 ];
%MR.UMCParameters.IterativeReconstruction.TVLambda={[0,0,0,0,0]};
%MR.UMCParameters.IterativeReconstruction.SplitDimension=3;
%MR.UMCParameters.IterativeReconstruction.WaveletLambda={300};
MR.UMCParameters.AdjointReconstruction.NufftSoftware='reconframe';
%MR.UMCParameters.AdjointReconstruction.R=6;
%MR.UMCParameters.SystemCorrections.Girf='yes';
%MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;

